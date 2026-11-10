/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef CAMPERBACKEND_H
#define CAMPERBACKEND_H

#include <QObject>
#include <QPointer>
#include <QString>

class VeQItem;
class VeQItemMqttProducer;

/*
	Connects the standalone illustration to a Venus OS MQTT broker, so that VeQuickItems in QML can
	read device values from "mqtt/<serviceType>/<deviceInstance>/<path>" uids, as in gui-v2.

	The connection is configured in the same way as the gui-v2 WebAssembly build: from the query of
	the page URL (mqtt, id, shard, user, pass, token, colorScheme) in a WebAssembly build, or from
	the command line in a desktop build, which is only for development.
*/
class CamperBackend : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool configured READ configured CONSTANT FINAL)
	Q_PROPERTY(bool ready READ ready NOTIFY readyChanged FINAL)
	Q_PROPERTY(QString colorScheme READ colorScheme CONSTANT FINAL)
	Q_PROPERTY(QString alternatorServiceUid READ alternatorServiceUid NOTIFY alternatorServiceUidChanged FINAL)

public:
	struct Configuration {
		QString address;     // ws(s):// URL in WebAssembly, host[:port] on the desktop
		QString portalId;
		QString username;
		QString password;
		QString token;
		QString colorScheme; // "light" or "dark"; anything else follows the default
	};

	static Configuration configurationFromUrlQuery(const QString &query);
	static QString vrmAddressFromShard(const QString &shard);
	static QString vrmAddressFromPortalId(const QString &portalId);

	explicit CamperBackend(const Configuration &configuration, QObject *parent = nullptr);

	bool configured() const;
	bool ready() const;
	QString colorScheme() const;
	QString alternatorServiceUid() const;

Q_SIGNALS:
	void readyChanged();
	void alternatorServiceUidChanged();

private:
	void open();
	void updateAlternatorServiceUid();

	Configuration m_configuration;
	VeQItemMqttProducer *m_producer = nullptr;
	QPointer<VeQItem> m_alternators;
	QString m_alternatorServiceUid;
	bool m_ready = false;
};

#endif // CAMPERBACKEND_H
