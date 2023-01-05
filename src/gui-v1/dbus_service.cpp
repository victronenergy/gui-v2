#include <qstringlist.h>
#include <QEvent>

#include <gui-v1/dbus_service.h>
#include <gui-v1/dbus_services.h>

DBusService::DBusService(VeQItem *serviceItem, DbusServiceType serviceType, QObject *parent) :
	QObject(parent),
	mServiceType(serviceType),
	mServiceItem(serviceItem),
	mInitDone(false)
{
	// Note: to support service without a CustomName item at all, also the state changes need
	// to be connected to, since there won't be any valueChange if the CustomName is not supported
	// at all!
	connect(item("CustomName"), SIGNAL(stateChanged(VeQItem::State)), SLOT(updateDescription()));
	connect(item("ProductName"), SIGNAL(stateChanged(VeQItem::State)), SLOT(updateDescription()));
	item("ProductName")->getValueAndChanges(this, SLOT(updateDescription(QVariant)), true, true);
	item("CustomName")->getValueAndChanges(this, SLOT(updateDescription(QVariant)), true, true);
	connect(serviceItem, SIGNAL(stateChanged(VeQItem::State)), SIGNAL(connectedChanged()));
	connect(serviceItem, SIGNAL(stateChanged(VeQItem::State)), SLOT(updateDescription()));
}

DBusService::~DBusService()
{
	emit serviceDestroyed();
	mServiceItem->itemDelete();
}

void DBusService::updateDescription(QVariant)
{
	VeQItem *productNameItem = item("ProductName");
	VeQItem *customNameItem = item("CustomName");

	if (customNameItem->getState() == VeQItem::Requested || productNameItem->getState() == VeQItem::Requested)
		return;

	QString customName = customNameItem->getValue().toString();

	// If a custom name is avaiable and set, use that as device description
	if (customNameItem->getState() == VeQItem::Synchronized && !customName.isEmpty()) {
		setDescription(customName);
	// Otherwise use the product name when valid
	} else if (mServiceItem->getState() == VeQItem::Synchronized &&
				(customNameItem->getState() == VeQItem::Offline || customName.isEmpty()) &&
				productNameItem->getState() == VeQItem::Synchronized) {
		setDescription(productNameItem->getValue().toString());
	// pending ..
	} else {
		return;
	}
}

void DBusService::updateDescription()
{
	updateDescription(QVariant());
}

void DBusService::setDescription(const QString &description)
{
	if (description == mDescription)
		return;

	mDescription = description;
	emit descriptionChanged();

	checkInitDone();
}

void DBusService::checkInitDone()
{
	if (mInitDone || mDescription.isEmpty())
		return;

	mInitDone = true;
	emit initialized();
}

