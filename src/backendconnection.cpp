#include "backendconnection.h"
#include "uidhelper.h"
#include "enums.h"

#if !defined(VENUS_WEBASSEMBLY_BUILD)
#include "veutil/qt/ve_dbus_connection.hpp"
#include "veutil/qt/ve_qitems_dbus.hpp"
#include "gui-v1/dbus_services.h"
#include "gui-v1/alarmbusitem.h"
#endif

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
		setState(BackendConnection::State::Reconnecting);
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

BackendConnection::MqttClientError BackendConnection::mqttClientError() const
{
	return MqttClientError(m_mqttClientError);
}

void BackendConnection::mqttErrorChanged()
{
	qWarning() << "MQTT client error:" << m_mqttProducer->error();
	if (m_mqttProducer->error() != m_mqttClientError) {
		m_mqttClientError = m_mqttProducer->error();
		emit mqttClientErrorChanged();
	}
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
		m_mqttProducer, [this] {
			// TODO: fetch updated credentials via VRM API if required...
			if (!m_username.isEmpty() || !m_password.isEmpty()) {
				m_mqttProducer->setCredentials(m_username, m_password);
			}
			m_mqttProducer->setPortalId(m_portalId);
			m_mqttProducer->continueConnect();
		});
	connect(m_mqttProducer, &VeQItemMqttProducer::messageReceived,
		m_uidHelper, &UidHelper::onMessageReceived);
	connect(m_mqttProducer, &VeQItemMqttProducer::nullMessageReceived,
		m_uidHelper, &UidHelper::onNullMessageReceived);
	connect(m_mqttProducer, &VeQItemMqttProducer::connectionStateChanged, this, [=] {
		setState(m_mqttProducer->connectionState());
	});
	connect(m_mqttProducer, &VeQItemMqttProducer::errorChanged,
		this, &BackendConnection::mqttErrorChanged);

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

QString BackendConnection::username() const
{
	return m_username;
}

void BackendConnection::setUsername(const QString &username)
{
	if (m_username != username) {
		m_username = username;
		emit usernameChanged();
	}
}

QString BackendConnection::password() const
{
	return m_password;
}

void BackendConnection::setPassword(const QString &password)
{
	if (m_password != password) {
		m_password = password;
		emit passwordChanged();
	}
}

QString BackendConnection::portalId() const
{
	return m_portalId;
}

void BackendConnection::setPortalId(const QString &portalId)
{
	if (m_portalId != portalId) {
		m_portalId = portalId;
		emit portalIdChanged();
	}
}

void BackendConnection::addSettings(VeQItemSettingsInfo *info)
{
	// 0=Dark, 1=Light, 2=Auto
	info->add("Gui/ColorScheme", 0, 0, 2);

	// see enum.h Units_Type for enum values
	info->add("Gui/Units/Energy", 2); // watt, amp

	// Configures the central gauges on the Brief page.
	// For all gauges, min value = Tank_Type_Fuel, max value = Tank_Type_Battery.
	info->add("Gui/BriefView/Level/1", Enums::Tank_Type_Battery, Enums::Tank_Type_Fuel, Enums::Tank_Type_Battery);
	info->add("Gui/BriefView/Level/2", Enums::Tank_Type_Fuel, Enums::Tank_Type_Fuel, Enums::Tank_Type_Battery);
	info->add("Gui/BriefView/Level/3", Enums::Tank_Type_FreshWater, Enums::Tank_Type_Fuel, Enums::Tank_Type_Battery);
	info->add("Gui/BriefView/Level/4", Enums::Tank_Type_BlackWater, Enums::Tank_Type_Fuel, Enums::Tank_Type_Battery);
	info->add("Gui/BriefView/ShowPercentages", 0, 0, 1);
}


}
}
