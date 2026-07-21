/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "mocktimerworker.h"

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

void MockTimerWorker::registerAnimator(const MockAnimatorConfig &config)
{
	// Store the config
	m_configs[config.animatorId] = config;

	// Seed the value cache with any initial values provided via updateValues() prior to this call.
	// (The GUI thread should have called updateValues() before registerAnimator().)

	// If globally active and not individually deactivated, start the timer immediately
	if (m_globalActive && !m_inactiveAnimators.contains(config.animatorId)) {
		startAnimatorTimer(config.animatorId);
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
	}
}

void MockTimerWorker::updateValue(const QString &uid, const QVariant &value)
{
	m_valueCache[uid] = value;
}

void MockTimerWorker::updateValues(const MockValueCache &values)
{
	for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
		m_valueCache[it.key()] = it.value();
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

void MockTimerWorker::startAnimatorTimer(int animatorId)
{
	if (m_animatorToTimer.contains(animatorId)) {
		return; // Already running
	}

	auto it = m_configs.find(animatorId);
	if (it == m_configs.end()) {
		return;
	}

	if (std::isnan(it->interval) || it->interval <= 0.0) {
		return; // Non-positive or invalid interval means disabled
	}
	const int interval = qMax(1, static_cast<int>(std::ceil(it->interval)));
	const int timerId = startTimer(interval);
	m_animatorToTimer[animatorId] = timerId;
	m_timerIdToAnimator[timerId] = animatorId;
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
}

void MockTimerWorker::processRandomizer(MockAnimatorConfig &config)
{
	qreal total = 0.0;
	qreal multiplyTotal = 0.0;
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
				multiplyTotal += derived;
			}
		}

		Q_EMIT notifyUpdate(config.animatorId, static_cast<int>(i), newValue);
	}

	// Write total to target uid if configured
	if (!config.totalTargetUid.isEmpty()) {
		m_valueCache[config.totalTargetUid] = total;
		m_pendingUpdates.append({config.totalTargetUid, QVariant(total)});
	}

	// Write multiply-derived total if configured
	if (hasMultiply && !config.derivedMultiplyTotalTargetUid.isEmpty()) {
		m_valueCache[config.derivedMultiplyTotalTargetUid] = multiplyTotal;
		m_pendingUpdates.append({config.derivedMultiplyTotalTargetUid, QVariant(multiplyTotal)});
	}

	Q_EMIT notifyTotal(config.animatorId, total);
}

void MockTimerWorker::processRangeAnimator(MockAnimatorConfig &config)
{
	if (config.rangeMax <= config.rangeMin) {
		stopAnimatorTimer(config.animatorId);
		return;
	}

	// Ensure step sizes are set for all UIDs
	while (config.actualStepSizes.size() < config.uids.size()) {
		config.actualStepSizes.append(config.stepSize);
	}

	qreal total = 0.0;
	qreal multiplyTotal = 0.0;
	bool stepSizesChanged = false;
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
	}

	// Write multiply-derived total if configured
	if (hasMultiply && !config.derivedMultiplyTotalTargetUid.isEmpty()) {
		m_valueCache[config.derivedMultiplyTotalTargetUid] = multiplyTotal;
		m_pendingUpdates.append({config.derivedMultiplyTotalTargetUid, QVariant(multiplyTotal)});
	}

	Q_EMIT notifyTotal(config.animatorId, total);

	if (stepSizesChanged) {
		Q_EMIT actualStepSizesChanged(config.animatorId, config.actualStepSizes);
	}
}

void MockTimerWorker::scheduleBatchFlush()
{
	// Use a zero-interval timer to flush at the end of the current event batch.
	// This coalesces all animator ticks that fire in the same event loop iteration
	// into a single valuesReady emission.
	if (m_flushTimerId == 0 && !m_pendingUpdates.isEmpty()) {
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

	if (!m_pendingUpdates.isEmpty()) {
		Q_EMIT valuesReady(m_pendingUpdates);
		m_pendingUpdates.clear();
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
	const MockConsumptionConfig &services)
{
	if (services.isEmpty()
			|| (!m_consumptionSystemPrefix.isEmpty() && m_consumptionSystemPrefix != systemUidPrefix)) {
		invalidateConsumptionValues();
	}
	m_consumptionSystemPrefix = systemUidPrefix;
	m_consumptionServices = services;
}

void MockTimerWorker::clearConsumptionConfig()
{
	invalidateConsumptionValues();
	m_consumptionSystemPrefix.clear();
	m_consumptionServices.clear();
}

void MockTimerWorker::evaluateConsumption()
{
	if (m_consumptionSystemPrefix.isEmpty() || m_consumptionServices.isEmpty()) {
		return;
	}

	int maxPhaseIndex = -1;

	for (int phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
		qreal phaseAcInPower = qQNaN();
		qreal phaseAcInCurrent = qQNaN();
		qreal phaseAcOutPower = qQNaN();
		qreal phaseAcOutCurrent = qQNaN();

		for (const auto &svc : m_consumptionServices) {
			// Determine AC-in bind prefix
			QString acInPrefix;
			if (svc.serviceType == QLatin1String("vebus")) {
				acInPrefix = svc.uid + QStringLiteral("/Ac/ActiveIn");
			} else if (svc.serviceType == QLatin1String("acsystem")) {
				acInPrefix = svc.uid + QStringLiteral("/Ac/In/") + QString::number(svc.index + 1);
			} else if (svc.serviceType == QLatin1String("charger")) {
				acInPrefix = svc.uid + QStringLiteral("/Ac/In");
			}
			// inverters have no AC-in

			// Determine AC-out bind prefix
			QString acOutPrefix;
			if (svc.serviceType != QLatin1String("charger")) {
				acOutPrefix = svc.uid + QStringLiteral("/Ac/Out");
			}

			// Power/current keys
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
	const QString &sourceCurrentPattern)
{
	if (m_phaseSumConfigs.contains(ruleId)) {
		const PhaseSumConfig &old = m_phaseSumConfigs[ruleId];
		if (old.targetPrefix != targetPrefix || serviceUids.isEmpty()
				|| old.sourcePhasePattern != sourcePhasePattern
				|| old.sourceCurrentPattern != sourceCurrentPattern) {
			invalidatePhaseSumValues(ruleId);
		}
	}
	if (serviceUids.isEmpty()) {
		m_phaseSumConfigs.remove(ruleId);
	} else {
		m_phaseSumConfigs[ruleId] = {targetPrefix, serviceUids, sourcePhasePattern, sourceCurrentPattern};
	}
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

			if (!qIsNaN(powerSum)) {
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