DBusService *DBusService::createInstance(VeQItem *serviceItem)
{
	QString name = serviceItem->id();

	if (!name.startsWith("com.victronenergy."))
		return 0;

	QStringList elements = name.split(".");
	if (elements.count() < 3)
		return 0;

	QString type = elements[2];

	if (type == "battery")
		return new DBusService(serviceItem, DBUS_SERVICE_BATTERY);

	if (type == "vebus")
		return new DBusService(serviceItem, DBUS_SERVICE_MULTI);

	if (type == "multi")
		return new DBusService(serviceItem, DBUS_SERVICE_MULTI_RS);

	if (type == "solarcharger")
		return new DBusService(serviceItem, DBUS_SERVICE_SOLAR_CHARGER);

	if (type == "pvinverter")
		return new DBusService(serviceItem, DBUS_SERVICE_PV_INVERTER);

	if (type == "charger")
		return new DBusService(serviceItem, DBUS_SERVICE_AC_CHARGER);

	if (type == "tank")
		return new DBusTankService(serviceItem);

	if (type == "grid")
		return new DBusService(serviceItem, DBUS_SERVICE_GRIDMETER);

	if (type == "genset")
		return new DBusService(serviceItem, DBUS_SERVICE_GENSET);

	if (type == "motordrive")
		return new DBusService(serviceItem, DBUS_SERVICE_MOTOR_DRIVE);

	if (type == "inverter")
		return new DBusService(serviceItem, DBUS_SERVICE_INVERTER);

	if (type == "system")
		return new DBusService(serviceItem, DBUS_SERVICE_SYSTEM_CALC);

	if (type == "temperature")
		return new DBusService(serviceItem, DBUS_SERVICE_TEMPERATURE_SENSOR);

	if (type == "generator")
		return new DBusService(serviceItem, DBUS_SERVICE_GENERATOR_STARTSTOP);

	if (type == "pulsemeter")
		return new DBusService(serviceItem, DBUS_SERVICE_PULSE_COUNTER);

	if (type == "digitalinput")
		return new DBusService(serviceItem, DBUS_SERVICE_DIGITAL_INPUT);

	if (type == "unsupported")
		return new DBusService(serviceItem, DBUS_SERVICE_UNSUPPORTED);

	if (type == "meteo")
		return new DBusService(serviceItem, DBUS_SERVICE_METEO);

	if (type == "vecan")
		return new DBusService(serviceItem, DBUS_SERVICE_VECAN);

	if (type == "evcharger")
		return new DBusService(serviceItem, DBUS_SERVICE_EVCHARGER);

	if (type == "acload")
		return new DBusService(serviceItem, DBUS_SERVICE_ACLOAD);

	if (type == "hub4")
		return new DBusService(serviceItem, DBUS_SERVICE_HUB4);

	if (type == "fuelcell")
		return new DBusService(serviceItem, DBUS_SERVICE_FUELCELL);

	if (type == "dcsource")
		return new DBusService(serviceItem, DBUS_SERVICE_DCSOURCE);

	if (type == "alternator")
		return new DBusService(serviceItem, DBUS_SERVICE_ALTERNATOR);

	if (type == "dcload")
		return new DBusService(serviceItem, DBUS_SERVICE_DCLOAD);

	if (type == "dcsystem")
		return new DBusService(serviceItem, DBUS_SERVICE_DCSYSTEM);

	return 0;
}

std::vector<QString> const &DBusTankService::knownFluidTypes()
{
	static std::vector<QString> fluidTypes;

	if (fluidTypes.size() == 0) {
		fluidTypes.push_back(tr("Fuel"));
		fluidTypes.push_back(tr("Fresh water"));
		fluidTypes.push_back(tr("Waste water"));
		fluidTypes.push_back(tr("Live well"));
		fluidTypes.push_back(tr("Oil"));
		fluidTypes.push_back(tr("Black water (sewage)"));
		fluidTypes.push_back(tr("Fuel (gasoline)"));
	}

	return fluidTypes;
}

const QString DBusTankService::fluidTypeName(unsigned int type)
{
	std::vector<QString> names = knownFluidTypes();

	if (type < names.size())
		return names[type];

	return tr("Unknown");
}

DBusTankService::DBusTankService(VeQItem *serviceItem, QObject *parent) :
	DBusService(serviceItem, DBUS_SERVICE_TANK, parent)
{
	// MIND IT! since bulk init might be active here, the state can bounch a bit.
	connect(item("DeviceInstance"), SIGNAL(stateChanged(VeQItem::State)), SLOT(updateDescription()));
	connect(item("FluidType"), SIGNAL(stateChanged(VeQItem::State)), SLOT(updateDescription()));

	item("DeviceInstance")->getValueAndChanges(this, SLOT(updateDescription(QVariant)), true, true);
	item("FluidType")->getValueAndChanges(this, SLOT(updateDescription(QVariant)), true, true);
}

void DBusTankService::updateDescription(QVariant)
{
	VeQItem *customNameItem = item("CustomName");
	QString customName = customNameItem->getValue().toString();

	// Mind it, not all tanks have a customName!!! Some NMEA2000 tanks lack the obligatory configuration
	// information and hence have no customName.
	if (customNameItem->getState() != VeQItem::Synchronized && customNameItem->getState() != VeQItem::Offline)
		return;

	// If a custom name is avaiable and set, used that as device description
	if (!customName.isEmpty()) {
		setDescription(customName);
		return;
	}

	VeQItem *vrmInstanceItem = item("DeviceInstance");
	VeQItem *typeItem = item("FluidType");

	if (vrmInstanceItem->getState() != VeQItem::Synchronized || typeItem->getState() != VeQItem::Synchronized)
		return;

	QString description = fluidTypeName(typeItem->getValue().toUInt()) + " " + tr("tank");
	description += " (" + QString::number(vrmInstanceItem->getValue().toInt()) + ")";
	setDescription(description);
}
