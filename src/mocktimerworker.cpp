/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "mocktimerworker.h"
#include "mockmanager.h"
#include "mockvalueapplier.h"

#include <algorithm>
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

bool sameStep(qreal left, qreal right)
{
	return (qIsNaN(left) && qIsNaN(right)) || left == right;
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

bool animatorWritesUid(const MockAnimatorConfig &config, const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return false;
	}
	auto listed = [&normalized](const QString &candidate) {
		return normalizedMockUid(candidate) == normalized;
	};
	if (listed(config.totalTargetUid) || listed(config.derivedMultiplyTotalTargetUid)) {
		return true;
	}
	for (const QString &candidate : config.uids + config.derivedTargetUids
			+ config.derivedMultiplyTargetUids) {
		if (listed(candidate)) {
			return true;
		}
	}
	return false;
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

	// A tick may already have reversed direction. Keep that vector when this
	// register is only a step-size change. An explicit actualStepSizes assignment
	// is sent with explicitStepSizes and replaces it.
	const auto existing = m_configs.constFind(stored.animatorId);
	if (existing != m_configs.constEnd()
			&& stored.type == MockAnimatorConfig::RangeAnimator
			&& !stored.explicitStepSizes
			&& existing->actualStepSizes.size() == stored.uids.size()) {
		bool reversed = false;
		for (qreal step : existing->actualStepSizes) {
			if (!sameStep(step, existing->stepSize)) {
				reversed = true;
				break;
			}
		}
		if (reversed) {
			stored.actualStepSizes = existing->actualStepSizes;
		}
	}

	// Publish the initial range direction before the timer starts. A dependent
	// followSignOf binding must not wait for this animator's first phase offset.
	if (stored.type == MockAnimatorConfig::RangeAnimator
			&& stored.actualStepSizes.size() < stored.uids.size()) {
		while (stored.actualStepSizes.size() < stored.uids.size()) {
			stored.actualStepSizes.append(stored.stepSize);
		}
	}

	m_pausedAnimators.remove(stored.animatorId);
	m_pauseOutputs.remove(stored.animatorId);
	m_configs[stored.animatorId] = stored;
	// Queued handlers read the stored vector, so emit after it is assigned.
	if (stored.type == MockAnimatorConfig::RangeAnimator
			&& stored.actualStepSizes.size() == stored.uids.size()
			&& config.actualStepSizes != stored.actualStepSizes) {
		Q_EMIT actualStepSizesChanged(stored.animatorId, stored.actualStepSizes,
				stored.stepRevision);
	}

	// The first tick reads the producer. No snapshot is copied in.

	// If globally active and not individually deactivated, start the timer immediately
	if (m_globalActive && !m_inactiveAnimators.contains(stored.animatorId)) {
		startAnimatorTimer(stored.animatorId);
	}
}

void MockTimerWorker::replaceAnimator(const MockAnimatorConfig &config)
{
	const int animatorId = config.animatorId;
	if (!m_configs.contains(animatorId)) {
		registerAnimator(config);
		return;
	}

	// The tick was calculated with the old configuration. Drop it, including a
	// later tick that already read it. The registration itself stays.
	stopAnimatorTimer(animatorId);
	QSet<QString> dropped = dropPendingTicks({}, {animatorId});
	if (MockValueApplier *applier = MockManager::create()->valueApplier()) {
		dropped.unite(applier->dropAnimator(animatorId));
	}
	if (!dropped.isEmpty()) {
		MockManager::create()->propagateCancellation(dropped);
	}

	const QSet<QString> pausedOutputs = m_pauseOutputs.value(animatorId);
	registerAnimator(config);
	if (pausedOutputs.isEmpty() || !m_configs.contains(animatorId)) {
		return;
	}
	const MockAnimatorConfig stored = m_configs.value(animatorId);
	QSet<QString> still;
	for (const QString &output : pausedOutputs) {
		if (animatorWritesUid(stored, output)) {
			still.insert(output);
		}
	}
	if (still.isEmpty()) {
		return;
	}
	// registerAnimator() started a timer because it cleared the pause. Stop it
	// again. The outputs the new configuration still writes have not been restored.
	stopAnimatorTimer(animatorId);
	m_pausedAnimators.insert(animatorId);
	m_pauseOutputs[animatorId] = still;
}

