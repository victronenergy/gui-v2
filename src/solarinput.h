/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SOLARINPUT_H
#define VICTRON_GUIV2_SOLARINPUT_H

#include <QtGlobal>
#include <QObject>
#include <QPointer>
#include <QMap>

#include "device.h"

#include <veutil/qt/ve_qitem.hpp>

namespace Victron {
namespace VenusOS {

/*
	Provides metadata and measurements for a solar input source, such as a single PV tracker, or
	a PV inverter service.
*/
class SolarInput : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString serviceUid READ serviceUid CONSTANT FINAL)
	Q_PROPERTY(QString serviceType READ serviceType CONSTANT FINAL)
	Q_PROPERTY(QString group READ group CONSTANT FINAL)
	Q_PROPERTY(QString name READ name NOTIFY nameChanged FINAL)
	Q_PROPERTY(bool enabled READ isEnabled NOTIFY enabledChanged FINAL)
	Q_PROPERTY(qreal todaysYield READ todaysYield NOTIFY todaysYieldChanged FINAL)
	Q_PROPERTY(qreal power READ power NOTIFY powerChanged FINAL)
	Q_PROPERTY(qreal current READ current NOTIFY currentChanged FINAL)
	Q_PROPERTY(qreal voltage READ voltage NOTIFY voltageChanged FINAL)

public:
	explicit SolarInput(const QString &serviceUid, const QString &group, QObject *parent = nullptr);

	QString serviceUid() const;
	QString serviceType() const;
	QString group() const;

	QString name() const;
	void setName(const QString &name);

	bool isEnabled() const;
	void setEnabled(const QVariant &enabled);

	qreal todaysYield() const;
	void setTodaysYield(const QVariant &todaysYield);

	qreal power() const;
	void setPower(const QVariant &power);

	qreal current() const;
	void setCurrent(const QVariant &current);

	qreal voltage() const;
	void setVoltage(const QVariant &voltage);

Q_SIGNALS:
	void enabledChanged();
	void nameChanged();
	void todaysYieldChanged();
	void powerChanged();
	void currentChanged();
	void voltageChanged();

protected:
	QString m_serviceUid;
	QString m_group;
	QString m_name;
	qreal m_todaysYield = qQNaN();
	qreal m_power = qQNaN();
	qreal m_current = qQNaN();
	qreal m_voltage = qQNaN();
	bool m_enabled = true;
};

/*
	Provides a solar input for a single tracker from a solarcharger, multi or inverter service.
*/
class TrackerSolarInput : public SolarInput
{
	Q_OBJECT
public:
	explicit TrackerSolarInput(Device *device, bool isSingleTrackerDevice, int trackerIndex, QObject *parent = nullptr);

	static bool isEnabledTracker(VeQItem *serviceItem, int trackerIndex);

private:
	void daysAvailableChanged(QVariant value);
	void updateName();
	void updatePower(const QVariant &value);
	void updateVoltage(const QVariant &value);
	void updateCurrent();

	QPointer<VeQItem> m_daysAvailableItem;
	QPointer<VeQItem> m_nameItem;
	QPointer<VeQItem> m_enabledItem;
	QPointer<VeQItem> m_todaysYieldItem;
	QPointer<VeQItem> m_powerItem;
	QPointer<VeQItem> m_voltageItem;
	Device *m_device = nullptr;
	int m_trackerIndex = 0;
	bool m_isSingleTrackerDevice = false;
};

/*
	Provides a solar input for a pvinverter service.

	The power value is the total power for all phases. If there is only a single phase with valid
	values, the current and voltage are for that phase; if there are multiple phases, the current
	and voltage are NaN, as these cannot be summed across multiple phases.
*/
class PvInverterSolarInput : public SolarInput
{
	Q_OBJECT
public:
	explicit PvInverterSolarInput(Device *device, QObject *parent = nullptr);

private:
	struct AcPhase {
		qreal current = qQNaN();
		qreal voltage = qQNaN();
	};

	bool isPhaseId(const QString &childId) const;
	void acChildAdded(VeQItem *child);
	void acChildAboutToBeRemoved(VeQItem *child);
	void addPhase(VeQItem *phaseItem);
	void updateSinglePhaseValues();

	QPointer<VeQItem> m_acItem;
	QPointer<VeQItem> m_powerItem;
	QMap<QString, AcPhase> m_phases;
	Device *m_device = nullptr;
};


} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SOLARINPUT_H
