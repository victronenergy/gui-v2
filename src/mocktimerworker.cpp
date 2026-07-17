/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "mocktimerworker.h"
#include "mockmanager.h"

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <limits>

#include <QtMath>

#if QT_CONFIG(thread)
#include <QThread>
#endif

using namespace Victron::VenusOS;

MockTimerWorker::MockTimerWorker(QObject *parent)
	: QObject(parent)
	, m_rng(QRandomGenerator::securelySeeded())
{
}

MockTimerWorker::~MockTimerWorker()
{
	// Kill all active timers
	for (auto it = m_animatorToTimer.constBegin(); it != m_animatorToTimer.constEnd(); ++it) {
		killTimer(it.value());
	}
	if (m_flushTimerId > 0) {
		killTimer(m_flushTimerId);
	}
}

namespace {

MockAnimatorConfig normalizedAnimatorConfig(const MockAnimatorConfig &config)
{
	MockAnimatorConfig normalized = config;
	auto normalizeList = [](QStringList uids) {
		for (QString &uid : uids) {
			uid = normalizedMockUid(uid);
		}
		return uids;
	};
	normalized.uids = normalizeList(normalized.uids);
	normalized.derivedTargetUids = normalizeList(normalized.derivedTargetUids);
	normalized.derivedDivisorUids = normalizeList(normalized.derivedDivisorUids);
	normalized.derivedMultiplyTargetUids = normalizeList(normalized.derivedMultiplyTargetUids);
	normalized.derivedMultiplierUids = normalizeList(normalized.derivedMultiplierUids);
	normalized.totalTargetUid = normalizedMockUid(normalized.totalTargetUid);
	normalized.derivedMultiplyTotalTargetUid = normalizedMockUid(normalized.derivedMultiplyTotalTargetUid);
	return normalized;
}

// Spread sequential animator ids across the interval. A zero result uses the
// full interval: startTimer(0) would spin.
int animatorPhaseDelayMs(int animatorId, int intervalMs)
{
	if (intervalMs <= 1) {
		return intervalMs;
	}
	const std::uint32_t mixed = static_cast<std::uint32_t>(animatorId) * 2654435761u;
	const int delay = static_cast<int>(mixed % static_cast<std::uint32_t>(intervalMs));
	return delay == 0 ? intervalMs : delay;
}

bool uidWritesUnderPrefix(const QString &uid, const QString &prefix)
{
	return !uid.isEmpty() && mockUidUnderPrefix(uid, prefix);
}

bool listWritesUnderPrefix(const QStringList &uids, const QString &prefix)
{
	for (const QString &uid : uids) {
		if (uidWritesUnderPrefix(uid, prefix)) {
			return true;
		}
	}
	return false;
}

bool animatorWritesUnderPrefix(const MockAnimatorConfig &config, const QString &prefix)
{
	return listWritesUnderPrefix(config.uids, prefix)
			|| uidWritesUnderPrefix(config.totalTargetUid, prefix)
			|| uidWritesUnderPrefix(config.derivedMultiplyTotalTargetUid, prefix)
			|| listWritesUnderPrefix(config.derivedTargetUids, prefix)
			|| listWritesUnderPrefix(config.derivedMultiplyTargetUids, prefix);
}

MockNotifyEvent notifyEvent(int type, int animatorId, int index, qreal value,
		const QStringList &dependsOn)
{
	MockNotifyEvent event;
	event.type = type;
	event.animatorId = animatorId;
	event.index = index;
	event.value = value;
	event.dependsOn = dependsOn;
	return event;
}

// Run fn on the worker thread. Returns true when the call was posted and the
// caller must not continue on this thread.
template <typename Fn>
bool postedToWorker(MockTimerWorker *worker, Fn &&fn, bool block = false)
{
#if QT_CONFIG(thread)
	if (QThread::currentThread() != worker->thread()) {
		QMetaObject::invokeMethod(worker, std::forward<Fn>(fn),
				block ? Qt::BlockingQueuedConnection : Qt::QueuedConnection);
		return true;
	}
#else
	Q_UNUSED(worker);
	Q_UNUSED(block);
	Q_UNUSED(fn);
#endif
	return false;
}

// A timer started from a GUI call must not fire before that call's caller has
// finished. Post back through the GUI thread so later calls in the same turn,
// such as a step-size change, are queued first.
template <typename Fn>
void deferUntilGuiTurn(MockTimerWorker *worker, Fn &&fn)
{
#if QT_CONFIG(thread)
	if (worker->thread() != MockManager::create()->thread()) {
		QMetaObject::invokeMethod(MockManager::create(), [worker, fn]() {
			QMetaObject::invokeMethod(worker, [fn]() {
				fn();
			}, Qt::QueuedConnection);
		}, Qt::QueuedConnection);
		return;
	}
#else
	Q_UNUSED(worker);
#endif
	fn();
}

QStringList animatorSeedUids(const MockAnimatorConfig &config)
{
	QStringList uids = config.uids;
	uids += config.derivedDivisorUids;
	uids += config.derivedMultiplierUids;
	return uids;
}

QStringList consumptionSeedUids(const MockConsumptionConfig &services, const QString &gaugesUidPrefix)
{
	QStringList uids;
	for (const MockConsumptionServiceInfo &svc : services) {
		const QString uid = normalizedMockUid(svc.uid);
		if (uid.isEmpty()) {
			continue;
		}
		appendPhaseMeasureUids(uids, consumptionAcInPrefix(uid, svc.serviceType, svc.index));
		appendPhaseMeasureUids(uids, consumptionAcOutPrefix(uid, svc.serviceType));
		if (svc.serviceType == QLatin1String("vebus")
				|| svc.serviceType == QLatin1String("acsystem")) {
			uids.append(uid + QStringLiteral("/Ac/NumberOfPhases"));
		}
	}
	const QString gauges = normalizedMockUid(gaugesUidPrefix);
	if (!gauges.isEmpty()) {
		const QStringList paths = consumptionGaugePaths();
		for (const QString &path : paths) {
			uids.append(gauges + path);
		}
	}
	return uids;
}

QStringList phaseSumSeedUids(const QStringList &serviceUids, const QString &powerPattern,
		const QString &currentPattern)
{
	QStringList services;
	services.reserve(serviceUids.size());
	for (const QString &uid : serviceUids) {
		const QString normalized = normalizedMockUid(uid);
		if (!normalized.isEmpty()) {
			services.append(normalized);
		}
	}
	QStringList uids;
	appendPhaseSumSourceUids(uids, services, powerPattern, currentPattern);
	return uids;
}

// Caller must be on the GUI thread. value() does not create a missing item.
MockValueCache snapshotUids(const QStringList &uids)
{
	MockValueCache cache;
	MockManager *manager = MockManager::create();
	if (!manager) {
		return cache;
	}
	for (const QString &uid : uids) {
		const QString normalized = normalizedMockUid(uid);
		if (normalized.isEmpty() || cache.contains(normalized)) {
			continue;
		}
		cache.insert(normalized, manager->value(normalized));
	}
	return cache;
}

}

