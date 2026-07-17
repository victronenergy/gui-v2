/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "mocktimerworker.h"

#include <cmath>
#include <cstdint>
#include <limits>

#include <QtMath>

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

}

void MockTimerWorker::registerAnimator(const MockAnimatorConfig &config)
{
	MockAnimatorConfig stored = normalizedAnimatorConfig(config);

	// Publish the initial range direction before the timer starts. A dependent
	// followSignOf binding must not wait for this animator's first phase offset.
	if (stored.type == MockAnimatorConfig::RangeAnimator
			&& stored.actualStepSizes.size() < stored.uids.size()) {
		while (stored.actualStepSizes.size() < stored.uids.size()) {
			stored.actualStepSizes.append(stored.stepSize);
		}
		Q_EMIT actualStepSizesChanged(stored.animatorId, stored.actualStepSizes);
	}

	m_configs[stored.animatorId] = stored;

	// Seed the value cache with any initial values provided via updateValues() prior to this call.
	// (The GUI thread should have called updateValues() before registerAnimator().)

	// If globally active and not individually deactivated, start the timer immediately
	if (m_globalActive && !m_inactiveAnimators.contains(stored.animatorId)) {
		startAnimatorTimer(stored.animatorId);
	}
}

void MockTimerWorker::unregisterAnimator(int animatorId)
{
	stopAnimatorTimer(animatorId);
	m_configs.remove(animatorId);
	m_inactiveAnimators.remove(animatorId);
}

void MockTimerWorker::setAnimatorActive(int animatorId, bool active)
{
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

void MockTimerWorker::updateValue(const QString &uid, const QVariant &value)
{
	if (!uid.isEmpty()) {
		m_valueCache[normalizedMockUid(uid)] = value;
	}
}

void MockTimerWorker::observeExternalValue(const QString &uid, const QVariant &value)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return;
	}
	m_valueCache[normalized] = value;
	Q_EMIT externalValueObserved(normalized);
}

void MockTimerWorker::forgetUidPrefix(const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	if (!normalized.isEmpty()) {
		MockValueUpdateList kept;
		kept.reserve(m_pendingUpdates.size());
		for (const MockValueUpdate &update : m_pendingUpdates) {
			if (!mockUidUnderPrefix(update.first, normalized)) {
				kept.append(update);
			}
		}
		m_pendingUpdates = kept;

		const QList<int> animatorIds = m_configs.keys();
		for (int animatorId : animatorIds) {
			if (animatorWritesUnderPrefix(m_configs.value(animatorId), normalized)) {
				unregisterAnimator(animatorId);
			}
		}

		// Do not call invalidateConsumptionValues() or invalidatePhaseSumValues().
		// Those append null updates and call scheduleBatchFlush(). The applier
		// would then call VeQItemMockProducer::setValue(), which calls
		// itemGetOrCreate() and recreates the deleted service. Drop the config only.
		if (mockUidUnderPrefix(m_gaugesUidPrefix, normalized)) {
			m_gaugesAutoMax = false;
			m_gaugesUidPrefix.clear();
		}
		if (mockUidUnderPrefix(m_consumptionSystemPrefix, normalized)) {
			m_consumptionSystemPrefix.clear();
			m_consumptionServices.clear();
			m_gaugesAutoMax = false;
			m_gaugesUidPrefix.clear();
		}
		const QList<int> ruleIds = m_phaseSumConfigs.keys();
		for (int ruleId : ruleIds) {
			if (mockUidUnderPrefix(m_phaseSumConfigs.value(ruleId).targetPrefix, normalized)) {
				m_phaseSumConfigs.remove(ruleId);
			}
		}

		// Drop notifies whose writes were stripped or whose animator was stopped.
		// Leaving them in the batch would emit notifyUpdate/notifyTotal with no setValue().
		MockNotifyEventList keptNotifications;
		keptNotifications.reserve(m_pendingNotifications.size());
		for (const MockNotifyEvent &event : m_pendingNotifications) {
			if (!m_configs.contains(event.animatorId)) {
				continue;
			}
			bool dropped = false;
			for (const QString &dep : event.dependsOn) {
				if (mockUidUnderPrefix(dep, normalized)) {
					dropped = true;
					break;
				}
			}
			if (!dropped) {
				keptNotifications.append(event);
			}
		}
		m_pendingNotifications = keptNotifications;
	}
	// Ack only after writers for this prefix are stopped. An earlier
	// uidPrefixForgotten() lets a later tick's valuesReady() recreate the service.
	Q_EMIT uidPrefixForgotten(normalized);
}

