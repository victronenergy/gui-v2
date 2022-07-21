#ifndef ALARMMONITOR_H
#define ALARMMONITOR_H

#include <QObject>
#include <velib/qt/ve_qitem.hpp>

#include <gui-v1/dbus_service.h>
#include <src/notificationsmodel.h>

class DeviceAlarms;

class AlarmMonitor : public QObject
{
	Q_OBJECT

public:
	enum Type {
		REGULAR,
		VEBUS_ERROR,
		CHARGER_ERROR,
		BMS_ERROR,
		WAKESPEED_ERROR
	};

	enum Enabled {
		NO_ALARM,
		ALARM_ONLY,
		ALARM_AND_WARNING
	};

	enum DbusAlarm {
		DBUS_NO_ERROR,
		DBUS_WARNING,
		DBUS_ERROR
	};

	explicit AlarmMonitor(DBusService *service, Type type, const QString &busitemPathAlarm,
						  const QString &description = "", const QString &busitemSetting = "",
						  const QString &busitemPathValue = "", DeviceAlarms *parent = 0);

	~AlarmMonitor();
	void setDescription(QString description) {mDescription = description; }

private slots:
	void notificationDestroyed();
	void settingChanged(VeQItem * item, QVariant var);
	void updateAlarm(VeQItem *item, QVariant var);

private:
	DBusService *mService;
	VeQItem *mBusitemValue;
	VeQItem *mAlarmTrigger;
	Type mType;
	QString mDescription;
	Enabled mEnabledNotifications;
	DeviceAlarms *mDeviceAlarms;

	bool mustBeShown(DbusAlarm alarm);
	void addOrUpdateNotification(Victron::VenusOS::Enums::Notification_Type type);
};

#endif
