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

using MockValueUpdate = QPair<QString, QVariant>;
using MockValueUpdateList = QVector<MockValueUpdate>;
using MockValueCache = QHash<QString, QVariant>;

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

// Configuration for consumption calculation on the worker thread
struct MockConsumptionServiceInfo {
	QString uid;
	QString serviceType;
	int index = 0;
};
using MockConsumptionConfig = QVector<MockConsumptionServiceInfo>;

// Producer paths and the worker cache omit a leading "mock/". QML service uids include it.
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

	// Derived value outputs (computed in worker, no GUI-thread JS needed)
	// If totalTargetUid is set, the sum of all data item values is written to that uid.
	QString totalTargetUid;
	// Per-item derived output: derivedTargetUids[i] = value[i] / cache[derivedDivisorUids[i]]
	// (e.g. current = power / voltage). Lists must be same size as uids.
	QStringList derivedTargetUids;
	QStringList derivedDivisorUids;
	// Per-item multiply derived output: derivedMultiplyTargetUids[i] = value[i] * cache[derivedMultiplierUids[i]]
	// (e.g. power = current * voltage). Lists must be same size as uids.
	QStringList derivedMultiplyTargetUids;
	QStringList derivedMultiplierUids;
	// If set, the sum of all multiply-derived values is written here (e.g. total power)
	QString derivedMultiplyTotalTargetUid;
};

/*
	MockTimerWorker lives on a dedicated worker thread.
	It owns all the mock-data timers and performs the value computations
	(random deltas, range-step animations) off the GUI thread.

	Results are emitted via valuesReady(), delivered to the GUI thread via a
	queued connection. Notify records in that batch are not QML signals. The
	applier emits notifyUpdate and notifyTotal after the associated setValue().
*/
class MockTimerWorker : public QObject
{
	Q_OBJECT

public:
	explicit MockTimerWorker(QObject *parent = nullptr);
	~MockTimerWorker() override;

public Q_SLOTS:
	void registerAnimator(const Victron::VenusOS::MockAnimatorConfig &config);
	void unregisterAnimator(int animatorId);
	void setAnimatorActive(int animatorId, bool active);
	void setAllTimersActive(bool active);
	void updateValue(const QString &uid, const QVariant &value);
	void updateValues(const Victron::VenusOS::MockValueCache &values);
	// External write: update the cache, then ack so the applier can unblock the uid.
	void observeExternalValue(const QString &uid, const QVariant &value);
	// Stop writers under prefix, then emit uidPrefixForgotten(). Do not ack earlier.
	void forgetUidPrefix(const QString &prefix);
	void updateAnimatorFollowSignOf(int animatorId, qreal followSignOf);
	void updateAnimatorActualStepSizes(int animatorId, const QVector<qreal> &stepSizes);
	void setConsumptionConfig(const QString &systemUidPrefix,
		const Victron::VenusOS::MockConsumptionConfig &services,
		bool gaugesAutoMax, const QString &gaugesUidPrefix,
		const Victron::VenusOS::MockValueCache &currentValues);
	void clearConsumptionConfig();
	void scheduleCalculatorFlush();
	void setPhaseSumConfig(int ruleId, const QString &targetPrefix,
		const QStringList &serviceUids, const QString &sourcePhasePattern,
		const QString &sourceCurrentPattern,
		const Victron::VenusOS::MockValueCache &currentValues);
	void clearPhaseSumConfig(int ruleId);

Q_SIGNALS:
	void valuesReady(const Victron::VenusOS::MockValueUpdateList &updates,
			const Victron::VenusOS::MockNotifyEventList &notifications);
	void actualStepSizesChanged(int animatorId, const QVector<qreal> &stepSizes);
	void externalValueObserved(const QString &uid);
	void uidPrefixForgotten(const QString &prefix);

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

	QHash<int, MockAnimatorConfig> m_configs;
	QHash<int, int> m_timerIdToAnimator;
	QHash<int, int> m_animatorToTimer;
	QSet<int> m_phasePending; // animators whose current timer is only the initial offset
	QHash<QString, QVariant> m_valueCache; // Not evicted on unregister. See .github/architecture.md.

	// Batching: accumulate updates from multiple animators firing in the same tick.
	// Notifications stay with the writes they describe; the applier emits them.
	MockValueUpdateList m_pendingUpdates;
	MockNotifyEventList m_pendingNotifications;
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

Q_DECLARE_METATYPE(Victron::VenusOS::MockAnimatorConfig)
Q_DECLARE_METATYPE(Victron::VenusOS::MockValueUpdateList)
Q_DECLARE_METATYPE(Victron::VenusOS::MockNotifyEvent)
Q_DECLARE_METATYPE(Victron::VenusOS::MockNotifyEventList)
Q_DECLARE_METATYPE(Victron::VenusOS::MockConsumptionConfig)

#endif // VICTRON_GUIV2_MOCKTIMERWORKER_H
