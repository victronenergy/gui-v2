/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKANIMATORS_H
#define VICTRON_GUIV2_MOCKANIMATORS_H

#include "mockmanager.h"
#include "mocktimerworker.h"
#include "mockvalueapplier.h"

#include <veutil/qt/ve_quick_item.hpp>

#include <QObject>
#include <QQmlEngine>
#include <QQmlListProperty>
#include <QTimerEvent>

#include <atomic>

namespace Victron {
namespace VenusOS {

inline std::atomic<int> s_nextAnimatorId{1};

// Repeatedly changes data values to a different value within the specified deltas.
class MockDataRandomizer : public QObject, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT

	// The data values to be updated
	Q_PROPERTY(QQmlListProperty<VeQuickItem> dataItems READ dataItems NOTIFY dataItemsChanged FINAL)

	// The min/max difference in value to shift on each update. E.g. if deltaLow=5, deltaHigh=10,
	// and current value=100, then the new value is between 95-110.
	// If not set, then the defaults are used
	Q_PROPERTY(qreal deltaLow READ deltaLow WRITE setDeltaLow NOTIFY deltaLowChanged FINAL)
	Q_PROPERTY(qreal deltaHigh READ deltaHigh WRITE setDeltaHigh NOTIFY deltaHighChanged FINAL)

	// Optional min/max values
	Q_PROPERTY(qreal minimumValue READ minimumValue WRITE setMinimumValue NOTIFY minimumValueChanged FINAL)
	Q_PROPERTY(qreal maximumValue READ maximumValue WRITE setMaximumValue NOTIFY maximumValueChanged FINAL)

	// If set, the randomized value will match the sign of this number. E.g. this is useful when a
	// battery power/current should be negative when the Soc is negative.
	Q_PROPERTY(qreal followSignOf READ followSignOf WRITE setFollowSignOf NOTIFY followSignOfChanged FINAL)

	Q_PROPERTY(qreal interval READ interval WRITE setInterval NOTIFY intervalChanged FINAL)
	Q_PROPERTY(bool repeat READ repeat WRITE setRepeat NOTIFY repeatChanged FINAL)
	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)

	// Derived value computation (done entirely in worker thread, no GUI JS needed)
	// totalTargetUid: the worker writes the sum of all data items to this uid
	Q_PROPERTY(QString totalTargetUid READ totalTargetUid WRITE setTotalTargetUid NOTIFY totalTargetUidChanged FINAL)
	// derivedTargetUids[i] = value[i] / cache[derivedDivisorUids[i]] (e.g. current = power/voltage)
	Q_PROPERTY(QStringList derivedTargetUids READ derivedTargetUids WRITE setDerivedTargetUids NOTIFY derivedTargetUidsChanged FINAL)
	Q_PROPERTY(QStringList derivedDivisorUids READ derivedDivisorUids WRITE setDerivedDivisorUids NOTIFY derivedDivisorUidsChanged FINAL)
	// derivedMultiplyTargetUids[i] = value[i] * cache[derivedMultiplierUids[i]] (e.g. power = current*voltage)
	Q_PROPERTY(QStringList derivedMultiplyTargetUids READ derivedMultiplyTargetUids WRITE setDerivedMultiplyTargetUids NOTIFY derivedMultiplyTargetUidsChanged FINAL)
	Q_PROPERTY(QStringList derivedMultiplierUids READ derivedMultiplierUids WRITE setDerivedMultiplierUids NOTIFY derivedMultiplierUidsChanged FINAL)
	// Sum of all multiply-derived values written to this uid
	Q_PROPERTY(QString derivedMultiplyTotalTargetUid READ derivedMultiplyTotalTargetUid WRITE setDerivedMultiplyTotalTargetUid NOTIFY derivedMultiplyTotalTargetUidChanged FINAL)

	Q_CLASSINFO("DefaultProperty", "dataItems")
	Q_INTERFACES(QQmlParserStatus)

public:
	explicit MockDataRandomizer(QObject *parent = nullptr)
			: QObject(parent)
			, m_animatorId(s_nextAnimatorId.fetch_add(1)) {
	}

	~MockDataRandomizer() override {
		unregisterFromWorker();
	}

	QQmlListProperty<VeQuickItem> dataItems() {
		return QQmlListProperty<VeQuickItem>(
			this,
			this,
			MockDataRandomizer::dataItems_append,
			MockDataRandomizer::dataItems_count,
			MockDataRandomizer::dataItems_at,
			MockDataRandomizer::dataItems_clear,
			nullptr, // no replace
			MockDataRandomizer::dataItems_removeLast);
	}

	qreal deltaLow() const { return m_deltaLow; }
	void setDeltaLow(qreal v) {
		if (m_deltaLow != v) {
			m_deltaLow = v;
			scheduleReregistration();
			Q_EMIT deltaLowChanged();
		}
	}

	qreal deltaHigh() const { return m_deltaHigh; }
	void setDeltaHigh(qreal v) {
		if (m_deltaHigh != v) {
			m_deltaHigh = v;
			scheduleReregistration();
			Q_EMIT deltaHighChanged();
		}
	}

	qreal minimumValue() const { return m_minimumValue; }
	void setMinimumValue(qreal v) {
		if (m_minimumValue != v) {
			m_minimumValue = v;
			scheduleReregistration();
			Q_EMIT minimumValueChanged();
		}
	}

