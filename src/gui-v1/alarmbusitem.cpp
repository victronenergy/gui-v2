#include <QDebug>
#include <QEvent>

#include "alarmbusitem.h"

/* ok, warning, alarm types */
AlarmMonitor *DeviceAlarms::addTripplet(const QString &description, const QString &busitemPathAlarm,
						const QString &busitemSetting, const QString &busitemPathValue)
{
	AlarmMonitor *ret = new AlarmMonitor(mService, AlarmMonitor::REGULAR, busitemPathAlarm,
										 description, busitemSetting, busitemPathValue, this);
	mAlarms.push_back(ret);
	return ret;
}

void DeviceAlarms::addVebusError(const QString &busitemPathAlarm)
{
	mAlarms.push_back(new AlarmMonitor(mService, AlarmMonitor::VEBUS_ERROR, busitemPathAlarm, "", "", "", this));
}

void DeviceAlarms::addBmsError(const QString &busitemPathAlarm)
{
	mAlarms.push_back(new AlarmMonitor(mService, AlarmMonitor::BMS_ERROR, busitemPathAlarm, "", "", "", this));
}

void DeviceAlarms::addChargerError(const QString &busitemPathAlarm)
{
	mAlarms.push_back(new AlarmMonitor(mService, AlarmMonitor::CHARGER_ERROR, busitemPathAlarm, "", "", "", this));
}

void DeviceAlarms::addWakespeedError(const QString &busitemPathAlarm)
{
	mAlarms.push_back(new AlarmMonitor(mService, AlarmMonitor::WAKESPEED_ERROR, busitemPathAlarm, "", "", "", this));
}

DeviceAlarms *DeviceAlarms::createBatteryAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	return new BatteryAlarms(service, noticationCenter);
}

DeviceAlarms *DeviceAlarms::createGeneratorStartStopAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Generator not detected at AC input"), "/Alarms/NoGeneratorAtAcIn", "", "");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createDigitalInputAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet("", "/Alarm", "", "");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createSolarChargerAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Low battery voltage"),		"/Alarms/LowVoltage",			"",		"/Dc/0/Voltage");
	alarms->addTripplet(tr("High battery voltage"),		"/Alarms/HighVoltage",			"",		"/Dc/0/Voltage");
	alarms->addChargerError("/ErrorCode");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createAcChargerAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Low battery voltage"),		"/Alarms/LowVoltage",			"",		"/Dc/0/Voltage");
	alarms->addTripplet(tr("High battery voltage"),		"/Alarms/HighVoltage",			"",		"/Dc/0/Voltage");
	alarms->addChargerError("/ErrorCode");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createInverterAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Low battery voltage"),		"/Alarms/LowVoltage",			"",		"/Dc/0/Voltage");
	alarms->addTripplet(tr("High battery voltage"),		"/Alarms/HighVoltage",			"",		"/Dc/0/Voltage");
	alarms->addTripplet(tr("Low AC voltage"),			"/Alarms/LowVoltageAcOut",		"",		"/Ac/Out/L1/V");
	alarms->addTripplet(tr("High AC voltage"),			"/Alarms/HighVoltageAcOut",		"",		"/Ac/Out/L1/V");
	alarms->addTripplet(tr("Low temperature"),			"/Alarms/LowTemperature",		"",		"");
	alarms->addTripplet(tr("High temperature"),			"/Alarms/HighTemperature",		"",		"");
	alarms->addTripplet(tr("Inverter overload"),		"/Alarms/Overload",				"",		"/Ac/Out/L1/I");
	alarms->addTripplet(tr("High DC ripple"),			"/Alarms/Ripple",				"",		"");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createMultiRsAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Low battery voltage"),		"/Alarms/LowVoltage",			"",		"/Dc/0/Voltage");
	alarms->addTripplet(tr("High battery voltage"),		"/Alarms/HighVoltage",			"",		"/Dc/0/Voltage");
	alarms->addTripplet(tr("Low AC voltage"),			"/Alarms/LowVoltageAcOut",		"",		""); /* Single phase is not always on L1 */
	alarms->addTripplet(tr("High AC voltage"),			"/Alarms/HighVoltageAcOut",		"",		""); /* Single phase is not always on L1 */
	alarms->addTripplet(tr("High temperature"),			"/Alarms/HighTemperature",		"",		"");
	alarms->addTripplet(tr("Inverter overload"),		"/Alarms/Overload",				"",		""); /* Single phase is not always on L1 */
	alarms->addTripplet(tr("High DC ripple"),			"/Alarms/Ripple",				"",		"");
	alarms->addChargerError("/ErrorCode");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createSystemCalcAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Circuit breaker tripped"), "/Dc/Battery/Alarms/CircuitBreakerTripped", "", "");
	alarms->addTripplet(tr("DVCC with incompatible firmware #48"), "/Dvcc/Alarms/FirmwareInsufficient", "", "");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createVecanAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet("Please set the VE.Can number to a free one", "/Alarms/SameUniqueNameUsed", "", "");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createEssAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Grid meter not found #49"), "/Alarms/NoGridMeter", "", "");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createTankAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Low level alarm"),  "/Alarms/Low/State",  "", "/Level");
	alarms->addTripplet(tr("High level alarm"), "/Alarms/High/State", "", "/Level");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createDcMeterAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = new DeviceAlarms(service, noticationCenter);

	alarms->addTripplet(tr("Low voltage"),		"/Alarms/LowVoltage",			"",		"/Dc/0/Voltage");
	alarms->addTripplet(tr("High voltage"),		"/Alarms/HighVoltage",			"",		"/Dc/0/Voltage");
	alarms->addTripplet(tr("Low aux voltage"),	"/Alarms/LowStarterVoltage",	"",		"/Dc/1/Voltage");
	alarms->addTripplet(tr("High aux voltage"),	"/Alarms/HighStarterVoltage",	"",		"/Dc/1/Voltage");
	alarms->addTripplet(tr("Low temperature"),	"/Alarms/LowTemperature",		"",		"/Dc/0/Temperature");
	alarms->addTripplet(tr("High Temperature"),	"/Alarms/HighTemperature",		"",		"/Dc/0/Temperature");

	return alarms;
}

