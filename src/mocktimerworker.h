/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKTIMERWORKER_H
#define VICTRON_GUIV2_MOCKTIMERWORKER_H

#include <QHash>
#include <QObject>
#include <QPair>
#include <QRandomGenerator>
#include <QSet>
#include <QTimerEvent>
#include <QVariant>
#include <QVector>

namespace Victron {
namespace VenusOS {

class MockValueApplier;

using MockValueUpdate = QPair<QString, QVariant>;
using MockValueUpdateList = QVector<MockValueUpdate>;

// A QML notifyUpdate/notifyTotal to emit after the listed uids have been written.
// The worker queues these with the value batch. It must not emit the QML signals.
struct MockNotifyEvent {
	enum Type {
		Update,
		Total
	};
	int type = Update;
	int animatorId = -1;
	int index = -1;
	qreal value = 0.0;
	QStringList dependsOn;
};
using MockNotifyEventList = QVector<MockNotifyEvent>;

// One animator tick. The applier uses this to drop outputs still waiting to be
// applied when any uid the tick read or wrote is written or removed.
// upstreamAnimatorIds are writers whose queued output this tick read after that
// output moved to a newer tick. Unregistering them still drops this tick.
struct MockTickRecord {
	int animatorId = -1;
	// Consumption and phase sums have no animator. A missing animator id must
	// not drop this tick; only a cancelled input or output should.
	bool calculator = false;
	QStringList inputs;
	QStringList outputs;
	QVector<int> upstreamAnimatorIds;
};
using MockTickRecordList = QVector<MockTickRecord>;

// Configuration for consumption calculation
struct MockConsumptionServiceInfo {
	QString uid;
	QString serviceType;
	int index = 0;
};
using MockConsumptionConfig = QVector<MockConsumptionServiceInfo>;

// Producer paths omit a leading "mock/". QML service uids include it.
inline QString normalizedMockUid(const QString &uid)
{
	return uid.startsWith(QLatin1String("mock/")) ? uid.mid(5) : uid;
}

// Exact uid, or a descendant. prefix + "0" is a sibling, not a descendant.
inline bool mockUidUnderPrefix(const QString &uid, const QString &prefix)
{
	const QString normalized = normalizedMockUid(uid);
	const QString normalizedPrefix = normalizedMockUid(prefix);
	if (normalized.isEmpty() || normalizedPrefix.isEmpty()) {
		return false;
	}
	return normalized == normalizedPrefix
			|| normalized.startsWith(normalizedPrefix + QLatin1Char('/'));
}

inline QString consumptionAcInPrefix(const QString &uid, const QString &serviceType, int index)
{
	if (serviceType == QLatin1String("vebus")) {
		return uid + QStringLiteral("/Ac/ActiveIn");
	}
	if (serviceType == QLatin1String("acsystem")) {
		return uid + QStringLiteral("/Ac/In/") + QString::number(index + 1);
	}
	if (serviceType == QLatin1String("charger")) {
		return uid + QStringLiteral("/Ac/In");
	}
	return QString();
}

inline QString consumptionAcOutPrefix(const QString &uid, const QString &serviceType)
{
	if (serviceType == QLatin1String("charger")) {
		return QString();
	}
	return uid + QStringLiteral("/Ac/Out");
}

inline void appendPhaseMeasureUids(QStringList &uids, const QString &prefix)
{
	if (prefix.isEmpty()) {
		return;
	}
	for (int phase = 1; phase <= 3; ++phase) {
		const QString phasePath = prefix + QStringLiteral("/L%1").arg(phase);
		uids.append(phasePath + QStringLiteral("/P"));
		uids.append(phasePath + QStringLiteral("/I"));
	}
}

inline QStringList consumptionGaugePaths()
{
	return {
		QStringLiteral("/Ac/AcIn1/Consumption/Current/Max"),
		QStringLiteral("/Ac/AcIn2/Consumption/Current/Max"),
		QStringLiteral("/Ac/NoAcIn/Consumption/Current/Max"),
	};
}

inline void appendPhaseSumSourceUids(QStringList &uids, const QStringList &serviceUids,
		const QString &powerPattern, const QString &currentPattern)
{
	for (const QString &serviceUid : serviceUids) {
		if (serviceUid.isEmpty()) {
			continue;
		}
		for (int phase = 1; phase <= 3; ++phase) {
			if (!powerPattern.isEmpty()) {
				uids.append(serviceUid + powerPattern.arg(phase));
			}
			if (!currentPattern.isEmpty()) {
				uids.append(serviceUid + currentPattern.arg(phase));
			}
		}
	}
}

struct MockAnimatorConfig {
	int animatorId = 0;
	enum Type { Randomizer, RangeAnimator, Stepper, Toggler } type = Randomizer;
	QStringList uids;
	qreal interval = 1000.0;
	bool repeat = true;