	qreal maximumValue() const { return m_maximumValue; }
	void setMaximumValue(qreal v) {
		if (m_maximumValue != v) {
			m_maximumValue = v;
			scheduleReregistration();
			Q_EMIT maximumValueChanged();
		}
	}

	qreal followSignOf() const { return m_followSignOf; }
	void setFollowSignOf(qreal v) {
		if (m_followSignOf != v) {
			m_followSignOf = v;
			// followSignOf changes frequently (e.g. bound to SOC), use lightweight update
			MockTimerWorker *worker = MockManager::create()->timerWorker();
			if (worker) {
				QMetaObject::invokeMethod(worker, "updateAnimatorFollowSignOf",
					Qt::QueuedConnection, Q_ARG(int, m_animatorId), Q_ARG(qreal, v));
			}
			Q_EMIT followSignOfChanged();
		}
	}

	qreal interval() const { return m_interval; }
	void setInterval(qreal v) {
		if (m_interval != v) {
			m_interval = v;
			scheduleReregistration();
			Q_EMIT intervalChanged();
		}
	}

	bool repeat() const { return m_repeat; }
	void setRepeat(bool v) {
		if (m_repeat != v) {
			m_repeat = v;
			scheduleReregistration();
			Q_EMIT repeatChanged();
		}
	}

	bool active() const { return m_active; }
	void setActive(bool v) {
		if (m_active != v) {
			m_active = v;
			MockTimerWorker *worker = MockManager::create()->timerWorker();
			if (worker && m_registered) {
				QMetaObject::invokeMethod(worker, "setAnimatorActive",
					Qt::QueuedConnection, Q_ARG(int, m_animatorId), Q_ARG(bool, v));
			} else if (v && m_complete && !m_registered) {
				registerWithWorker();
			}
			Q_EMIT activeChanged();
		}
	}

	QString totalTargetUid() const { return m_totalTargetUid; }
	void setTotalTargetUid(const QString &v) {
		if (m_totalTargetUid != v) {
			m_totalTargetUid = v;
			scheduleReregistration();
			Q_EMIT totalTargetUidChanged();
		}
	}

	QStringList derivedTargetUids() const { return m_derivedTargetUids; }
	void setDerivedTargetUids(const QStringList &v) {
		if (m_derivedTargetUids != v) {
			m_derivedTargetUids = v;
			scheduleReregistration();
			Q_EMIT derivedTargetUidsChanged();
		}
	}

	QStringList derivedDivisorUids() const { return m_derivedDivisorUids; }
	void setDerivedDivisorUids(const QStringList &v) {
		if (m_derivedDivisorUids != v) {
			m_derivedDivisorUids = v;
			scheduleReregistration();
			Q_EMIT derivedDivisorUidsChanged();
		}
	}

	QStringList derivedMultiplyTargetUids() const { return m_derivedMultiplyTargetUids; }
	void setDerivedMultiplyTargetUids(const QStringList &v) {
		if (m_derivedMultiplyTargetUids != v) {
			m_derivedMultiplyTargetUids = v;
			scheduleReregistration();
			Q_EMIT derivedMultiplyTargetUidsChanged();
		}
	}

	QStringList derivedMultiplierUids() const { return m_derivedMultiplierUids; }
	void setDerivedMultiplierUids(const QStringList &v) {
		if (m_derivedMultiplierUids != v) {
			m_derivedMultiplierUids = v;
			scheduleReregistration();
			Q_EMIT derivedMultiplierUidsChanged();
		}
	}

	QString derivedMultiplyTotalTargetUid() const { return m_derivedMultiplyTotalTargetUid; }
	void setDerivedMultiplyTotalTargetUid(const QString &v) {
		if (m_derivedMultiplyTotalTargetUid != v) {
			m_derivedMultiplyTotalTargetUid = v;
			scheduleReregistration();
			Q_EMIT derivedMultiplyTotalTargetUidChanged();
		}
	}

Q_SIGNALS:
	void notifyUpdate(int i, qreal newValue);
	void notifyTotal(qreal total);

