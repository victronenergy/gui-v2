/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef BACKENDCONNECTION_H
#define BACKENDCONNECTION_H

#include <QObject>
#include <QQmlEngine>
#include <QNetworkAccessManager>
#include <QMqttClient>

#include "veutil/qt/ve_qitems_mqtt.hpp"

class VeQItemDbusProducer;
class AlarmBusitem;

namespace Victron {
namespace VenusOS {

class BackendConnection : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(State state READ state NOTIFY stateChanged FINAL)
	Q_PROPERTY(HeartbeatState heartbeatState READ heartbeatState NOTIFY heartbeatStateChanged FINAL)
	Q_PROPERTY(VrmPortalMode vrmPortalMode READ vrmPortalMode NOTIFY vrmPortalModeChanged FINAL)
	Q_PROPERTY(SourceType type READ type NOTIFY typeChanged FINAL)
	Q_PROPERTY(MqttClientError mqttClientError READ mqttClientError NOTIFY mqttClientErrorChanged FINAL)
	Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged FINAL)
	Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged FINAL)
	Q_PROPERTY(QString portalId READ portalId WRITE setPortalId NOTIFY portalIdChanged FINAL)
	Q_PROPERTY(QString shard READ shard WRITE setShard NOTIFY shardChanged FINAL)
	Q_PROPERTY(QString token READ token WRITE setToken NOTIFY tokenChanged FINAL)
	Q_PROPERTY(QUrl demoImageFileName READ demoImageFileName CONSTANT FINAL)
	Q_PROPERTY(int idUser READ idUser WRITE setIdUser NOTIFY idUserChanged FINAL)
	Q_PROPERTY(bool vrm READ isVrm WRITE setVrm NOTIFY vrmChanged FINAL)
	Q_PROPERTY(bool applicationVisible READ isApplicationVisible WRITE setApplicationVisible NOTIFY applicationVisibleChanged FINAL)
	Q_PROPERTY(bool needsWasmKeyboardHandler READ needsWasmKeyboardHandler WRITE setNeedsWasmKeyboardHandler NOTIFY needsWasmKeyboardHandlerChanged FINAL)

	friend class BackendConnectionTester;
public:
	enum SourceType {
		UnknownSource,
		DBusSource,
		MqttSource,
		MockSource
	};
	Q_ENUM(SourceType)

	// Same as VeQItemMqttProducer::ConnectionState
	enum State {
		Idle,
		Connecting,
		Connected,
		Initializing,
		Ready,
		Disconnected,
		Reconnecting,
		Failed
	};
	Q_ENUM(State)

	// Same as VeQItemMqttProducer::HeartbeatState
	enum HeartbeatState {
		HeartbeatActive,
		HeartbeatMissing,
		HeartbeatInactive,
	};
	Q_ENUM(HeartbeatState)

	// Same as VeQItemMqttProducer::VrmPortalMode
	enum VrmPortalMode {
		Unknown = -1,
		Off = 0,
		ReadOnly = 1,
		Full = 2
	};
	Q_ENUM(VrmPortalMode)

	enum MqttClientError {
		MqttClient_NoError = QMqttClient::NoError,
		MqttClient_InvalidProtocolVersion = QMqttClient::InvalidProtocolVersion,
		MqttClient_IdRejected = QMqttClient::IdRejected,
		MqttClient_ServerUnavailable = QMqttClient::ServerUnavailable,
		MqttClient_BadUsernameOrPassword = QMqttClient::BadUsernameOrPassword,
		MqttClient_NotAuthorized = QMqttClient::NotAuthorized,
		MqttClient_TransportInvalid = QMqttClient::TransportInvalid,
		MqttClient_ProtocolViolation = QMqttClient::ProtocolViolation,
		MqttClient_UnknownError = QMqttClient::UnknownError,
		MqttClient_Mqtt5SpecificError = QMqttClient::Mqtt5SpecificError
	};
	Q_ENUM(MqttClientError)

	static BackendConnection* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

	State state() const;
	HeartbeatState heartbeatState() const;
	VrmPortalMode vrmPortalMode() const;
	MqttClientError mqttClientError() const;

	void loadConfiguration();

	SourceType type() const;
	void setType(SourceType type, const QString &address = QString());

	QString username() const;
	void setUsername(const QString &username);

	QString password() const;
	void setPassword(const QString &password);

	QString portalId() const;
	void setPortalId(const QString &portalId);

	QString shard() const;
	void setShard(const QString &shard);

	QString token() const;
	void setToken(const QString &tok);

	int idUser() const;
	void setIdUser(int id);

	void loginVrmApi();
	void requestShardFromVrmApi();

	bool isVrm() const;
	void setVrm(bool v);

	bool isApplicationVisible() const;
	void setApplicationVisible(bool v);

	bool needsWasmKeyboardHandler() const;
	void setNeedsWasmKeyboardHandler(bool needsWasmKeyboardHandler);

	QUrl demoImageFileName() const;

	// Each service type (system, settings, battery, etc.) has a base uid, which has different
	// forms on D-Bus and MQTT:
	// - D-Bus uid: "dbus/<serviceName>"
	//   E.g. "dbus/com.victronenergy.system", "dbus/com.victronenergy.battery.lynxparallel"
	//   (The serviceName format is "com.victronenergy.<serviceType>[.suffix]/*".)
	// - MQTT uid: "mqtt/<serviceType>/<deviceInstance>"
	//   E.g. "mqtt/system/0", "mqtt/battery/256"
	//   (Unlike for D-Bus, MQTT uids never have a suffix after the serviceType, so the device
	//   instance number must be available to create the MQTT uid.)
	Q_INVOKABLE QString serviceUidForType(const QString &serviceType) const;
	Q_INVOKABLE QString serviceTypeFromUid(const QString &uid) const;
	Q_INVOKABLE QString serviceUidFromName(const QString &serviceName, int deviceInstance) const;
	Q_INVOKABLE QString serviceUidFromUid(const QString &fullUid) const;
	Q_INVOKABLE QString uidPrefix() const;

	// A portable service id has the format "com.victronenergy.<serviceType>/<deviceInstance"
	Q_INVOKABLE QString serviceUidToPortableId(const QString &serviceUid, int deviceInstance) const;
	Q_INVOKABLE QVariantMap portableIdInfo(const QString &portableId) const;

	Q_INVOKABLE void logout();
	Q_INVOKABLE void securityProtocolChanged();
	Q_INVOKABLE void reloadPage();
	Q_INVOKABLE void openUrl(const QString &url);

	// Move this to some mock data manager when available
	Q_INVOKABLE void setMockValue(const QString &uid, const QVariant &value);
	Q_INVOKABLE QVariant mockValue(const QString &uid) const;