void MockTimerWorker::registerAnimator(const MockAnimatorConfig &config)
{
#if QT_CONFIG(thread)
	if (QThread::currentThread() != thread()) {
		const MockValueCache seed = snapshotUids(animatorSeedUids(config));
		QMetaObject::invokeMethod(this, [this, config, seed]() {
			absorbCache(seed);
			registerAnimator(config);
		}, Qt::QueuedConnection);
		return;
	}
#else
	absorbCache(snapshotUids(animatorSeedUids(config)));
#endif
	MockAnimatorConfig stored = normalizedAnimatorConfig(config);

	// Publish the initial range direction before the timer starts. A dependent
	// followSignOf binding must not wait for this animator's first phase offset.
	if (stored.type == MockAnimatorConfig::RangeAnimator
			&& stored.actualStepSizes.size() < stored.uids.size()) {
		while (stored.actualStepSizes.size() < stored.uids.size()) {
			stored.actualStepSizes.append(stored.stepSize);
		}
	}

	m_pausedAnimators.remove(stored.animatorId);
	m_configs[stored.animatorId] = stored;
	// Queued handlers read the stored vector, so emit after it is assigned.
	if (stored.type == MockAnimatorConfig::RangeAnimator
			&& stored.actualStepSizes.size() == stored.uids.size()
			&& config.actualStepSizes.size() < config.uids.size()) {
		Q_EMIT actualStepSizesChanged(stored.animatorId, stored.actualStepSizes);
	}

	// If globally active and not individually deactivated, start the timer immediately
	if (m_globalActive && !m_inactiveAnimators.contains(stored.animatorId)) {
		startAnimatorTimer(stored.animatorId);
	}
}

void MockTimerWorker::unregisterAnimator(int animatorId)
{
	if (postedToWorker(this, [this, animatorId]() { unregisterAnimator(animatorId); })) {
		return;
	}
	stopAnimatorTimer(animatorId);
	m_configs.remove(animatorId);
	m_inactiveAnimators.remove(animatorId);
	m_pausedAnimators.remove(animatorId);
	// A batched tick made with this config must not be applied, even if the same
	// id is registered again before the flush.
	dropPendingTicks({});
}

void MockTimerWorker::setAnimatorActive(int animatorId, bool active)
{
	if (postedToWorker(this, [this, animatorId, active]() {
			setAnimatorActive(animatorId, active);
		})) {
		return;
	}
	if (!m_configs.contains(animatorId)) {
		return;
	}

	if (active) {
		m_inactiveAnimators.remove(animatorId);
		if (m_globalActive) {
			startAnimatorTimer(animatorId);
		}
	} else {
		m_inactiveAnimators.insert(animatorId);
		stopAnimatorTimer(animatorId);
	}
}

void MockTimerWorker::setAllTimersActive(bool active)
{
	if (postedToWorker(this, [this, active]() { setAllTimersActive(active); })) {
		return;
	}
	m_globalActive = active;

	if (active) {
		// Start timers for all registered animators that are not individually deactivated
		for (auto it = m_configs.constBegin(); it != m_configs.constEnd(); ++it) {
			if (!m_inactiveAnimators.contains(it.key())) {
				startAnimatorTimer(it.key());
			}
		}
	} else {
		// Stop all timers
		for (auto it = m_animatorToTimer.constBegin(); it != m_animatorToTimer.constEnd(); ++it) {
			killTimer(it.value());
		}
		m_timerIdToAnimator.clear();
		m_animatorToTimer.clear();
		m_phasePending.clear();
	}
}

void MockTimerWorker::forgetUidPrefix(const QString &prefix)
{
	if (postedToWorker(this, [this, prefix]() { forgetUidPrefix(prefix); })) {
		return;
	}
	const QString normalized = normalizedMockUid(prefix);
	if (normalized.isEmpty()) {
		Q_EMIT uidPrefixForgotten(normalized);
		return;
	}

	// Keep the config. Unregistering would leave the QML object thinking it is
	// still registered, so the same path would not resume.
	QSet<int> pausedNow;
	const QList<int> animatorIds = m_configs.keys();
	for (int animatorId : animatorIds) {
		if (animatorWritesUnderPrefix(m_configs.value(animatorId), normalized)) {
			pauseAnimator(animatorId);
			pausedNow.insert(animatorId);
		}
	}

	// Do not call invalidateConsumptionValues() or invalidatePhaseSumValues().
	// Those append null updates and call scheduleBatchFlush(). The applier
	// would then call VeQItemMockProducer::setValue(), which calls
	// itemGetOrCreate() and recreates the deleted service. Pause instead of
	// dropping the config, so a later setValue() can resume the same writer.
	if (mockUidUnderPrefix(m_gaugesUidPrefix, normalized)) {
		m_gaugesPaused = true;
	}
	if (mockUidUnderPrefix(m_consumptionSystemPrefix, normalized)) {
		m_consumptionPaused = true;
	}
	const QList<int> ruleIds = m_phaseSumConfigs.keys();
	for (int ruleId : ruleIds) {
		if (mockUidUnderPrefix(m_phaseSumConfigs.value(ruleId).targetPrefix, normalized)) {
			m_pausedPhaseSums.insert(ruleId);
		}
	}

	// Drop every unflushed write under the removed path, and the whole tick that
	// produced it, including outputs outside that path.
	QSet<QString> dropped;
	for (const MockValueUpdate &update : m_pendingUpdates) {
		if (mockUidUnderPrefix(update.first, normalized)) {
			dropped.insert(update.first);
		}
	}
	dropPendingTicks(dropped, pausedNow);
	Q_EMIT uidPrefixForgotten(normalized);
}

void MockTimerWorker::noteUidWritten(const QString &uid)
{
	if (postedToWorker(this, [this, uid]() { noteUidWritten(uid); })) {
		return;
	}
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return;
	}

	bool flush = false;
	if (m_consumptionPaused && mockUidUnderPrefix(normalized, m_consumptionSystemPrefix)) {
		m_consumptionPaused = false;
		flush = true;
	}
	if (m_gaugesPaused && mockUidUnderPrefix(normalized, m_gaugesUidPrefix)) {
		m_gaugesPaused = false;
		flush = true;
	}
	const QList<int> ruleIds = m_pausedPhaseSums.values();
	for (int ruleId : ruleIds) {
		const auto it = m_phaseSumConfigs.constFind(ruleId);
		if (it != m_phaseSumConfigs.constEnd()
				&& mockUidUnderPrefix(normalized, it->targetPrefix)) {
			m_pausedPhaseSums.remove(ruleId);
			flush = true;
		}
	}
	if (flush) {
		scheduleCalculatorFlush();
	}

	const QList<int> animatorIds = m_pausedAnimators.values();
	for (int animatorId : animatorIds) {
		const auto it = m_configs.constFind(animatorId);
		if (it == m_configs.constEnd()) {
			m_pausedAnimators.remove(animatorId);
			continue;
		}
		if (!animatorWritesUnderPrefix(it.value(), normalized)) {
			continue;
		}
		m_pausedAnimators.remove(animatorId);
		if (m_globalActive && !m_inactiveAnimators.contains(animatorId)) {
			startAnimatorTimer(animatorId);
		}
	}
}

