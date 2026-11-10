/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "camperbackend.h"

#include <veutil/qt/ve_qitem.hpp>
#include <veutil/qt/ve_qitems_mqtt.hpp>

#include <QHostAddress>
#include <QUrl>
#include <QUrlQuery>

namespace {

// The producer id, which is the first part of every uid, as in gui-v2.
const QString ProducerId = QStringLiteral("mqtt");

QString queryValue(const QUrlQuery &query, const QString &key)
{
	return query.queryItemValue(key, QUrl::FullyDecoded);
}

}

CamperBackend::Configuration CamperBackend::configurationFromUrlQuery(const QString &queryString)
{
	// The same parameters as the gui-v2 WebAssembly build, see src/main.cpp.
	const QUrlQuery query(queryString);
	Configuration configuration;
	configuration.address = queryValue(query, QStringLiteral("mqtt"));
	configuration.portalId = queryValue(query, QStringLiteral("id"));
	configuration.username = queryValue(query, QStringLiteral("user"));
	configuration.password = queryValue(query, QStringLiteral("pass"));
	configuration.token = queryValue(query, QStringLiteral("token"));
	configuration.colorScheme = queryValue(query, QStringLiteral("colorScheme"));

	if (configuration.address.isEmpty()) {
		const QString shard = queryValue(query, QStringLiteral("shard"));
		if (!shard.isEmpty()) {
			configuration.address = vrmAddressFromShard(shard);
		} else if (!configuration.portalId.isEmpty()) {
			configuration.address = vrmAddressFromPortalId(configuration.portalId);
		}
	}
	return configuration;
}

// These match calculateMqttAddressFromShard() and calculateMqttAddressFromPortalId() in
// src/main.cpp, which is not linked into this app.
QString CamperBackend::vrmAddressFromShard(const QString &shard)
{
	return QStringLiteral("wss://webmqtt%1.victronenergy.com/mqtt").arg(shard);
}

QString CamperBackend::vrmAddressFromPortalId(const QString &portalId)
{
	int shard = 0;
	for (const QChar &ch : portalId.toLower().trimmed()) {
		shard += ch.toLatin1();
	}
	return vrmAddressFromShard(shard > 0 ? QString::number(shard % 128) : QString());
}

CamperBackend::CamperBackend(const Configuration &configuration, QObject *parent)
	: QObject(parent)
	, m_configuration(configuration)
{
	if (configured()) {
		open();
	} else {
		qWarning("No MQTT broker given: the illustration will show no values.");
	}
}

bool CamperBackend::configured() const
{
	return !m_configuration.address.isEmpty();
}

bool CamperBackend::ready() const
{
	return m_ready;
}

QString CamperBackend::colorScheme() const
{
	return m_configuration.colorScheme;
}

QString CamperBackend::alternatorServiceUid() const
{
	return m_alternatorServiceUid;
}

void CamperBackend::open()
{
	m_producer = new VeQItemMqttProducer(VeQItems::getRoot(), ProducerId, QStringLiteral("camperview"), this);

	connect(m_producer, &VeQItemMqttProducer::aboutToConnect, this, [this] {
		if (!m_configuration.token.isEmpty()) {
			m_producer->setCredentials(m_configuration.username, m_configuration.token);
		} else if (!m_configuration.username.isEmpty() || !m_configuration.password.isEmpty()) {
			m_producer->setCredentials(m_configuration.username, m_configuration.password);
		}
		m_producer->continueConnect();
	});
	connect(m_producer, &VeQItemMqttProducer::connectionStateChanged, this, [this] {
		const bool ready = m_producer->connectionState() == VeQItemMqttProducer::Ready;
		if (m_ready != ready) {
			m_ready = ready;
			emit readyChanged();
		}
	});

	// The first alternator, in device instance order, is the one whose state is shown.
	m_alternators = m_producer->services()->itemGetOrCreate(QStringLiteral("alternator"), false);
	connect(m_alternators, &VeQItem::childAdded, this, &CamperBackend::updateAlternatorServiceUid);
	connect(m_alternators, &VeQItem::childRemoved, this, &CamperBackend::updateAlternatorServiceUid);
	updateAlternatorServiceUid();

	if (!m_configuration.portalId.isEmpty()) {
		m_producer->setPortalId(m_configuration.portalId);
	}

	qInfo().noquote() << "Connecting to MQTT broker at" << m_configuration.address;
#if defined(VENUS_WEBASSEMBLY_BUILD)
	m_producer->open(QUrl(m_configuration.address), QMqttClient::MQTT_3_1);
#else
	const QStringList parts = m_configuration.address.split(QLatin1Char(':'));
	bool ok = false;
	const int port = parts.size() >= 2 ? parts.at(1).toInt(&ok) : 0;
	m_producer->open(QHostAddress(parts.first()), ok ? port : 1883);
#endif
}

void CamperBackend::updateAlternatorServiceUid()
{
	QString uid;
	if (m_alternators) {
		int lowestInstance = -1;
		const VeQItem::Children &children = m_alternators->itemChildren();
		for (auto it = children.cbegin(); it != children.cend(); ++it) {
			bool ok = false;
			const int instance = it.key().toInt(&ok);
			if (ok && (lowestInstance < 0 || instance < lowestInstance)) {
				lowestInstance = instance;
			}
		}
		if (lowestInstance >= 0) {
			uid = QStringLiteral("%1/alternator/%2").arg(ProducerId).arg(lowestInstance);
		}
	}
	if (m_alternatorServiceUid != uid) {
		m_alternatorServiceUid = uid;
		emit alternatorServiceUidChanged();
	}
}
