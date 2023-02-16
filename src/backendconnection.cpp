#include "backendconnection.h"
#include "uidhelper.h"

#if !defined(VENUS_WEBASSEMBLY_BUILD)
#include "veutil/qt/ve_dbus_connection.hpp"
#include "veutil/qt/ve_qitems_dbus.hpp"
#include "gui-v1/dbus_services.h"
#include "gui-v1/alarmbusitem.h"
#endif

namespace {

void addSettings(VeQItemSettingsInfo *info)
{
	// 0=Dark, 1=Light, 2=Auto
	info->add("Gui/ColorScheme", 0, 0, 2);

	// see enum.h Units_Type for enum values
	info->add("Gui/Units/Energy", 2); // watt, amp
	info->add("Gui/Units/Temperature", 4);  // celsius, fahrenheit
	info->add("Gui/Units/Volume", 6);  // cubic meter, liter, gallon US, gallon imperial

	// Brief settings levels are 0-6 (Fuel - Gasoline) or -1 for Battery.
	info->add("Gui/BriefView/Level/1", -1, -1, 6);     // Battery
	info->add("Gui/BriefView/Level/2", 0, -1, 6);    // Fuel
	info->add("Gui/BriefView/Level/3", 1, -1, 6);    // Fresh water
	info->add("Gui/BriefView/Level/4", 5, -1, 6);    // Black water
	info->add("Gui/BriefView/ShowPercentages", 0, 0, 1);
}

}

namespace Victron {
namespace VenusOS {

BackendConnection* BackendConnection::instance(QQmlEngine *, QJSEngine *)
{
	static BackendConnection* connection = nullptr;

	if (connection == nullptr) {
		connection = new BackendConnection();
	}
	return connection;
}

BackendConnection::BackendConnection(QObject *parent)
	: QObject{parent}
{
}

BackendConnection::State BackendConnection::state() const
{
	return m_state;
}

void BackendConnection::setState(State backendConnectionState)
{
	qDebug() << "BackendConnection state:" << backendConnectionState;

	if (m_state != backendConnectionState) {
		m_state = backendConnectionState;
		emit stateChanged();
	}
}

void BackendConnection::setState(VeQItemMqttProducer::ConnectionState backendConnectionState)
{
	switch(backendConnectionState) {
	case VeQItemMqttProducer::Idle:
	{
		setState(BackendConnection::State::Idle);
		break;
	}
	case VeQItemMqttProducer::Connecting:
	{
		setState(BackendConnection::State::Connecting);
		break;
	}
	case VeQItemMqttProducer::Connected:
	{
		setState(BackendConnection::State::Connected);
		break;
	}
	case VeQItemMqttProducer::Ready:
	{
		setState(BackendConnection::State::Ready);
		break;
	}
	case VeQItemMqttProducer::Disconnected:
	{
		setState(BackendConnection::State::Disconnected);
		break;
	}
	case VeQItemMqttProducer::Reconnecting:
	{
		setState(BackendConnection::State::Disconnected);
		break;
	}
	case VeQItemMqttProducer::Failed:
	{
		setState(BackendConnection::State::Failed);
		break;
	}
	default: {
		qWarning() << "Attempted to set an unknown backend connection state";
	}
	}
}

void BackendConnection::setState(bool connected)
{
	setState(connected ? Ready : Disconnected);
}

BackendConnection::SourceType BackendConnection::type() const
{
	return m_type;
}

#if !defined(VENUS_WEBASSEMBLY_BUILD)
void BackendConnection::initDBusConnection(const QString &address)
{
	m_dbusProducer = new VeQItemDbusProducer(VeQItems::getRoot(), "dbus");

	if (address.isEmpty()) {
		qWarning() << "Connecting to system bus...";
		VeDbusConnection::setConnectionType(QDBusConnection::SystemBus);
	} else {
		qWarning() << "Connecting to session bus...";
		// Default to the session bus on the pc
		VeDbusConnection::setConnectionType(QDBusConnection::SessionBus);
		VeDbusConnection::setDBusAddress(address);
	}

	QDBusConnection dbus = VeDbusConnection::getConnection();
	if (!dbus.isConnected()) {
		qWarning() << "D-Bus connection failed!";
		setState(Failed);
		return;
	}

	m_dbusProducer->open(dbus);
	DBusServices *alarmServices = new DBusServices(m_dbusProducer->services(), this);
	m_alarmBusItem = new AlarmBusitem(alarmServices, ActiveNotificationsModel::instance());
	alarmServices->initialScan();

	VeQItemSettings *settings = new VeQItemDbusSettings(m_dbusProducer->services(), QString("com.victronenergy.settings"));
	VeQItemSettingsInfo settingsInfo;
	addSettings(&settingsInfo);
	if (!settings->addSettings(settingsInfo)) {
		qCritical() << "Adding settings failed, localsettings not running?";
		return;
	}

	setState(VeDbusConnection::getConnection().isConnected());
}
#endif

void BackendConnection::initMqttConnection(const QString &address)
{
	qWarning() << "Connecting to MQTT source at" << address << "...";

	if (address.isEmpty()) {
		qCritical("No MQTT address specified!");
		return;
	}
	if (m_mqttProducer) {
		m_mqttProducer->deleteLater();
		m_mqttProducer = nullptr;
	}

	m_mqttProducer = new VeQItemMqttProducer(VeQItems::getRoot(), "mqtt", "gui-v2");
	m_uidHelper = UidHelper::instance();
	connect(m_mqttProducer, &VeQItemMqttProducer::aboutToConnect,
		m_mqttProducer, &VeQItemMqttProducer::continueConnect); // TODO: setCredentials().
	connect(m_mqttProducer, &VeQItemMqttProducer::messageReceived,
		m_uidHelper, &UidHelper::onMessageReceived);
	connect(m_mqttProducer, &VeQItemMqttProducer::nullMessageReceived,
		m_uidHelper, &UidHelper::onNullMessageReceived);
	connect(m_mqttProducer, &VeQItemMqttProducer::connectionStateChanged, this, [=] {
		setState(m_mqttProducer->connectionState());
	});

#if defined(VENUS_WEBASSEMBLY_BUILD)
	m_mqttProducer->open(QUrl(address), QMqttClient::MQTT_3_1);
#else
	m_mqttProducer->open(QHostAddress(address), 1883);
#endif
}

void BackendConnection::setType(const SourceType type, const QString &address)
{
	if (m_type == type) {
		return;
	}
	m_type = type;

	switch (type) {
	case DBusSource:
#if defined(VENUS_WEBASSEMBLY_BUILD)
		qWarning() << "D-Bus connection not supported in WebAssembly!";
#else
		initDBusConnection(address);
#endif
		break;
	case MqttSource:
		initMqttConnection(address);
		break;
	case MockSource:
		setState(true);
		break;
	default:
		qWarning() << "Unsupported backend source type!" << type;
	}

	emit typeChanged();
}
}
}