	void dataItemsChanged();
	void deltaLowChanged();
	void deltaHighChanged();
	void minimumValueChanged();
	void maximumValueChanged();
	void followSignOfChanged();
	void intervalChanged();
	void repeatChanged();
	void activeChanged();
	void totalTargetUidChanged();
	void derivedTargetUidsChanged();
	void derivedDivisorUidsChanged();
	void derivedMultiplyTargetUidsChanged();
	void derivedMultiplierUidsChanged();
	void derivedMultiplyTotalTargetUidChanged();

protected:
	// QQmlParserStatus
	void classBegin() override {}
	void componentComplete() override {
		m_complete = true;
		if (m_active) {
			registerWithWorker();
		}
	}

private:
	void registerWithWorker() {
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (!worker || m_dataItems.isEmpty()) {
			return;
		}

		// Build config
		MockAnimatorConfig config;
		config.animatorId = m_animatorId;
		config.type = MockAnimatorConfig::Randomizer;
		config.interval = m_interval;
		config.repeat = m_repeat;
		config.deltaLow = m_deltaLow;
		config.deltaHigh = m_deltaHigh;
		config.minimumValue = m_minimumValue;
		config.maximumValue = m_maximumValue;
		config.followSignOf = m_followSignOf;
		config.totalTargetUid = m_totalTargetUid;
		config.derivedTargetUids = m_derivedTargetUids;
		config.derivedDivisorUids = m_derivedDivisorUids;
		config.derivedMultiplyTargetUids = m_derivedMultiplyTargetUids;
		config.derivedMultiplierUids = m_derivedMultiplierUids;
		config.derivedMultiplyTotalTargetUid = m_derivedMultiplyTotalTargetUid;

		// Collect UIDs and sync current values to worker cache
		QHash<QString, QVariant> initialValues;
		for (VeQuickItem *item : m_dataItems) {
			if (item) {
				const QString uid = item->getUid();
				config.uids.append(uid);
				initialValues[uid] = item->getValue();
			} else {
				config.uids.append(QString());
			}
		}

		// Also sync derived-value dependencies (e.g. voltages for current = power / voltage)
		auto syncDerivedDeps = [&initialValues](const QStringList &uids) {
			for (const QString &uid : uids) {
				if (!uid.isEmpty() && !initialValues.contains(uid)) {
					VeQItem *item = VeQItems::getRoot()->itemGet(uid);
					if (item && item->getValue().isValid()) {
						initialValues[uid] = item->getValue();
					}
				}
			}
		};
		syncDerivedDeps(config.derivedDivisorUids);
		syncDerivedDeps(config.derivedMultiplierUids);

		// Sync values to worker cache first, then register
		QMetaObject::invokeMethod(worker, "updateValues",
			Qt::QueuedConnection, Q_ARG(MockValueCache, initialValues));
		QMetaObject::invokeMethod(worker, "registerAnimator",
			Qt::QueuedConnection,
			Q_ARG(Victron::VenusOS::MockAnimatorConfig, config));

		// Register targeted notification dispatch
		MockValueApplier *applier = MockManager::create()->valueApplier();
		if (applier) {
			applier->registerNotify(m_animatorId, {
				[this](int index, qreal newValue) { Q_EMIT notifyUpdate(index, newValue); },
				[this](qreal total) { Q_EMIT notifyTotal(total); }
			});
		}

		m_registered = true;
	}

	void unregisterFromWorker() {
		if (!m_registered) {
			return;
		}
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (worker) {
			QMetaObject::invokeMethod(worker, "unregisterAnimator",
				Qt::QueuedConnection, Q_ARG(int, m_animatorId));
		}
		MockValueApplier *applier = MockManager::create()->valueApplier();
		if (applier) {
			applier->unregisterNotify(m_animatorId);
		}
		m_registered = false;
	}

	void scheduleReregistration() {
		if (!m_complete) return;
		if (m_registered) {
			unregisterFromWorker();
		}
		if (m_active) {
			registerWithWorker();
		}
	}

	static void dataItems_append(QQmlListProperty<VeQuickItem> *prop, VeQuickItem *object) {
		MockDataRandomizer *self = static_cast<MockDataRandomizer*>(prop->data);
		self->m_dataItems.append(object);
		self->scheduleReregistration();
		Q_EMIT self->dataItemsChanged();
	}
	static qsizetype dataItems_count(QQmlListProperty<VeQuickItem> *prop) {
		MockDataRandomizer *self = static_cast<MockDataRandomizer*>(prop->data);
		return self->m_dataItems.count();
	}
	static VeQuickItem *dataItems_at(QQmlListProperty<VeQuickItem> *prop, qsizetype index) {
		MockDataRandomizer *self = static_cast<MockDataRandomizer*>(prop->data);
		return (index >= 0 && index < self->m_dataItems.count()) ? self->m_dataItems.at(index) : nullptr;
	}
	static void dataItems_clear(QQmlListProperty<VeQuickItem> *prop) {
		MockDataRandomizer *self = static_cast<MockDataRandomizer*>(prop->data);
		self->m_dataItems.clear();
		self->scheduleReregistration();
		Q_EMIT self->dataItemsChanged();
	}
	static void dataItems_removeLast(QQmlListProperty<VeQuickItem> *prop) {
		MockDataRandomizer *self = static_cast<MockDataRandomizer*>(prop->data);
		if (!self->m_dataItems.isEmpty()) {
			self->m_dataItems.removeLast();
			self->scheduleReregistration();
			Q_EMIT self->dataItemsChanged();
		}
	}

	const int m_animatorId;
	QVector<VeQuickItem*> m_dataItems;
	QString m_totalTargetUid;
	QStringList m_derivedTargetUids;
	QStringList m_derivedDivisorUids;
	QStringList m_derivedMultiplyTargetUids;
	QStringList m_derivedMultiplierUids;
	QString m_derivedMultiplyTotalTargetUid;
	qreal m_deltaLow = qQNaN();
	qreal m_deltaHigh = qQNaN();
	qreal m_minimumValue = qQNaN();
	qreal m_maximumValue = qQNaN();
	qreal m_followSignOf = qQNaN();
	qreal m_interval = 1000.0;
	bool m_repeat = true;
	bool m_active = false;
	bool m_complete = false;
	bool m_registered = false;
};

