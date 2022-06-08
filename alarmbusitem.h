#ifndef ALARMBUSITEM_H
#define ALARMBUSITEM_H

#include <QObject>
#include <QLinkedList>

#include <velib/qt/ve_qitem.hpp>

#include "alarmmonitor.h"
#include <dbus_services.h>
#include <dbus_service.h>

// Object containing the alarms being monitored in a certain service
class DeviceAlarms : public QObject {
	Q_OBJECT

public:
	DeviceAlarms(DBusService *service, NotificationCenter *noticationCenter) :
		QObject(service),
		mService(service),
		mNotificationCenter(noticationCenter)
	{
	}

	/* ok, warning, alarm types */
	AlarmMonitor *addTripplet(const QString &description, const QString &busitemPathAlarm,
							const QString &busitemSetting = "", const QString &busitemPathValue = "");
	void addVebusError(const QString &busitemPathAlarm);
	void addBmsError(const QString &busitemPathAlarm);
	void addChargerError(const QString &busitemPathAlarm);
	void addWakespeedError(const QString &busitemPathAlarm);

	static DeviceAlarms *createBatteryAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createSolarChargerAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createAcChargerAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createInverterAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createMultiRsAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createSystemCalcAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createGeneratorStartStopAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createDigitalInputAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createVecanAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createEssAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createTankAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createDcMeterAlarms(DBusService *service, NotificationCenter *noticationCenter);
	static DeviceAlarms *createAlternatorAlarms(DBusService *service, NotificationCenter *noticationCenter);

	NotificationCenter *notificationCenter() { return mNotificationCenter; }

protected:
	DBusService *mService;
	QLinkedList<AlarmMonitor *> mAlarms;
	NotificationCenter *mNotificationCenter;
};

// Object to add alarms to the discovered services
class AlarmBusitem : public QObject
{
	Q_OBJECT

public:
	explicit AlarmBusitem(DBusServices *services, NotificationCenter *notificationCenter);

public slots:
	void dbusServiceFound(DBusService *service);

private:
	NotificationCenter *mNotificationCenter;
};

class VebusAlarms : public DeviceAlarms {
	Q_OBJECT

public:
	VebusAlarms(DBusService *service, NotificationCenter *noticationCenter);

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
	BatteryAlarms(DBusService *service, NotificationCenter *noticationCenter);

private slots:
	void numberOfDistributorsChanged(VeQItem *item, QVariant value);

private:
	VeQItem *mNrOfDistributors;
	bool mDistributorAlarmsAdded;
};

#endif
