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

bool MockValueApplier::shouldSkip(const QString &uid) const
{
	const QString normalized = normalizedMockUid(uid);
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

QSet<QString> MockValueApplier::supersede(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return {};
	}
	// Drop calculated outputs still waiting, not only this uid.
	const QSet<QString> dropped = dropQueuedTickOutputs([&normalized](const QString &candidate) {
		return candidate == normalized;
	});
	removeQueued(normalized);
	// Do not apply here. The caller may still drop another tick in this call.
	continueDrain();
	return dropped;
}

QSet<QString> MockValueApplier::dropPrefix(const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	if (normalized.isEmpty()) {
		return {};
	}
	// Drop queued copies now. Applying one would call VeQItemMockProducer::setValue(),
	// which calls itemGetOrCreate() and recreates the deleted service. Also drop
	// outputs outside this path that were calculated from it.
	const QSet<QString> dropped = dropQueuedTickOutputs([&normalized](const QString &candidate) {
		return mockUidUnderPrefix(candidate, normalized);
	});
	removeQueuedUnderPrefix(normalized);
	if (m_applyingValues && !m_skipPrefixes.contains(normalized)) {
		m_skipPrefixes.append(normalized);
	}
	// Do not apply here. A paused writer may still be dropped in this call.
	continueDrain();
	return dropped;
}

void MockValueApplier::discardQueuedValues(const QSet<QString> &uids)
{
	for (const QString &uid : uids) {
		removeQueued(normalizedMockUid(uid));
	}
	retireOutputOwnership(uids);
}

void MockValueApplier::retireOutputOwnership(const QSet<QString> &uids)
{
	if (uids.isEmpty() || m_queuedTicks.isEmpty()) {
		return;
	}
	QSet<QString> normalized;
	normalized.reserve(uids.size());
	for (const QString &uid : uids) {
		const QString n = normalizedMockUid(uid);
		if (!n.isEmpty()) {
			normalized.insert(n);
		}
	}
	if (normalized.isEmpty()) {
		return;
	}
	QVector<MockTickRecord> kept;
	kept.reserve(m_queuedTicks.size());
	for (const MockTickRecord &tick : m_queuedTicks) {
		MockTickRecord remaining = tick;
		remaining.outputs.clear();
		for (const QString &output : tick.outputs) {
			if (!normalized.contains(normalizedMockUid(output))) {
				remaining.outputs.append(output);
			}
		}
		if (!remaining.outputs.isEmpty()) {
			kept.append(remaining);
		}
	}
	m_queuedTicks = kept;
}

QSet<QString> MockValueApplier::dropAnimator(int animatorId)
{
	// A replacement keeps the registration, so unregisterNotify is not called.
	// Drop this animator's notifies first, or a ready notify can still run.
	QVector<MockNotifyEvent> kept;
	kept.reserve(m_pendingNotifications.size());
	for (const MockNotifyEvent &event : m_pendingNotifications) {
		if (event.animatorId != animatorId) {
			kept.append(event);
		}
	}
	m_pendingNotifications = kept;
	// Leave calculator ticks unless they used an output of this animator, or
	// inherited that use after the output moved to a newer tick.
	return dropQueuedTickOutputs({}, [animatorId](const MockTickRecord &tick) {
		if (tick.upstreamAnimatorIds.contains(animatorId)) {
			return true;
		}
		return !tick.calculator && tick.animatorId == animatorId;
	});
}