// Repeatedly changes data values between the specified minimum and maximum in a linear fashion.
// Values will increase to the maximum, then decrease to the minimum, and repeat.
class MockDataRangeAnimator : public QObject, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT

	// The data values to be updated
	Q_PROPERTY(QQmlListProperty<VeQuickItem> dataItems READ dataItems NOTIFY dataItemsChanged FINAL)

	// The min/max value to animate between
	Q_PROPERTY(qreal minimumValue READ minimumValue WRITE setMinimumValue NOTIFY minimumValueChanged FINAL)
	Q_PROPERTY(qreal maximumValue READ maximumValue WRITE setMaximumValue NOTIFY maximumValueChanged FINAL)

	// The preferred step size, and actual step size (which changes when reversing direction)
	Q_PROPERTY(qreal stepSize READ stepSize WRITE setStepSize NOTIFY stepSizeChanged FINAL)
	Q_PROPERTY(QVector<qreal> actualStepSizes READ actualStepSizes WRITE setActualStepSizes NOTIFY actualStepSizesChanged FINAL)

	Q_PROPERTY(qreal interval READ interval WRITE setInterval NOTIFY intervalChanged FINAL)
	Q_PROPERTY(bool repeat READ repeat WRITE setRepeat NOTIFY repeatChanged FINAL)
	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)

	// Derived value computation (done entirely in worker thread)
	Q_PROPERTY(QString totalTargetUid READ totalTargetUid WRITE setTotalTargetUid NOTIFY totalTargetUidChanged FINAL)
	Q_PROPERTY(QStringList derivedTargetUids READ derivedTargetUids WRITE setDerivedTargetUids NOTIFY derivedTargetUidsChanged FINAL)
	Q_PROPERTY(QStringList derivedDivisorUids READ derivedDivisorUids WRITE setDerivedDivisorUids NOTIFY derivedDivisorUidsChanged FINAL)
	Q_PROPERTY(QStringList derivedMultiplyTargetUids READ derivedMultiplyTargetUids WRITE setDerivedMultiplyTargetUids NOTIFY derivedMultiplyTargetUidsChanged FINAL)
	Q_PROPERTY(QStringList derivedMultiplierUids READ derivedMultiplierUids WRITE setDerivedMultiplierUids NOTIFY derivedMultiplierUidsChanged FINAL)
	Q_PROPERTY(QString derivedMultiplyTotalTargetUid READ derivedMultiplyTotalTargetUid WRITE setDerivedMultiplyTotalTargetUid NOTIFY derivedMultiplyTotalTargetUidChanged FINAL)

	Q_CLASSINFO("DefaultProperty", "dataItems")
	Q_INTERFACES(QQmlParserStatus)

public:
	explicit MockDataRangeAnimator(QObject *parent = nullptr)
			: QObject(parent)
			, m_animatorId(s_nextAnimatorId.fetch_add(1)) {
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (worker) {
			// actualStepSizesChanged is infrequent (only on direction reversal);
			// AutoConnection resolves to QueuedConnection (cross-thread).
			connect(worker, &MockTimerWorker::actualStepSizesChanged,
					this, [this](int animatorId, const QVector<qreal> &stepSizes) {
						if (animatorId == m_animatorId) {
							if (m_actualStepSizes != stepSizes) {
								m_actualStepSizes = stepSizes;
								Q_EMIT actualStepSizesChanged();
							}
						}
					});
		}
	}

	~MockDataRangeAnimator() override {
		unregisterFromWorker();
	}

	QQmlListProperty<VeQuickItem> dataItems() {
		return QQmlListProperty<VeQuickItem>(
			this,
			this,
			MockDataRangeAnimator::dataItems_append,
			MockDataRangeAnimator::dataItems_count,
			MockDataRangeAnimator::dataItems_at,
			MockDataRangeAnimator::dataItems_clear,
			nullptr, // no replace
			MockDataRangeAnimator::dataItems_removeLast);
	}

	qreal minimumValue() const { return m_minimumValue; }
	void setMinimumValue(qreal v) {
		if (m_minimumValue != v) {
			m_minimumValue = v;
			scheduleReregistration();
			Q_EMIT minimumValueChanged();
		}
	}

	qreal maximumValue() const { return m_maximumValue; }
	void setMaximumValue(qreal v) {
		if (m_maximumValue != v) {
			m_maximumValue = v;
			scheduleReregistration();
			Q_EMIT maximumValueChanged();
		}
	}

	qreal stepSize() const { return m_stepSize; }
	void setStepSize(qreal v) {
		if (m_stepSize != v) {
			m_stepSize = v;
			scheduleReregistration();
			Q_EMIT stepSizeChanged();
		}
	}

	QVector<qreal> actualStepSizes() const { return m_actualStepSizes; }
	void setActualStepSizes(const QVector<qreal> &v) {
		if (m_actualStepSizes != v) {
			m_actualStepSizes = v;
			Q_EMIT actualStepSizesChanged();
		}
	}

	qreal interval() const { return m_interval; }
	void setInterval(qreal v) {
		if (m_interval != v) {
			m_interval = v;
			scheduleReregistration();
			Q_EMIT intervalChanged();
		}
	}

	bool repeat() const { return m_repeat; }
	void setRepeat(bool v) {
		if (m_repeat != v) {
			m_repeat = v;
			scheduleReregistration();
			Q_EMIT repeatChanged();
		}
	}

	bool active() const { return m_active; }
	void setActive(bool v) {
		if (m_active != v) {
			m_active = v;
			MockTimerWorker *worker = MockManager::create()->timerWorker();
			if (worker && m_registered) {
				QMetaObject::invokeMethod(worker, "setAnimatorActive",
					Qt::QueuedConnection, Q_ARG(int, m_animatorId), Q_ARG(bool, v));
			} else if (v && m_complete && !m_registered) {
				registerWithWorker();
			}
			Q_EMIT activeChanged();
		}
	}

	QString totalTargetUid() const { return m_totalTargetUid; }
	void setTotalTargetUid(const QString &v) {
		if (m_totalTargetUid != v) {
			m_totalTargetUid = v;
			scheduleReregistration();
			Q_EMIT totalTargetUidChanged();
		}
	}

	QStringList derivedTargetUids() const { return m_derivedTargetUids; }
	void setDerivedTargetUids(const QStringList &v) {
		if (m_derivedTargetUids != v) {
			m_derivedTargetUids = v;
			scheduleReregistration();
			Q_EMIT derivedTargetUidsChanged();
		}
	}

	QStringList derivedDivisorUids() const { return m_derivedDivisorUids; }
	void setDerivedDivisorUids(const QStringList &v) {
		if (m_derivedDivisorUids != v) {
			m_derivedDivisorUids = v;
			scheduleReregistration();
			Q_EMIT derivedDivisorUidsChanged();
		}
	}

	QStringList derivedMultiplyTargetUids() const { return m_derivedMultiplyTargetUids; }
	void setDerivedMultiplyTargetUids(const QStringList &v) {
		if (m_derivedMultiplyTargetUids != v) {
			m_derivedMultiplyTargetUids = v;
			scheduleReregistration();
			Q_EMIT derivedMultiplyTargetUidsChanged();
		}
	}

	QStringList derivedMultiplierUids() const { return m_derivedMultiplierUids; }
	void setDerivedMultiplierUids(const QStringList &v) {
		if (m_derivedMultiplierUids != v) {
			m_derivedMultiplierUids = v;
			scheduleReregistration();
			Q_EMIT derivedMultiplierUidsChanged();
		}
	}

	QString derivedMultiplyTotalTargetUid() const { return m_derivedMultiplyTotalTargetUid; }
	void setDerivedMultiplyTotalTargetUid(const QString &v) {
		if (m_derivedMultiplyTotalTargetUid != v) {
			m_derivedMultiplyTotalTargetUid = v;
			scheduleReregistration();
			Q_EMIT derivedMultiplyTotalTargetUidChanged();
		}
	}

