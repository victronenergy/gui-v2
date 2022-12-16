/*
** Copyright (C) 2022 Victron Energy B.V.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_UIDHELPER_H
#define VICTRON_VENUSOS_GUI_V2_UIDHELPER_H

#include <QtCore/QPointer>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QHash>
#include <QtCore/QSet>

#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>

namespace Victron {

namespace VenusOS {

class UidHelper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QHash<QString, QString> serviceNamesToPaths READ serviceNamesToPaths WRITE setServiceNamesToPaths NOTIFY serviceNamesToPathsChanged)

public:
	QHash<QString, QString> serviceNamesToPaths() const;
	void setServiceNamesToPaths(const QHash<QString, QString> &hash);
	Q_INVOKABLE QString pathForServiceName(const QString &serviceName) const;

	static UidHelper* instance(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void serviceNamesToPathsChanged();
	void pathForServiceNameChanged(const QString &serviceName, const QString &path);

public Q_SLOTS:
	void onMessageReceived(const QString &path, const QVariant &message);
	void onNullMessageReceived(const QString &path);

private:
	UidHelper(QObject *parent = nullptr);

	QHash<QString, QString> m_serviceNamesToPaths;
	QHash<QString, QString> m_pathToServiceName;
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

public Q_SLOTS:
	void onPathForServiceNameChanged(const QString &serviceName, const QString &path);

Q_SIGNALS:
	void dbusUidChanged();
	void mqttUidChanged();

private:
	QPointer<UidHelper> m_uidHelper;
	QString m_dbusUid;
	QString m_mqttUid;
	QString m_serviceName;
	QString m_mqttDevicePath;
	QString m_remainderPath;
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_UIDHELPER_H

