/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef ALLNOTIFICATIONSMODEL_H
#define ALLNOTIFICATIONSMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QAbstractListModel>
#include "basenotification.h"

namespace Victron {

namespace VenusOS {

class AllNotificationsModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	enum NotificationRoles {
		NotificationId = Qt::UserRole,
		Acknowledged,
		Active,
		Type,
		DateTime,
		Description,
		DeviceName,
		Value
	};
	Q_ENUM(NotificationRoles);

	explicit AllNotificationsModel(QObject *parent = nullptr);

	int count(const QModelIndex& parent = QModelIndex()) const;
	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;
	bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

	//Q_INVOKABLE void insertByDate(Victron::VenusOS::BaseNotification *notification);
	Q_INVOKABLE void insertNotification(Victron::VenusOS::BaseNotification *notification);
	Q_INVOKABLE void removeNotification(int notificationId);
	Q_INVOKABLE void reset();

	void insert(const int index, BaseNotification *newNotification);
	void remove(int index);

signals:
	void countChanged(int);

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
#endif // ALLNOTIFICATIONSMODEL_H
