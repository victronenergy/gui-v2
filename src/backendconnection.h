/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef BACKENDCONNECTION_H
#define BACKENDCONNECTION_H

#include <QObject>
#include <QQmlEngine>
#include <QNetworkAccessManager>

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
	Q_PROPERTY(State state READ state NOTIFY stateChanged)
	Q_PROPERTY(SourceType type READ type NOTIFY typeChanged)
	Q_PROPERTY(MqttClientError mqttClientError READ mqttClientError NOTIFY mqttClientErrorChanged)
	Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
	Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
	Q_PROPERTY(QString portalId READ portalId WRITE setPortalId NOTIFY portalIdChanged)
	Q_PROPERTY(QString shard READ shard WRITE setShard NOTIFY shardChanged)
	Q_PROPERTY(QString token READ token WRITE setToken NOTIFY tokenChanged)
	Q_PROPERTY(int idUser READ idUser WRITE setIdUser NOTIFY idUserChanged)
	Q_PROPERTY(bool applicationVisible READ isApplicationVisible WRITE setApplicationVisible NOTIFY applicationVisibleChanged)

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

	bool isApplicationVisible() const;
	void setApplicationVisible(bool v);

	Q_INVOKABLE QString serviceUidForType(const QString &serviceType) const;
	Q_INVOKABLE QString uidPrefix() const;

	// Move this to some mock data manager when available
	Q_INVOKABLE void setMockValue(const QString &uid, const QVariant &value);
	Q_INVOKABLE QVariant mockValue(const QString &uid) const;

Q_SIGNALS:
	void stateChanged();
	void typeChanged();
	void mqttClientErrorChanged();
	void usernameChanged();
	void passwordChanged();
	void portalIdChanged();
	void shardChanged();
	void tokenChanged();
	void idUserChanged();
	void applicationVisibleChanged();

private:
	explicit BackendConnection(QObject *parent = nullptr);
	void setState(State backendConnectionState);
	void setState(VeQItemMqttProducer::ConnectionState backendConnectionState);
	void setState(bool connected);
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

	bool m_applicationVisible = true;

	State m_state = BackendConnection::State::Idle;
	SourceType m_type = UnknownSource;
	QMqttClient::ClientError m_mqttClientError = QMqttClient::NoError;

	VeQItemProducer *m_producer = nullptr;
#if !defined(VENUS_WEBASSEMBLY_BUILD)
	AlarmBusitem *m_alarmBusItem = nullptr;
#endif
	QNetworkAccessManager *m_network = nullptr;
};

}
}

#endif // BACKENDCONNECTION_H