void MockTimerWorker::updateAnimatorActualStepSizes(int animatorId, const QVector<qreal> &stepSizes)
{
	if (postedToWorker(this, [this, animatorId, stepSizes]() {
			updateAnimatorActualStepSizes(animatorId, stepSizes);
		})) {
		return;
	}
	auto it = m_configs.find(animatorId);
	if (it == m_configs.end()) {
		return;
	}
	// setActualStepSizes() already stored this vector, then emitted
	// actualStepSizesPushed to call this slot. Only assign the worker config.
	// Do not Q_EMIT actualStepSizesChanged(). That signal's GUI handler writes
	// m_actualStepSizes directly and must not call setActualStepSizes(): that
	// setter emits actualStepSizesPushed and would call this slot again.
	it->actualStepSizes = stepSizes;
}

QVariant MockTimerWorker::readValue(const QString &uid) const
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return {};
	}
	for (qsizetype i = m_pendingUpdates.size() - 1; i >= 0; --i) {
		if (m_pendingUpdates.at(i).first == normalized) {
			return m_pendingUpdates.at(i).second;
		}
	}
	return m_valueCache.value(normalized);
}

void MockTimerWorker::absorbCache(const MockValueCache &values)
{
	for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
		m_valueCache.insert(normalizedMockUid(it.key()), it.value());
	}
}

void MockTimerWorker::observeExternalValue(const QString &uid, const QVariant &value)
{
	if (postedToWorker(this, [this, uid, value]() { observeExternalValue(uid, value); })) {
		return;
	}
	const QString normalized = normalizedMockUid(uid);
	if (!normalized.isEmpty()) {
		m_valueCache.insert(normalized, value);
		dropPendingUpdate(normalized);
		noteUidWritten(normalized);
	}
	Q_EMIT externalValueObserved(normalized);
}

void MockTimerWorker::writePending(const QString &uid, const QVariant &value)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return;
	}
	// An in-place update is still an output of the tick that wrote it.
	if (m_recordingOutputs && !m_recordingOutputs->contains(normalized)) {
		m_recordingOutputs->append(normalized);
	}
	for (MockValueUpdate &update : m_pendingUpdates) {
		if (update.first == normalized) {
			update.second = value;
			return;
		}
	}
	m_pendingUpdates.append({normalized, value});
}

void MockTimerWorker::processTick(MockAnimatorConfig &config)
{
	MockTickRecord tick;
	tick.animatorId = config.animatorId;
	tick.inputs = config.uids + config.derivedDivisorUids + config.derivedMultiplierUids;
	m_recordingOutputs = &tick.outputs;
	switch (config.type) {
	case MockAnimatorConfig::Randomizer:
		processRandomizer(config);
		break;
	case MockAnimatorConfig::RangeAnimator:
		processRangeAnimator(config);
		break;
	case MockAnimatorConfig::Stepper:
		processStepper(config);
		break;
	case MockAnimatorConfig::Toggler:
		processToggler(config);
		break;
	}
	m_recordingOutputs = nullptr;
	if (!tick.outputs.isEmpty()) {
		m_pendingTicks.append(tick);
	}
}

void MockTimerWorker::dropPendingTicks(QSet<QString> dropped, const QSet<int> &dropAnimators)
{
	// Drop every tick that read or wrote a dropped uid, whose animator was paused
	// for a removed path, or whose animator is gone. Its outputs are dropped too,
	// including earlier writes of the same uid, so repeat until nothing more drops.
	QSet<int> droppedAnimators;
	for (bool changed = true; changed;) {
		changed = false;
		for (auto it = m_pendingTicks.begin(); it != m_pendingTicks.end();) {
			bool drop = dropAnimators.contains(it->animatorId)
					|| !m_configs.contains(it->animatorId);
			if (!drop) {
				const QStringList touched = it->inputs + it->outputs;
				for (const QString &uid : touched) {
					if (dropped.contains(uid)) {
						drop = true;
						break;
					}
				}
			}
			if (drop) {
				const QStringList outputs = it->outputs;
				droppedAnimators.insert(it->animatorId);
				it = m_pendingTicks.erase(it);
				for (const QString &uid : outputs) {
					dropped.insert(uid);
				}
				changed = true;
			} else {
				++it;
			}
		}
	}
	m_pendingUpdates.removeIf([&dropped](const MockValueUpdate &update) {
		return dropped.contains(update.first);
	});
	m_pendingNotifications.removeIf([&](const MockNotifyEvent &event) {
		if (dropAnimators.contains(event.animatorId)
				|| droppedAnimators.contains(event.animatorId)
				|| !m_configs.contains(event.animatorId)) {
			return true;
		}
		for (const QString &dep : event.dependsOn) {
			if (dropped.contains(dep)) {
				return true;
			}
		}
		return false;
	});
}

void MockTimerWorker::dropPendingUpdate(const QString &uid)
{
	if (postedToWorker(this, [this, uid]() { dropPendingUpdate(uid); })) {
		return;
	}
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return;
	}
	// A tick that wrote uid, or computed something from it, is dropped whole.
	dropPendingTicks({normalized});
}

QVector<qreal> MockTimerWorker::actualStepSizes(int animatorId) const
{
	const auto it = m_configs.constFind(animatorId);
	if (it == m_configs.constEnd()) {
		return {};
	}
	return it->actualStepSizes;
}

void MockTimerWorker::updateAnimatorFollowSignOf(int animatorId, qreal followSignOf)
{
	if (postedToWorker(this, [this, animatorId, followSignOf]() {
			updateAnimatorFollowSignOf(animatorId, followSignOf);
		})) {
		return;
	}
	if (m_configs.contains(animatorId)) {
		m_configs[animatorId].followSignOf = followSignOf;
	}
}

void MockTimerWorker::timerEvent(QTimerEvent *event)
{
	const int timerId = event->timerId();

	// Handle the batch flush timer
	if (timerId == m_flushTimerId) {
		flushBatch();
		return;
	}

	auto it = m_timerIdToAnimator.find(timerId);
	if (it == m_timerIdToAnimator.end()) {
		return;
	}

	const int animatorId = it.value();
	auto configIt = m_configs.find(animatorId);
	if (configIt == m_configs.end()) {
		return;
	}

	MockAnimatorConfig &config = configIt.value();

	// The first timeout may be a phase offset. Switch to the steady interval
	// before processing so a short offset cannot repeat.
	if (m_phasePending.remove(animatorId)) {
		stopAnimatorTimer(animatorId);
		if (config.repeat) {
			startAnimatorTimer(animatorId, false);
		}
	}

	processTick(config);

	if (!config.repeat) {
		stopAnimatorTimer(animatorId);
	}

	scheduleBatchFlush();
}

void MockTimerWorker::pauseAnimator(int animatorId)
{
	stopAnimatorTimer(animatorId);
	m_pausedAnimators.insert(animatorId);
}