DeviceAlarms *DeviceAlarms::createAlternatorAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter)
{
	DeviceAlarms *alarms = createDcMeterAlarms(service, noticationCenter);

	/* Wakespeed is the only alternator controller we support for now */
	alarms->addWakespeedError("/ErrorCode");

	return alarms;
}

AlarmBusitem::AlarmBusitem(DBusServices *services, Victron::VenusOS::ActiveNotificationsModel *notificationCenter) :
	QObject(services),
	mActiveNotificationModel(notificationCenter)
{
	connect(services, SIGNAL(dbusServiceFound(DBusService*)), SLOT(dbusServiceFound(DBusService*)));
}

void AlarmBusitem::dbusServiceFound(DBusService *service)
{
	switch (service->getType())
	{
	case DBusService::DBUS_SERVICE_BATTERY:
		DeviceAlarms::createBatteryAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_FUELCELL:
	case DBusService::DBUS_SERVICE_DCSOURCE:
	case DBusService::DBUS_SERVICE_DCLOAD:
	case DBusService::DBUS_SERVICE_DCSYSTEM:
		DeviceAlarms::createDcMeterAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_ALTERNATOR:
		DeviceAlarms::createAlternatorAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_MULTI:
		new VebusAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_MULTI_RS:
		DeviceAlarms::createMultiRsAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_SOLAR_CHARGER:
		DeviceAlarms::createSolarChargerAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_AC_CHARGER:
		DeviceAlarms::createAcChargerAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_INVERTER:
		DeviceAlarms::createInverterAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_SYSTEM_CALC:
		DeviceAlarms::createSystemCalcAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_GENERATOR_STARTSTOP:
		DeviceAlarms::createGeneratorStartStopAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_DIGITAL_INPUT:
		DeviceAlarms::createDigitalInputAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_VECAN:
		DeviceAlarms::createVecanAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_HUB4:
		DeviceAlarms::createEssAlarms(service, mActiveNotificationModel);
		break;
	case DBusService::DBUS_SERVICE_TANK:
		DeviceAlarms::createTankAlarms(service, mActiveNotificationModel);
		break;
	default:
		;
	}
}