void MockTimerWorker::unregisterAnimator(int animatorId)
{
	stopAnimatorTimer(animatorId);
	m_configs.remove(animatorId);
	m_inactiveAnimators.remove(animatorId);
	m_pausedAnimators.remove(animatorId);
	m_pauseOutputs.remove(animatorId);
	// A batched tick made with this config must not be applied, even if the same
	// id is registered again before the flush. Queued outputs of that tick go too,
	// including a later tick that already read them.
	QSet<QString> dropped = dropPendingTicks({});
	if (MockValueApplier *applier = MockManager::create()->valueApplier()) {
		dropped.unite(applier->dropAnimator(animatorId));
	}
	if (!dropped.isEmpty()) {
		MockManager::create()->propagateCancellation(dropped);
	}
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

QSet<QString> MockTimerWorker::forgetUidPrefix(const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	if (normalized.isEmpty()) {
		return {};
	}

	// Keep the config. Unregistering would leave the QML object thinking it is
	// still registered, so the same path would not resume.
	QSet<int> pausedNow;
	const QList<int> animatorIds = m_configs.keys();
	for (int animatorId : animatorIds) {
		if (animatorWritesUnderPrefix(m_configs.value(animatorId), normalized)) {
			pauseAnimator(animatorId, normalized);
			pausedNow.insert(animatorId);
		}
	}

	// Do not call invalidateConsumptionValues() or invalidatePhaseSumValues().
	// Those append null updates and call scheduleBatchFlush(). The applier
	// would then call VeQItemMockProducer::setValue(), which calls
	// itemGetOrCreate() and recreates the deleted service. Pause instead of
	// dropping the config, so a later setValue() can resume the same writer.
	// An ancestor of the target pauses the whole calculation. A removed output
	// under the target pauses only that output, so a later source change cannot
	// write it back while the other outputs still update.
	if (mockUidUnderPrefix(m_gaugesUidPrefix, normalized)) {
		m_gaugesPaused = true;
	} else {
		pauseMatchingOutputs(m_pausedGaugeOutputs, gaugeOutputUids(), normalized);
	}
	if (mockUidUnderPrefix(m_consumptionSystemPrefix, normalized)) {
		m_consumptionPaused = true;
	} else {
		pauseMatchingOutputs(m_pausedConsumptionOutputs, consumptionOutputUids(), normalized);
	}
	const QList<int> ruleIds = m_phaseSumConfigs.keys();
	for (int ruleId : ruleIds) {
		const PhaseSumConfig config = m_phaseSumConfigs.value(ruleId);
		if (mockUidUnderPrefix(config.targetPrefix, normalized)) {
			m_pausedPhaseSums.insert(ruleId);
		} else {
			pauseMatchingOutputs(m_pausedPhaseSumOutputs[ruleId],
					phaseSumOutputUids(config), normalized);
		}
	}

	// Drop every unflushed write under the removed path, and the whole tick that
	// produced it, including outputs outside that path. A tick that only read the
	// removed path is dropped too: its outputs were calculated from a value that
	// is about to disappear.
	QSet<QString> dropped;
	for (const MockValueUpdate &update : m_pendingUpdates) {
		if (mockUidUnderPrefix(update.first, normalized)) {
			dropped.insert(update.first);
		}
	}
	for (const PendingTick &tick : m_pendingTicks) {
		const QStringList touched = tick.inputs + tick.outputs;
		for (const QString &uid : touched) {
			if (mockUidUnderPrefix(uid, normalized)) {
				dropped.insert(uid);
			}
		}
	}
	return dropPendingTicks(dropped, pausedNow);
}

void MockTimerWorker::noteUidWritten(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return;
	}

	bool flush = false;
	if (m_consumptionPaused && mockUidUnderPrefix(normalized, m_consumptionSystemPrefix)) {
		m_consumptionPaused = false;
		flush = true;
	}
	if (restorePausedOutputs(m_pausedConsumptionOutputs, normalized)) {
		flush = true;
	}
	if (m_gaugesPaused && mockUidUnderPrefix(normalized, m_gaugesUidPrefix)) {
		m_gaugesPaused = false;
		flush = true;
	}
	if (restorePausedOutputs(m_pausedGaugeOutputs, normalized)) {
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
	const QList<int> partialRules = m_pausedPhaseSumOutputs.keys();
	for (int ruleId : partialRules) {
		auto it = m_pausedPhaseSumOutputs.find(ruleId);
		if (it == m_pausedPhaseSumOutputs.end()) {
			continue;
		}
		if (!restorePausedOutputs(it.value(), normalized)) {
			continue;
		}
		flush = true;
		if (it.value().isEmpty()) {
			m_pausedPhaseSumOutputs.erase(it);
		}
	}
	if (flush) {
		scheduleCalculatorFlush();
	}

	// Resume only a removed output, not a surviving output of the same animator.
	// Every removed output must be written again. Restoring one must not
	// recreate the others.
	const QList<int> animatorIds = m_pausedAnimators.values();
	for (int animatorId : animatorIds) {
		if (!m_configs.contains(animatorId)) {
			m_pauseOutputs.remove(animatorId);
			m_pausedAnimators.remove(animatorId);
			continue;
		}
		auto outputs = m_pauseOutputs.find(animatorId);
		if (outputs == m_pauseOutputs.end() || outputs->isEmpty()) {
			continue;
		}
		bool restored = false;
		QSet<QString> remaining;
		for (const QString &output : *outputs) {
			// The write covers this output, or this output is under the write.
			// A sibling under the same removed service does not match.
			if (output == normalized || mockUidUnderPrefix(output, normalized)) {
				restored = true;
			} else {
				remaining.insert(output);
			}
		}
		if (!restored) {
			continue;
		}
		if (!remaining.isEmpty()) {
			*outputs = remaining;
			continue;
		}
		m_pauseOutputs.erase(outputs);
		m_pausedAnimators.remove(animatorId);
		if (m_globalActive && !m_inactiveAnimators.contains(animatorId)
				&& m_configs.contains(animatorId)) {
			startAnimatorTimer(animatorId);
		}
	}
}

void MockTimerWorker::updateAnimatorActualStepSizes(int animatorId, const QVector<qreal> &stepSizes,
		quint64 revision)
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
	// The revision makes a reversal queued before this assignment obsolete.
	it->actualStepSizes = stepSizes;
	it->stepRevision = revision;
}

