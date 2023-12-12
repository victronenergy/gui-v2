/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_UIDHELPER_H
#define VICTRON_VENUSOS_GUI_V2_UIDHELPER_H

#include <QtCore/QPointer>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QHash>

#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>

namespace Victron {

namespace VenusOS {

class UidHelper : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

public:
	int deviceInstanceForService(const QString &service) const;

	static UidHelper* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void serviceRegistered(const QString &service, int deviceInstance);
	void serviceUnregistered(const QString &service);

public Q_SLOTS:
	void onMessageReceived(const QString &path, const QVariant &message);
	void onNullMessageReceived(const QString &path);

private:
	UidHelper(QObject *parent);

	void addServiceMapping(const QString &serviceMappingKey, const QString &service);
	void removeServiceMapping(const QString &serviceMappingKey);

	QHash<QString, QString> m_serviceMappings;
	QHash<QString, int> m_serviceDeviceInstances;
};

class SingleUidHelper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString dbusUid READ dbusUid WRITE setDBusUid NOTIFY dbusUidChanged)
	Q_PROPERTY(QString mqttUid READ mqttUid NOTIFY mqttUidChanged)

public:
	SingleUidHelper(QObject *parent = nullptr);

	void setDBusUid(const QString &dbusUid);
	QString dbusUid() const;

	QString mqttUid() const;

Q_SIGNALS:
	void dbusUidChanged();
	void mqttUidChanged();

private:
	void updateMqttUid();
	void onServiceRegistered(const QString &service, int deviceInstance);
	void onServiceUnregistered(const QString &service);

	QPointer<UidHelper> m_uidHelper;
	QString m_dbusUid;
	QString m_mqttUid;
	QString m_serviceName;
	QString m_remainderPath;
	int m_deviceInstance = -1;
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_UIDHELPER_H

