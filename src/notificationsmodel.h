/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef NOTIFICATIONSMODEL_H
#define NOTIFICATIONSMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QDateTime>
#include <QVariantList>
#include "enums.h"

class QQmlEngine;
class QJSEngine;

class AlarmMonitor;

namespace Victron {

namespace VenusOS {

struct Notification
{
	Notification(const Notification& other);
	Notification(const bool acknowledged,
				 const bool active,
				 const Enums::Notification_Type type,
				 const QString &deviceName,
				 const QDateTime& dateTime,
				 const QString &description);
	Notification& operator=(const Notification &other);

	bool acknowledged = false;
	bool active = true;
	Enums::Notification_Type type = Enums::Notification_Alarm;
	QString deviceName;
	QDateTime dateTime;
	QString description;
	QString value;
};

class NotificationsModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
	enum RoleNames {
		AcknowledgedRole = Qt::UserRole,
		ActiveRole,
		TypeRole,
		ServiceRole,
		DateTimeRole,
		DescriptionRole,
		ValueRole
	};

	~NotificationsModel() override = 0;

	int count(const QModelIndex& parent = QModelIndex()) const;
	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	void insertByDate(const Victron::VenusOS::Notification& newNotification);
	Q_INVOKABLE void deactivateSingleAlarm(); // testing only
	Q_INVOKABLE void insertByDate(bool acknowledged,
							const bool active,
							const Enums::Notification_Type type,
							const QString &deviceName,
							const QDateTime& dateTime,
							const QString &description);
	Q_INVOKABLE void remove(int index);
	Q_INVOKABLE void reset();
	void insert(const int index, const Victron::VenusOS::Notification& newNotification);
	void append(const Victron::VenusOS::Notification& notification);

signals:
	void countChanged(int);

protected:
	explicit NotificationsModel(QObject *parent = nullptr);
	QHash<int, QByteArray> roleNames() const override;

	QList<Notification> m_data;
	const int m_maxNotifications;

private:
	QHash<int, QByteArray> m_roleNames;
};

class ActiveNotificationsModel : public NotificationsModel
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(bool hasNewNotifications READ hasNewNotifications NOTIFY hasNewNotificationsChanged) // when true, we display a red dot on the 'notifications' button in the nav bar
public:

	~ActiveNotificationsModel() override;
	static ActiveNotificationsModel* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);
	bool setData(const QModelIndex &index, const QVariant &value, int role) override;
	bool hasNewNotifications() const;
	void addOrUpdateNotification(Enums::Notification_Type type, const QString &devicename, const QString &description, const QString &value);

public slots:
	void handleChanges();

signals:
	void hasNewNotificationsChanged();

protected:
	explicit ActiveNotificationsModel(QObject *parent);

private:
	void setHasNewNotifications(const bool hasNewNotifications);
	bool m_hasNewNotifications = false;
};

class HistoricalNotificationsModel : public NotificationsModel
{
	Q_OBJECT
public:
	~HistoricalNotificationsModel() override;
	static HistoricalNotificationsModel* instance(QObject* parent = nullptr);
	bool setData(const QModelIndex &index, const QVariant &value, int role) override;

protected:
	explicit HistoricalNotificationsModel(QObject *parent = nullptr);
};

} /* VenusOS */

} /* Victron */
#endif // NOTIFICATIONSMODEL_H
