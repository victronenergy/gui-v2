/*
** Copyright (C) 2022 Victron Energy B.V.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_UIDHELPER_H
#define VICTRON_VENUSOS_GUI_V2_UIDHELPER_H

#include <QtCore/QPointer>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QSet>

#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>

namespace Victron {

namespace VenusOS {

class UidHelper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QSet<QString> activeTopics READ activeTopics NOTIFY activeTopicsChanged)

public:
	void setActiveTopics(const QSet<QString> &topics);
	QSet<QString> activeTopics() const;

	static UidHelper* instance(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void activeTopicsChanged();

private:
	UidHelper(QObject *parent = nullptr);

	QSet<QString> m_activeTopics;
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
	void recalculateMqttUid(); // triggered by activeTopicsChanged() and dbusUidChanged()

Q_SIGNALS:
	void dbusUidChanged();
	void mqttUidChanged();

private:
	QPointer<UidHelper> m_uidHelper;
	QString m_dbusUid;
	QString m_mqttUid;
	bool m_uidIsFallback = true;
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_UIDHELPER_H