Q_SIGNALS:
	void notifyTotal(qreal total);

	void dataItemsChanged();
	void minimumValueChanged();
	void maximumValueChanged();
	void stepSizeChanged();
	void actualStepSizesChanged();
	void intervalChanged();
	void repeatChanged();
	void activeChanged();
	void totalTargetUidChanged();
	void derivedTargetUidsChanged();
	void derivedDivisorUidsChanged();
	void derivedMultiplyTargetUidsChanged();
	void derivedMultiplierUidsChanged();
	void derivedMultiplyTotalTargetUidChanged();

protected:
	// QQmlParserStatus
	void classBegin() override {}
	void componentComplete() override {
		m_complete = true;
		if (m_active) {
			registerWithWorker();
		}
	}

private:
	void registerWithWorker() {
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (!worker || m_dataItems.isEmpty()) {
			return;
		}

		// Build config
		MockAnimatorConfig config;
		config.animatorId = m_animatorId;
		config.type = MockAnimatorConfig::RangeAnimator;
		config.interval = m_interval;
		config.repeat = m_repeat;
		config.stepSize = m_stepSize;
		config.rangeMin = m_minimumValue;
		config.rangeMax = m_maximumValue;
		config.actualStepSizes = m_actualStepSizes;
		config.totalTargetUid = m_totalTargetUid;
		config.derivedTargetUids = m_derivedTargetUids;
		config.derivedDivisorUids = m_derivedDivisorUids;
		config.derivedMultiplyTargetUids = m_derivedMultiplyTargetUids;
		config.derivedMultiplierUids = m_derivedMultiplierUids;
		config.derivedMultiplyTotalTargetUid = m_derivedMultiplyTotalTargetUid;

		// Collect UIDs and sync current values to worker cache
		QHash<QString, QVariant> initialValues;
		for (VeQuickItem *item : m_dataItems) {
			if (item) {
				const QString uid = item->getUid();
				config.uids.append(uid);
				initialValues[uid] = item->getValue();
			} else {
				config.uids.append(QString());
			}
		}

		// Also sync derived-value dependencies (e.g. voltages for power = current * voltage)
		auto syncDerivedDeps = [&initialValues](const QStringList &uids) {
			for (const QString &uid : uids) {
				if (!uid.isEmpty() && !initialValues.contains(uid)) {
					VeQItem *item = VeQItems::getRoot()->itemGet(uid);
					if (item && item->getValue().isValid()) {
						initialValues[uid] = item->getValue();
					}
				}
			}
		};
		syncDerivedDeps(config.derivedDivisorUids);
		syncDerivedDeps(config.derivedMultiplierUids);

		// Sync values to worker cache first, then register
		QMetaObject::invokeMethod(worker, "updateValues",
			Qt::QueuedConnection, Q_ARG(MockValueCache, initialValues));
		QMetaObject::invokeMethod(worker, "registerAnimator",
			Qt::QueuedConnection,
			Q_ARG(Victron::VenusOS::MockAnimatorConfig, config));

		// Register targeted notification dispatch
		MockValueApplier *applier = MockManager::create()->valueApplier();
		if (applier) {
			applier->registerNotify(m_animatorId, {
				nullptr,
				[this](qreal total) { Q_EMIT notifyTotal(total); }
			});
		}

		m_registered = true;
	}

	void unregisterFromWorker() {
		if (!m_registered) {
			return;
		}
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (worker) {
			QMetaObject::invokeMethod(worker, "unregisterAnimator",
				Qt::QueuedConnection, Q_ARG(int, m_animatorId));
		}
		MockValueApplier *applier = MockManager::create()->valueApplier();
		if (applier) {
			applier->unregisterNotify(m_animatorId);
		}
		m_registered = false;
	}

	void scheduleReregistration() {
		if (!m_complete) return;
		if (m_registered) {
			unregisterFromWorker();
		}
		if (m_active) {
			registerWithWorker();
		}
	}

	static void dataItems_append(QQmlListProperty<VeQuickItem> *prop, VeQuickItem *object) {
		MockDataRangeAnimator *self = static_cast<MockDataRangeAnimator*>(prop->data);
		self->m_dataItems.append(object);
		self->scheduleReregistration();
		Q_EMIT self->dataItemsChanged();
	}
	static qsizetype dataItems_count(QQmlListProperty<VeQuickItem> *prop) {
		MockDataRangeAnimator *self = static_cast<MockDataRangeAnimator*>(prop->data);
		return self->m_dataItems.count();
	}
	static VeQuickItem *dataItems_at(QQmlListProperty<VeQuickItem> *prop, qsizetype index) {
		MockDataRangeAnimator *self = static_cast<MockDataRangeAnimator*>(prop->data);
		return (index >= 0 && index < self->m_dataItems.count()) ? self->m_dataItems.at(index) : nullptr;
	}
	static void dataItems_clear(QQmlListProperty<VeQuickItem> *prop) {
		MockDataRangeAnimator *self = static_cast<MockDataRangeAnimator*>(prop->data);
		self->m_dataItems.clear();
		self->scheduleReregistration();
		Q_EMIT self->dataItemsChanged();
	}
	static void dataItems_removeLast(QQmlListProperty<VeQuickItem> *prop) {
		MockDataRangeAnimator *self = static_cast<MockDataRangeAnimator*>(prop->data);
		if (!self->m_dataItems.isEmpty()) {
			self->m_dataItems.removeLast();
			self->scheduleReregistration();
			Q_EMIT self->dataItemsChanged();
		}
	}

	const int m_animatorId;
	QVector<VeQuickItem*> m_dataItems;
	QVector<qreal> m_actualStepSizes;
	QString m_totalTargetUid;
	QStringList m_derivedTargetUids;
	QStringList m_derivedDivisorUids;
	QStringList m_derivedMultiplyTargetUids;
	QStringList m_derivedMultiplierUids;
	QString m_derivedMultiplyTotalTargetUid;
	qreal m_minimumValue = 0.0;
	qreal m_maximumValue = 100.0;
	qreal m_stepSize = 1.0;
	qreal m_interval = 1000.0;
	bool m_repeat = true;
	bool m_active = false;
	bool m_complete = false;
	bool m_registered = false;
};

