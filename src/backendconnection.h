#ifndef BACKENDCONNECTION_H
#define BACKENDCONNECTION_H

#include <QObject>
#include <QQmlEngine>

#include "velib/qt/ve_qitems_mqtt.hpp"
#include "src/enums.h"

namespace Victron {
namespace VenusOS {

class BackendConnection : public QObject
{
	Q_OBJECT
	Q_PROPERTY(State state READ state NOTIFY stateChanged)
	Q_PROPERTY(SourceType type READ type NOTIFY typeChanged)

public:
	enum SourceType {
		UnknownSource,
		DBusSource,
		MqttSource,
		MockSource
	};
	Q_ENUM(SourceType)

	enum State {
		Idle,
		Connecting,
		Connected,
		Ready,
		Disconnected,
		Failed
	};
	Q_ENUM(State)

	static BackendConnection* instance(QQmlEngine *, QJSEngine *);


	State state() const;
	void setState(const SourceType type, const VeQItemMqttProducer::ConnectionState backendConnectionState);
	void setState(const SourceType type, const bool connected);

	SourceType type() const;
	void setType(const SourceType type);

Q_SIGNALS:
	void stateChanged();
	void typeChanged();

private:
	explicit BackendConnection(QObject *parent = nullptr);
	void setState(const State backendConnectionState);
	State m_state = BackendConnection::State::Idle;
	SourceType m_type = UnknownSource;
};

}
}

#endif // BACKENDCONNECTION_H