void MockTimerWorker::updateAnimatorActualStepSizes(int animatorId, const QVector<qreal> &stepSizes)
{
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

void MockTimerWorker::updateValues(const MockValueCache &values)
{
	for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
		if (!it.key().isEmpty()) {
			m_valueCache[normalizedMockUid(it.key())] = it.value();
		}
	}
}

void MockTimerWorker::updateAnimatorFollowSignOf(int animatorId, qreal followSignOf)
{
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

	if (!config.repeat) {
		stopAnimatorTimer(animatorId);
	}

	scheduleBatchFlush();
}

void MockTimerWorker::startAnimatorTimer(int animatorId, bool applyPhase)
{
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
	QStringList tickDepends;
	const bool hasDerived = !config.derivedTargetUids.isEmpty()
		&& config.derivedTargetUids.size() == config.uids.size()
		&& config.derivedDivisorUids.size() == config.uids.size();
	const bool hasMultiply = !config.derivedMultiplyTargetUids.isEmpty()
		&& config.derivedMultiplyTargetUids.size() == config.uids.size()
		&& config.derivedMultiplierUids.size() == config.uids.size();

	for (qsizetype i = 0; i < config.uids.size(); ++i) {
		const QString &uid = config.uids[i];
		const QVariant cached = m_valueCache.value(uid);

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

		// Update our local cache
		m_valueCache[uid] = newValue;

		m_pendingUpdates.append({uid, QVariant(newValue)});
		total += newValue;
		QStringList itemDepends;
		itemDepends.append(uid);

		// Compute derived value (e.g. current = power / voltage)
		if (hasDerived && !config.derivedTargetUids[i].isEmpty()) {
			const QString &divisorUid = config.derivedDivisorUids[i];
			const QVariant divisorVal = m_valueCache.value(divisorUid);
			bool divOk = false;
			const qreal divisor = divisorVal.toReal(&divOk);
			if (divOk && divisor > 0.0) {
				const qreal derived = newValue / divisor;
				const QString &targetUid = config.derivedTargetUids[i];
				m_valueCache[targetUid] = derived;
				m_pendingUpdates.append({targetUid, QVariant(derived)});
				itemDepends.append(targetUid);
			}
		}

		// Compute multiply derived value (e.g. power = current * voltage)
		if (hasMultiply && !config.derivedMultiplyTargetUids[i].isEmpty()) {
			const QString &multiplierUid = config.derivedMultiplierUids[i];
			const QVariant multiplierVal = m_valueCache.value(multiplierUid);
			bool mulOk = false;
			const qreal multiplier = multiplierVal.toReal(&mulOk);
			if (mulOk) {
				const qreal derived = newValue * multiplier;
				const QString &targetUid = config.derivedMultiplyTargetUids[i];
				m_valueCache[targetUid] = derived;
				m_pendingUpdates.append({targetUid, QVariant(derived)});
				itemDepends.append(targetUid);
				multiplyTotal += derived;
			}
		}

		tickDepends.append(itemDepends);
		// The applier emits this after setValue() for itemDepends. Do not Q_EMIT
		// notifyUpdate here: that runs the QML handler before setValue().
		m_pendingNotifications.append(notifyEvent(
				MockNotifyEvent::Update, config.animatorId, static_cast<int>(i),
				newValue, itemDepends));
	}

	// Write total to target uid if configured
	if (!config.totalTargetUid.isEmpty()) {
		m_valueCache[config.totalTargetUid] = total;
		m_pendingUpdates.append({config.totalTargetUid, QVariant(total)});
		tickDepends.append(config.totalTargetUid);
	}

	// Write multiply-derived total if configured
	if (hasMultiply && !config.derivedMultiplyTotalTargetUid.isEmpty()) {
		m_valueCache[config.derivedMultiplyTotalTargetUid] = multiplyTotal;
		m_pendingUpdates.append({config.derivedMultiplyTotalTargetUid, QVariant(multiplyTotal)});
		tickDepends.append(config.derivedMultiplyTotalTargetUid);
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
	QStringList tickDepends;
	const bool hasDerived = !config.derivedTargetUids.isEmpty()
		&& config.derivedTargetUids.size() == config.uids.size()
		&& config.derivedDivisorUids.size() == config.uids.size();
	const bool hasMultiply = !config.derivedMultiplyTargetUids.isEmpty()
		&& config.derivedMultiplyTargetUids.size() == config.uids.size()
		&& config.derivedMultiplierUids.size() == config.uids.size();

	for (qsizetype i = 0; i < config.uids.size(); ++i) {
		const QString &uid = config.uids[i];
		const QVariant cached = m_valueCache.value(uid);

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

		// Update our local cache
		m_valueCache[uid] = newValue;

		m_pendingUpdates.append({uid, QVariant(newValue)});
		total += newValue;
		tickDepends.append(uid);

		// Compute derived value (e.g. current = power / voltage)
		if (hasDerived && !config.derivedTargetUids[i].isEmpty()) {
			const QString &divisorUid = config.derivedDivisorUids[i];
			const QVariant divisorVal = m_valueCache.value(divisorUid);
			bool divOk = false;
			const qreal divisor = divisorVal.toReal(&divOk);
			if (divOk && divisor > 0.0) {
				const qreal derived = newValue / divisor;
				const QString &targetUid = config.derivedTargetUids[i];
				m_valueCache[targetUid] = derived;
				m_pendingUpdates.append({targetUid, QVariant(derived)});
				tickDepends.append(targetUid);
			}
		}

		// Compute multiply derived value (e.g. power = current * voltage)
		if (hasMultiply && !config.derivedMultiplyTargetUids[i].isEmpty()) {
			const QString &multiplierUid = config.derivedMultiplierUids[i];
			const QVariant multiplierVal = m_valueCache.value(multiplierUid);
			bool mulOk = false;
			const qreal multiplier = multiplierVal.toReal(&mulOk);
			if (mulOk) {
				const qreal derived = newValue * multiplier;
				const QString &targetUid = config.derivedMultiplyTargetUids[i];
				m_valueCache[targetUid] = derived;
				m_pendingUpdates.append({targetUid, QVariant(derived)});
				tickDepends.append(targetUid);
				multiplyTotal += derived;
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

	// Write total to target uid if configured
	if (!config.totalTargetUid.isEmpty()) {
		m_valueCache[config.totalTargetUid] = total;
		m_pendingUpdates.append({config.totalTargetUid, QVariant(total)});
		tickDepends.append(config.totalTargetUid);
	}

	// Write multiply-derived total if configured
	if (hasMultiply && !config.derivedMultiplyTotalTargetUid.isEmpty()) {
		m_valueCache[config.derivedMultiplyTotalTargetUid] = multiplyTotal;
		m_pendingUpdates.append({config.derivedMultiplyTotalTargetUid, QVariant(multiplyTotal)});
		tickDepends.append(config.derivedMultiplyTotalTargetUid);
	}

	// The applier emits this after setValue() for every uid in tickDepends.
	// Do not Q_EMIT notifyTotal here: that runs the QML handler before setValue().
	m_pendingNotifications.append(notifyEvent(
			MockNotifyEvent::Total, config.animatorId, -1, total, tickDepends));

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

void MockTimerWorker::scheduleCalculatorFlush()
{
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

	// Evaluate consumption after all animator ticks have updated the cache
	if (!m_consumptionServices.isEmpty()) {
		evaluateConsumption();
	}

	// Evaluate phase sum aggregations
	if (!m_phaseSumConfigs.isEmpty()) {
		evaluatePhaseSums();
	}

	if (!m_pendingUpdates.isEmpty() || !m_pendingNotifications.isEmpty()) {
		Q_EMIT valuesReady(m_pendingUpdates, m_pendingNotifications);
		m_pendingUpdates.clear();
		m_pendingNotifications.clear();
	}
}

void MockTimerWorker::processStepper(MockAnimatorConfig &config)
{
	for (qsizetype i = 0; i < config.uids.size(); ++i) {
		const QString &uid = config.uids[i];
		const QVariant cached = m_valueCache.value(uid);

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

		m_valueCache[uid] = newValue;
		m_pendingUpdates.append({uid, QVariant(newValue)});
	}
}

void MockTimerWorker::processToggler(MockAnimatorConfig &config)
{
	for (const QString &uid : config.uids) {
		const QVariant cached = m_valueCache.value(uid);
		const QVariant newValue = (cached == config.toggleA) ? config.toggleB : config.toggleA;
		m_valueCache[uid] = newValue;
		m_pendingUpdates.append({uid, newValue});
	}
}

void MockTimerWorker::setConsumptionConfig(const QString &systemUidPrefix,
	const MockConsumptionConfig &services, bool gaugesAutoMax, const QString &gaugesUidPrefix,
	const MockValueCache &currentValues)
{
	// evaluateConsumption() reads this copy. The live values were written before this call.
	updateValues(currentValues);
	const QString prefix = normalizedMockUid(systemUidPrefix);
	MockConsumptionConfig normalized = services;
	for (MockConsumptionServiceInfo &svc : normalized) {
		svc.uid = normalizedMockUid(svc.uid);
	}
	if (normalized.isEmpty()
			|| (!m_consumptionSystemPrefix.isEmpty() && m_consumptionSystemPrefix != prefix)) {
		invalidateConsumptionValues();
	}
	m_consumptionSystemPrefix = prefix;
	m_consumptionServices = normalized;
	m_gaugesAutoMax = gaugesAutoMax;
	m_gaugesUidPrefix = normalizedMockUid(gaugesUidPrefix);
	scheduleCalculatorFlush();
}

void MockTimerWorker::clearConsumptionConfig()
{
	invalidateConsumptionValues();
	m_consumptionSystemPrefix.clear();
	m_consumptionServices.clear();
	m_gaugesAutoMax = false;
	m_gaugesUidPrefix.clear();
}

void MockTimerWorker::evaluateConsumption()
{
	if (m_consumptionSystemPrefix.isEmpty() || m_consumptionServices.isEmpty()) {
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
				servicePhaseCount = m_valueCache.value(phaseCountUid).toInt(&limitPhases);
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
				const QVariant inPVal = m_valueCache.value(inPowerUid);
				bool ok = false;
				const qreal p = inPVal.toReal(&ok);
				if (ok && !qIsNaN(p)) {
					phaseAcInPower = qIsNaN(phaseAcInPower) ? p : (phaseAcInPower + p);
				}

				const QString inCurrentUid = acInPrefix + phaseStr + currentKey;
				const QVariant inIVal = m_valueCache.value(inCurrentUid);
				const qreal c = inIVal.toReal(&ok);
				if (ok && !qIsNaN(c)) {
					phaseAcInCurrent = qIsNaN(phaseAcInCurrent) ? c : (phaseAcInCurrent + c);
				}
			}

			// Sum AC-out power/current
			if (!acOutPrefix.isEmpty()) {
				const QString outPowerUid = acOutPrefix + phaseStr + powerKey;
				const QVariant outPVal = m_valueCache.value(outPowerUid);
				bool ok = false;
				const qreal p = outPVal.toReal(&ok);
				if (ok && !qIsNaN(p)) {
					phaseAcOutPower = qIsNaN(phaseAcOutPower) ? p : (phaseAcOutPower + p);
				}

				const QString outCurrentUid = acOutPrefix + phaseStr + currentKey;
				const QVariant outIVal = m_valueCache.value(outCurrentUid);
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
			if (m_valueCache.value(uid) != v) {
				m_valueCache[uid] = v;
				m_pendingUpdates.append({uid, v});
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
		if (m_valueCache.value(uid) != phaseCount) {
			m_valueCache[uid] = phaseCount;
			m_pendingUpdates.append({uid, phaseCount});
		}
	};
	writePhaseCount(QStringLiteral("/Ac/ConsumptionOnOutput/NumberOfPhases"));
	writePhaseCount(QStringLiteral("/Ac/ConsumptionOnInput/NumberOfPhases"));
	writePhaseCount(QStringLiteral("/Ac/Consumption/NumberOfPhases"));

	if (m_gaugesAutoMax && !m_gaugesUidPrefix.isEmpty()) {
		auto raiseGaugeMax = [this](const QString &path, qreal computed) {
			const QString uid = m_gaugesUidPrefix + path;
			bool ok = false;
			const qreal existing = m_valueCache.value(uid).toReal(&ok);
			const qreal floor = (ok && !qIsNaN(existing)) ? existing : 0.0;
			const qreal next = qMax(computed, floor);
			if (!ok || qIsNaN(existing) || next > existing) {
				m_valueCache[uid] = next;
				m_pendingUpdates.append({uid, QVariant(next)});
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
		m_valueCache.remove(prefix + path);
		m_pendingUpdates.append({prefix + path, QVariant()});
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
	const QString &sourceCurrentPattern, const MockValueCache &currentValues)
{
	// evaluatePhaseSums() reads this copy. The live values were written before this call.
	updateValues(currentValues);
	const QString prefix = normalizedMockUid(targetPrefix);
	QStringList services;
	services.reserve(serviceUids.size());
	for (const QString &uid : serviceUids) {
		const QString normalized = normalizedMockUid(uid);
		if (!normalized.isEmpty()) {
			services.append(normalized);
		}
	}
	if (m_phaseSumConfigs.contains(ruleId)) {
		const PhaseSumConfig &old = m_phaseSumConfigs[ruleId];
		if (old.targetPrefix != prefix || services.isEmpty()
				|| old.sourcePhasePattern != sourcePhasePattern
				|| old.sourceCurrentPattern != sourceCurrentPattern) {
			invalidatePhaseSumValues(ruleId);
		}
	}
	if (services.isEmpty()) {
		m_phaseSumConfigs.remove(ruleId);
	} else {
		m_phaseSumConfigs[ruleId] = {prefix, services, sourcePhasePattern, sourceCurrentPattern};
	}
	scheduleCalculatorFlush();
}

void MockTimerWorker::clearPhaseSumConfig(int ruleId)
{
	invalidatePhaseSumValues(ruleId);
	m_phaseSumConfigs.remove(ruleId);
}

void MockTimerWorker::evaluatePhaseSums()
{
	for (auto it = m_phaseSumConfigs.constBegin(); it != m_phaseSumConfigs.constEnd(); ++it) {
		const PhaseSumConfig &cfg = it.value();
		int maxPhaseIndex = -1;

		for (int phase = 1; phase <= 3; ++phase) {
			qreal powerSum = qQNaN();
			qreal currentSum = qQNaN();

			for (const QString &svcUid : cfg.serviceUids) {
				// Sum power
				const QString powerUid = svcUid + cfg.sourcePhasePattern.arg(phase);
				const QVariant pVal = m_valueCache.value(powerUid);
				bool ok = false;
				const qreal p = pVal.toReal(&ok);
				if (ok && !qIsNaN(p)) {
					powerSum = qIsNaN(powerSum) ? p : (powerSum + p);
				}

				// Sum current
				if (!cfg.sourceCurrentPattern.isEmpty()) {
					const QString currentUid = svcUid + cfg.sourceCurrentPattern.arg(phase);
					const QVariant cVal = m_valueCache.value(currentUid);
					const qreal c = cVal.toReal(&ok);
					if (ok && !qIsNaN(c)) {
						currentSum = qIsNaN(currentSum) ? c : (currentSum + c);
					}
				}
			}

			// Write power
			const QString targetPower = cfg.targetPrefix + QStringLiteral("/L%1/Power").arg(phase);
			const QVariant pv = qIsNaN(powerSum) ? QVariant() : QVariant(powerSum);
			if (m_valueCache.value(targetPower) != pv) {
				m_valueCache[targetPower] = pv;
				m_pendingUpdates.append({targetPower, pv});
			}

			// Write current
			if (!cfg.sourceCurrentPattern.isEmpty()) {
				const QString targetCurrent = cfg.targetPrefix + QStringLiteral("/L%1/Current").arg(phase);
				const QVariant cv = qIsNaN(currentSum) ? QVariant() : QVariant(currentSum);
				if (m_valueCache.value(targetCurrent) != cv) {
					m_valueCache[targetCurrent] = cv;
					m_pendingUpdates.append({targetCurrent, cv});
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
		if (m_valueCache.value(nPhasesUid) != nPhases) {
			m_valueCache[nPhasesUid] = nPhases;
			m_pendingUpdates.append({nPhasesUid, nPhases});
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
		m_valueCache.remove(path);
		m_pendingUpdates.append({path, QVariant()});
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