// Increments data values by a fixed step on each tick (no direction reversal).
// Use for monotonically increasing counters like generator runtime.
class MockDataStepper : public QObject, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QQmlListProperty<VeQuickItem> dataItems READ dataItems NOTIFY dataItemsChanged FINAL)
	Q_PROPERTY(qreal stepSize READ stepSize WRITE setStepSize NOTIFY stepSizeChanged FINAL)
	Q_PROPERTY(qreal interval READ interval WRITE setInterval NOTIFY intervalChanged FINAL)
	Q_PROPERTY(bool repeat READ repeat WRITE setRepeat NOTIFY repeatChanged FINAL)
	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)

	Q_CLASSINFO("DefaultProperty", "dataItems")
	Q_INTERFACES(QQmlParserStatus)

public:
	explicit MockDataStepper(QObject *parent = nullptr)
			: QObject(parent)
			, m_animatorId(s_nextAnimatorId.fetch_add(1)) {
	}

	~MockDataStepper() override {
		unregisterFromWorker();
	}

	QQmlListProperty<VeQuickItem> dataItems() {
		return QQmlListProperty<VeQuickItem>(
			this, this,
			MockDataStepper::dataItems_append,
			MockDataStepper::dataItems_count,
			MockDataStepper::dataItems_at,
			MockDataStepper::dataItems_clear,
			nullptr,
			MockDataStepper::dataItems_removeLast);
	}

	qreal stepSize() const { return m_stepSize; }
	void setStepSize(qreal v) {
		if (m_stepSize != v) {
			m_stepSize = v;
			scheduleReregistration();
			Q_EMIT stepSizeChanged();
		}
	}

	qreal interval() const { return m_interval; }
	void setInterval(qreal v) {
		if (m_interval != v) {
			m_interval = v;
			scheduleReregistration();
			Q_EMIT intervalChanged();
		}
	}

	bool repeat() const { return m_repeat; }
	void setRepeat(bool v) {
		if (m_repeat != v) {
			m_repeat = v;
			scheduleReregistration();
			Q_EMIT repeatChanged();
		}
	}

	bool active() const { return m_active; }
	void setActive(bool v) {
		if (m_active != v) {
			m_active = v;
			MockTimerWorker *worker = MockManager::create()->timerWorker();
			if (worker && m_registered) {
				QMetaObject::invokeMethod(worker, "setAnimatorActive",
					Qt::QueuedConnection, Q_ARG(int, m_animatorId), Q_ARG(bool, v));
			} else if (v && m_complete && !m_registered) {
				registerWithWorker();
			}
			Q_EMIT activeChanged();
		}
	}

