/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "mockvalueapplier.h"
#include "backendconnection.h"
#include "veqitemmockproducer.h"

using namespace Victron::VenusOS;

MockValueApplier::MockValueApplier(QObject *parent)
	: QObject(parent)
	, m_producer(qobject_cast<VeQItemMockProducer *>(BackendConnection::create()->producer()))
{
	if (!m_producer) {
		qWarning("MockValueApplier: VeQItemMockProducer not available!");
	}

	// Drain timer fires every ~16ms (one frame at 60fps) to spread value
	// application across frames rather than applying everything at once.
	m_drainTimer.setInterval(16);
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
	if (!m_applying && m_queue.isEmpty()) {
		dispatchReadyNotifications();
		if (m_pendingNotifications.isEmpty()) {
			m_drainTimer.stop();
		}
	}
}

void MockValueApplier::removeQueued(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
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
	if (!m_applying && m_queue.isEmpty()) {
		dispatchReadyNotifications();
		if (m_pendingNotifications.isEmpty()) {
			m_drainTimer.stop();
		}
	}
}

void MockValueApplier::removeQueuedUnderPrefix(const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	if (normalized.isEmpty()) {
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
	if (!m_applying && m_queue.isEmpty()) {
		dispatchReadyNotifications();
		if (m_pendingNotifications.isEmpty()) {
			m_drainTimer.stop();
		}
	}
}

QVariant MockValueApplier::latestValue(const QString &uid) const
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return QVariant();
	}
	// applyValues() keeps at most one queued update per uid.
	for (const MockValueUpdate &update : m_queue) {
		if (update.first == normalized) {
			return update.second;
		}
	}
	return m_producer ? m_producer->value(normalized) : QVariant();
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
	// dispatches the rest in order.
	if (m_applying) {
		return;
	}
	m_applying = true;
	// Do not skip a not-ready record. A later notify must not jump ahead of it.
	while (!m_pendingNotifications.isEmpty()
			&& notificationReady(m_pendingNotifications.constFirst())) {
		dispatchNotification(m_pendingNotifications.takeFirst());
	}
	m_applying = false;
}

void MockValueApplier::applyValues(const MockValueUpdateList &updates,
		const MockNotifyEventList &notifications)
{
	if (!m_producer || (updates.isEmpty() && notifications.isEmpty())) {
		return;
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
		if (normalized.isEmpty()) {
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
		enqueueNotification(event);
	}

	// Safety valve: if the queue is growing beyond a reasonable size,
	// drain everything immediately to prevent unbounded accumulation.
	if (m_queue.size() > MaxQueueSize) {
		m_applying = true;
		while (!m_queue.isEmpty()) {
			const auto [uid, value] = m_queue.dequeue();
			m_producer->setValue(uid, value.isNull() ? QVariant() : value);
		}
		m_applying = false;
		dispatchReadyNotifications();
		m_drainTimer.stop();
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
	m_applying = true;
	for (int i = 0; i < MaxUpdatesPerTick && !m_queue.isEmpty(); ++i) {
		const auto [uid, value] = m_queue.dequeue();
		m_producer->setValue(uid, value.isNull() ? QVariant() : value);
	}
	m_applying = false;
	// Emit notifyUpdate/notifyTotal only after the setValue() calls above.
	dispatchReadyNotifications();

	if (m_queue.isEmpty() && m_pendingNotifications.isEmpty()) {
		m_drainTimer.stop();
	}
}
