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

// Configuration for consumption calculation
struct MockConsumptionServiceInfo {
	QString uid;
	QString serviceType;
	int index = 0;
};
using MockConsumptionConfig = QVector<MockConsumptionServiceInfo>;

// Producer paths and queued updates omit a leading "mock/". QML service uids include it.
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

	// Toggler params
	QVariant toggleA;
	QVariant toggleB;

	// Derived value outputs (computed in C++, no QML JS needed)
	// If totalTargetUid is set, the sum of all data item values is written to that uid.
	QString totalTargetUid;
	// Per-item derived output: derivedTargetUids[i] = value[i] / value[derivedDivisorUids[i]]
	// (e.g. current = power / voltage). Lists must be same size as uids.
	QStringList derivedTargetUids;
	QStringList derivedDivisorUids;
	// Per-item multiply derived output: derivedMultiplyTargetUids[i] = value[i] * value[derivedMultiplierUids[i]]
	// (e.g. power = current * voltage). Lists must be same size as uids.
	QStringList derivedMultiplyTargetUids;
	QStringList derivedMultiplierUids;
	// If set, the sum of all multiply-derived values is written here (e.g. total power)
	QString derivedMultiplyTotalTargetUid;
};

/*
	MockTimerWorker lives on the GUI thread, as does everything else in the mock.
	It owns all the mock-data timers and performs the value computations
	(random deltas, range-step animations, consumption and phase sums) in C++
	instead of in QML.

	It reads the current values from the mock producer, and passes each batch of
	results to MockValueApplier, which writes them a few per frame. Notify records
	in that batch are not QML signals. The applier emits notifyUpdate and
	notifyTotal after the associated setValue().
*/
class MockTimerWorker : public QObject
{
	Q_OBJECT

public:
	explicit MockTimerWorker(MockValueApplier *applier, QObject *parent = nullptr);
	~MockTimerWorker() override;

	void registerAnimator(const MockAnimatorConfig &config);
	void unregisterAnimator(int animatorId);
	void setAnimatorActive(int animatorId, bool active);
	void setAllTimersActive(bool active);
	// Stop writers under prefix, and drop their batched updates.
	void forgetUidPrefix(const QString &prefix);
	// An external write replaces a batched update for uid that is not flushed yet.
	void dropPendingUpdate(const QString &uid);
	QVector<qreal> actualStepSizes(int animatorId) const;
	void updateAnimatorFollowSignOf(int animatorId, qreal followSignOf);
	void updateAnimatorActualStepSizes(int animatorId, const QVector<qreal> &stepSizes);
	void setConsumptionConfig(const QString &systemUidPrefix,
		const MockConsumptionConfig &services,
		bool gaugesAutoMax, const QString &gaugesUidPrefix);
	void clearConsumptionConfig();
	void scheduleCalculatorFlush();
	void setPhaseSumConfig(int ruleId, const QString &targetPrefix,
		const QStringList &serviceUids, const QString &sourcePhasePattern,
		const QString &sourceCurrentPattern);
	void clearPhaseSumConfig(int ruleId);
	void queueUpdateForTest(const QString &uid, const QVariant &value);
	void tickAnimatorsForTest();

Q_SIGNALS:
	void actualStepSizesChanged(int animatorId);

protected:
	void timerEvent(QTimerEvent *event) override;

private:
	void startAnimatorTimer(int animatorId, bool applyPhase = true);
	void stopAnimatorTimer(int animatorId);
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
	QVariant currentValue(const QString &uid) const;
	void processTick(MockAnimatorConfig &config);
	void dropPendingTicks(QSet<QString> dropped);

	MockValueApplier *m_applier = nullptr;
	QHash<int, MockAnimatorConfig> m_configs;
	QHash<int, int> m_timerIdToAnimator;
	QHash<int, int> m_animatorToTimer;
	QSet<int> m_phasePending; // animators whose current timer is only the initial offset

	// Batching: accumulate updates from multiple animators firing in the same tick.
	// Notifications stay with the writes they describe; the applier emits them.
	MockValueUpdateList m_pendingUpdates;
	MockNotifyEventList m_pendingNotifications;
	// The animator ticks in the batch, in order, with the uids each read and wrote.
	struct PendingTick {
		int animatorId = -1;
		QStringList inputs;
		QStringList outputs;
	};
	QVector<PendingTick> m_pendingTicks;
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

	QSet<int> m_inactiveAnimators; // animators individually deactivated via setAnimatorActive(false)
	bool m_globalActive = false;
	QRandomGenerator m_rng;
};

} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_MOCKTIMERWORKER_H
