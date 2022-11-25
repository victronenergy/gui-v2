#include "backendconnection.h"


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

void BackendConnection::setState(const State backendConnectionState)
{
	if (m_state != backendConnectionState) {
		m_state = backendConnectionState;
		emit stateChanged();
	}
}

void BackendConnection::setState(const Enums::DataPoint_SourceType type, const VeQItemMqttProducer::ConnectionState backendConnectionState)
{
	qDebug() << "BackendConnection::setState()" << backendConnectionState;
	setType(type);
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

void BackendConnection::setState(const Enums::DataPoint_SourceType type, const bool connected)
{
	setType(type);
	setState(connected ? Ready : Disconnected);
}

Enums::DataPoint_SourceType BackendConnection::type() const
{
	return m_type;
}

void BackendConnection::setType(const Enums::DataPoint_SourceType type)
{
	if (m_type != type) {
		m_type = type;
		emit typeChanged();
	}
}
}
}