QVariant MockTimerWorker::readValue(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return {};
	}
	// While a calculator is running, remember every uid it used. A later
	// write of one of them must drop the aggregate, not only this read.
	// A comparison of this calculator's own output must use
	// readComparedOutput(). Recording that read would make a replacement
	// inherit the previous calculation's sources.
	if (m_recordingInputs && !m_recordingInputs->contains(normalized)) {
		m_recordingInputs->append(normalized);
	}
	return readStoredValue(normalized);
}

QVariant MockTimerWorker::readComparedOutput(const QString &uid)
{
	return readStoredValue(normalizedMockUid(uid));
}

QVariant MockTimerWorker::readStoredValue(const QString &normalized)
{
	if (normalized.isEmpty()) {
		return {};
	}
	for (qsizetype i = m_pendingUpdates.size() - 1; i >= 0; --i) {
		if (m_pendingUpdates.at(i).first == normalized) {
			return m_pendingUpdates.at(i).second;
		}
	}
	if (MockValueApplier *applier = MockManager::create()->valueApplier()) {
		QVariant queued;
		if (applier->pendingValue(normalized, &queued)) {
			return queued;
		}
	}
	return MockManager::create()->value(normalized);
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
			// A later write in this batch replaces the value an older notify
			// named. Drop that notify. The replacement's notify is appended
			// after this write, so it is kept. The same value does not drop it.
			if (update.second != value) {
				m_pendingNotifications.removeIf([&normalized](const MockNotifyEvent &event) {
					for (const QString &dep : event.dependsOn) {
						if (normalizedMockUid(dep) == normalized) {
							return true;
						}
					}
					return false;
				});
			}
			update.second = value;
			return;
		}
	}
	m_pendingUpdates.append({normalized, value});
}

