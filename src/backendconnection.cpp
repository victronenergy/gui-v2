/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "backendconnection.h"
#include "veqitemmockproducer.h"
#include "enums.h"

#if defined(VENUS_WEBASSEMBLY_BUILD)
#include <emscripten.h>
#else
#include "veutil/qt/ve_dbus_connection.hpp"
#include "veutil/qt/ve_qitems_dbus.hpp"
#endif

#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonValue>
#include <QtCore/QJsonArray>
#include <QQmlContext>
#include <QFile>

namespace Victron {
namespace VenusOS {

BackendConnection* BackendConnection::create(QQmlEngine *, QJSEngine *)
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
	if (m_state != backendConnectionState) {
		qDebug() << "BackendConnection state:" << backendConnectionState;
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
	case VeQItemMqttProducer::WaitingToConnect: // fall through
	case VeQItemMqttProducer::TransportConnecting: // fall through
	case VeQItemMqttProducer::TransportConnected: // fall through
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
	case VeQItemMqttProducer::Identified: // fall through
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
	case VeQItemMqttProducer::WaitingToReconnect: // fall through
	case VeQItemMqttProducer::TransportReconnecting: // fall through
	case VeQItemMqttProducer::TransportReconnected: // fall through
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

BackendConnection::HeartbeatState BackendConnection::heartbeatState() const
{
	return m_heartbeatState;
}

void BackendConnection::setHeartbeatState(HeartbeatState backendHeartbeatState)
{
	if (m_heartbeatState != backendHeartbeatState) {
		m_heartbeatState = backendHeartbeatState;
		emit heartbeatStateChanged();
	}
}

void BackendConnection::setHeartbeatState(VeQItemMqttProducer::HeartbeatState backendHeartbeatState)
{
	switch (backendHeartbeatState) {
		case VeQItemMqttProducer::HeartbeatState::HeartbeatActive: {
			setHeartbeatState(BackendConnection::HeartbeatState::HeartbeatActive);
			break;
		}
		case VeQItemMqttProducer::HeartbeatState::HeartbeatMissing: {
			setHeartbeatState(BackendConnection::HeartbeatState::HeartbeatMissing);
			break;
		}
		case VeQItemMqttProducer::HeartbeatState::HeartbeatInactive: {
			setHeartbeatState(BackendConnection::HeartbeatState::HeartbeatInactive);
			break;
		}
	}
}

BackendConnection::VrmPortalMode BackendConnection::vrmPortalMode() const
{
	return m_vrmPortalMode;
}

void BackendConnection::setVrmPortalMode(VeQItemMqttProducer::VrmPortalMode backendVrmPortalMode)
{
	m_vrmPortalMode = static_cast<BackendConnection::VrmPortalMode>(backendVrmPortalMode);
	emit vrmPortalModeChanged();
}

BackendConnection::MqttClientError BackendConnection::mqttClientError() const
{
	return MqttClientError(m_mqttClientError);
}

void BackendConnection::mqttErrorChanged()
{
	if (VeQItemMqttProducer *mqttProducer = qobject_cast<VeQItemMqttProducer *>(m_producer)) {
		qWarning() << "MQTT client error:" << mqttProducer->error();
		if (mqttProducer->error() != m_mqttClientError) {
			m_mqttClientError = mqttProducer->error();
			emit mqttClientErrorChanged();
		}
	}
}

BackendConnection::SourceType BackendConnection::type() const
{
	return m_type;
}

#if !defined(VENUS_WEBASSEMBLY_BUILD)
void BackendConnection::initDBusConnection(const QString &address)
{
	VeQItemDbusProducer *dbusProducer = new VeQItemDbusProducer(VeQItems::getRoot(), "dbus");
	m_producer = dbusProducer;

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

	dbusProducer->open(dbus);

	setState(VeDbusConnection::getConnection().isConnected());
}
#endif

#if defined(VENUS_WEBASSEMBLY_BUILD)
void BackendConnection::onNetworkConfigChanged(const QVariant var)
{
	if (!isVrm() && var.isValid() && var.toInt() > 0 && !mRestartDelayTimer) {
		qWarning() << "Closing MQTT connection and reloading due to network config change";
		VeQItemMqttProducer *mqtt = qobject_cast<VeQItemMqttProducer *>(m_producer);
		if (mqtt) {
			mqtt->close();
		}

		mRestartDelayTimer = new QTimer();
		connect(mRestartDelayTimer, &QTimer::timeout, this, &BackendConnection::onReloadPageTimerExpired);
		mRestartDelayTimer->setSingleShot(true);
		mRestartDelayTimer->start(3000);
	}
}

void BackendConnection::onReloadPageTimerExpired()
{
	if (mRestartDelayTimer) {
		delete mRestartDelayTimer;
		mRestartDelayTimer = nullptr;
	}

	reloadPage();
}

// If the wasm itself changed the Security Profile, it should normally be notified
// that it is accepted by receiving a Network Config change. Since that event is send
// over a connection which is going to be disconnected, this acts as a fallback if
// that fails and still triggers a reload (albeit a bit later).
void BackendConnection::securityProtocolChanged()
{
	if (isVrm()) {
		return;
	}
	QTimer *timer = new QTimer(this);
	connect(timer, &QTimer::timeout, this, &BackendConnection::onReloadPageTimerExpired);
	connect(timer, &QTimer::timeout, timer, &QObject::deleteLater);
	timer->setSingleShot(true);
	timer->start(5000);
}

void BackendConnection::reloadPage()
{
	if (isVrm()) {
		emscripten_run_script("location.reload();");
	} else {
		emscripten_run_script("reload();");
	}
}

void BackendConnection::openUrl(const QString &url)
{
	const QString s = QStringLiteral("window.open(\"%1\", \"_blank\");").arg(url);
	const QByteArray ba = s.toLocal8Bit();
	emscripten_run_script(ba.constData());
}

void BackendConnection::hitWatchdog()
{
	emscripten_run_script("watchdogHit = true"); // 'watchdogHit' is defined in index.html, which checks it periodically and reloads the page if not hit regularly.
}

#else

void BackendConnection::onNetworkConfigChanged(const QVariant var) { Q_UNUSED(var); }
void BackendConnection::onReloadPageTimerExpired() {}
void BackendConnection::securityProtocolChanged() {}
void BackendConnection::reloadPage() {}
void BackendConnection::openUrl(const QString &) {}

#endif

void BackendConnection::initMqttConnection(const QString &address)
{
	qWarning() << "Connecting to MQTT source at" << address << "...";

	if (address.isEmpty()) {
		qCritical("No MQTT address specified!");
		return;
	}

	VeQItemMqttProducer *mqttProducer = new VeQItemMqttProducer(VeQItems::getRoot(), "mqtt", "gui-v2");
	m_producer = mqttProducer;

	connect(mqttProducer, &VeQItemMqttProducer::aboutToConnect,
			mqttProducer, [this] {
		if (VeQItemMqttProducer *producer = qobject_cast<VeQItemMqttProducer *>(m_producer)) {
			if (!m_token.isEmpty()) {
				producer->setCredentials(m_username, m_token);
			} else if (!m_username.isEmpty() || !m_password.isEmpty()) {
				// TODO: fetch updated credentials via VRM API if required...
				producer->setCredentials(m_username, m_password);
			}
			producer->continueConnect();
		}
	});
	connect(mqttProducer, &VeQItemMqttProducer::connectionStateChanged, this, [mqttProducer, this] {
		setState(mqttProducer->connectionState());
	});
	connect(mqttProducer, &VeQItemMqttProducer::heartbeatStateChanged, this, [mqttProducer, this] {
		setHeartbeatState(mqttProducer->heartbeatState());
	});
	connect(mqttProducer, &VeQItemMqttProducer::vrmPortalModeChanged, this, [mqttProducer, this] {
		setVrmPortalMode(mqttProducer->vrmPortalMode());
	});
	connect(mqttProducer, &VeQItemMqttProducer::errorChanged,
		this, &BackendConnection::mqttErrorChanged);

	if (!m_portalId.isEmpty()) {
		mqttProducer->setPortalId(m_portalId);
	}
#if defined(VENUS_WEBASSEMBLY_BUILD)
	setVrm(address.startsWith(QStringLiteral("wss://webmqtt"))
		&& address.contains(QStringLiteral(".victronenergy.com")));
	if (isVrm()) {
		setHeartbeatState(mqttProducer->heartbeatState());
	}
	mqttProducer->open(QUrl(address), QMqttClient::MQTT_3_1);

	VeQItem *item = mqttProducer->services()->itemGetOrCreate("/platform/0/Network/ConfigChanged");
	connect(item, &VeQItem::valueChanged, this, &BackendConnection::onNetworkConfigChanged);
#else
	const QStringList parts = address.split(':');
	if (parts.size() >= 2) {
		bool ok = true;
		const int port = parts[1].toInt(&ok);
		if (ok) {
			qDebug() << "connecting to: " << parts[0] << ":" << port;
			mqttProducer->open(QHostAddress(parts[0]), port);
		} else {
			qWarning() << "Unable to parse port. Using default MQTT port: 1883";
			mqttProducer->open(QHostAddress(parts[0]), 1883);
		}
	} else {
		qDebug() << "Using default MQTT port: 1883";
		mqttProducer->open(QHostAddress(address), 1883);
	}
#endif
}

void BackendConnection::initMockConnection()
{
	VeQItemMockProducer *producer = new VeQItemMockProducer(VeQItems::getRoot(), "mock");
	m_producer = producer;
	producer->initialize();
	setState(true);
}

void BackendConnection::setType(const SourceType type, const QString &address)
{
	if (m_type == type) {
		return;
	}
	m_type = type;

	if (m_producer) {
		m_producer->deleteLater();
		m_producer = nullptr;
	}

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
		initMockConnection();
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
					const qsizetype prefixLength = QStringLiteral("wss://webmqtt").length();
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

void BackendConnection::logout()
{
#if defined(VENUS_WEBASSEMBLY_BUILD)
	emscripten_run_script("location.href = \'../auth/logout.php\';");
#endif
}

bool BackendConnection::isVrm() const
{
	return m_vrm;
}

void BackendConnection::setVrm(bool v)
{
	if (m_vrm != v) {
		m_vrm = v;
		emit vrmChanged();
	}
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

bool BackendConnection::needsWasmKeyboardHandler() const
{
	return m_needsWasmKeyboardHandler;
}

void BackendConnection::setNeedsWasmKeyboardHandler(bool needsWasmKeyboardHandler)
{
	if (m_needsWasmKeyboardHandler != needsWasmKeyboardHandler) {
		m_needsWasmKeyboardHandler = needsWasmKeyboardHandler;
		emit needsWasmKeyboardHandlerChanged();
	}
}

QUrl BackendConnection::demoImageFileName() const
{
	static const QUrl filePath = QUrl::fromLocalFile("/data/demo-brief.png");
	static const bool fileExists = QFile::exists(filePath.toLocalFile());
	return fileExists ? filePath : QUrl();
}

QString BackendConnection::serviceUidForType(const QString &serviceType) const
{
	// Assumes the specified service has the equivalent of DeviceInstance = 0 on MQTT. That is,
	// /DeviceInstance = 0 for the service, or there is only a single instance of this service and
	// so it can be accessed as if it had /DeviceInstance = 0.
	//
	// E.g. for a service name like "com.victronenergy.system", returns:
	//  - D-Bus: dbus/com.victronenergy.system
	//  - MQTT: mqtt/system/0
	//  - Mock: mock/com.victronenergy.system

	return m_type == MqttSource
			? QStringLiteral("mqtt/%1/0").arg(serviceType)
			: QStringLiteral("%1/com.victronenergy.%2").arg(uidPrefix()).arg(serviceType);
}

QString BackendConnection::serviceTypeFromUid(const QString &uid) const
{
	switch (type()) {
	case UnknownSource:
		break;
	case DBusSource:
	case MockSource:
	{
		// uid format is "<dbus|mock>/com.victronenergy.<serviceType>[.suffix]/*"
		const QString serviceTypePart = uid.split('/').value(1);
		return serviceTypePart.split('.').value(2);
	}
	case MqttSource:
		// uid format is "mqtt/<serviceType>/*"
		return uid.split('/').value(1);
	}
	return QString();
}

QString BackendConnection::serviceUidFromName(const QString &serviceName, int deviceInstance) const
{
	// serviceName format is "com.victronenergy.<serviceType>[.suffix]/*"
	if (serviceName.isEmpty() || deviceInstance < 0) {
		return QString();
	}

	switch (type()) {
	case UnknownSource:
		break;
	case DBusSource:
	case MockSource:
		// Return <dbus|mock>/<serviceName>
		return uidPrefix() + '/' + serviceName;
	case MqttSource:
	{
		// Return mqtt/<serviceType>/<deviceInstance>
		const QString serviceType = serviceName.split('.').value(2);
		return QString("%1/%2/%3").arg(uidPrefix(), serviceType, QString::number(deviceInstance));
	}
	}
	return QString();
}

QString BackendConnection::serviceUidFromUid(const QString &fullUid) const
{
	// If the given uid has a path appended, this strips the path and returns the base service uid.
	switch (type()) {
	case UnknownSource:
		break;
	case DBusSource:
	case MockSource:
	{
		// full uid format is "<dbus|mock>/com.victronenergy.<serviceType>[.suffix]/path/to/value"
		return fullUid.mid(0, fullUid.indexOf('/', uidPrefix().length() + 1));
	}
	case MqttSource:
		// uid format is "mqtt/<serviceType>/<deviceInstance>/path/to/value"
		return fullUid.split('/').mid(0, 3).join('/');
	}
	return QString();
}

QString BackendConnection::uidPrefix() const
{
	switch (type()) {
	case UnknownSource:
		break;
	case DBusSource:
		return QStringLiteral("dbus");
	case MqttSource:
		return QStringLiteral("mqtt");
	case MockSource:
		return QStringLiteral("mock");
	}
	return QString();
}

QString BackendConnection::serviceUidToPortableId(const QString &serviceUid, int deviceInstance) const
{
	const QString serviceType = serviceTypeFromUid(serviceUid);
	return QStringLiteral("com.victronenergy.%1/%2").arg(serviceType).arg(QString::number(deviceInstance));
}

QVariantMap BackendConnection::portableIdInfo(const QString &portableId) const
{
	const QStringList parts = portableId.split('/');
	const QString serviceName = parts.first();

	QVariantMap map;
	map.insert(QStringLiteral("type"), serviceName.split('.').last());
	map.insert(QStringLiteral("instance"), parts.last());
	return map;
}

void BackendConnection::setMockValue(const QString &uid, const QVariant &value)
{
	if (VeQItemMockProducer *producer = qobject_cast<VeQItemMockProducer *>(m_producer)) {
		producer->setValue(uid, value);
	}
}

QVariant BackendConnection::mockValue(const QString &uid) const
{
	if (VeQItemMockProducer *producer = qobject_cast<VeQItemMockProducer *>(m_producer)) {
		return producer->value(uid);
	}
	return QVariant();
}

BackendConnectionTester::BackendConnectionTester()
{
	mqttBackend.setType(Victron::VenusOS::BackendConnection::SourceType::MqttSource);
	dbusBackend.setType(Victron::VenusOS::BackendConnection::SourceType::DBusSource);
}

void BackendConnectionTester::qmlEngineAvailable(QQmlEngine *engine)
{
	// Initialization requiring the QQmlEngine to be constructed
	engine->rootContext()->setContextProperty("mqttBackend", &mqttBackend);
	engine->rootContext()->setContextProperty("dbusBackend", &dbusBackend);
}

}
}