	// Randomizer params
	qreal deltaLow = qQNaN();
	qreal deltaHigh = qQNaN();
	qreal minimumValue = qQNaN();
	qreal maximumValue = qQNaN();
	qreal followSignOf = qQNaN();

	// RangeAnimator params
	qreal stepSize = 1.0;
	qreal rangeMin = 0.0;
	qreal rangeMax = 100.0;
	QVector<qreal> actualStepSizes;
	// True when QML assigned actualStepSizes. A later register must keep that
	// vector. An automatic fill follows stepSize until a tick reverses direction.
	bool explicitStepSizes = false;
	// Bumped when QML assigns actualStepSizes. A queued reversal carries the
	// revision from when it was calculated, and is ignored if this is newer.
	quint64 stepRevision = 0;

	// Toggler params
	QVariant toggleA;
	QVariant toggleB;

	// Derived value outputs (computed in worker, no GUI-thread JS needed)
	// If totalTargetUid is set, the sum of all data item values is written to that uid.
	QString totalTargetUid;
	// Per-item derived output: derivedTargetUids[i] = value[i] / current[derivedDivisorUids[i]]
	// (e.g. current = power / voltage). Lists must be same size as uids.
	QStringList derivedTargetUids;
	QStringList derivedDivisorUids;
	// Per-item multiply derived output: derivedMultiplyTargetUids[i] = value[i] * current[derivedMultiplierUids[i]]
	// (e.g. power = current * voltage). Lists must be same size as uids.
	QStringList derivedMultiplyTargetUids;
	QStringList derivedMultiplierUids;
	// If set, the sum of all multiply-derived values is written here (e.g. total power)
	QString derivedMultiplyTotalTargetUid;
};

/*
	MockTimerWorker runs on the GUI thread. It owns the mock-data timers and
	calculates animator ticks, AC consumption, and phase sums in C++.

	A separate thread does not help: the values have to be applied on the GUI
	thread, and the calculation is cheap. Ticks are spread across the interval.
	MockValueApplier applies one queued value at a time, so a tick does not
	freeze the GUI.

	Each tick reads a value staged earlier in the same turn, otherwise a value
	still waiting to be applied, otherwise the producer. There is no second
	queue. The tick is staged before any signal from that tick, and the drain
	is held until calculators have read it. Then one value is applied.

	Notify records travel with the staged tick. The applier emits notifyUpdate
	and notifyTotal after setValue() has applied the listed uids.

	A UI write drops the queued tick that wrote that uid, including values
	calculated from it. Removing a path pauses the writer and drops that tick
	too, but keeps the registration. The pause lists each owned output under
	that path that already had a value. It also lists a derived destination,
	total, or toggler path that is still queued, because the next tick would
	create it. A configured input with no value, and no queued write, is not
	required. The writer resumes only when every listed output is written
	again. A write of one removed output does not resume the others.
	Changing the configuration keeps a pause that still applies, and still
	cancels the old tick.
*/
class MockTimerWorker : public QObject
{
	Q_OBJECT

public:
	explicit MockTimerWorker(QObject *parent = nullptr);
	~MockTimerWorker() override;

	void registerAnimator(const MockAnimatorConfig &config);
	// Same id, new configuration. Cancels the old tick. Keeps a removal pause
	// for outputs the new configuration still writes.
	void replaceAnimator(const MockAnimatorConfig &config);
	void unregisterAnimator(int animatorId);
	void setAnimatorActive(int animatorId, bool active);
	void setAllTimersActive(bool active);
	void updateAnimatorFollowSignOf(int animatorId, qreal followSignOf);
	QVector<qreal> actualStepSizes(int animatorId) const;
	void updateAnimatorActualStepSizes(int animatorId, const QVector<qreal> &stepSizes,
			quint64 revision);

	void setConsumptionConfig(const QString &systemUidPrefix,
		const MockConsumptionConfig &services,
		bool gaugesAutoMax, const QString &gaugesUidPrefix);
	void clearConsumptionConfig();
	void scheduleCalculatorFlush();

	void setPhaseSumConfig(int ruleId, const QString &targetPrefix,
		const QStringList &serviceUids, const QString &sourcePhasePattern,
		const QString &sourceCurrentPattern);
	void clearPhaseSumConfig(int ruleId);

