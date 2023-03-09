#ifndef BACKENDCONNECTION_H
#define BACKENDCONNECTION_H

#include <QObject>
#include <QQmlEngine>

#include "veutil/qt/ve_qitems_mqtt.hpp"

class VeQItemDbusProducer;
class AlarmBusitem;

namespace Victron {
namespace VenusOS {

class UidHelper;

class BackendConnection : public QObject
{
	Q_OBJECT
	Q_PROPERTY(State state READ state NOTIFY stateChanged)
	Q_PROPERTY(SourceType type READ type NOTIFY typeChanged)
	Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
	Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
	Q_PROPERTY(QString portalId READ portalId WRITE setPortalId NOTIFY portalIdChanged)

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
		Ready,
		Disconnected,
		Reconnecting,
		Failed
	};
	Q_ENUM(State)

	static BackendConnection* instance(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

	State state() const;

	void loadConfiguration();

	SourceType type() const;
	void setType(SourceType type, const QString &address = QString());

	QString username() const;
	void setUsername(const QString &username);

	QString password() const;
	void setPassword(const QString &password);

	QString portalId() const;
	void setPortalId(const QString &portalId);

Q_SIGNALS:
	void stateChanged();
	void typeChanged();
	void usernameChanged();
	void passwordChanged();
	void portalIdChanged();

private:
	explicit BackendConnection(QObject *parent = nullptr);
	void setState(State backendConnectionState);
	void setState(VeQItemMqttProducer::ConnectionState backendConnectionState);
	void setState(bool connected);

#if !defined(VENUS_WEBASSEMBLY_BUILD)
	void initDBusConnection(const QString &address);
#endif
	void initMqttConnection(const QString &address);

	QString m_username;
	QString m_password;
	QString m_portalId;

	State m_state = BackendConnection::State::Idle;
	SourceType m_type = UnknownSource;

#if !defined(VENUS_WEBASSEMBLY_BUILD)
	VeQItemDbusProducer *m_dbusProducer = nullptr;
	AlarmBusitem *m_alarmBusItem = nullptr;
#endif
	VeQItemMqttProducer *m_mqttProducer = nullptr;
	UidHelper *m_uidHelper = nullptr;
};

}
}

#endif // BACKENDCONNECTION_H
