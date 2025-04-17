/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "notificationsmodel.h"

using namespace Victron::VenusOS;

NotificationsModel::NotificationsModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_roleNames.insert(NotificationRoles::Notification, "notification");
	m_roleNames.insert(NotificationRoles::NotificationId, "notificationId");
	m_roleNames.insert(NotificationRoles::Acknowledged, "acknowledged");
	m_roleNames.insert(NotificationRoles::Active, "active");
	m_roleNames.insert(NotificationRoles::ActiveOrUnAcknowledged, "activeOrUnAcknowledged");
	m_roleNames.insert(NotificationRoles::Type, "type");
	m_roleNames.insert(NotificationRoles::DateTime, "dateTime");
	m_roleNames.insert(NotificationRoles::Description, "description");
	m_roleNames.insert(NotificationRoles::DeviceName, "deviceName");
	m_roleNames.insert(NotificationRoles::Value, "value");
}

int NotificationsModel::count(const QModelIndex &) const
{
	return static_cast<int>(m_data.count());
}

QVariant NotificationsModel::data(const QModelIndex &index, int role) const
{
	int row = index.row();

	if (row < 0 || row >= m_data.count()) {
		return QVariant();
	}
	switch (role)
	{
	case Notification:
		return QVariant::fromValue(m_data.at(row).get());
	case NotificationId:
		return m_data.at(row).get()->notificationId();
	case Acknowledged:
		return m_data.at(row).get()->acknowledged();
	case Active:
		return m_data.at(row).get()->active();
	case ActiveOrUnAcknowledged:
		return m_data.at(row).get()->activeOrUnAcknowledged();
	case Type:
		return m_data.at(row).get()->type();
	case DateTime:
		return m_data.at(row).get()->dateTime();
	case Description:
		return m_data.at(row).get()->description();
	case DeviceName:
		return m_data.at(row).get()->deviceName();
	case Value:
		return m_data.at(row).get()->value();
	default:
		return QVariant();

	}
	return QVariant();
}

void NotificationsModel::insert(const int index, BaseNotification* notification)
{
	if (index < 0 || index > m_data.count() || notification == nullptr) {
		return;
	}
	beginInsertRows(QModelIndex(), index, index);
	m_data.insert(index, notification);

	connect(notification, &BaseNotification::notificationIdChanged, this, &NotificationsModel::notificationIdChangedHandler);
	connect(notification, &BaseNotification::acknowledgedChanged,       this, &NotificationsModel::acknowledgedChangedHandler);
	connect(notification, &BaseNotification::activeChanged,         this, &NotificationsModel::activeChangedHandler);
	connect(notification, &BaseNotification::typeChanged,           this, &NotificationsModel::typeChangedHandler);
	connect(notification, &BaseNotification::dateTimeChanged,       this, &NotificationsModel::dateTimeChangedHandler);
	connect(notification, &BaseNotification::descriptionChanged,    this, &NotificationsModel::descriptionChangedHandler);
	connect(notification, &BaseNotification::deviceNameChanged,     this, &NotificationsModel::deviceNameChangedHandler);
	connect(notification, &BaseNotification::valueChanged,          this, &NotificationsModel::valueChangedHandler);

	endInsertRows();
	emit countChanged();
	emit notificationInserted(notification);
}

void NotificationsModel::insertNotification(BaseNotification *newNotification)
{
	insert(count(), newNotification);
}

void NotificationsModel::removeNotification(BaseNotification *notification)
{
	for (int i = 0; i < m_data.size(); ++i) {
		const BaseNotification *existingNotification = m_data.at(i);
		if (existingNotification == notification) {
			emit notificationRemoved(notification);
			remove(i);
			break;
		}
	}
}

void NotificationsModel::removeNotification(int notificationId)
{
	for (int i = 0; i < m_data.size(); ++i) {
		const BaseNotification *notification = m_data.at(i);
		if (notification && notification->notificationId() == notificationId) {
			emit notificationRemoved(notification);
			remove(i);
			break;
		}
	}
}

void NotificationsModel::remove(int index)
{
	if (index < 0 || index >= m_data.count()) {
		return;
	}

	const BaseNotification *notification = m_data.at(index);
	if (notification) {

		beginRemoveRows(QModelIndex(), index, index);

		disconnect(notification, &BaseNotification::notificationIdChanged, this, &NotificationsModel::notificationIdChangedHandler);
		disconnect(notification, &BaseNotification::acknowledgedChanged,       this, &NotificationsModel::acknowledgedChangedHandler);
		disconnect(notification, &BaseNotification::activeChanged,         this, &NotificationsModel::activeChangedHandler);
		disconnect(notification, &BaseNotification::typeChanged,           this, &NotificationsModel::typeChangedHandler);
		disconnect(notification, &BaseNotification::dateTimeChanged,       this, &NotificationsModel::dateTimeChangedHandler);
		disconnect(notification, &BaseNotification::descriptionChanged,    this, &NotificationsModel::descriptionChangedHandler);
		disconnect(notification, &BaseNotification::deviceNameChanged,     this, &NotificationsModel::deviceNameChangedHandler);
		disconnect(notification, &BaseNotification::valueChanged,          this, &NotificationsModel::valueChangedHandler);

		m_data.removeAt(index);

		endRemoveRows();
		emit countChanged();
	}
}

void NotificationsModel::reset()
{
	beginResetModel();
	m_data.clear();
	endResetModel();
	emit countChanged();
}

int NotificationsModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_data.count());
}

QHash<int, QByteArray> NotificationsModel::roleNames() const
{
	return m_roleNames;
}

void NotificationsModel::roleChangedHandler(BaseNotification *notification, NotificationRoles role)
{
	if (notification == nullptr) {
		return;
	}
	qint32 row = m_data.indexOf(notification);
	if (row == -1) {
		return;
	}
	QModelIndex index = this->index(row, 0, QModelIndex());
	QVector<int> roles = { role };
	if (role == Active || role == Acknowledged) {
		roles << ActiveOrUnAcknowledged;
	}

	emit dataChanged(index, index, roles);
	emit notificationUpdated(notification);
}

void NotificationsModel::notificationIdChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::NotificationId);
}

void NotificationsModel::acknowledgedChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Acknowledged);
}

void NotificationsModel::activeChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Active);
}

void NotificationsModel::typeChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Type);
}

void NotificationsModel::dateTimeChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::DateTime);
}

void NotificationsModel::descriptionChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Description);
}

void NotificationsModel::deviceNameChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::DeviceName);
}

void NotificationsModel::valueChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Value);
}
