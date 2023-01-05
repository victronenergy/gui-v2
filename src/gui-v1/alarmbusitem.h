#ifndef ALARMBUSITEM_H
#define ALARMBUSITEM_H

#include <QObject>
#include <list>

#include <veutil/qt/ve_qitem.hpp>

#include "alarmmonitor.h"
#include <gui-v1/dbus_services.h>
#include <gui-v1/dbus_service.h>

namespace Victron {
namespace VenusOS {
class ActiveNotificationsModel;
}
}

// Object containing the alarms being monitored in a certain service
class DeviceAlarms : public QObject {
	Q_OBJECT

public:
	DeviceAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter) :
		QObject(service),
		mService(service),
		mActiveNotificationModel(noticationCenter)
	{
	}

	/* ok, warning, alarm types */
	AlarmMonitor *addTripplet(const QString &description, const QString &busitemPathAlarm,
							const QString &busitemSetting = "", const QString &busitemPathValue = "");
	void addVebusError(const QString &busitemPathAlarm);
	void addBmsError(const QString &busitemPathAlarm);
	void addChargerError(const QString &busitemPathAlarm);
	void addWakespeedError(const QString &busitemPathAlarm);

	static DeviceAlarms *createBatteryAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createSolarChargerAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createAcChargerAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createInverterAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createMultiRsAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createSystemCalcAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createGeneratorStartStopAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createDigitalInputAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createVecanAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createEssAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createTankAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createDcMeterAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);
	static DeviceAlarms *createAlternatorAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);

	Victron::VenusOS::ActiveNotificationsModel *notificationCenter() { return mActiveNotificationModel; }

protected:
	DBusService *mService;
	std::list<AlarmMonitor *> mAlarms;
	Victron::VenusOS::ActiveNotificationsModel *mActiveNotificationModel;
};

// Object to add alarms to the discovered services
class AlarmBusitem : public QObject
{
	Q_OBJECT

public:
	explicit AlarmBusitem(DBusServices *services, Victron::VenusOS::ActiveNotificationsModel *notificationCenter);

public slots:
	void dbusServiceFound(DBusService *service);

private:
	Victron::VenusOS::ActiveNotificationsModel *mActiveNotificationModel;
};

class VebusAlarms : public DeviceAlarms {
	Q_OBJECT

public:
	VebusAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);

	QString highTempTextL1(bool single) { return single ? tr("High Temperature") : tr("High Temperature on L1"); }
	QString inverterOverloadTextL1(bool single) { return single ? tr("Inverter overload") : tr("Inverter overload on L1"); }

	void init(bool single);

	void update(bool single);

private slots:
	void numberOfPhasesChanged(VeQItem *item, QVariant value);
	void connectionTypeChanged(VeQItem *item, QVariant value);

private:
	VeQItem *mNumberOfPhases;
	VeQItem *mConnectionType;
	AlarmMonitor *highTempTextL1Alarm;
	AlarmMonitor *inverterOverloadTextL1Alarm;
};

class BatteryAlarms : public DeviceAlarms {
	Q_OBJECT

public:
	BatteryAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter);

private slots:
	void numberOfDistributorsChanged(QVariant value);

private:
	VeQItem *mNrOfDistributors;
	bool mDistributorAlarmsAdded;
};

#endif
