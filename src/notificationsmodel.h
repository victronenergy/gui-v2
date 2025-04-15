/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef NOTIFICATIONSMODEL_H
#define NOTIFICATIONSMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QAbstractListModel>
#include "basenotification.h"

namespace Victron {

namespace VenusOS {

class NotificationsModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	enum NotificationRoles {
		Notification = Qt::UserRole,
		NotificationId,
		Acknowledged,
		Active,
		ActiveOrUnAcknowledged,
		Type,
		DateTime,
		Description,
		DeviceName,
		Value
	};
	Q_ENUM(NotificationRoles);

	explicit NotificationsModel(QObject *parent = nullptr);

	int count(const QModelIndex& parent = QModelIndex()) const;
	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE void insertNotification(Victron::VenusOS::BaseNotification *notification);
	Q_INVOKABLE void removeNotification(Victron::VenusOS::BaseNotification *notification);
	Q_INVOKABLE void removeNotification(int notificationId);
	Q_INVOKABLE void reset();

	void insert(const int index, BaseNotification *newNotification);
	void remove(int index);

signals:
	void countChanged();
	void notificationInserted(const Victron::VenusOS::BaseNotification* notification);
	void notificationRemoved(const Victron::VenusOS::BaseNotification* notification);
	void notificationUpdated(const Victron::VenusOS::BaseNotification* notification);

protected:
	QHash<int, QByteArray> roleNames() const override;

	QVector<QPointer<BaseNotification> > m_data;

private:
	void roleChangedHandler(BaseNotification *notification, NotificationRoles role);
	void notificationIdChangedHandler();
	void acknowledgedChangedHandler();
	void activeChangedHandler();
	void typeChangedHandler();
	void dateTimeChangedHandler();
	void descriptionChangedHandler();
	void deviceNameChangedHandler();
	void valueChangedHandler();

	QHash<int, QByteArray> m_roleNames;
};

} /* VenusOS */

} /* Victron */
#endif // NOTIFICATIONSMODEL_H