void MockTimerWorker::startAnimatorTimer(int animatorId, bool applyPhase, bool deferred)
{
	// A start requested from the GUI must wait until that turn has queued any
	// follow-up change, such as a new step size. The phase switch passes
	// applyPhase false and starts immediately.
	if (applyPhase && !deferred) {
		deferUntilGuiTurn(this, [this, animatorId]() {
			startAnimatorTimer(animatorId, true, true);
		});
		return;
	}
	// The deferred start can arrive after timers were turned off.
	if (!m_globalActive || m_inactiveAnimators.contains(animatorId)) {
		return;
	}
	// A removed path must not tick. The next setValue() of that path resumes it.
	if (m_pausedAnimators.contains(animatorId)) {
		return;
	}
	if (m_animatorToTimer.contains(animatorId)) {
		return; // Already running
	}

	auto it = m_configs.find(animatorId);
	if (it == m_configs.end()) {
		return;
	}

	// static_cast<int>(std::ceil(interval)) is undefined for NaN, +Inf, and
	// values above INT_MAX. Reject those before the cast. startTimer() returns
	// 0 when it does not start; do not store 0 in m_animatorToTimer or
	// m_timerIdToAnimator.
	if (!std::isfinite(it->interval) || it->interval <= 0.0) {
		return;
	}
	const double ceiled = std::ceil(static_cast<double>(it->interval));
	if (ceiled > static_cast<double>(std::numeric_limits<int>::max())) {
		return;
	}
	const int interval = qMax(1, static_cast<int>(ceiled));
	const int delay = applyPhase ? animatorPhaseDelayMs(animatorId, interval) : interval;
	const int timerId = startTimer(delay);
	if (timerId == 0) {
		return;
	}
	m_animatorToTimer[animatorId] = timerId;
	m_timerIdToAnimator[timerId] = animatorId;
	if (delay != interval) {
		m_phasePending.insert(animatorId);
	}
}

void MockTimerWorker::stopAnimatorTimer(int animatorId)
{
	auto it = m_animatorToTimer.find(animatorId);
	if (it == m_animatorToTimer.end()) {
		return;
	}

	const int timerId = it.value();
	killTimer(timerId);
	m_timerIdToAnimator.remove(timerId);
	m_animatorToTimer.erase(it);
	m_phasePending.remove(animatorId);
}

void MockTimerWorker::processRandomizer(MockAnimatorConfig &config)
{
	qreal total = 0.0;
	qreal multiplyTotal = 0.0;
	bool anyValue = false;
	bool anyMultiply = false;
	QStringList tickDepends;
	const bool hasDerived = !config.derivedTargetUids.isEmpty()
		&& config.derivedTargetUids.size() == config.uids.size()
		&& config.derivedDivisorUids.size() == config.uids.size();
	const bool hasMultiply = !config.derivedMultiplyTargetUids.isEmpty()
		&& config.derivedMultiplyTargetUids.size() == config.uids.size()
		&& config.derivedMultiplierUids.size() == config.uids.size();

	for (qsizetype i = 0; i < config.uids.size(); ++i) {
		const QString &uid = config.uids[i];
		const QVariant cached = readValue(uid);

		bool ok = false;
		const qreal rv = cached.toReal(&ok);
		if (!ok || qIsNaN(rv)) {
			continue;
		}

		const qreal high = qIsNaN(config.deltaHigh)
			? (rv * 1.1)
			: (rv + config.deltaHigh);

		const qreal low = qIsNaN(config.deltaLow)
			? (rv * 0.9)
			: (rv - config.deltaLow);

		qreal newValue = (m_rng.bounded(1.0) * (high - low)) + low;
		if (!qIsNaN(config.followSignOf)) {
			newValue = qAbs(newValue) * (config.followSignOf < 0.0 ? -1.0 : 1.0);
		}
		if (!qIsNaN(config.minimumValue)) {
			newValue = qMax(config.minimumValue, newValue);
		}
		if (!qIsNaN(config.maximumValue)) {
			newValue = qMin(config.maximumValue, newValue);
		}

		writePending(uid, newValue);
		total += newValue;
		anyValue = true;
		QStringList itemDepends;
		itemDepends.append(uid);

		// Compute derived value (e.g. current = power / voltage)
		if (hasDerived && !config.derivedTargetUids[i].isEmpty()) {
			const QString &divisorUid = config.derivedDivisorUids[i];
			const QVariant divisorVal = readValue(divisorUid);
			bool divOk = false;
			const qreal divisor = divisorVal.toReal(&divOk);
			if (divOk && divisor > 0.0) {
				const qreal derived = newValue / divisor;
				const QString &targetUid = config.derivedTargetUids[i];
				writePending(targetUid, QVariant(derived));
				itemDepends.append(targetUid);
			}
		}

		// Compute multiply derived value (e.g. power = current * voltage)
		if (hasMultiply && !config.derivedMultiplyTargetUids[i].isEmpty()) {
			const QString &multiplierUid = config.derivedMultiplierUids[i];
			const QVariant multiplierVal = readValue(multiplierUid);
			bool mulOk = false;
			const qreal multiplier = multiplierVal.toReal(&mulOk);
			if (mulOk) {
				const qreal derived = newValue * multiplier;
				const QString &targetUid = config.derivedMultiplyTargetUids[i];
				writePending(targetUid, QVariant(derived));
				itemDepends.append(targetUid);
				multiplyTotal += derived;
				anyMultiply = true;
			}
		}

		tickDepends.append(itemDepends);
		// The applier emits this after setValue() for itemDepends. Do not Q_EMIT
		// notifyUpdate here: that runs the QML handler before setValue().
		m_pendingNotifications.append(notifyEvent(
				MockNotifyEvent::Update, config.animatorId, static_cast<int>(i),
				newValue, itemDepends));
	}

	// A tick that read nothing must not replace a real total with 0.
	if (!config.totalTargetUid.isEmpty() && anyValue) {
		writePending(config.totalTargetUid, QVariant(total));
		tickDepends.append(config.totalTargetUid);
	}

	if (hasMultiply && !config.derivedMultiplyTotalTargetUid.isEmpty() && anyMultiply) {
		writePending(config.derivedMultiplyTotalTargetUid, QVariant(multiplyTotal));
		tickDepends.append(config.derivedMultiplyTotalTargetUid);
	}

	if (!anyValue) {
		return;
	}
	// The applier emits this after setValue() for every uid in tickDepends.
	m_pendingNotifications.append(notifyEvent(
			MockNotifyEvent::Total, config.animatorId, -1, total, tickDepends));
}

