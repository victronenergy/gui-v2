/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "mockvalueapplier.h"
#include "backendconnection.h"
#include "veqitemmockproducer.h"

#include <QSet>

using namespace Victron::VenusOS;

MockValueApplier::MockValueApplier(QObject *parent)
	: QObject(parent)
	, m_producer(qobject_cast<VeQItemMockProducer *>(BackendConnection::create()->producer()))
{
	if (!m_producer) {
		qWarning("MockValueApplier: VeQItemMockProducer not available!");
	}

	// One value per tick. PreciseTimer so Windows does not round this up to
	// 15.6ms and fall behind the animator tick rate. The slot returns between
	// values so the window can paint; applying the whole tick at once does not.
	m_drainTimer.setTimerType(Qt::PreciseTimer);
	m_drainTimer.setInterval(10);
	m_drainTimer.setSingleShot(false);
	connect(&m_drainTimer, &QTimer::timeout, this, &MockValueApplier::processQueue);
}

void MockValueApplier::registerNotify(int animatorId, const MockNotifyCallbacks &callbacks)
{
	m_notifyMap[animatorId] = callbacks;
}

void MockValueApplier::unregisterNotify(int animatorId)
{
	m_notifyMap.remove(animatorId);
	QVector<MockNotifyEvent> kept;
	kept.reserve(m_pendingNotifications.size());
	for (const MockNotifyEvent &event : m_pendingNotifications) {
		if (event.animatorId != animatorId) {
			kept.append(event);
		}
	}
	m_pendingNotifications = kept;
	if (m_queue.isEmpty()) {
		dispatchReadyNotifications();
		if (m_pendingNotifications.isEmpty()) {
			m_drainTimer.stop();
		}
	}
}

bool MockValueApplier::isBlocked(const QString &uid) const
{
	const QString normalized = normalizedMockUid(uid);
	if (m_externalBlocks.value(normalized) > 0) {
		return true;
	}
	for (auto it = m_prefixBlocks.constBegin(); it != m_prefixBlocks.constEnd(); ++it) {
		if (it.value() > 0 && mockUidUnderPrefix(normalized, it.key())) {
			return true;
		}
	}
	return false;
}

bool MockValueApplier::shouldSkip(const QString &uid) const
{
	const QString normalized = normalizedMockUid(uid);
	if (isBlocked(normalized)) {
		return true;
	}
	for (const QString &prefix : m_skipPrefixes) {
		if (mockUidUnderPrefix(normalized, prefix)) {
			return true;
		}
	}
	return false;
}

void MockValueApplier::removeQueued(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty() || (m_queue.isEmpty() && m_pendingNotifications.isEmpty())) {
		return;
	}
	if (!m_queue.isEmpty()) {
		QQueue<MockValueUpdate> kept;
		while (!m_queue.isEmpty()) {
			const MockValueUpdate update = m_queue.dequeue();
			if (normalizedMockUid(update.first) != normalized) {
				kept.enqueue(update);
			}
		}
		m_queue = kept;
	}
	// Also drop a notify whose write was already applied and is no longer queued.
	dropNotifications([&normalized](const QString &dep) { return dep == normalized; });
	if (m_queue.isEmpty()) {
		dispatchReadyNotifications();
		if (m_pendingNotifications.isEmpty()) {
			m_drainTimer.stop();
		}
	}
}

void MockValueApplier::removeQueuedUnderPrefix(const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	if (normalized.isEmpty() || (m_queue.isEmpty() && m_pendingNotifications.isEmpty())) {
		return;
	}
	if (!m_queue.isEmpty()) {
		QQueue<MockValueUpdate> kept;
		while (!m_queue.isEmpty()) {
			const MockValueUpdate update = m_queue.dequeue();
			if (!mockUidUnderPrefix(update.first, normalized)) {
				kept.enqueue(update);
			}
		}
		m_queue = kept;
	}
	dropNotifications([&normalized](const QString &dep) {
		return mockUidUnderPrefix(dep, normalized);
	});
	if (m_queue.isEmpty()) {
		dispatchReadyNotifications();
		if (m_pendingNotifications.isEmpty()) {
			m_drainTimer.stop();
		}
	}
}

void MockValueApplier::supersede(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return;
	}
	removeQueued(normalized);
	m_externalBlocks[normalized] += 1;
}

void MockValueApplier::blockPrefix(const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	if (normalized.isEmpty()) {
		return;
	}
	dropPrefix(normalized);
	m_prefixBlocks[normalized] += 1;
}