Q_SIGNALS:
	void dataItemsChanged();
	void stepSizeChanged();
	void intervalChanged();
	void repeatChanged();
	void activeChanged();

protected:
	void classBegin() override {}
	void componentComplete() override {
		m_complete = true;
		if (m_active) {
			registerWithWorker();
		}
	}

private:
	void registerWithWorker() {
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (!worker || m_dataItems.isEmpty()) {
			return;
		}

		MockAnimatorConfig config;
		config.animatorId = m_animatorId;
		config.type = MockAnimatorConfig::Stepper;
		config.interval = m_interval;
		config.repeat = m_repeat;
		config.stepSize = m_stepSize;

		QHash<QString, QVariant> initialValues;
		for (VeQuickItem *item : m_dataItems) {
			if (item) {
				const QString uid = item->getUid();
				config.uids.append(uid);
				initialValues[uid] = item->getValue();
			} else {
				config.uids.append(QString());
			}
		}

		QMetaObject::invokeMethod(worker, "updateValues",
			Qt::QueuedConnection, Q_ARG(MockValueCache, initialValues));
		QMetaObject::invokeMethod(worker, "registerAnimator",
			Qt::QueuedConnection,
			Q_ARG(Victron::VenusOS::MockAnimatorConfig, config));

		m_registered = true;
	}

	void unregisterFromWorker() {
		if (!m_registered) return;
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (worker) {
			QMetaObject::invokeMethod(worker, "unregisterAnimator",
				Qt::QueuedConnection, Q_ARG(int, m_animatorId));
		}
		m_registered = false;
	}

	void scheduleReregistration() {
		if (!m_complete) return;
		if (m_registered) {
			unregisterFromWorker();
		}
		if (m_active) registerWithWorker();
	}

	static void dataItems_append(QQmlListProperty<VeQuickItem> *prop, VeQuickItem *object) {
		auto *self = static_cast<MockDataStepper*>(prop->data);
		self->m_dataItems.append(object);
		self->scheduleReregistration();
		Q_EMIT self->dataItemsChanged();
	}
	static qsizetype dataItems_count(QQmlListProperty<VeQuickItem> *prop) {
		return static_cast<MockDataStepper*>(prop->data)->m_dataItems.count();
	}
	static VeQuickItem *dataItems_at(QQmlListProperty<VeQuickItem> *prop, qsizetype index) {
		auto *self = static_cast<MockDataStepper*>(prop->data);
		return (index >= 0 && index < self->m_dataItems.count()) ? self->m_dataItems.at(index) : nullptr;
	}
	static void dataItems_clear(QQmlListProperty<VeQuickItem> *prop) {
		auto *self = static_cast<MockDataStepper*>(prop->data);
		self->m_dataItems.clear();
		self->scheduleReregistration();
		Q_EMIT self->dataItemsChanged();
	}
	static void dataItems_removeLast(QQmlListProperty<VeQuickItem> *prop) {
		auto *self = static_cast<MockDataStepper*>(prop->data);
		if (!self->m_dataItems.isEmpty()) {
			self->m_dataItems.removeLast();
			self->scheduleReregistration();
			Q_EMIT self->dataItemsChanged();
		}
	}

	const int m_animatorId;
	QVector<VeQuickItem*> m_dataItems;
	qreal m_stepSize = 1.0;
	qreal m_interval = 1000.0;
	bool m_repeat = true;
	bool m_active = false;
	bool m_complete = false;
	bool m_registered = false;
};

// Toggles data values between two specified values on each tick.
class MockDataToggler : public QObject, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QQmlListProperty<VeQuickItem> dataItems READ dataItems NOTIFY dataItemsChanged FINAL)
	Q_PROPERTY(QVariant valueA READ valueA WRITE setValueA NOTIFY valueAChanged FINAL)
	Q_PROPERTY(QVariant valueB READ valueB WRITE setValueB NOTIFY valueBChanged FINAL)
	Q_PROPERTY(qreal interval READ interval WRITE setInterval NOTIFY intervalChanged FINAL)
	Q_PROPERTY(bool repeat READ repeat WRITE setRepeat NOTIFY repeatChanged FINAL)
	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)

	Q_CLASSINFO("DefaultProperty", "dataItems")
	Q_INTERFACES(QQmlParserStatus)