#if defined(VENUS_WEBASSEMBLY_BUILD)
	Q_INVOKABLE void hitWatchdog();
#endif

Q_SIGNALS:
	void stateChanged();
	void heartbeatStateChanged();
	void vrmPortalModeChanged();
	void typeChanged();
	void mqttClientErrorChanged();
	void usernameChanged();
	void passwordChanged();
	void portalIdChanged();
	void shardChanged();
	void tokenChanged();
	void idUserChanged();
	void vrmChanged();
	void applicationVisibleChanged();
	void needsWasmKeyboardHandlerChanged();

private Q_SLOTS:
	void onNetworkConfigChanged(const QVariant var);
	void onReloadPageTimerExpired();

private:
	explicit BackendConnection(QObject *parent = nullptr);
	void setState(State backendConnectionState);
	void setState(VeQItemMqttProducer::ConnectionState backendConnectionState);
	void setState(bool connected);
	void setHeartbeatState(HeartbeatState backendHeartbeatState);
	void setHeartbeatState(VeQItemMqttProducer::HeartbeatState backendHeartbeatState);
	void setVrmPortalMode(VeQItemMqttProducer::VrmPortalMode backendVrmPortalMode);
	void mqttErrorChanged();
	void addSettings(VeQItemSettingsInfo *info);

#if !defined(VENUS_WEBASSEMBLY_BUILD)
	void initDBusConnection(const QString &address);
#endif
	void initMqttConnection(const QString &address);
	void initMockConnection();

	QString m_username;
	QString m_password;
	QString m_portalId;

	QString m_shard;
	QString m_token;
	int m_idUser = -1;

	bool m_vrm = false;
	bool m_applicationVisible = true;
	bool m_needsWasmKeyboardHandler = false;

	State m_state = BackendConnection::State::Idle;
	HeartbeatState m_heartbeatState = BackendConnection::HeartbeatState::HeartbeatActive;
	VrmPortalMode m_vrmPortalMode = BackendConnection::VrmPortalMode::Unknown;
	SourceType m_type = UnknownSource;
	QMqttClient::ClientError m_mqttClientError = QMqttClient::NoError;

	QTimer *mRestartDelayTimer = nullptr;

	VeQItemProducer *m_producer = nullptr;
#if !defined(VENUS_WEBASSEMBLY_BUILD)
	AlarmBusitem *m_alarmBusItem = nullptr;
#endif
	QNetworkAccessManager *m_network = nullptr;
};

class BackendConnectionTester : public QObject
{
	Q_OBJECT

public:
	BackendConnectionTester();
	Victron::VenusOS::BackendConnection mqttBackend, dbusBackend;

public slots:
	void applicationAvailable()
	{
		// Initialization that only requires the QGuiApplication object to be available
	}

	void qmlEngineAvailable(QQmlEngine *engine); // Initialization requiring the QQmlEngine to be constructed

	void cleanupTestCase()
	{
		// Implement custom resource cleanup
	}
};

}
}

#endif // BACKENDCONNECTION_H