VebusAlarms::VebusAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter) : DeviceAlarms(service, noticationCenter)
{
	mNumberOfPhases = service->item("/Ac/NumberOfPhases");
	mNumberOfPhases->getValueAndChanges(this, SLOT(numberOfPhasesChanged(VeQItem *, QVariant)));
	mConnectionType = service->item("/Mgmt/Connection");
	mConnectionType->getValueAndChanges(this, SLOT(connectionTypeChanged(VeQItem*,QVariant)));
}

void VebusAlarms::init(bool single)
{
	addVebusError("/VebusError");
	addTripplet(tr("Temperature sense error"),	"/Alarms/TemperatureSensor",	"/Vebus/TemperatureSenseError");
	addTripplet(tr("Voltage sense error"),		"/Alarms/VoltageSensor",		"/Vebus/VoltageSenseError");
	addTripplet(tr("Low battery voltage"),		"/Alarms/LowBattery",			"/Vebus/LowBattery",			"/Dc/0/Voltage");
	addTripplet(tr("High DC ripple"),			"/Alarms/Ripple",				"/Vebus/HighDcRipple");
	addTripplet(tr("Wrong phase rotation detected"), "/Alarms/PhaseRotation");

	// Phase 1 (note the description depends on the number of phases!)
	highTempTextL1Alarm = addTripplet(highTempTextL1(single),					"/Alarms/L1/HighTemperature",	"/Vebus/HighTemperature");
	inverterOverloadTextL1Alarm = addTripplet(inverterOverloadTextL1(single),	"/Alarms/L1/Overload",			"/Vebus/InverterOverload");
	// Phase 2
	addTripplet(tr("High Temperature on L2"),	"/Alarms/L2/HighTemperature",	"/Vebus/HighTemperature");
	addTripplet(tr("Inverter overload on L2"),	"/Alarms/L2/Overload",			"/Vebus/InverterOverload");
	// Phase 3
	addTripplet(tr("High Temperature on L3"),	"/Alarms/L3/HighTemperature",	"/Vebus/HighTemperature");
	addTripplet(tr("Inverter overload on L3"),	"/Alarms/L3/Overload",			"/Vebus/InverterOverload");

	// Grid alarm
	addTripplet(tr("Grid lost"),				"/Alarms/GridLost");

	// DC voltage and current alarms
	addTripplet(tr("High DC voltage"),			"/Alarms/HighDcVoltage",		"/Vebus/HighDcVoltage");
	addTripplet(tr("High DC current"),			"/Alarms/HighDcCurrent",		"/Vebus/HighDcCurrent");
}

void VebusAlarms::update(bool single)
{
	// update phase 1 (note the description depends on the number of phases!)
	highTempTextL1Alarm->setDescription(highTempTextL1(single));
	inverterOverloadTextL1Alarm->setDescription(inverterOverloadTextL1(single));
}

void VebusAlarms::connectionTypeChanged(VeQItem *item, QVariant value)
{
	Q_UNUSED(item);

	if (value.isValid() && value.value<QString>() == "VE.Can") {
		// backwards compatible, the CAN-bus sends these e.g.
		addTripplet(tr("High Temperature"),			"/Alarms/HighTemperature",		"/Vebus/HighTemperature");
		addTripplet(tr("Inverter overload"),		"/Alarms/Overload",				"/Vebus/InverterOverload");
		mConnectionType->disconnect(this, SLOT(connectionTypeChanged(VeQItem*,QVariant)));
	}
}