void MockTimerWorker::processRangeAnimator(MockAnimatorConfig &config)
{
	if (config.rangeMax <= config.rangeMin) {
		stopAnimatorTimer(config.animatorId);
		return;
	}

	// Publish the initial direction as well as later reversals. followSignOf
	// bindings read actualStepSizes before the first bound is hit.
	bool stepSizesChanged = false;
	if (config.actualStepSizes.size() < config.uids.size()) {
		while (config.actualStepSizes.size() < config.uids.size()) {
			config.actualStepSizes.append(config.stepSize);
		}
		stepSizesChanged = true;
	}

	qreal total = 0.0;
	qreal multiplyTotal = 0.0;
	bool anyValue = false;
	bool anyMultiply = false;
	QStringList tickDepends;
	const bool hasDerived = !config.derivedTargetUids.isEmpty()
		&& config.derivedTargetUids.size() == config.uids.size()
		&& config.derivedDivisorUids.size() == config.uids.size();
	const bool hasMultiply = !config.derivedMultiplyTargetUids.isEmpty()
		&& config.derivedMultiplyTargetUids.size() == config.uids.size()
		&& config.derivedMultiplierUids.size() == config.uids.size();

	for (qsizetype i = 0; i < config.uids.size(); ++i) {
		const QString &uid = config.uids[i];
		const QVariant cached = readValue(uid);

		bool ok = false;
		const qreal rv = cached.toReal(&ok);
		if (!ok || qIsNaN(rv)) {
			continue;
		}

		qreal newValue = rv + config.actualStepSizes[i];
		if (!qIsNaN(config.rangeMin)) {
			newValue = qMax(config.rangeMin, newValue);
		}
		if (!qIsNaN(config.rangeMax)) {
			newValue = qMin(config.rangeMax, newValue);
		}

		writePending(uid, newValue);
		total += newValue;
		anyValue = true;
		tickDepends.append(uid);

		// Compute derived value (e.g. current = power / voltage)
		if (hasDerived && !config.derivedTargetUids[i].isEmpty()) {
			const QString &divisorUid = config.derivedDivisorUids[i];
			const QVariant divisorVal = readValue(divisorUid);
			bool divOk = false;
			const qreal divisor = divisorVal.toReal(&divOk);
			if (divOk && divisor > 0.0) {
				const qreal derived = newValue / divisor;
				const QString &targetUid = config.derivedTargetUids[i];
				writePending(targetUid, QVariant(derived));
				tickDepends.append(targetUid);
			}
		}

		// Compute multiply derived value (e.g. power = current * voltage)
		if (hasMultiply && !config.derivedMultiplyTargetUids[i].isEmpty()) {
			const QString &multiplierUid = config.derivedMultiplierUids[i];
			const QVariant multiplierVal = readValue(multiplierUid);
			bool mulOk = false;
			const qreal multiplier = multiplierVal.toReal(&mulOk);
			if (mulOk) {
				const qreal derived = newValue * multiplier;
				const QString &targetUid = config.derivedMultiplyTargetUids[i];
				writePending(targetUid, QVariant(derived));
				tickDepends.append(targetUid);
				multiplyTotal += derived;
				anyMultiply = true;
			}
		}

		// Reverse direction if bounds are reached
		if (rv <= config.rangeMin) {
			const qreal newStep = qAbs(config.actualStepSizes[i]);
			if (config.actualStepSizes[i] != newStep) {
				config.actualStepSizes[i] = newStep;
				stepSizesChanged = true;
			}
		} else if (rv >= config.rangeMax) {
			const qreal newStep = qAbs(config.actualStepSizes[i]) * -1.0;
			if (config.actualStepSizes[i] != newStep) {
				config.actualStepSizes[i] = newStep;
				stepSizesChanged = true;
			}
		}
	}

	// A tick that read nothing must not replace a real total with 0.
	if (!config.totalTargetUid.isEmpty() && anyValue) {
		writePending(config.totalTargetUid, QVariant(total));
		tickDepends.append(config.totalTargetUid);
	}

	if (hasMultiply && !config.derivedMultiplyTotalTargetUid.isEmpty() && anyMultiply) {
		writePending(config.derivedMultiplyTotalTargetUid, QVariant(multiplyTotal));
		tickDepends.append(config.derivedMultiplyTotalTargetUid);
	}

	// The applier emits this after setValue() for every uid in tickDepends.
	// Do not Q_EMIT notifyTotal here: that runs the QML handler before setValue().
	if (anyValue) {
		m_pendingNotifications.append(notifyEvent(
				MockNotifyEvent::Total, config.animatorId, -1, total, tickDepends));
	}

	if (stepSizesChanged) {
		Q_EMIT actualStepSizesChanged(config.animatorId, config.actualStepSizes);
	}
}

void MockTimerWorker::scheduleBatchFlush()
{
	// Coalesce every animator tick in this event-loop iteration into one
	// valuesReady() emission. Notifications travel in that same emission.
	if (m_flushTimerId == 0
			&& (!m_pendingUpdates.isEmpty() || !m_pendingNotifications.isEmpty())) {
		m_flushTimerId = startTimer(0);
	}
}

void MockTimerWorker::queueUpdateForTest(const QString &uid, const QVariant &value)
{
	if (postedToWorker(this, [this, uid, value]() { queueUpdateForTest(uid, value); }, true)) {
		return;
	}
	writePending(uid, value);
	deferUntilGuiTurn(this, [this]() { flushBatch(); });
}

void MockTimerWorker::tickAnimatorsForTest()
{
	if (postedToWorker(this, [this]() { tickAnimatorsForTest(); }, true)) {
		return;
	}
	// In creation order, so a later animator can read an earlier one's outputs.
	// Skip a paused animator: this hook must not write a removed service.
	QList<int> animatorIds = m_configs.keys();
	std::sort(animatorIds.begin(), animatorIds.end());
	for (int animatorId : animatorIds) {
		if (m_pausedAnimators.contains(animatorId)) {
			continue;
		}
		auto it = m_configs.find(animatorId);
		if (it == m_configs.end()) {
			continue;
		}
		processTick(it.value());
	}
	deferUntilGuiTurn(this, [this]() { flushBatch(); });
}

void MockTimerWorker::scheduleCalculatorFlush()
{
	if (postedToWorker(this, [this]() { scheduleCalculatorFlush(); })) {
		return;
	}
	// Consumption and phase sums must run even when no animator produced an update
	// (mock timers off, or a source changed outside an animator tick).
	if (m_flushTimerId == 0) {
		m_flushTimerId = startTimer(0);
	}
}

void MockTimerWorker::flushBatch()
{
	if (m_flushTimerId > 0) {
		killTimer(m_flushTimerId);
		m_flushTimerId = 0;
	}

	// Evaluate consumption after animator ticks have queued their writes.
	if (!m_consumptionServices.isEmpty()) {
		evaluateConsumption();
	}

	// Evaluate phase sum aggregations
	if (!m_phaseSumConfigs.isEmpty()) {
		evaluatePhaseSums();
	}

	// These writes are about to be applied. A later UI write must not treat them
	// as still unflushed.
	if (m_pendingUpdates.isEmpty() && m_pendingNotifications.isEmpty()) {
		m_pendingTicks.clear();
		return;
	}
	// Copy first. On a build without threads the signal is delivered immediately,
	// and setValue() can drop pending updates while applyValues() is still reading.
	const MockValueUpdateList updates = m_pendingUpdates;
	const MockNotifyEventList notifications = m_pendingNotifications;
	const MockTickRecordList ticks = m_pendingTicks;
	m_pendingUpdates.clear();
	m_pendingNotifications.clear();
	m_pendingTicks.clear();
	for (const MockValueUpdate &update : updates) {
		m_valueCache.insert(update.first, update.second);
	}
	Q_EMIT valuesReady(updates, notifications, ticks);
}

