#include "alarmmonitor.h"
#include "alarmbusitem.h"
#include "wakespeed_error.hpp"

#include <veutil/qt/vebus_error.hpp>

AlarmMonitor::AlarmMonitor(DBusService *service, Type type, const QString &busitemPathAlarm,
			const QString &description, const QString &alarmEnablePath,
			const QString &alarmValuePath, DeviceAlarms *parent) :
	QObject(parent), mService(service), mAlarmTrigger(0), mType(type),
	mDescription(description), mDeviceAlarms(parent)
{
	// Alarms can optionally be enabled / supressed by a setting.
	if (!alarmEnablePath.isEmpty()) {
		mEnabledNotifications = NO_ALARM;
		// FIXME: get this from the settings provider
		QString id("dbus/com.victronenergy.settings/Settings/Alarm" + alarmEnablePath);
		VeQItems::getRoot()->itemGetOrCreate(id)->getValueAndChanges(this, SLOT(settingChanged(QVariant)));
	} else {
		mEnabledNotifications = ALARM_AND_WARNING;
	}

	// Optionally an value can be associated with an alarm, e.g. voltage
	// for an low voltage alarm.
	if (!alarmValuePath.isEmpty()) {
		mBusitemValue = service->item(alarmValuePath);
		mBusitemValue->getText();
	} else {
		mBusitemValue = new VeQItem(0, this);
	}

	// The actual trigger of the alarm, see Type for the supported formats.
	mAlarmTrigger = service->item(busitemPathAlarm);
	mAlarmTrigger->getValueAndChanges(this, SLOT(updateAlarm(QVariant)));
}

AlarmMonitor::~AlarmMonitor()
{
}

bool AlarmMonitor::mustBeShown(DbusAlarm alarm)
{
	if (alarm == DBUS_NO_ERROR)
		return false;

	if (mEnabledNotifications == ALARM_ONLY && alarm == DBUS_WARNING)
		return false;

	return true;
}

void AlarmMonitor::updateAlarm(QVariant var)
{
	if (!var.isValid() || mEnabledNotifications == NO_ALARM)
		return;

	DbusAlarm alarm = DBUS_NO_ERROR;
	switch (mType)
	{
	case REGULAR:
		alarm = static_cast<DbusAlarm>(var.toInt());
		break;
	case VEBUS_ERROR:
	{
		int vebusErrorCode = var.toInt();
		if (vebusErrorCode == 0) {
			alarm = DBUS_NO_ERROR;
		} else {
			alarm = DBUS_ERROR;
			mDescription = VebusError::getDescription(vebusErrorCode);
		}
		break;
	}
	case BMS_ERROR:
	{
		int error = var.toInt();
		if (error == 0) {
			alarm = DBUS_NO_ERROR;
		} else {
			alarm = DBUS_ERROR;
			//FIXME: get from veutil when BmsError is ported there
			//mDescription = BmsError::getDescription(error);
			mDescription = "BMS error";
		}
		break;
	}
	case CHARGER_ERROR:
	{
		int error = var.toInt();
		if (error == 0) {
			alarm = DBUS_NO_ERROR;
		} else {
			//FIXME: get from veutil when ChargerError is ported there
			//alarm = ChargerError::isWarning(error) ? DBUS_WARNING : DBUS_ERROR;
			//mDescription = ChargerError::getDescription(error);
			alarm = DBUS_ERROR;
			mDescription = "Charger error";
		}
		break;
	}
	case WAKESPEED_ERROR:
	{
		int error = var.toInt();
		if (error == 0) {
			alarm = DBUS_NO_ERROR;
		} else {
			alarm = WakespeedError::isWarning(error) ? DBUS_WARNING : DBUS_ERROR;
			mDescription = WakespeedError::getDescription(error);
		}
		break;
	}
	default:
		break;
	}

	addOrUpdateNotification(alarm == DBUS_NO_ERROR ? Victron::VenusOS::Enums::Notification_Inactive :
											 alarm == DBUS_WARNING ? Victron::VenusOS::Enums::Notification_Warning :
																	 Victron::VenusOS::Enums::Notification_Alarm );

}

// Copied to mEnabledNotifications since having the enabled as a setting is optional
void AlarmMonitor::settingChanged(QVariant var)
{
	mEnabledNotifications = static_cast<Enabled>(var.toInt());
	if (mAlarmTrigger)
		updateAlarm(mAlarmTrigger->getValue());
}

void AlarmMonitor::addOrUpdateNotification(Victron::VenusOS::Enums::Notification_Type type)
{
	Victron::VenusOS::ActiveNotificationsModel::instance()->addOrUpdateNotification(type, mService->getDescription(),
														  mDescription, mBusitemValue->getText());
}

void AlarmMonitor::notificationDestroyed()
{
}
