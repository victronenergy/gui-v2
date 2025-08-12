/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKANIMATORS_H
#define VICTRON_GUIV2_MOCKANIMATORS_H

#include "mockmanager.h"

#include <veutil/qt/ve_quick_item.hpp>

#include <QObject>
#include <QQmlEngine>
#include <QQmlListProperty>
#include <QRandomGenerator>
#include <QTimerEvent>
#include <qcoreevent.h>

namespace Victron {
namespace VenusOS {

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

	Q_CLASSINFO("DefaultProperty", "dataItems")
	Q_INTERFACES(QQmlParserStatus)

public:
	explicit MockDataRandomizer(QObject *parent = nullptr)
			: QObject(parent) {
		MockManager *manager = MockManager::create();
		connect(manager, &MockManager::timersActiveChanged,
				this, [this, manager] {
					if (manager->timersActive()) {
						maybeStartTimer();
					} else if (m_timerId > 0) {
						killTimer(m_timerId);
						m_timerId = 0;
					}
				});
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
			Q_EMIT deltaLowChanged();
		}
	}

	qreal deltaHigh() const { return m_deltaHigh; }
	void setDeltaHigh(qreal v) {
		if (m_deltaHigh != v) {
			m_deltaHigh = v;
			Q_EMIT deltaHighChanged();
		}
	}

	qreal minimumValue() const { return m_minimumValue; }
	void setMinimumValue(qreal v) {
		if (m_minimumValue != v) {
			m_minimumValue = v;
			Q_EMIT minimumValueChanged();
		}
	}

	qreal maximumValue() const { return m_maximumValue; }
	void setMaximumValue(qreal v) {
		if (m_maximumValue != v) {
			m_maximumValue = v;
			Q_EMIT maximumValueChanged();
		}
	}

	qreal followSignOf() const { return m_followSignOf; }
	void setFollowSignOf(qreal v) {
		if (m_followSignOf != v) {
			m_followSignOf = v;
			Q_EMIT followSignOfChanged();
		}
	}

	qreal interval() const { return m_interval; }
	void setInterval(qreal v) {
		if (m_interval != v) {
			m_interval = v;
			if (m_timerId > 0) {
				killTimer(m_timerId);
				m_timerId = 0;
			}
			maybeStartTimer();
			Q_EMIT intervalChanged();
		}
	}

	bool repeat() const { return m_repeat; }
	void setRepeat(bool v) {
		if (m_repeat != v) {
			m_repeat = v;
			if (m_repeat) {
				maybeStartTimer();
			}
			Q_EMIT repeatChanged();
		}
	}

	bool active() const { return m_active; }
	void setActive(bool v) {
		if (m_active != v) {
			m_active = v;
			if (m_timerId > 0) {
				killTimer(m_timerId);
				m_timerId = 0;
			}
			maybeStartTimer();
			Q_EMIT activeChanged();
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

protected:
	// QQmlParserStatus
	void classBegin() override {}
	void componentComplete() override {
		m_complete = true;
		maybeStartTimer();
	}

	// QObject
	void timerEvent(QTimerEvent *event) override {
		if (event->timerId() != m_timerId) {
			return;
		}

		qreal total = 0.0;

		for (qsizetype i = 0; i < m_dataItems.count(); ++i) {
			VeQuickItem *item = m_dataItems[i];
			if (!item) {
				continue;
			}

			bool ok = false;
			const QVariant v = item->getValue();
			const qreal rv = v.toReal(&ok);
			if (!ok || qIsNaN(rv)) {
				continue;
			}

			const qreal high = qIsNaN(m_deltaHigh)
				? (rv * 1.1)
				: (rv + m_deltaHigh);

			const qreal low = qIsNaN(m_deltaLow)
				? (rv * 0.9)
				: (rv - m_deltaLow);

			qreal newValue = (QRandomGenerator::global()->bounded(1.0) * (high - low)) + low;
			if (!qIsNaN(m_followSignOf)) {
				newValue = qAbs(newValue) * (m_followSignOf < 0.0 ? -1.0 : 1.0);
			}
			if (!qIsNaN(m_minimumValue)) {
				newValue = qMax(m_minimumValue, newValue);
			}
			if (!qIsNaN(m_maximumValue)) {
				newValue = qMin(m_maximumValue, newValue);
			}

			item->setValue(newValue);
			total += newValue;
			Q_EMIT notifyUpdate(i, newValue);
		}
		Q_EMIT notifyTotal(total);

		if (!m_repeat) {
			killTimer(m_timerId);
			m_timerId = 0;
		}
	}

	void maybeStartTimer() {
		MockManager *manager = MockManager::create();
		if (manager->timersActive()
				&& m_complete
				&& m_active
				&& m_interval > 0
				&& m_timerId == 0) {
			m_timerId = startTimer(m_interval);
		}
	}

private:
	static void dataItems_append(QQmlListProperty<VeQuickItem> *prop, VeQuickItem *object) {
		MockDataRandomizer *self = static_cast<MockDataRandomizer*>(prop->data);
		self->m_dataItems.append(object);
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
		Q_EMIT self->dataItemsChanged();
	}
	static void dataItems_removeLast(QQmlListProperty<VeQuickItem> *prop) {
		MockDataRandomizer *self = static_cast<MockDataRandomizer*>(prop->data);
		if (!self->m_dataItems.isEmpty()) {
			self->m_dataItems.removeLast();
			Q_EMIT self->dataItemsChanged();
		}
	}
	QVector<VeQuickItem*> m_dataItems;
	qreal m_deltaLow = qQNaN();
	qreal m_deltaHigh = qQNaN();
	qreal m_minimumValue = qQNaN();
	qreal m_maximumValue = qQNaN();
	qreal m_followSignOf = qQNaN();
	qreal m_interval = 1000.0;
	int m_timerId = 0;
	bool m_repeat = true;
	bool m_active = true;
	bool m_complete = false;
};

}
}

#endif // VICTRON_GUIV2_MOCKANIMATORS_H