void MockTimerWorker::processStepper(MockAnimatorConfig &config)
{
	for (qsizetype i = 0; i < config.uids.size(); ++i) {
		const QString &uid = config.uids[i];
		const QVariant cached = readValue(uid);

		bool ok = false;
		const qreal rv = cached.toReal(&ok);
		if (!ok || qIsNaN(rv)) {
			continue;
		}

		qreal newValue = rv + config.stepSize;

		// Optional clamping (NaN means no limit)
		if (!qIsNaN(config.minimumValue)) {
			newValue = qMax(config.minimumValue, newValue);
		}
		if (!qIsNaN(config.maximumValue)) {
			newValue = qMin(config.maximumValue, newValue);
		}

		writePending(uid, QVariant(newValue));
	}
}

void MockTimerWorker::processToggler(MockAnimatorConfig &config)
{
	for (const QString &uid : config.uids) {
		const QVariant cached = readValue(uid);
		const QVariant newValue = (cached == config.toggleA) ? config.toggleB : config.toggleA;
		writePending(uid, newValue);
	}
}

void MockTimerWorker::setConsumptionConfig(const QString &systemUidPrefix,
	const MockConsumptionConfig &services, bool gaugesAutoMax, const QString &gaugesUidPrefix)
{
#if QT_CONFIG(thread)
	if (QThread::currentThread() != thread()) {
		const MockValueCache seed = snapshotUids(consumptionSeedUids(services, gaugesUidPrefix));
		QMetaObject::invokeMethod(this, [this, systemUidPrefix, services, gaugesAutoMax, gaugesUidPrefix, seed]() {
			absorbCache(seed);
			setConsumptionConfig(systemUidPrefix, services, gaugesAutoMax, gaugesUidPrefix);
		}, Qt::QueuedConnection);
		return;
	}
#else
	absorbCache(snapshotUids(consumptionSeedUids(services, gaugesUidPrefix)));
#endif
	const QString prefix = normalizedMockUid(systemUidPrefix);
	MockConsumptionConfig normalized = services;
	for (MockConsumptionServiceInfo &svc : normalized) {
		svc.uid = normalizedMockUid(svc.uid);
	}
	const QString gauges = normalizedMockUid(gaugesUidPrefix);
	const bool sameSystem = !prefix.isEmpty() && prefix == m_consumptionSystemPrefix;
	// A removed system must not be written back just because a source was added.
	if (m_consumptionPaused && sameSystem) {
		m_consumptionServices = normalized;
		m_gaugesAutoMax = gaugesAutoMax;
		if (gauges != m_gaugesUidPrefix) {
			m_gaugesPaused = false;
			m_gaugesUidPrefix = gauges;
		}
		return;
	}
	if (m_consumptionPaused && !sameSystem) {
		m_consumptionPaused = false;
	} else if (normalized.isEmpty()
			|| (!m_consumptionSystemPrefix.isEmpty() && m_consumptionSystemPrefix != prefix)) {
		invalidateConsumptionValues();
	}
	if (m_gaugesPaused && gauges != m_gaugesUidPrefix) {
		m_gaugesPaused = false;
	}
	m_consumptionSystemPrefix = prefix;
	m_consumptionServices = normalized;
	m_gaugesAutoMax = gaugesAutoMax;
	m_gaugesUidPrefix = gauges;
	scheduleCalculatorFlush();
}

void MockTimerWorker::clearConsumptionConfig()
{
	if (postedToWorker(this, [this]() { clearConsumptionConfig(); })) {
		return;
	}
	// Invalidation writes would recreate a service that was just removed.
	if (!m_consumptionPaused) {
		invalidateConsumptionValues();
	}
	m_consumptionPaused = false;
	m_gaugesPaused = false;
	m_consumptionSystemPrefix.clear();
	m_consumptionServices.clear();
	m_gaugesAutoMax = false;
	m_gaugesUidPrefix.clear();
}