	// Pause writers under prefix and drop their queued tick. Does not write.
	// The registration is kept. Each owned output under prefix that already
	// had a value is recorded. A derived destination, total, or toggler path
	// that is still queued is recorded too. Resume waits until every one of
	// those outputs has been written again. A configured input with no value
	// and no queued write is not required.
	// Returns outputs that were dropped.
	QSet<QString> forgetUidPrefix(const QString &prefix);
	// Resume a removed output this write covers. A sibling output stays paused.
	// Called after the write.
	void noteUidWritten(const QString &uid);
	// Test hooks. The tick hook does not flush; the caller writes before the timer.
	void queueUpdateForTest(const QString &uid, const QVariant &value);
	void tickAnimatorsForTest();
	// Send the pending tick now, before the GUI drain timer runs.
	void flushPendingForTest();

Q_SIGNALS:
	// The vector is copied with the signal. The animator assigns it directly
	// and must not call setActualStepSizes().
	void actualStepSizesChanged(int animatorId, const QVector<qreal> &stepSizes,
			quint64 revision);

protected:
	void timerEvent(QTimerEvent *event) override;

private:
	QVariant readValue(const QString &uid);
	// Same lookup as readValue(), but do not record the uid. A comparison of
	// this calculator's own output is not an input. Recording it would make a
	// replacement inherit the previous calculation's sources.
	QVariant readComparedOutput(const QString &uid);
	QVariant readStoredValue(const QString &normalized);
	void writePending(const QString &uid, const QVariant &value);
	// Write when the stored result differs. An equal value still waiting to be
	// applied is claimed by this calculation and is not written again.
	void writeComparedOutput(const QString &uid, const QVariant &value);
	void processTick(MockAnimatorConfig &config);
	// Stage the writes made while this tick was on the stack. Holds the drain.
	// An empty tick is not staged. This is not a second cancellation queue.
	void commitOpenTick(const MockTickRecord &tick);
	MockValueApplier *applier() const;
	void startAnimatorTimer(int animatorId, bool applyPhase = true);
	void stopAnimatorTimer(int animatorId);
	void pauseAnimator(int animatorId, const QString &prefix);
	void cancelPendingGaugeWrites();
	QStringList consumptionOutputUids() const;
	QStringList gaugeOutputUids() const;
	void pauseMatchingOutputs(QSet<QString> &paused, const QStringList &outputs,
			const QString &removedPrefix);
	bool restorePausedOutputs(QSet<QString> &paused, const QString &written);
	void processRandomizer(MockAnimatorConfig &config);
	void processRangeAnimator(MockAnimatorConfig &config);
	void processStepper(MockAnimatorConfig &config);
	void processToggler(MockAnimatorConfig &config);
	void scheduleBatchFlush();
	void flushBatch();
	void evaluateConsumption();
	void invalidateConsumptionValues();
	void evaluatePhaseSums();
	void invalidatePhaseSumValues(int ruleId);

	QHash<int, MockAnimatorConfig> m_configs;
	QHash<int, int> m_timerIdToAnimator;
	QHash<int, int> m_animatorToTimer;
	QSet<int> m_phasePending; // animators whose current timer is only the initial offset

	// Writes and notifies made while one tick function is on the stack. Staged
	// together at the end of that function, so a write is not retired before its
	// tick record claims it. Not walked by cancellation.
	MockValueUpdateList m_openUpdates;
	MockNotifyEventList m_openNotifications;
	QStringList *m_recordingInputs = nullptr;
	QStringList *m_recordingOutputs = nullptr;
	bool m_stepSizesChanged = false;
	// A tick or invalidation was staged. The 0ms flush runs calculators, then
	// releases the drain. Cleared when that flush runs.
	bool m_needsFlush = false;
	int m_flushTimerId = 0;

	// Consumption calculation state
	QString m_consumptionSystemPrefix;
	MockConsumptionConfig m_consumptionServices;
	bool m_gaugesAutoMax = false;
	QString m_gaugesUidPrefix;

	// Phase sum calculation state (generic per-phase aggregation)
	struct PhaseSumConfig {
		QString targetPrefix;          // canonical uid, without a "mock/" prefix
		QStringList serviceUids;
		QString sourcePhasePattern;    // e.g. "/Ac/L%1/Power" (%1 = phase number)
		QString sourceCurrentPattern;  // e.g. "/Ac/L%1/Current"
	};
	QHash<int, PhaseSumConfig> m_phaseSumConfigs;
	QStringList phaseSumOutputUids(const PhaseSumConfig &config) const;

	QSet<int> m_inactiveAnimators; // animators individually deactivated via setAnimatorActive(false)
	// Removed outputs that already had a value, plus a derived destination,
	// total, or toggler path that was still queued. A configured input with
	// no value and no queued write is not listed, including an empty item
	// created by a binding. Kept registered so a later write of the listed
	// outputs can resume. The set of ids is the animators that still have at
	// least one such output.
	QSet<int> m_pausedAnimators;
	QHash<int, QSet<QString>> m_pauseOutputs;
	QSet<int> m_pausedPhaseSums;
	// Calculator outputs removed individually. A source change must not write
	// these back. The whole-prefix flags above still cover a removed parent.
	QSet<QString> m_pausedConsumptionOutputs;
	QSet<QString> m_pausedGaugeOutputs;
	QHash<int, QSet<QString>> m_pausedPhaseSumOutputs;
	bool m_consumptionPaused = false;
	bool m_gaugesPaused = false;
	bool m_globalActive = false;
	QRandomGenerator m_rng;
};

} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_MOCKTIMERWORKER_H
