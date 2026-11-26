/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_CAMPERBACKEND_H
#define VICTRON_VENUSOS_GUI_V2_CAMPERBACKEND_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <qqmlintegration.h>

class VeQItemMqttProducer;

namespace Victron {
namespace VenusOS {

/*
	Connects the standalone illustration to a Venus OS MQTT broker, so that VeQuickItems in QML can
	read device values from "mqtt/<serviceType>/<deviceInstance>/<path>" uids, as in gui-v2.

	The connection is configured with the same options as gui-v2 (mqtt, id, shard, user, pass,
	token, colorScheme). They come from the command line, which is how the VRM remote console
	passes them to a WebAssembly build, or else from the query of the page URL.
*/
class CamperBackend : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_UNCREATABLE("CamperBackend is created by main.cpp")
	Q_PROPERTY(bool configured READ configured CONSTANT FINAL)
	Q_PROPERTY(bool ready READ ready NOTIFY readyChanged FINAL)
	Q_PROPERTY(HeartbeatState heartbeatState READ heartbeatState NOTIFY heartbeatStateChanged FINAL)
	Q_PROPERTY(ColorScheme colorScheme READ colorScheme CONSTANT FINAL)

public:
	// Mirrors VeQItemMqttProducer::HeartbeatState.
	enum HeartbeatState {
		HeartbeatActive,
		HeartbeatMissing,
		HeartbeatInactive
	};
	Q_ENUM(HeartbeatState)

	// The colorScheme option, as in gui-v2's Theme::ForcedColorScheme.
	enum ColorScheme {
		ColorSchemeDark,
		ColorSchemeLight,
		ColorSchemeAuto,
		ColorSchemeDefault
	};
	Q_ENUM(ColorScheme)

	struct Configuration {
		QString address;     // ws(s):// URL in WebAssembly, host[:port] on the desktop
		QString portalId;
		QString username;
		QString password;
		QString token;
		ColorScheme colorScheme = ColorSchemeDefault;
	};

	static Configuration configurationFromArguments(const QStringList &arguments);
	static Configuration configurationFromUrlQuery(const QString &query);
	static ColorScheme colorSchemeFromString(const QString &value);

	explicit CamperBackend(const Configuration &configuration, QObject *parent = nullptr);

	bool configured() const;
	bool ready() const;
	HeartbeatState heartbeatState() const;
	ColorScheme colorScheme() const;

Q_SIGNALS:
	void readyChanged();
	void heartbeatStateChanged();

private:
	void open();

	Configuration m_configuration;
	VeQItemMqttProducer *m_producer = nullptr;
	HeartbeatState m_heartbeatState = HeartbeatInactive;
	bool m_ready = false;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_CAMPERBACKEND_H