void MockTimerWorker::evaluateConsumption()
{
	if (m_consumptionPaused || m_consumptionSystemPrefix.isEmpty() || m_consumptionServices.isEmpty()) {
		return;
	}

	// No measurements means NumberOfPhases is invalid, not 1.
	int maxPhaseIndex = -1;
	qreal acIn1MaxCurrent = 0.0;
	qreal acIn2MaxCurrent = 0.0;
	qreal noAcInMaxCurrent = 0.0;

	for (int phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
		qreal phaseAcInPower = qQNaN();
		qreal phaseAcInCurrent = qQNaN();
		qreal phaseAcOutPower = qQNaN();
		qreal phaseAcOutCurrent = qQNaN();

		for (const auto &svc : m_consumptionServices) {
			bool limitPhases = false;
			int servicePhaseCount = 0;
			if (svc.serviceType == QLatin1String("vebus") || svc.serviceType == QLatin1String("acsystem")) {
				const QString phaseCountUid = svc.uid + QStringLiteral("/Ac/NumberOfPhases");
				servicePhaseCount = readValue(phaseCountUid).toInt(&limitPhases);
			}
			if (limitPhases && phaseIndex >= servicePhaseCount) {
				continue;
			}

			const QString acInPrefix = consumptionAcInPrefix(svc.uid, svc.serviceType, svc.index);
			const QString acOutPrefix = consumptionAcOutPrefix(svc.uid, svc.serviceType);
			const QString phaseStr = QStringLiteral("/L") + QString::number(phaseIndex + 1);
			const QString powerKey = QStringLiteral("/P");
			const QString currentKey = QStringLiteral("/I");

			// Sum AC-in power/current
			if (!acInPrefix.isEmpty()) {
				const QString inPowerUid = acInPrefix + phaseStr + powerKey;
				const QVariant inPVal = readValue(inPowerUid);
				bool ok = false;
				const qreal p = inPVal.toReal(&ok);
				if (ok && !qIsNaN(p)) {
					phaseAcInPower = qIsNaN(phaseAcInPower) ? p : (phaseAcInPower + p);
				}

				const QString inCurrentUid = acInPrefix + phaseStr + currentKey;
				const QVariant inIVal = readValue(inCurrentUid);
				const qreal c = inIVal.toReal(&ok);
				if (ok && !qIsNaN(c)) {
					phaseAcInCurrent = qIsNaN(phaseAcInCurrent) ? c : (phaseAcInCurrent + c);
				}
			}

			// Sum AC-out power/current
			if (!acOutPrefix.isEmpty()) {
				const QString outPowerUid = acOutPrefix + phaseStr + powerKey;
				const QVariant outPVal = readValue(outPowerUid);
				bool ok = false;
				const qreal p = outPVal.toReal(&ok);
				if (ok && !qIsNaN(p)) {
					phaseAcOutPower = qIsNaN(phaseAcOutPower) ? p : (phaseAcOutPower + p);
				}

				const QString outCurrentUid = acOutPrefix + phaseStr + currentKey;
				const QVariant outIVal = readValue(outCurrentUid);
				const qreal c = outIVal.toReal(&ok);
				if (ok && !qIsNaN(c)) {
					phaseAcOutCurrent = qIsNaN(phaseAcOutCurrent) ? c : (phaseAcOutCurrent + c);
				}
			}

			if (m_gaugesAutoMax) {
				const qreal inCurrent = qIsNaN(phaseAcInCurrent) ? 0.0 : phaseAcInCurrent;
				const qreal outCurrent = qIsNaN(phaseAcOutCurrent) ? 0.0 : phaseAcOutCurrent;
				const qreal inputCurrent = inCurrent + outCurrent;
				if (svc.index == 0) {
					acIn1MaxCurrent = qMax(acIn1MaxCurrent, inputCurrent);
				} else if (svc.index == 1) {
					acIn2MaxCurrent = qMax(acIn2MaxCurrent, inputCurrent);
				} else {
					noAcInMaxCurrent = qMax(noAcInMaxCurrent, inputCurrent);
				}
			}
		}

		const qreal consumptionOnInputPower = qIsNaN(phaseAcInPower) || qIsNaN(phaseAcOutPower)
			? qQNaN() : qMax(0.0, phaseAcInPower - phaseAcOutPower);
		const qreal consumptionOnInputCurrent = qIsNaN(phaseAcInCurrent) || qIsNaN(phaseAcOutCurrent)
			? qQNaN() : qMax(0.0, phaseAcInCurrent - phaseAcOutCurrent);
		const qreal consumptionOnOutputPower = phaseAcOutPower;
		const qreal consumptionOnOutputCurrent = phaseAcOutCurrent;

		const QString phaseStr = QStringLiteral("/L") + QString::number(phaseIndex + 1);
		const QString prefix = m_consumptionSystemPrefix;

		auto writeValue = [&](const QString &path, qreal value) {
			const QVariant v = qIsNaN(value) ? QVariant() : QVariant(value);
			const QString uid = prefix + path;
			if (readValue(uid) != v) {
				writePending(uid, v);
			}
		};

		// Only write if we have data for this phase
		const bool hasData = !qIsNaN(phaseAcInPower) || !qIsNaN(phaseAcOutPower)
			|| !qIsNaN(phaseAcInCurrent) || !qIsNaN(phaseAcOutCurrent);
		if (hasData) {
			writeValue(QStringLiteral("/Ac/ConsumptionOnInput") + phaseStr + QStringLiteral("/Power"),
				consumptionOnInputPower);
			writeValue(QStringLiteral("/Ac/ConsumptionOnInput") + phaseStr + QStringLiteral("/Current"),
				consumptionOnInputCurrent);
			writeValue(QStringLiteral("/Ac/ConsumptionOnOutput") + phaseStr + QStringLiteral("/Power"),
				consumptionOnOutputPower);
			writeValue(QStringLiteral("/Ac/ConsumptionOnOutput") + phaseStr + QStringLiteral("/Current"),
				consumptionOnOutputCurrent);

			// Consumption = sum of both
			qreal combinedPower = qQNaN();
			if (!qIsNaN(consumptionOnInputPower))
				combinedPower = consumptionOnInputPower;
			if (!qIsNaN(consumptionOnOutputPower))
				combinedPower = qIsNaN(combinedPower) ? consumptionOnOutputPower : (combinedPower + consumptionOnOutputPower);
			qreal combinedCurrent = qQNaN();
			if (!qIsNaN(consumptionOnInputCurrent))
				combinedCurrent = consumptionOnInputCurrent;
			if (!qIsNaN(consumptionOnOutputCurrent))
				combinedCurrent = qIsNaN(combinedCurrent) ? consumptionOnOutputCurrent : (combinedCurrent + consumptionOnOutputCurrent);

			writeValue(QStringLiteral("/Ac/Consumption") + phaseStr + QStringLiteral("/Power"), combinedPower);
			writeValue(QStringLiteral("/Ac/Consumption") + phaseStr + QStringLiteral("/Current"), combinedCurrent);
			maxPhaseIndex = qMax(maxPhaseIndex, phaseIndex);
		} else {
			// Clear stale values for phases that no longer have data
			writeValue(QStringLiteral("/Ac/ConsumptionOnInput") + phaseStr + QStringLiteral("/Power"), qQNaN());
			writeValue(QStringLiteral("/Ac/ConsumptionOnInput") + phaseStr + QStringLiteral("/Current"), qQNaN());
			writeValue(QStringLiteral("/Ac/ConsumptionOnOutput") + phaseStr + QStringLiteral("/Power"), qQNaN());
			writeValue(QStringLiteral("/Ac/ConsumptionOnOutput") + phaseStr + QStringLiteral("/Current"), qQNaN());
			writeValue(QStringLiteral("/Ac/Consumption") + phaseStr + QStringLiteral("/Power"), qQNaN());
			writeValue(QStringLiteral("/Ac/Consumption") + phaseStr + QStringLiteral("/Current"), qQNaN());
		}
	}

	const QVariant phaseCount = maxPhaseIndex >= 0 ? QVariant(maxPhaseIndex + 1) : QVariant();
	auto writePhaseCount = [&](const QString &path) {
		const QString uid = m_consumptionSystemPrefix + path;
		if (readValue(uid) != phaseCount) {
			writePending(uid, phaseCount);
		}
	};
	writePhaseCount(QStringLiteral("/Ac/ConsumptionOnOutput/NumberOfPhases"));
	writePhaseCount(QStringLiteral("/Ac/ConsumptionOnInput/NumberOfPhases"));
	writePhaseCount(QStringLiteral("/Ac/Consumption/NumberOfPhases"));

	if (m_gaugesAutoMax && !m_gaugesPaused && !m_gaugesUidPrefix.isEmpty()) {
		auto raiseGaugeMax = [this](const QString &path, qreal computed) {
			const QString uid = m_gaugesUidPrefix + path;
			bool ok = false;
			const qreal existing = readValue(uid).toReal(&ok);
			const qreal floor = (ok && !qIsNaN(existing)) ? existing : 0.0;
			const qreal next = qMax(computed, floor);
			if (!ok || qIsNaN(existing) || next > existing) {
				writePending(uid, QVariant(next));
			}
		};
		raiseGaugeMax(QStringLiteral("/Ac/AcIn1/Consumption/Current/Max"), acIn1MaxCurrent);
		raiseGaugeMax(QStringLiteral("/Ac/AcIn2/Consumption/Current/Max"), acIn2MaxCurrent);
		raiseGaugeMax(QStringLiteral("/Ac/NoAcIn/Consumption/Current/Max"), noAcInMaxCurrent);
	}
}

void MockTimerWorker::invalidateConsumptionValues()
{
	if (m_consumptionSystemPrefix.isEmpty()) {
		return;
	}

	const QString prefix = m_consumptionSystemPrefix;
	auto invalidate = [&](const QString &path) {
		writePending(prefix + path, QVariant());
	};

	for (int phase = 1; phase <= 3; ++phase) {
		const QString ps = QStringLiteral("/L") + QString::number(phase);
		invalidate(QStringLiteral("/Ac/ConsumptionOnInput") + ps + QStringLiteral("/Power"));
		invalidate(QStringLiteral("/Ac/ConsumptionOnInput") + ps + QStringLiteral("/Current"));
		invalidate(QStringLiteral("/Ac/ConsumptionOnOutput") + ps + QStringLiteral("/Power"));
		invalidate(QStringLiteral("/Ac/ConsumptionOnOutput") + ps + QStringLiteral("/Current"));
		invalidate(QStringLiteral("/Ac/Consumption") + ps + QStringLiteral("/Power"));
		invalidate(QStringLiteral("/Ac/Consumption") + ps + QStringLiteral("/Current"));
	}
	invalidate(QStringLiteral("/Ac/ConsumptionOnOutput/NumberOfPhases"));
	invalidate(QStringLiteral("/Ac/ConsumptionOnInput/NumberOfPhases"));
	invalidate(QStringLiteral("/Ac/Consumption/NumberOfPhases"));

	scheduleBatchFlush();
}