void VebusAlarms::numberOfPhasesChanged(VeQItem *item, QVariant value)
{
	Q_UNUSED(item);

	if (!value.isValid())
		return;

	bool singlePhase = value.toInt() == 1;
	if (mAlarms.empty()) {
		init(singlePhase);
	} else {
		update(singlePhase);
	}
}
/* TODO - declare translatable strings like this:
static const char * const ids[] = {
	//% "High Temperature"
	QT_TRID_NOOP("high_temperature")
};

... and then, 

	addTripplet(tr("high_temperature"),			"/Alarms/HighTemperature",		"",		"/Dc/0/Temperature");
*/
BatteryAlarms::BatteryAlarms(DBusService *service, Victron::VenusOS::ActiveNotificationsModel *noticationCenter) :
	DeviceAlarms(service, noticationCenter), mDistributorAlarmsAdded(false)
{
	mNrOfDistributors = service->item("/NrOfDistributors");
	mNrOfDistributors->getValueAndChanges(this, SLOT(numberOfDistributorsChanged(VeQItem *, QVariant)));

	addTripplet(tr("Low voltage"),				"/Alarms/LowVoltage",			"",		"/Dc/0/Voltage");
	addTripplet(tr("High voltage"),				"/Alarms/HighVoltage",			"",		"/Dc/0/Voltage");
	addTripplet(tr("High current"),				"/Alarms/HighCurrent",			"",		"/Dc/0/Current");
	addTripplet(tr("High charge current"),		"/Alarms/HighChargeCurrent",	"",		"/Dc/0/Current");
	addTripplet(tr("High discharge current"),	"/Alarms/HighDischargeCurrent",	"",		"/Dc/0/Current");
	addTripplet(tr("High charge temperature"),	"/Alarms/HighChargeTemperature", "",	"/Dc/0/Temperature");
	addTripplet(tr("Low charge temperature"),	"/Alarms/LowChargeTemperature", "",		"/Dc/0/Temperature");
	addTripplet(tr("Low SOC"),					"/Alarms/LowSoc",				"",		"/Soc");
	addTripplet(tr("State of health"),			"/Alarms/StateOfHealth",		"",		"/Soh");
	addTripplet(tr("Low starter voltage"),		"/Alarms/LowStarterVoltage",	"",		"/Dc/1/Voltage");
	addTripplet(tr("High starter voltage"),		"/Alarms/HighStarterVoltage",	"",		"/Dc/1/Voltage");
	addTripplet(tr("Low temperature"),			"/Alarms/LowTemperature",		"",		"/Dc/0/Temperature");
	addTripplet(tr("High Temperature"),			"/Alarms/HighTemperature",		"",		"/Dc/0/Temperature");
	addTripplet(tr("Mid-point voltage"),		"/Alarms/MidVoltage",			"",		"/Dc/0/MidVoltageDeviation");
	addTripplet(tr("Low-fused voltage"),		"/Alarms/LowFusedVoltage",		"",		"/Dc/1/Voltage");
	addTripplet(tr("High-fused voltage"),		"/Alarms/HighFusedVoltage",		"",		"/Dc/1/Voltage");
	addTripplet(tr("Fuse blown"),				"/Alarms/FuseBlown",			"",		"");
	addTripplet(tr("High internal temperature"),"/Alarms/HighInternalTemperature","",	"");
	addTripplet(tr("Internal failure"),			"/Alarms/InternalFailure",		"",		"");
	addTripplet(tr("Battery temperature sensor"),	"/Alarms/BatteryTemperatureSensor",	"", "");
	addTripplet(tr("Cell imbalance"),			"/Alarms/CellImbalance",		"",		"");
	addTripplet(tr("Low cell voltage"),			"/Alarms/LowCellVoltage",		"",		"/System/MinCellVoltage");
	addTripplet(tr("Bad contactor"),			"/Alarms/Contactor",			"",		"");
	addTripplet(tr("BMS cable fault"),			"/Alarms/BmsCable",				"",		"");
	addBmsError("/ErrorCode");
}

void BatteryAlarms::numberOfDistributorsChanged(VeQItem *item, QVariant value)
{
	Q_UNUSED(item);

	if (!value.isValid() || value.toInt() <= 0 || mDistributorAlarmsAdded)
		return;

	/* Register alarms for all distributors and fuses as /NrOfDistributors reflects the number of connected
	 * distributors, not which distributors are connected. I.e. distributor C & D can be present without A & B being present. */
	for (int d = 0; d < 8; d++) {
		const char distName = 'A' + d;
		const QString distPath = QString("/Distributor/%1").arg(distName);
		addTripplet(tr("Distributor %1 connection lost").arg(distName), distPath + "/Alarms/ConnectionLost", "", "");
		for (int f = 0; f < 8; f++) {
			const QString fusePath = (distPath + "/Fuse/%1").arg(f);
			addTripplet(tr("Fuse blown"), fusePath + "/Alarms/Blown", "", fusePath + "/Name");
		}
	}

	mDistributorAlarmsAdded = true;
}