void MockValueApplier::acknowledgeExternalWrite(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	auto it = m_externalBlocks.find(normalized);
	if (it == m_externalBlocks.end()) {
		return;
	}
	if (it.value() <= 1) {
		m_externalBlocks.erase(it);
	} else {
		--it.value();
	}
}

void MockValueApplier::acknowledgePrefix(const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	auto it = m_prefixBlocks.find(normalized);
	if (it == m_prefixBlocks.end()) {
		return;
	}
	if (it.value() <= 1) {
		m_prefixBlocks.erase(it);
	} else {
		--it.value();
	}
}

void MockValueApplier::dropPrefix(const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	if (normalized.isEmpty()) {
		return;
	}
	// Drop queued copies now. Applying one would call VeQItemMockProducer::setValue(),
	// which calls itemGetOrCreate() and recreates the deleted service.
	removeQueuedUnderPrefix(normalized);
	if (m_applyingValues && !m_skipPrefixes.contains(normalized)) {
		m_skipPrefixes.append(normalized);
	}
}

bool MockValueApplier::hasPending(const QString &uid) const
{
	return pendingValue(uid, nullptr);
}

bool MockValueApplier::hasPendingWork() const
{
	return !m_queue.isEmpty() || !m_pendingNotifications.isEmpty();
}

void MockValueApplier::drainPendingForTest()
{
	// One value per call, matching the GUI timer, but without the 10ms gap.
	// Stop if a call makes no progress, so a stuck notify cannot spin forever.
	for (int i = 0; i < 10000; ++i) {
		if (!hasPendingWork()) {
			return;
		}
		const qsizetype waiting = m_queue.size() + m_pendingNotifications.size();
		processQueue();
		if (m_queue.size() + m_pendingNotifications.size() >= waiting) {
			return;
		}
	}
}

bool MockValueApplier::pendingValue(const QString &uid, QVariant *value) const
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return false;
	}
	for (qsizetype i = m_queue.size() - 1; i >= 0; --i) {
		if (m_queue.at(i).first == normalized) {
			if (value) {
				*value = m_queue.at(i).second;
			}
			return true;
		}
	}
	return false;
}

bool MockValueApplier::notificationReady(const MockNotifyEvent &event) const
{
	for (const QString &dep : event.dependsOn) {
		for (const MockValueUpdate &update : m_queue) {
			if (update.first == dep) {
				return false;
			}
		}
	}
	return true;
}

void MockValueApplier::enqueueNotification(const MockNotifyEvent &event)
{
	MockNotifyEvent normalized = event;
	QStringList depends;
	depends.reserve(event.dependsOn.size());
	for (const QString &dep : event.dependsOn) {
		const QString uid = normalizedMockUid(dep);
		if (uid.isEmpty()) {
			continue;
		}
		if (shouldSkip(uid)) {
			return;
		}
		depends.append(uid);
	}
	normalized.dependsOn = depends;

	for (MockNotifyEvent &pending : m_pendingNotifications) {
		const bool sameUpdate = normalized.type == MockNotifyEvent::Update
				&& pending.type == MockNotifyEvent::Update
				&& pending.index == normalized.index;
		const bool sameTotal = normalized.type == MockNotifyEvent::Total
				&& pending.type == MockNotifyEvent::Total;
		if (pending.animatorId == normalized.animatorId && (sameUpdate || sameTotal)) {
			pending = normalized;
			return;
		}
	}
	m_pendingNotifications.append(normalized);
}

void MockValueApplier::dropNotifications(const std::function<bool(const QString &)> &affected)
{
	if (!affected || m_pendingNotifications.isEmpty()) {
		return;
	}
	QVector<MockNotifyEvent> kept;
	kept.reserve(m_pendingNotifications.size());
	for (const MockNotifyEvent &event : m_pendingNotifications) {
		bool drop = false;
		for (const QString &dep : event.dependsOn) {
			if (affected(dep)) {
				drop = true;
				break;
			}
		}
		if (!drop) {
			kept.append(event);
		}
	}
	m_pendingNotifications = kept;
}

void MockValueApplier::dispatchNotification(const MockNotifyEvent &event)
{
	auto it = m_notifyMap.find(event.animatorId);
	if (it == m_notifyMap.end()) {
		return;
	}
	// Copy: the handler can re-register or unregister this animator.
	const MockNotifyCallbacks callbacks = it.value();
	if (event.type == MockNotifyEvent::Update) {
		if (callbacks.onUpdate) {
			callbacks.onUpdate(event.index, event.value);
		}
	} else if (callbacks.onTotal) {
		callbacks.onTotal(event.value);
	}
}