public:
	explicit MockDataToggler(QObject *parent = nullptr)
			: QObject(parent)
			, m_animatorId(s_nextAnimatorId.fetch_add(1)) {
	}

	~MockDataToggler() override {
		unregisterFromWorker();
	}

	QQmlListProperty<VeQuickItem> dataItems() {
		return QQmlListProperty<VeQuickItem>(
			this, this,
			MockDataToggler::dataItems_append,
			MockDataToggler::dataItems_count,
			MockDataToggler::dataItems_at,
			MockDataToggler::dataItems_clear,
			nullptr,
			MockDataToggler::dataItems_removeLast);
	}

	QVariant valueA() const { return m_valueA; }
	void setValueA(const QVariant &v) {
		if (m_valueA != v) {
			m_valueA = v;
			scheduleReregistration();
			Q_EMIT valueAChanged();
		}
	}

	QVariant valueB() const { return m_valueB; }
	void setValueB(const QVariant &v) {
		if (m_valueB != v) {
			m_valueB = v;
			scheduleReregistration();
			Q_EMIT valueBChanged();
		}
	}

	qreal interval() const { return m_interval; }
	void setInterval(qreal v) {
		if (m_interval != v) {
			m_interval = v;
			scheduleReregistration();
			Q_EMIT intervalChanged();
		}
	}

	bool repeat() const { return m_repeat; }
	void setRepeat(bool v) {
		if (m_repeat != v) {
			m_repeat = v;
			scheduleReregistration();
			Q_EMIT repeatChanged();
		}
	}

	bool active() const { return m_active; }
	void setActive(bool v) {
		if (m_active != v) {
			m_active = v;
			MockTimerWorker *worker = MockManager::create()->timerWorker();
			if (worker && m_registered) {
				QMetaObject::invokeMethod(worker, "setAnimatorActive",
					Qt::QueuedConnection, Q_ARG(int, m_animatorId), Q_ARG(bool, v));
			} else if (v && m_complete && !m_registered) {
				registerWithWorker();
			}
			Q_EMIT activeChanged();
		}
	}

Q_SIGNALS:
	void dataItemsChanged();
	void valueAChanged();
	void valueBChanged();
	void intervalChanged();
	void repeatChanged();
	void activeChanged();

protected:
	void classBegin() override {}
	void componentComplete() override {
		m_complete = true;
		if (m_active) {
			registerWithWorker();
		}
	}

private:
	void registerWithWorker() {
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (!worker || m_dataItems.isEmpty()) {
			return;
		}

		MockAnimatorConfig config;
		config.animatorId = m_animatorId;
		config.type = MockAnimatorConfig::Toggler;
		config.interval = m_interval;
		config.repeat = m_repeat;
		config.toggleA = m_valueA;
		config.toggleB = m_valueB;

		QHash<QString, QVariant> initialValues;
		for (VeQuickItem *item : m_dataItems) {
			if (item) {
				const QString uid = item->getUid();
				config.uids.append(uid);
				initialValues[uid] = item->getValue();
			} else {
				config.uids.append(QString());
			}
		}

		QMetaObject::invokeMethod(worker, "updateValues",
			Qt::QueuedConnection, Q_ARG(MockValueCache, initialValues));
		QMetaObject::invokeMethod(worker, "registerAnimator",
			Qt::QueuedConnection,
			Q_ARG(Victron::VenusOS::MockAnimatorConfig, config));

		m_registered = true;
	}

	void unregisterFromWorker() {
		if (!m_registered) return;
		MockTimerWorker *worker = MockManager::create()->timerWorker();
		if (worker) {
			QMetaObject::invokeMethod(worker, "unregisterAnimator",
				Qt::QueuedConnection, Q_ARG(int, m_animatorId));
		}
		m_registered = false;
	}

	void scheduleReregistration() {
		if (!m_complete) return;
		if (m_registered) {
			unregisterFromWorker();
		}
		if (m_active) registerWithWorker();
	}

	static void dataItems_append(QQmlListProperty<VeQuickItem> *prop, VeQuickItem *object) {
		auto *self = static_cast<MockDataToggler*>(prop->data);
		self->m_dataItems.append(object);
		self->scheduleReregistration();
		Q_EMIT self->dataItemsChanged();
	}
	static qsizetype dataItems_count(QQmlListProperty<VeQuickItem> *prop) {
		return static_cast<MockDataToggler*>(prop->data)->m_dataItems.count();
	}
	static VeQuickItem *dataItems_at(QQmlListProperty<VeQuickItem> *prop, qsizetype index) {
		auto *self = static_cast<MockDataToggler*>(prop->data);
		return (index >= 0 && index < self->m_dataItems.count()) ? self->m_dataItems.at(index) : nullptr;
	}
	static void dataItems_clear(QQmlListProperty<VeQuickItem> *prop) {
		auto *self = static_cast<MockDataToggler*>(prop->data);
		self->m_dataItems.clear();
		self->scheduleReregistration();
		Q_EMIT self->dataItemsChanged();
	}
	static void dataItems_removeLast(QQmlListProperty<VeQuickItem> *prop) {
		auto *self = static_cast<MockDataToggler*>(prop->data);
		if (!self->m_dataItems.isEmpty()) {
			self->m_dataItems.removeLast();
			self->scheduleReregistration();
			Q_EMIT self->dataItemsChanged();
		}
	}

	const int m_animatorId;
	QVector<VeQuickItem*> m_dataItems;
	QVariant m_valueA;
	QVariant m_valueB;
	qreal m_interval = 1000.0;
	bool m_repeat = true;
	bool m_active = false;
	bool m_complete = false;
	bool m_registered = false;
};

}
}

#endif // VICTRON_GUIV2_MOCKANIMATORS_H