void MockTimerWorker::setPhaseSumConfig(int ruleId, const QString &targetPrefix,
	const QStringList &serviceUids, const QString &sourcePhasePattern,
	const QString &sourceCurrentPattern)
{
#if QT_CONFIG(thread)
	if (QThread::currentThread() != thread()) {
		const MockValueCache seed = snapshotUids(
				phaseSumSeedUids(serviceUids, sourcePhasePattern, sourceCurrentPattern));
		QMetaObject::invokeMethod(this, [this, ruleId, targetPrefix, serviceUids,
				sourcePhasePattern, sourceCurrentPattern, seed]() {
			absorbCache(seed);
			setPhaseSumConfig(ruleId, targetPrefix, serviceUids, sourcePhasePattern, sourceCurrentPattern);
		}, Qt::QueuedConnection);
		return;
	}
#else
	absorbCache(snapshotUids(phaseSumSeedUids(serviceUids, sourcePhasePattern, sourceCurrentPattern)));
#endif
	const QString prefix = normalizedMockUid(targetPrefix);
	QStringList services;
	services.reserve(serviceUids.size());
	for (const QString &uid : serviceUids) {
		const QString normalized = normalizedMockUid(uid);
		if (!normalized.isEmpty()) {
			services.append(normalized);
		}
	}
	const bool paused = m_pausedPhaseSums.contains(ruleId);
	if (m_phaseSumConfigs.contains(ruleId)) {
		const PhaseSumConfig &old = m_phaseSumConfigs[ruleId];
		const bool targetChanged = old.targetPrefix != prefix;
		if (targetChanged) {
			m_pausedPhaseSums.remove(ruleId);
		}
		// Do not write a removed target back. A later setValue() resumes it.
		if (!paused && (targetChanged || services.isEmpty()
				|| old.sourcePhasePattern != sourcePhasePattern
				|| old.sourceCurrentPattern != sourceCurrentPattern)) {
			invalidatePhaseSumValues(ruleId);
		}
	}
	if (services.isEmpty()) {
		m_phaseSumConfigs.remove(ruleId);
		m_pausedPhaseSums.remove(ruleId);
	} else {
		m_phaseSumConfigs[ruleId] = {prefix, services, sourcePhasePattern, sourceCurrentPattern};
	}
	if (!m_pausedPhaseSums.contains(ruleId)) {
		scheduleCalculatorFlush();
	}
}

void MockTimerWorker::clearPhaseSumConfig(int ruleId)
{
	if (postedToWorker(this, [this, ruleId]() { clearPhaseSumConfig(ruleId); })) {
		return;
	}
	if (!m_pausedPhaseSums.contains(ruleId)) {
		invalidatePhaseSumValues(ruleId);
	}
	m_pausedPhaseSums.remove(ruleId);
	m_phaseSumConfigs.remove(ruleId);
}

void MockTimerWorker::evaluatePhaseSums()
{
	for (auto it = m_phaseSumConfigs.constBegin(); it != m_phaseSumConfigs.constEnd(); ++it) {
		if (m_pausedPhaseSums.contains(it.key())) {
			continue;
		}
		const PhaseSumConfig &cfg = it.value();
		int maxPhaseIndex = -1;

		for (int phase = 1; phase <= 3; ++phase) {
			qreal powerSum = qQNaN();
			qreal currentSum = qQNaN();

			for (const QString &svcUid : cfg.serviceUids) {
				// Sum power
				const QString powerUid = svcUid + cfg.sourcePhasePattern.arg(phase);
				const QVariant pVal = readValue(powerUid);
				bool ok = false;
				const qreal p = pVal.toReal(&ok);
				if (ok && !qIsNaN(p)) {
					powerSum = qIsNaN(powerSum) ? p : (powerSum + p);
				}

				// Sum current
				if (!cfg.sourceCurrentPattern.isEmpty()) {
					const QString currentUid = svcUid + cfg.sourceCurrentPattern.arg(phase);
					const QVariant cVal = readValue(currentUid);
					const qreal c = cVal.toReal(&ok);
					if (ok && !qIsNaN(c)) {
						currentSum = qIsNaN(currentSum) ? c : (currentSum + c);
					}
				}
			}

			// Write power
			const QString targetPower = cfg.targetPrefix + QStringLiteral("/L%1/Power").arg(phase);
			const QVariant pv = qIsNaN(powerSum) ? QVariant() : QVariant(powerSum);
			if (readValue(targetPower) != pv) {
				writePending(targetPower, pv);
			}

			// Write current
			if (!cfg.sourceCurrentPattern.isEmpty()) {
				const QString targetCurrent = cfg.targetPrefix + QStringLiteral("/L%1/Current").arg(phase);
				const QVariant cv = qIsNaN(currentSum) ? QVariant() : QVariant(currentSum);
				if (readValue(targetCurrent) != cv) {
					writePending(targetCurrent, cv);
				}
			}

			// Count a phase when either requested measurement is present. Current-only
			// phases are still written above and must not be hidden by NumberOfPhases.
			const bool phaseHasCurrent = !cfg.sourceCurrentPattern.isEmpty() && !qIsNaN(currentSum);
			if (!qIsNaN(powerSum) || phaseHasCurrent) {
				maxPhaseIndex = qMax(maxPhaseIndex, phase - 1);
			}
		}

		// Write NumberOfPhases only if changed
		const QString nPhasesUid = cfg.targetPrefix + QStringLiteral("/NumberOfPhases");
		const QVariant nPhases = maxPhaseIndex >= 0 ? QVariant(maxPhaseIndex + 1) : QVariant();
		if (readValue(nPhasesUid) != nPhases) {
			writePending(nPhasesUid, nPhases);
		}
	}
}

void MockTimerWorker::invalidatePhaseSumValues(int ruleId)
{
	auto it = m_phaseSumConfigs.constFind(ruleId);
	if (it == m_phaseSumConfigs.constEnd()) {
		return;
	}

	const PhaseSumConfig &cfg = it.value();
	auto invalidate = [&](const QString &path) {
		writePending(path, QVariant());
	};

	for (int phase = 1; phase <= 3; ++phase) {
		invalidate(cfg.targetPrefix + QStringLiteral("/L%1/Power").arg(phase));
		if (!cfg.sourceCurrentPattern.isEmpty()) {
			invalidate(cfg.targetPrefix + QStringLiteral("/L%1/Current").arg(phase));
		}
	}
	invalidate(cfg.targetPrefix + QStringLiteral("/NumberOfPhases"));

	scheduleBatchFlush();
}
