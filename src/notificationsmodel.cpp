/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "notificationsmodel.h"

using namespace Victron::VenusOS;

int BaseNotification::notificationId() const
{
	return m_notificationId;
}

void BaseNotification::setNotificationId(int notificationId)
{
	if (m_notificationId != notificationId) {
		m_notificationId = notificationId;
		Q_EMIT notificationIdChanged();
	}
}

bool BaseNotification::acknowledged() const
{
	return m_acknowledged;
}

void BaseNotification::setAcknowledged(bool acknowledged)
{
	if (m_acknowledged != acknowledged) {
		m_acknowledged = acknowledged;
		Q_EMIT acknowledgedChanged();
	}
}

bool BaseNotification::active() const
{
	return m_active;
}

void BaseNotification::setActive(bool active)
{
	if (m_active != active) {
		m_active = active;
		Q_EMIT activeChanged();
	}
}

int BaseNotification::type() const
{
	return m_type;
}

void BaseNotification::setType(int type)
{
	if (m_type != type) {
		m_type = type;
		Q_EMIT typeChanged();
	}
}

QDateTime BaseNotification::dateTime() const
{
	return m_dateTime;
}

void BaseNotification::setDateTime(const QDateTime &dateTime)
{
	if (m_dateTime != dateTime) {
		m_dateTime = dateTime;
		Q_EMIT dateTimeChanged();
	}
}

QString BaseNotification::description() const
{
	return m_description;
}

void BaseNotification::setDescription(const QString &description)
{
	if (m_description != description) {
		m_description = description;
		Q_EMIT descriptionChanged();
	}
}

QString BaseNotification::deviceName() const
{
	return m_deviceName;
}

void BaseNotification::setDeviceName(const QString &deviceName)
{
	if (m_deviceName != deviceName) {
		m_deviceName = deviceName;
		Q_EMIT deviceNameChanged();
	}
}

QString BaseNotification::value() const
{
	return m_value;
}

void BaseNotification::setValue(const QString &value)
{
	if (m_value != value) {
		m_value = value;
		Q_EMIT valueChanged();
	}
}


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