int MockValueApplier::queuedTickCountForTest() const
{
	return static_cast<int>(m_queuedTicks.size());
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

bool MockValueApplier::hadValue(const QString &uid) const
{
	return m_producer && m_producer->value(uid).isValid();
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

void MockValueApplier::rememberTicks(const MockTickRecordList &ticks)
{
	for (const MockTickRecord &tick : ticks) {
		MockTickRecord normalized;
		normalized.animatorId = tick.animatorId;
		normalized.calculator = tick.calculator;
		normalized.inputs.reserve(tick.inputs.size());
		normalized.outputs.reserve(tick.outputs.size());
		for (const QString &uid : tick.inputs) {
			const QString n = normalizedMockUid(uid);
			if (!n.isEmpty()) {
				normalized.inputs.append(n);
			}
		}
		for (const QString &uid : tick.outputs) {
			const QString n = normalizedMockUid(uid);
			if (!n.isEmpty()) {
				normalized.outputs.append(n);
			}
		}
		if (!normalized.outputs.isEmpty()) {
			// A newer tick owns these outputs. Older records must not keep them,
			// or the record list grows for the whole session. Readers keep the
			// older inputs and animator so cancellation still reaches them.
			retireReplacedOutputs(normalized);
			m_queuedTicks.append(normalized);
		}
	}
}

void MockValueApplier::retireReplacedOutputs(MockTickRecord &incoming)
{
	if (incoming.outputs.isEmpty() || m_queuedTicks.isEmpty()) {
		return;
	}
	QSet<QString> replaced;
	replaced.reserve(incoming.outputs.size());
	for (const QString &uid : incoming.outputs) {
		replaced.insert(uid);
	}

	// A donation is an output this tick now owns, plus the inputs and animators
	// that produced the value being replaced. Only a tick that read that output
	// takes the donation. A writer that did not read it does not.
	// One pass is enough for the writers that exist today. A chain of three
	// replacements in the same call can miss the earliest input. No current
	// mock writer replaces two earlier stages while reading only the later one.
	struct Donation {
		QSet<QString> outputs;
		QStringList inputs;
		QVector<int> animatorIds;
	};
	QVector<Donation> donations;
	QVector<MockTickRecord> kept;
	kept.reserve(m_queuedTicks.size());
	for (const MockTickRecord &tick : m_queuedTicks) {
		Donation donation;
		MockTickRecord remaining = tick;
		remaining.outputs.clear();
		for (const QString &uid : tick.outputs) {
			if (replaced.contains(uid)) {
				donation.outputs.insert(uid);
			} else {
				remaining.outputs.append(uid);
			}
		}
		if (!donation.outputs.isEmpty()) {
			donation.inputs = tick.inputs;
			donation.animatorIds = tick.upstreamAnimatorIds;
			if (!tick.calculator) {
				donation.animatorIds.append(tick.animatorId);
			}
			donations.append(donation);
		}
		if (!remaining.outputs.isEmpty()) {
			kept.append(remaining);
		}
	}

	auto absorb = [&donations](MockTickRecord &record) {
		QSet<QString> have;
		have.reserve(record.inputs.size());
		for (const QString &uid : record.inputs) {
			have.insert(uid);
		}
		for (const Donation &donation : donations) {
			bool read = false;
			for (const QString &uid : donation.outputs) {
				if (have.contains(uid)) {
					read = true;
					break;
				}
			}
			if (!read) {
				continue;
			}
			for (const QString &uid : donation.inputs) {
				if (!have.contains(uid)) {
					record.inputs.append(uid);
					have.insert(uid);
				}
			}
			for (int animatorId : donation.animatorIds) {
				if (record.upstreamAnimatorIds.contains(animatorId)) {
					continue;
				}
				if (!record.calculator && animatorId == record.animatorId) {
					continue;
				}
				record.upstreamAnimatorIds.append(animatorId);
			}
		}
	};
	for (MockTickRecord &record : kept) {
		absorb(record);
	}
	absorb(incoming);
	m_queuedTicks = kept;
}

QSet<QString> MockValueApplier::dropQueuedTickOutputs(
		const std::function<bool(const QString &)> &affected,
		const std::function<bool(const MockTickRecord &)> &dropTick)
{
	if (m_queuedTicks.isEmpty() || (!affected && !dropTick)) {
		return {};
	}
	QSet<QString> dropped;
	QSet<qsizetype> droppedTicks;
	for (bool changed = true; changed;) {
		changed = false;
		for (qsizetype i = 0; i < m_queuedTicks.size(); ++i) {
			if (droppedTicks.contains(i)) {
				continue;
			}
			const MockTickRecord &tick = m_queuedTicks.at(i);
			bool drop = dropTick && dropTick(tick);
			if (!drop) {
				const QStringList touched = tick.inputs + tick.outputs;
				for (const QString &uid : touched) {
					if (dropped.contains(uid) || (affected && affected(uid))) {
						drop = true;
						break;
					}
				}
			}
			if (!drop) {
				continue;
			}
			droppedTicks.insert(i);
			for (const QString &uid : tick.outputs) {
				if (!dropped.contains(uid)) {
					dropped.insert(uid);
					changed = true;
				}
			}
		}
	}
	if (droppedTicks.isEmpty()) {
		return {};
	}
	if (!dropped.isEmpty() && !m_queue.isEmpty()) {
		QQueue<MockValueUpdate> kept;
		while (!m_queue.isEmpty()) {
			const MockValueUpdate update = m_queue.dequeue();
			if (!dropped.contains(update.first)) {
				kept.enqueue(update);
			}
		}
		m_queue = kept;
	}
	dropNotifications([&dropped](const QString &dep) { return dropped.contains(dep); });
	QVector<MockTickRecord> keptTicks;
	keptTicks.reserve(m_queuedTicks.size() - droppedTicks.size());
	for (qsizetype i = 0; i < m_queuedTicks.size(); ++i) {
		if (!droppedTicks.contains(i)) {
			keptTicks.append(m_queuedTicks.at(i));
		}
	}
	m_queuedTicks = keptTicks;
	if (m_queue.isEmpty()) {
		dispatchReadyNotifications();
		if (m_pendingNotifications.isEmpty()) {
			m_drainTimer.stop();
		}
	}
	return dropped;
}

void MockValueApplier::pruneAppliedTicks()
{
	if (m_queuedTicks.isEmpty()) {
		return;
	}
	QSet<QString> queued;
	queued.reserve(m_queue.size());
	for (const MockValueUpdate &update : m_queue) {
		queued.insert(update.first);
	}
	QVector<MockTickRecord> kept;
	kept.reserve(m_queuedTicks.size());
	for (const MockTickRecord &tick : m_queuedTicks) {
		bool waiting = false;
		for (const QString &uid : tick.outputs) {
			if (queued.contains(uid)) {
				waiting = true;
				break;
			}
		}
		if (waiting) {
			kept.append(tick);
		}
	}
	m_queuedTicks = kept;
}

void MockValueApplier::stage(const MockValueUpdateList &updates,
		const MockNotifyEventList &notifications, const MockTickRecordList &ticks)
{
	// An equal recalculation can send a tick with no new values. Still record it,
	// or waiting outputs stay owned by the previous inputs.
	if (!m_producer || (updates.isEmpty() && notifications.isEmpty() && ticks.isEmpty())) {
		return;
	}

	// Deduplicate: keep only the latest value per uid.
	// Build a uid to index map of the current queue for O(1) lookups.
	QHash<QString, qsizetype> uidIndex;
	uidIndex.reserve(m_queue.size());
	for (qsizetype i = 0; i < m_queue.size(); ++i) {
		uidIndex[m_queue[i].first] = i;
	}
	QSet<QString> replaced;

	for (const auto &[uid, value] : updates) {
		const QString normalized = normalizedMockUid(uid);
		if (normalized.isEmpty() || shouldSkip(normalized)) {
			continue;
		}
		auto it = uidIndex.find(normalized);
		if (it != uidIndex.end()) {
			if (m_queue[it.value()].second != value) {
				replaced.insert(normalized);
			}
			m_queue[it.value()].second = value;
		} else {
			uidIndex[normalized] = m_queue.size();
			m_queue.enqueue({normalized, value});
			// Not queued. It may already have been applied, with a notify still
			// waiting on another output. A different stored value must drop that
			// notify, or it reports the old value after this one is applied.
			if (m_producer->value(normalized) != value) {
				replaced.insert(normalized);
			}
		}
	}
	// A notify waiting on the old value would report that value after the
	// replacement has been applied. That includes a value already applied while
	// another output of the tick is still queued. Drop it before adding this
	// batch's notifies. The same value does not drop the waiting notify.
	if (!replaced.isEmpty()) {
		dropNotifications([&replaced](const QString &dep) { return replaced.contains(dep); });
	}

	for (const MockNotifyEvent &event : notifications) {
		enqueueNotification(event);
	}
	// A write that is not part of a new tick replaces a queued value but must
	// not stay owned by the old tick. Otherwise a later write of an old input
	// cancels the replacement.
	QSet<QString> claimed;
	for (const MockTickRecord &tick : ticks) {
		for (const QString &uid : tick.outputs) {
			const QString n = normalizedMockUid(uid);
			if (!n.isEmpty()) {
				claimed.insert(n);
			}
		}
	}
	QSet<QString> untracked;
	for (const auto &[uid, value] : updates) {
		const QString n = normalizedMockUid(uid);
		if (n.isEmpty() || shouldSkip(n) || claimed.contains(n)) {
			continue;
		}
		untracked.insert(n);
	}
	retireOutputOwnership(untracked);
	rememberTicks(ticks);
	// Drop records whose outputs have already been applied. An ownership-only
	// tick does not apply a value, and the drain may be held for calculators,
	// so this cannot wait for processQueue().
	pruneAppliedTicks();
}

void MockValueApplier::applyValues(const MockValueUpdateList &updates,
		const MockNotifyEventList &notifications, const MockTickRecordList &ticks)
{
	stage(updates, notifications, ticks);
	startDrain();
}

void MockValueApplier::holdDrain()
{
	m_drainHeld = true;
}

void MockValueApplier::releaseAndDrain()
{
	m_drainHeld = false;
	startDrain();
}

void MockValueApplier::startDrain()
{
	// A held drain waits until calculators have read the staged values.
	// A re-entrant call during setValue() must not apply a second value.
	if (m_drainHeld || m_applyingValues || m_dispatchingNotifications) {
		return;
	}
	if (!m_drainTimer.isActive()) {
		// Apply the first value immediately. Later values wait for the timer.
		processQueue();
		if (!m_queue.isEmpty() || !m_pendingNotifications.isEmpty()) {
			m_drainTimer.start();
		}
	}
}

void MockValueApplier::continueDrain()
{
	if (m_drainHeld || m_applyingValues || m_dispatchingNotifications) {
		return;
	}
	if ((m_queue.isEmpty() && m_pendingNotifications.isEmpty()) || m_drainTimer.isActive()) {
		return;
	}
	m_drainTimer.start();
}

void MockValueApplier::cancel(const QSet<QString> &uids)
{
	QSet<QString> pending = uids;
	QSet<QString> seen;
	while (!pending.isEmpty()) {
		QSet<QString> next;
		for (const QString &uid : pending) {
			const QString normalized = normalizedMockUid(uid);
			if (normalized.isEmpty() || seen.contains(normalized)) {
				continue;
			}
			seen.insert(normalized);
			next.unite(supersede(normalized));
		}
		pending = next;
	}
}

void MockValueApplier::processQueue()
{
	// The 10ms timer can already be due when a tick is staged. Applying now
	// would write a value before calculators read it, and the flush could
	// apply a second value in the same turn.
	if (m_drainHeld) {
		return;
	}
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
	pruneAppliedTicks();

	if (m_queue.isEmpty() && m_pendingNotifications.isEmpty()) {
		m_drainTimer.stop();
	} else if (!m_drainHeld && !m_drainTimer.isActive()) {
		m_drainTimer.start();
	}
}
