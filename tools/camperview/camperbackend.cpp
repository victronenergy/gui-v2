/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "camperbackend.h"
#include "mqttaddress.h"

#include <veutil/qt/ve_qitem.hpp>
#include <veutil/qt/ve_qitems_mqtt.hpp>

#include <QCommandLineParser>
#include <QHostAddress>
#include <QUrl>
#include <QUrlQuery>

namespace {

using Victron::VenusOS::CamperBackend;

// The producer id, which is the first part of every uid, as in gui-v2.
const QString ProducerId = QStringLiteral("mqtt");

QString queryValue(const QUrlQuery &query, const QString &key)
{
	return query.queryItemValue(key, QUrl::FullyDecoded);
}

// Fills in a missing VRM broker address from the shard or portal id, as gui-v2 does. Only a
// WebAssembly build can reach a wss:// broker.
CamperBackend::Configuration withDefaultAddress(CamperBackend::Configuration configuration, const QString &shard)
{
	// gui-v2 asks the VRM API for the broker when shard=vrm, which this app does not do.
	const bool vrmApiShard = shard.compare(QStringLiteral("vrm"), Qt::CaseInsensitive) == 0;
	if (vrmApiShard && configuration.address.isEmpty()) {
		qWarning("shard=vrm (VRM API login) is not supported; pass --mqtt or --id");
	}
#if defined(VENUS_WEBASSEMBLY_BUILD)
	if (configuration.address.isEmpty()) {
		if (!shard.isEmpty() && !vrmApiShard) {
			configuration.address = Victron::VenusOS::calculateMqttAddressFromShard(shard);
		} else if (!configuration.portalId.isEmpty()) {
			configuration.address = Victron::VenusOS::calculateMqttAddressFromPortalId(configuration.portalId);
		}
	}
#endif
	return configuration;
}

}

namespace Victron {
namespace VenusOS {

CamperBackend::Configuration CamperBackend::configurationFromArguments(const QStringList &arguments)
{
	// The same options as gui-v2, see src/main.cpp. VRM passes e.g.
	// --mqtt wss://webmqtt<n>.victronenergy.com/mqtt?idUser=<n> --id <portal> --user <u> --pass <JWT>.
	QCommandLineParser parser;
	parser.setApplicationDescription(QStringLiteral("Standalone RV illustration"));
	const QCommandLineOption help = parser.addHelpOption();
	const QCommandLineOption mqtt({ "m", "mqtt" }, QStringLiteral("MQTT broker: a ws(s):// URL in WebAssembly, host[:port] on the desktop."), QStringLiteral("address"));
	const QCommandLineOption id({ "i", "id" }, QStringLiteral("Portal id of the device."), QStringLiteral("portalId"));
	const QCommandLineOption shard({ "s", "shard" }, QStringLiteral("VRM broker shard."), QStringLiteral("shard"));
	const QCommandLineOption user({ "u", "user" }, QStringLiteral("MQTT user name."), QStringLiteral("user"));
	const QCommandLineOption pass({ "p", "pass" }, QStringLiteral("MQTT password."), QStringLiteral("password"));
	const QCommandLineOption token({ "t", "token" }, QStringLiteral("MQTT auth token."), QStringLiteral("token"));
	const QCommandLineOption colorScheme("colorScheme", QStringLiteral("light, dark, auto or default."), QStringLiteral("scheme"));
	parser.addOptions({ mqtt, id, shard, user, pass, token, colorScheme });

	// Report a bad option but keep going: a host may pass options this app does not know.
	if (!parser.parse(arguments)) {
		qWarning().noquote() << parser.errorText();
	}
	if (parser.isSet(help)) {
		parser.showHelp();
	}

	Configuration configuration;
	configuration.address = parser.value(mqtt);
	configuration.portalId = parser.value(id);
	configuration.username = parser.value(user);
	configuration.password = parser.value(pass);
	configuration.token = parser.value(token);
	configuration.colorScheme = colorSchemeFromString(parser.value(colorScheme));
	return withDefaultAddress(configuration, parser.value(shard));
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
	configuration.colorScheme = colorSchemeFromString(queryValue(query, QStringLiteral("colorScheme")));
	return withDefaultAddress(configuration, queryValue(query, QStringLiteral("shard")));
}

// Matches the colorScheme handling in gui-v2's src/main.cpp.
CamperBackend::ColorScheme CamperBackend::colorSchemeFromString(const QString &value)
{
	const QString scheme = value.toLower();
	if (scheme == QStringLiteral("dark")) {
		return ColorSchemeDark;
	} else if (scheme == QStringLiteral("light")) {
		return ColorSchemeLight;
	} else if (scheme == QStringLiteral("auto")) {
		return ColorSchemeAuto;
	}
	return ColorSchemeDefault;
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

CamperBackend::HeartbeatState CamperBackend::heartbeatState() const
{
	return m_heartbeatState;
}

CamperBackend::ColorScheme CamperBackend::colorScheme() const
{
	return m_configuration.colorScheme;
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
	connect(m_producer, &VeQItemMqttProducer::heartbeatStateChanged, this, [this] {
		const HeartbeatState state = static_cast<HeartbeatState>(m_producer->heartbeatState());
		if (m_heartbeatState != state) {
			m_heartbeatState = state;
			emit heartbeatStateChanged();
		}
	});
	connect(m_producer, &VeQItemMqttProducer::errorChanged, this, [this] {
		qWarning() << "MQTT client error:" << m_producer->error();
	});

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

}
}