void MockValueApplier::dispatchReadyNotifications()
{
	// A handler can write values, which calls back in here. The outer call
	// dispatches the rest in order. Do not start a pass while values are
	// still being applied, or a notify can run before its setValue().
	if (m_applyingValues || m_dispatchingNotifications) {
		return;
	}
	m_dispatchingNotifications = true;
	// Do not skip a not-ready record. A later notify must not jump ahead of it.
	while (!m_pendingNotifications.isEmpty()
			&& notificationReady(m_pendingNotifications.constFirst())) {
		dispatchNotification(m_pendingNotifications.takeFirst());
	}
	m_dispatchingNotifications = false;
}

void MockValueApplier::applyValues(const MockValueUpdateList &updates,
		const MockNotifyEventList &notifications, const MockTickRecordList &ticks)
{
	if (!m_producer || (updates.isEmpty() && notifications.isEmpty())) {
		return;
	}

	// A write or removal may have arrived after this batch was sent. Drop every
	// output of a tick that read or wrote a held uid, then the ticks that used
	// those outputs.
	QSet<QString> droppedTickOutputs;
	QSet<int> droppedTickIndexes;
	for (bool changed = true; changed;) {
		changed = false;
		for (qsizetype i = 0; i < ticks.size(); ++i) {
			if (droppedTickIndexes.contains(i)) {
				continue;
			}
			const MockTickRecord &tick = ticks.at(i);
			const QStringList touched = tick.inputs + tick.outputs;
			bool drop = false;
			for (const QString &uid : touched) {
				const QString normalized = normalizedMockUid(uid);
				if (isBlocked(normalized) || droppedTickOutputs.contains(normalized)) {
					drop = true;
					break;
				}
			}
			if (!drop) {
				continue;
			}
			droppedTickIndexes.insert(i);
			for (const QString &uid : tick.outputs) {
				const QString normalized = normalizedMockUid(uid);
				if (!droppedTickOutputs.contains(normalized)) {
					droppedTickOutputs.insert(normalized);
					changed = true;
				}
			}
		}
	}

	// Deduplicate: keep only the latest value per uid.
	// Build a uid to index map of the current queue for O(1) lookups.
	QHash<QString, qsizetype> uidIndex;
	uidIndex.reserve(m_queue.size());
	for (qsizetype i = 0; i < m_queue.size(); ++i) {
		uidIndex[m_queue[i].first] = i;
	}

	for (const auto &[uid, value] : updates) {
		const QString normalized = normalizedMockUid(uid);
		if (normalized.isEmpty() || shouldSkip(normalized)
				|| droppedTickOutputs.contains(normalized)) {
			continue;
		}
		auto it = uidIndex.find(normalized);
		if (it != uidIndex.end()) {
			m_queue[it.value()].second = value;
		} else {
			uidIndex[normalized] = m_queue.size();
			m_queue.enqueue({normalized, value});
		}
	}

	for (const MockNotifyEvent &event : notifications) {
		bool drop = false;
		for (const QString &dep : event.dependsOn) {
			if (droppedTickOutputs.contains(normalizedMockUid(dep))) {
				drop = true;
				break;
			}
		}
		if (!drop) {
			enqueueNotification(event);
		}
	}

	// Do not apply a long queue in this turn. Distinct uids are already
	// collapsed to the latest value, and a synchronous drain freezes the GUI.
	if (m_applyingValues || m_dispatchingNotifications) {
		return;
	}
	if (!m_drainTimer.isActive()) {
		// Apply the first batch immediately (no delay for the first frame)
		processQueue();
		if (!m_queue.isEmpty() || !m_pendingNotifications.isEmpty()) {
			m_drainTimer.start();
		}
	}
}

void MockValueApplier::processQueue()
{
	if (!m_producer) {
		m_drainTimer.stop();
		return;
	}
	if (m_queue.isEmpty() && m_pendingNotifications.isEmpty()) {
		m_drainTimer.stop();
		return;
	}

	// setValue() runs QML handlers, which can write values and so shrink m_queue.
	m_applyingValues = true;
	int applied = 0;
	while (applied < MaxUpdatesPerTick && !m_queue.isEmpty()) {
		const auto [uid, value] = m_queue.dequeue();
		if (shouldSkip(uid)) {
			dropNotifications([&uid](const QString &dep) { return dep == uid; });
			continue;
		}
		m_producer->setValue(uid, value.isNull() ? QVariant() : value);
		++applied;
	}
	m_applyingValues = false;
	m_skipPrefixes.clear();
	// Emit notifyUpdate/notifyTotal only after the setValue() calls above.
	dispatchReadyNotifications();

	if (m_queue.isEmpty() && m_pendingNotifications.isEmpty()) {
		m_drainTimer.stop();
	}
}
