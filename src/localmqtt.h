/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_LOCALMQTT_H
#define VICTRON_GUIV2_LOCALMQTT_H

#include <QMqttClient>
#include <QMqttMessage>
#include <qqmlintegration.h>

class QMqttSubscription;

namespace Victron {
namespace VenusOS {

class LocalMqttClient : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged FINAL)
	Q_PROPERTY(bool vrmHeartbeatActive READ vrmHeartbeatActive NOTIFY vrmHeartbeatActiveChanged FINAL)
	Q_PROPERTY(QString currentAppPage READ currentAppPage WRITE setCurrentAppPage NOTIFY currentAppPageChanged FINAL)

public:
	explicit LocalMqttClient(QObject *parent = nullptr);
	~LocalMqttClient();

	bool isActive() const;
	void setActive(bool active);

	QString currentAppPage() const;
	void setCurrentAppPage(const QString &pageName);

	bool vrmHeartbeatActive() const;

Q_SIGNALS:
	void activeChanged();
	void vrmHeartbeatActiveChanged();
	void currentAppPageChanged();
	void requestGoToPage(const QString &pageName);

private:
	void readMessageReceived(QMqttMessage msg);
	void writeMessageReceived(QMqttMessage msg);
	void stateChanged(QMqttClient::ClientState state);

	QString m_currentAppPage;
	QMqttClient *m_client = nullptr;
	QMqttSubscription *m_readSub = nullptr;
	QMqttSubscription *m_writeSub = nullptr;
	bool m_vrmHeartbeatActive = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_LOCALMQTT_H

