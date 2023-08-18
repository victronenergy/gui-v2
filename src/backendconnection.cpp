#include "backendconnection.h"
#include "uidhelper.h"
#include "enums.h"

#if !defined(VENUS_WEBASSEMBLY_BUILD)
#include "veutil/qt/ve_dbus_connection.hpp"
#include "veutil/qt/ve_qitems_dbus.hpp"
#include "gui-v1/dbus_services.h"
#include "gui-v1/alarmbusitem.h"
#endif

#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonValue>
#include <QtCore/QJsonArray>

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
	case VeQItemMqttProducer::Initializing:
	{
		setState(BackendConnection::State::Initializing);
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
			if (!m_token.isEmpty()) {
				m_mqttProducer->setCredentials(m_username, m_token);
			} else if (!m_username.isEmpty() || !m_password.isEmpty()) {
				// TODO: fetch updated credentials via VRM API if required...
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

QString BackendConnection::shard() const
{
	return m_shard;
}

void BackendConnection::setShard(const QString &shard)
{
	if (m_shard != shard) {
		m_shard = shard;
		emit shardChanged();
	}
}

QString BackendConnection::token() const
{
	return m_token;
}

void BackendConnection::setToken(const QString &tok)
{
	if (m_token != tok) {
		m_token = tok;
		emit tokenChanged();
	}
}

int BackendConnection::idUser() const
{
	return m_idUser;
}

void BackendConnection::setIdUser(int id)
{
	if (m_idUser != id) {
		m_idUser = id;
		emit idUserChanged();
	}
}

void BackendConnection::loginVrmApi()
{
	if (m_username.isEmpty() || m_password.isEmpty()) {
		qWarning() << "Unable to login to VRM API: invalid credentials supplied";
		return;
	}

	if (m_network == nullptr) {
		m_network = new QNetworkAccessManager(this);
	}

	const QByteArray loginData = QStringLiteral("{ \"username\": \"%1\", \"password\": \"%2\" }")
			.arg(m_username.startsWith(QStringLiteral("vrmlogin_live_"), Qt::CaseInsensitive)
					? m_username.mid(QStringLiteral("vrmlogin_live_").length())
					: m_username,
				m_password).toUtf8();
	QNetworkRequest loginRequest(QUrl(QStringLiteral("https://vrmapi.victronenergy.com/v2/auth/login")));
	loginRequest.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json").toUtf8());
	loginRequest.setHeader(QNetworkRequest::ContentLengthHeader, loginData.size());
	QNetworkReply *loginReply = m_network->post(loginRequest, loginData);

	connect(loginReply, &QNetworkReply::finished,
		this, [this, loginReply] {
			loginReply->deleteLater();
			if (loginReply->error() != QNetworkReply::NoError) {
				qWarning() << "VRM API login failed: " << loginReply->errorString();
				return;
			}

			const QByteArray response = loginReply->readAll();
			const QJsonDocument doc = QJsonDocument::fromJson(response);
			if (!doc.isObject()) {
				qWarning() << "VRM API login failed: not valid JSON object: " << QString::fromUtf8(response);
				return;
			}

			const QJsonObject obj = doc.object();
			const int idUser = obj.value(QStringLiteral("idUser")).toInt(-1);
			const QString token = obj.value(QStringLiteral("token")).toString();
			if (idUser < 0 || token.isEmpty()) {
				qWarning() << "VRM API login failed: invalid idUser or token: " << idUser << ", " << token;
				return;
			}

			setIdUser(idUser);
			setToken(token);
			requestShardFromVrmApi();
		});
}


void BackendConnection::requestShardFromVrmApi()
{
	if (m_token.isEmpty() || m_idUser < 0) {
		qWarning() << "Unable to request installation info from VRM API: invalid token or idUser";
		return;
	}

	if (m_portalId.isEmpty()) {
		qWarning() << "Unable to determine installation info from VRM API: no portalId specified";
		return;
	}

	if (m_network == nullptr) {
		m_network = new QNetworkAccessManager(this);
	}

	QNetworkRequest installationsRequest(QUrl(QStringLiteral("https://vrmapi.victronenergy.com/v2/users/%1/installations?extended=1").arg(m_idUser)));
	installationsRequest.setRawHeader(QStringLiteral("x-authorization").toUtf8(),
			QStringLiteral("Bearer %1").arg(m_token).toUtf8());
	QNetworkReply *installationsReply = m_network->get(installationsRequest);

	connect(installationsReply, &QNetworkReply::finished,
		this, [this, installationsReply] {
			installationsReply->deleteLater();
			if (installationsReply->error() != QNetworkReply::NoError) {
				qWarning() << "VRM API request failed: " << installationsReply->errorString();
				return;
			}

			const QByteArray response = installationsReply->readAll();
			const QJsonDocument doc = QJsonDocument::fromJson(response);
			if (!doc.isObject()) {
				qWarning() << "VRM API request failed: not a valid JSON object: " << QString::fromUtf8(response);
				return;
			}

			const QJsonObject obj = doc.object();
			const QJsonArray records = obj.value(QStringLiteral("records")).toArray();
			if (records.size() == 0) {
				qWarning() << "VRM API request failed: no valid installation records: " << QString::fromUtf8(response);
				return;
			}

			for (QJsonArray::const_iterator it = records.constBegin(); it != records.constEnd(); ++it) {
				const QJsonObject record = it->toObject();
				const QString identifier = record.value(QStringLiteral("identifier")).toString();
				if (identifier.compare(m_portalId, Qt::CaseInsensitive) == 0) {
					const QString mqtt_webhost = record.value(QStringLiteral("mqtt_webhost")).toString();
					const QString webhost = mqtt_webhost.startsWith(QStringLiteral("wss://"), Qt::CaseInsensitive)
							? mqtt_webhost : QStringLiteral("wss://%1").arg(mqtt_webhost);
					const int prefixLength = QStringLiteral("wss://webmqtt").length();
					const QString shard = webhost.mid(prefixLength, webhost.indexOf('.') - prefixLength);
					if (shard.isEmpty()) {
						qWarning() << "Unable to determine shard from mqtt_webhost " << mqtt_webhost << " in record " << record.toVariantMap();
						qWarning() << "Original response was: " << response;
						return;
					}

					qDebug() << "Calculated shard: " << shard << " from webhost: " << webhost;
					setShard(shard);
					if (!m_username.startsWith(QStringLiteral("vrmlogin_live_"), Qt::CaseInsensitive)) {
						setUsername(QStringLiteral("vrmlogin_live_%1").arg(m_username));
					}
					setType(MqttSource, webhost);
					return;
				}
			}

			qWarning() << "Unable to find record matching portal id: " << m_portalId;
		});
}

bool BackendConnection::isApplicationVisible() const
{
	return m_applicationVisible;
}

void BackendConnection::setApplicationVisible(bool v)
{
	if (m_applicationVisible != v) {
		m_applicationVisible = v;
		emit applicationVisibleChanged();
	}
}

}
}
