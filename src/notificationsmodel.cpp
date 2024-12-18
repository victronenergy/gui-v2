/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "notificationsmodel.h"

using namespace Victron::VenusOS;

NotificationsModel::NotificationsModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_roleNames[NotificationRole] = "notification";
}

int NotificationsModel::count(const QModelIndex &) const
{
	return static_cast<int>(m_data.count());
}

QVariant NotificationsModel::data(const QModelIndex &index, int role) const
{
	int row = index.row();

	if(row < 0 || row >= m_data.count()) {
		return QVariant();
	}
	switch (role)
	{
	case NotificationRole:
		return QVariant::fromValue<BaseNotification *>(m_data.at(row).get());
	}
	return QVariant();
}

void NotificationsModel::insert(const int index, BaseNotification* notification)
{
	if (index < 0 || index > m_data.count()) {
		return;
	}
	emit beginInsertRows(QModelIndex(), index, index);
	m_data.insert(index, notification);
	emit endInsertRows();
	emit countChanged(static_cast<int>(m_data.count()));
}

void NotificationsModel::insertByDate(Victron::VenusOS::BaseNotification *newNotification)
{
	for (int i = 0; i < m_data.size(); ++i) {
		const BaseNotification *notification = m_data.at(i);
		if (notification && newNotification->m_dateTime > notification->m_dateTime) {
			insert(i, newNotification);
			return;
		}
	}
	insert(count(), newNotification);
}

void NotificationsModel::removeNotification(int notificationId)
{
	for (int i = 0; i < m_data.size(); ++i) {
		const BaseNotification *notification = m_data.at(i);
		if (notification && notification->notificationId() == notificationId) {
			remove(i);
			break;
		}
	}
}

void NotificationsModel::remove(int index)
{
	if(index < 0 || index >= m_data.count()) {
		return;
	}
	emit beginRemoveRows(QModelIndex(), index, index);
	m_data.removeAt(index);
	emit endRemoveRows();
	emit countChanged(static_cast<int>(m_data.count()));
}

void NotificationsModel::reset()
{
	beginResetModel();
	m_data.clear();
	endResetModel();
	emit countChanged(static_cast<int>(m_data.count()));
}

int NotificationsModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_data.count());
}

QHash<int, QByteArray> NotificationsModel::roleNames() const
{
	return m_roleNames;
}
