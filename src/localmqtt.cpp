/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "localmqtt.h"
#include "backendconnection.h"

#include <QMqttSubscription>
#include <QMqttTopicName>

using namespace Victron::VenusOS;

LocalMqttClient::LocalMqttClient(QObject *parent)
	: QObject(parent)
{
	BackendConnection *backend = BackendConnection::create();
	connect(backend, &BackendConnection::heartbeatStateChanged, this, [this, backend]() {
		const bool prevHeartbeatActive = vrmHeartbeatActive();
		m_vrmHeartbeatActive = backend->heartbeatState() == BackendConnection::HeartbeatActive;
		if (prevHeartbeatActive != m_vrmHeartbeatActive) {
			Q_EMIT vrmHeartbeatActiveChanged();
		}
	});
}

LocalMqttClient::~LocalMqttClient()
{
	if (m_readSub) {
		m_readSub->unsubscribe();
		delete m_readSub;
	}
	if (m_writeSub) {
		m_writeSub->unsubscribe();
		delete m_writeSub;
	}
}

void LocalMqttClient::readMessageReceived(QMqttMessage msg)
{
	Q_ASSERT(m_client);

	const QMqttTopicName topic = msg.topic();
	qWarning() << "*** R message:" << topic.name() << msg.payload();

	if (topic.name() == "R/victron/ui/currentpage") {
		m_client->publish(QMqttTopicName("victron/ui/currentpage"), m_currentAppPage.toUtf8());
	} else if (topic.name() == "R/victron/vrm/connected") {
		m_client->publish(QMqttTopicName("victron/vrm/connected"), m_vrmHeartbeatActive ? "true" : "false");
	}
}

void LocalMqttClient::writeMessageReceived(QMqttMessage msg)
{
	const QMqttTopicName topic = msg.topic();
	qWarning() << "*** W message:" << topic.name() << msg.payload();

	if (topic.name() == "W/victron/ui/currentpage") {
		Q_EMIT requestGoToPage(msg.payload());
	}
}

void LocalMqttClient::stateChanged(QMqttClient::ClientState state)
{
	if (state == QMqttClient::Connected) {
		m_readSub = m_client->subscribe(QMqttTopicFilter("R/victron/#"));
		if (m_readSub) {
			connect(m_readSub, &QMqttSubscription::messageReceived, this, &LocalMqttClient::readMessageReceived);
		}
		m_writeSub = m_client->subscribe(QMqttTopicFilter("W/victron/#"));
		if (m_writeSub) {
			connect(m_writeSub, &QMqttSubscription::messageReceived, this, &LocalMqttClient::writeMessageReceived);
		}
	}
}

bool LocalMqttClient::isActive() const
{
	return m_client != nullptr;
}

void LocalMqttClient::setActive(bool active)
{
	qWarning() << "*** setActive:" << active;
	if (isActive() == active) {
		return;
	}

	if (m_readSub) {
		m_readSub->unsubscribe();
		delete m_readSub;
		m_readSub = nullptr;
	}
	if (m_writeSub) {
		m_writeSub->unsubscribe();
		delete m_writeSub;
		m_writeSub = nullptr;
	}
	if (m_client) {
		delete m_client;
		m_client = nullptr;
	}

	if (active) {
		m_client = new QMqttClient(this);
		connect(m_client, &QMqttClient::stateChanged, this, &LocalMqttClient::stateChanged);
		m_client->setHostname("localhost");
		m_client->setPort(1883);
		m_client->connectToHost();
	}

	Q_EMIT activeChanged();
}

bool LocalMqttClient::vrmHeartbeatActive() const
{
	return m_vrmHeartbeatActive;
}

QString LocalMqttClient::currentAppPage() const
{
	return m_currentAppPage;
}

void LocalMqttClient::setCurrentAppPage(const QString &pageName)
{
	if (m_currentAppPage != pageName) {
		m_currentAppPage = pageName;
		Q_EMIT currentAppPageChanged();
	}
}