void MockTimerWorker::writeComparedOutput(const QString &uid, const QVariant &value)
{
	if (readComparedOutput(uid) != value) {
		writePending(uid, value);
		return;
	}
	// Already the stored result. Do not write it again. A value that has been
	// applied has no queued dependency to refresh. A value still waiting must
	// move to this calculation, or a removed input cancels it and nothing reruns.
	if (!m_recordingOutputs) {
		return;
	}
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty() || m_recordingOutputs->contains(normalized)) {
		return;
	}
	for (const MockValueUpdate &update : m_pendingUpdates) {
		if (update.first == normalized) {
			m_recordingOutputs->append(normalized);
			return;
		}
	}
	if (MockValueApplier *applier = MockManager::create()->valueApplier()) {
		if (applier->pendingValue(normalized, nullptr)) {
			m_recordingOutputs->append(normalized);
		}
	}
}

void MockTimerWorker::processTick(MockAnimatorConfig &config)
{
	PendingTick tick;
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

QSet<QString> MockTimerWorker::dropPendingTicks(QSet<QString> dropped, const QSet<int> &dropAnimators)
{
	// Drop every tick that read or wrote a dropped uid, whose animator was paused
	// for a removed path, or whose animator is gone. Its outputs are dropped too,
	// including earlier writes of the same uid, so repeat until nothing more drops.
	// A calculator tick has no animator. Do not drop it just because that id is
	// missing; only a cancelled input or output should.
	const QSet<QString> seed = dropped;
	QSet<int> droppedAnimators;
	for (bool changed = true; changed;) {
		changed = false;
		for (auto it = m_pendingTicks.begin(); it != m_pendingTicks.end();) {
			bool drop = false;
			if (!it->calculator) {
				drop = dropAnimators.contains(it->animatorId)
						|| !m_configs.contains(it->animatorId);
			}
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
				if (!it->calculator) {
					droppedAnimators.insert(it->animatorId);
				}
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
	QSet<QString> extra;
	for (const QString &uid : dropped) {
		if (!seed.contains(uid)) {
			extra.insert(uid);
		}
	}
	return extra;
}

QSet<QString> MockTimerWorker::dropPendingUpdate(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return {};
	}
	// A tick that wrote uid, or computed something from it, is dropped whole.
	return dropPendingTicks({normalized});
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

void MockTimerWorker::pauseAnimator(int animatorId, const QString &prefix)
{
	const QString normalized = normalizedMockUid(prefix);
	if (normalized.isEmpty() || !m_configs.contains(animatorId)) {
		stopAnimatorTimer(animatorId);
		m_pausedAnimators.insert(animatorId);
		return;
	}
	MockValueApplier *values = MockManager::create()->valueApplier();
	const MockAnimatorConfig &config = m_configs[animatorId];
	bool added = false;
	auto queuedWrite = [this, values](const QString &output) {
		for (const MockValueUpdate &update : m_pendingUpdates) {
			if (update.first == output) {
				return true;
			}
		}
		return values && values->pendingValue(output, nullptr);
	};
	// generated: a path the tick writes even when it has no value yet. That is
	// a derived destination, a total, or a toggler uid. A numeric input with
	// no value is skipped, so it is not required, including an empty item
	// created by a binding.
	auto consider = [this, values, animatorId, &normalized, &added, &queuedWrite](
			const QString &uid, bool generated) {
		const QString output = normalizedMockUid(uid);
		if (!uidWritesUnderPrefix(output, normalized)) {
			return;
		}
		if (values && values->hadValue(output)) {
			m_pauseOutputs[animatorId].insert(output);
			added = true;
			return;
		}
		if (!generated) {
			return;
		}
		// The removal drops this waiting write. The next tick would create the
		// item unless the output stays paused. A generated path with no value
		// and no waiting write is not required, so restoring the inputs that
		// did exist still resumes the animator.
		if (!queuedWrite(output)) {
			return;
		}
		m_pauseOutputs[animatorId].insert(output);
		added = true;
	};
	for (const QString &uid : config.uids) {
		// A toggler writes this uid even when the path is missing. A numeric
		// input does not.
		consider(uid, config.type == MockAnimatorConfig::Toggler);
	}
	consider(config.totalTargetUid, true);
	consider(config.derivedMultiplyTotalTargetUid, true);
	for (const QString &uid : config.derivedTargetUids) {
		consider(uid, true);
	}
	for (const QString &uid : config.derivedMultiplyTargetUids) {
		consider(uid, true);
	}
	if (!added && m_pauseOutputs.value(animatorId).isEmpty()) {
		return;
	}
	stopAnimatorTimer(animatorId);
	m_pausedAnimators.insert(animatorId);
}

void MockTimerWorker::releaseOutputOwnership(const QSet<QString> &uids)
{
	if (uids.isEmpty()) {
		return;
	}
	for (auto it = m_pendingTicks.begin(); it != m_pendingTicks.end();) {
		QStringList kept;
		bool removed = false;
		for (const QString &output : it->outputs) {
			if (uids.contains(normalizedMockUid(output))) {
				removed = true;
			} else {
				kept.append(output);
			}
		}
		if (!removed) {
			++it;
			continue;
		}
		it->outputs = kept;
		if (it->outputs.isEmpty()) {
			it = m_pendingTicks.erase(it);
		} else {
			++it;
		}
	}
	if (MockValueApplier *applier = MockManager::create()->valueApplier()) {
		applier->retireOutputOwnership(uids);
	}
}

void MockTimerWorker::cancelPendingGaugeWrites()
{
	const QStringList gauges = gaugeOutputUids();
	if (gauges.isEmpty()) {
		return;
	}
	const QSet<QString> uids(gauges.cbegin(), gauges.cend());
	m_pendingUpdates.removeIf([&uids](const MockValueUpdate &update) {
		return uids.contains(update.first);
	});
	releaseOutputOwnership(uids);
	if (MockValueApplier *applier = MockManager::create()->valueApplier()) {
		applier->discardQueuedValues(uids);
	}
}

QStringList MockTimerWorker::consumptionOutputUids() const
{
	QStringList uids;
	if (m_consumptionSystemPrefix.isEmpty()) {
		return uids;
	}
	const QString prefix = m_consumptionSystemPrefix;
	for (int phase = 1; phase <= 3; ++phase) {
		const QString ps = QStringLiteral("/L") + QString::number(phase);
		uids.append(prefix + QStringLiteral("/Ac/ConsumptionOnInput") + ps + QStringLiteral("/Power"));
		uids.append(prefix + QStringLiteral("/Ac/ConsumptionOnInput") + ps + QStringLiteral("/Current"));
		uids.append(prefix + QStringLiteral("/Ac/ConsumptionOnOutput") + ps + QStringLiteral("/Power"));
		uids.append(prefix + QStringLiteral("/Ac/ConsumptionOnOutput") + ps + QStringLiteral("/Current"));
		uids.append(prefix + QStringLiteral("/Ac/Consumption") + ps + QStringLiteral("/Power"));
		uids.append(prefix + QStringLiteral("/Ac/Consumption") + ps + QStringLiteral("/Current"));
	}
	uids.append(prefix + QStringLiteral("/Ac/ConsumptionOnOutput/NumberOfPhases"));
	uids.append(prefix + QStringLiteral("/Ac/ConsumptionOnInput/NumberOfPhases"));
	uids.append(prefix + QStringLiteral("/Ac/Consumption/NumberOfPhases"));
	return uids;
}

QStringList MockTimerWorker::gaugeOutputUids() const
{
	QStringList uids;
	if (m_gaugesUidPrefix.isEmpty()) {
		return uids;
	}
	const QStringList paths = consumptionGaugePaths();
	uids.reserve(paths.size());
	for (const QString &path : paths) {
		uids.append(m_gaugesUidPrefix + path);
	}
	return uids;
}

QStringList MockTimerWorker::phaseSumOutputUids(const PhaseSumConfig &config) const
{
	QStringList uids;
	if (config.targetPrefix.isEmpty()) {
		return uids;
	}
	for (int phase = 1; phase <= 3; ++phase) {
		uids.append(config.targetPrefix + QStringLiteral("/L%1/Power").arg(phase));
		if (!config.sourceCurrentPattern.isEmpty()) {
			uids.append(config.targetPrefix + QStringLiteral("/L%1/Current").arg(phase));
		}
	}
	uids.append(config.targetPrefix + QStringLiteral("/NumberOfPhases"));
	return uids;
}

void MockTimerWorker::pauseMatchingOutputs(QSet<QString> &paused, const QStringList &outputs,
		const QString &removedPrefix)
{
	for (const QString &output : outputs) {
		if (mockUidUnderPrefix(output, removedPrefix)) {
			paused.insert(normalizedMockUid(output));
		}
	}
}

bool MockTimerWorker::restorePausedOutputs(QSet<QString> &paused, const QString &written)
{
	if (paused.isEmpty()) {
		return false;
	}
	bool restored = false;
	QSet<QString> remaining;
	for (const QString &output : paused) {
		if (output == written || mockUidUnderPrefix(output, written)) {
			restored = true;
		} else {
			remaining.insert(output);
		}
	}
	if (restored) {
		paused = remaining;
	}
	return restored;
}

void MockTimerWorker::startAnimatorTimer(int animatorId, bool applyPhase)
{
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
		Q_EMIT actualStepSizesChanged(config.animatorId, config.actualStepSizes,
				config.stepRevision);
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
	writePending(uid, value);
	scheduleBatchFlush();
}

void MockTimerWorker::tickAnimatorsForTest()
{
	// In creation order, so a later animator can read an earlier one's outputs.
	// Skip a paused animator: this hook must not write a removed service.
	// Skip an inactive animator so a test can tick a later one on its own.
	QList<int> animatorIds = m_configs.keys();
	std::sort(animatorIds.begin(), animatorIds.end());
	for (int animatorId : animatorIds) {
		if (m_pausedAnimators.contains(animatorId)
				|| m_inactiveAnimators.contains(animatorId)) {
			continue;
		}
		auto it = m_configs.find(animatorId);
		if (it == m_configs.end()) {
			continue;
		}
		processTick(it.value());
	}
	scheduleBatchFlush();
}

void MockTimerWorker::flushPendingForTest()
{
	flushBatch();
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

	// Record what each calculation read and wrote, after animator ticks have
	// queued their writes. A later write can then drop the aggregate, not only
	// the animator value it was calculated from. Keep the two calculations apart
	// so cancelling one does not throw away the other.
	auto recordCalculation = [this](auto evaluate) {
		PendingTick tick;
		tick.calculator = true;
		m_recordingInputs = &tick.inputs;
		m_recordingOutputs = &tick.outputs;
		evaluate();
		m_recordingInputs = nullptr;
		m_recordingOutputs = nullptr;
		if (!tick.outputs.isEmpty()) {
			m_pendingTicks.append(tick);
		}
	};
	if (!m_consumptionServices.isEmpty()) {
		recordCalculation([this]() { evaluateConsumption(); });
	}
	if (!m_phaseSumConfigs.isEmpty()) {
		recordCalculation([this]() { evaluatePhaseSums(); });
	}

	// These writes are about to be queued. A later UI write must not treat them
	// as still unflushed. The applier drops any of them still waiting to be applied.
	MockTickRecordList ticks;
	ticks.reserve(m_pendingTicks.size());
	for (const PendingTick &tick : m_pendingTicks) {
		MockTickRecord record;
		record.animatorId = tick.animatorId;
		record.calculator = tick.calculator;
		record.inputs = tick.inputs;
		record.outputs = tick.outputs;
		ticks.append(record);
	}
	m_pendingTicks.clear();
	if (m_pendingUpdates.isEmpty() && m_pendingNotifications.isEmpty()) {
		// An equal recalculation writes nothing, but it may still claim outputs
		// that are waiting. Deliver that tick, or the old inputs keep them.
		if (!ticks.isEmpty()) {
			Q_EMIT valuesReady(MockValueUpdateList(), MockNotifyEventList(), ticks);
		}
		return;
	}
	// Copy first. valuesReady() is a direct connection, and setValue() can
	// drop pending updates while applyValues() is still reading this batch.
	const MockValueUpdateList updates = m_pendingUpdates;
	const MockNotifyEventList notifications = m_pendingNotifications;
	m_pendingUpdates.clear();
	m_pendingNotifications.clear();
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
	const QString prefix = normalizedMockUid(systemUidPrefix);
	MockConsumptionConfig normalized = services;
	for (MockConsumptionServiceInfo &svc : normalized) {
		svc.uid = normalizedMockUid(svc.uid);
	}
	const QString gauges = normalizedMockUid(gaugesUidPrefix);
	// A gauge increase already waiting must not be applied after auto-max is
	// turned off, or after the gauge prefix changes. Cancel it before either
	// assignment below, including the paused-system return.
	if ((m_gaugesAutoMax && !gaugesAutoMax) || gauges != m_gaugesUidPrefix) {
		cancelPendingGaugeWrites();
	}
	const bool sameSystem = !prefix.isEmpty() && prefix == m_consumptionSystemPrefix;
	// A removed system must not be written back just because a source was added.
	if (m_consumptionPaused && sameSystem) {
		m_consumptionServices = normalized;
		m_gaugesAutoMax = gaugesAutoMax;
		if (gauges != m_gaugesUidPrefix) {
			m_gaugesPaused = false;
			m_pausedGaugeOutputs.clear();
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
	if (gauges != m_gaugesUidPrefix) {
		m_pausedGaugeOutputs.clear();
		if (m_gaugesPaused) {
			m_gaugesPaused = false;
		}
	}
	m_consumptionSystemPrefix = prefix;
	m_consumptionServices = normalized;
	m_gaugesAutoMax = gaugesAutoMax;
	m_gaugesUidPrefix = gauges;
	scheduleCalculatorFlush();
}

void MockTimerWorker::clearConsumptionConfig()
{
	// A gauge increase already waiting must not be applied after the
	// calculator stops. Cancel it before the prefix or the flag changes.
	cancelPendingGaugeWrites();
	// Invalidation writes would recreate a service that was just removed.
	if (!m_consumptionPaused) {
		invalidateConsumptionValues();
	}
	m_consumptionPaused = false;
	m_gaugesPaused = false;
	m_pausedConsumptionOutputs.clear();
	m_pausedGaugeOutputs.clear();
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
			if (m_pausedConsumptionOutputs.contains(normalizedMockUid(uid))) {
				return;
			}
			writeComparedOutput(uid, v);
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
		if (m_pausedConsumptionOutputs.contains(normalizedMockUid(uid))) {
			return;
		}
		writeComparedOutput(uid, phaseCount);
	};
	writePhaseCount(QStringLiteral("/Ac/ConsumptionOnOutput/NumberOfPhases"));
	writePhaseCount(QStringLiteral("/Ac/ConsumptionOnInput/NumberOfPhases"));
	writePhaseCount(QStringLiteral("/Ac/Consumption/NumberOfPhases"));

	if (m_gaugesAutoMax && !m_gaugesPaused && !m_gaugesUidPrefix.isEmpty()) {
		auto raiseGaugeMax = [this](const QString &path, qreal computed) {
			const QString uid = m_gaugesUidPrefix + path;
			if (m_pausedGaugeOutputs.contains(normalizedMockUid(uid))) {
				return;
			}
			bool ok = false;
			const qreal existing = readComparedOutput(uid).toReal(&ok);
			// This calculation reached the stored maximum on its own. Do not
			// record that read. A waiting equal result must move to this
			// calculation, or a removed input keeps the old tick and a later
			// write cancels the replacement.
			if (!ok || qIsNaN(existing) || computed >= existing) {
				writeComparedOutput(uid, QVariant(qMax(computed, 0.0)));
				return;
			}
			// The stored maximum is higher. Recording that read makes a later
			// write of the floor cancel this calculation.
			readValue(uid);
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
	QSet<QString> clearing;
	auto invalidate = [&](const QString &path) {
		const QString uid = normalizedMockUid(prefix + path);
		if (m_pausedConsumptionOutputs.contains(uid)) {
			return;
		}
		clearing.insert(uid);
		writePending(uid, QVariant());
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

	// These writes replace queued values but are not a new tick. Drop the old
	// tick's claim on them, or a later write of an old input cancels the clear.
	releaseOutputOwnership(clearing);
	scheduleBatchFlush();
}

void MockTimerWorker::setPhaseSumConfig(int ruleId, const QString &targetPrefix,
	const QStringList &serviceUids, const QString &sourcePhasePattern,
	const QString &sourceCurrentPattern)
{
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
		// Do not write a removed target back. A later setValue() resumes it.
		// Invalidate while a removed leaf is still paused. Clearing that pause
		// first would write null and recreate the deleted path.
		if (!paused && (targetChanged || services.isEmpty()
				|| old.sourcePhasePattern != sourcePhasePattern
				|| old.sourceCurrentPattern != sourceCurrentPattern)) {
			invalidatePhaseSumValues(ruleId);
		}
		if (targetChanged) {
			m_pausedPhaseSums.remove(ruleId);
			m_pausedPhaseSumOutputs.remove(ruleId);
		}
	}
	if (services.isEmpty()) {
		m_phaseSumConfigs.remove(ruleId);
		m_pausedPhaseSums.remove(ruleId);
		m_pausedPhaseSumOutputs.remove(ruleId);
	} else {
		m_phaseSumConfigs[ruleId] = {prefix, services, sourcePhasePattern, sourceCurrentPattern};
	}
	if (!m_pausedPhaseSums.contains(ruleId)) {
		scheduleCalculatorFlush();
	}
}

void MockTimerWorker::clearPhaseSumConfig(int ruleId)
{
	if (!m_pausedPhaseSums.contains(ruleId)) {
		invalidatePhaseSumValues(ruleId);
	}
	m_pausedPhaseSums.remove(ruleId);
	m_pausedPhaseSumOutputs.remove(ruleId);
	m_phaseSumConfigs.remove(ruleId);
}

void MockTimerWorker::evaluatePhaseSums()
{
	for (auto it = m_phaseSumConfigs.constBegin(); it != m_phaseSumConfigs.constEnd(); ++it) {
		if (m_pausedPhaseSums.contains(it.key())) {
			continue;
		}
		const PhaseSumConfig &cfg = it.value();
		const QSet<QString> pausedOutputs = m_pausedPhaseSumOutputs.value(it.key());
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
			if (!pausedOutputs.contains(normalizedMockUid(targetPower))) {
				writeComparedOutput(targetPower, pv);
			}

			// Write current
			if (!cfg.sourceCurrentPattern.isEmpty()) {
				const QString targetCurrent = cfg.targetPrefix + QStringLiteral("/L%1/Current").arg(phase);
				const QVariant cv = qIsNaN(currentSum) ? QVariant() : QVariant(currentSum);
				if (!pausedOutputs.contains(normalizedMockUid(targetCurrent))) {
					writeComparedOutput(targetCurrent, cv);
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
		if (!pausedOutputs.contains(normalizedMockUid(nPhasesUid))) {
			writeComparedOutput(nPhasesUid, nPhases);
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
	const QSet<QString> pausedOutputs = m_pausedPhaseSumOutputs.value(ruleId);
	QSet<QString> clearing;
	auto invalidate = [&](const QString &path) {
		const QString uid = normalizedMockUid(path);
		if (pausedOutputs.contains(uid)) {
			return;
		}
		clearing.insert(uid);
		writePending(uid, QVariant());
	};

	for (int phase = 1; phase <= 3; ++phase) {
		invalidate(cfg.targetPrefix + QStringLiteral("/L%1/Power").arg(phase));
		if (!cfg.sourceCurrentPattern.isEmpty()) {
			invalidate(cfg.targetPrefix + QStringLiteral("/L%1/Current").arg(phase));
		}
	}
	invalidate(cfg.targetPrefix + QStringLiteral("/NumberOfPhases"));

	// These writes replace queued values but are not a new tick. Drop the old
	// tick's claim on them, or a later write of an old input cancels the clear.
	releaseOutputOwnership(clearing);
	scheduleBatchFlush();
}
