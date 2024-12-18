/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "allnotificationsmodel.h"

using namespace Victron::VenusOS;

AllNotificationsModel::AllNotificationsModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_roleNames.insert(NotificationRoles::NotificationId, "notificationId");
	m_roleNames.insert(NotificationRoles::Acknowledged, "acknowledged");
	m_roleNames.insert(NotificationRoles::Active, "active");
	m_roleNames.insert(NotificationRoles::Type, "type");
	m_roleNames.insert(NotificationRoles::DateTime, "dateTime");
	m_roleNames.insert(NotificationRoles::Description, "description");
	m_roleNames.insert(NotificationRoles::DeviceName, "deviceName");
	m_roleNames.insert(NotificationRoles::Value, "value");
}

int AllNotificationsModel::count(const QModelIndex &) const
{
	return static_cast<int>(m_data.count());
}

QVariant AllNotificationsModel::data(const QModelIndex &index, int role) const
{
	int row = index.row();

	if(row < 0 || row >= m_data.count()) {
		return QVariant();
	}
	switch (role)
	{
	case NotificationId:
		return m_data.at(row).get()->notificationId();
	case Acknowledged:
		return m_data.at(row).get()->acknowledged();
	case Active:
		return m_data.at(row).get()->active();
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

bool AllNotificationsModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
	int row = index.row();

	if(row < 0 || row >= m_data.count()) {
		return false;
	}
	switch (role)
	{
	case NotificationRoles::NotificationId:
	{
		bool intOK = false;
		int notificationId = value.toInt(&intOK);
		if(intOK) {
			m_data.at(row).get()->setNotificationId(notificationId);
			return true;
		}
		else {
			return false;
		}
	}
	case NotificationRoles::Acknowledged:
		m_data.at(row).get()->setAcknowledged(value.toBool());
	case NotificationRoles::Active:
		m_data.at(row).get()->setActive(value.toBool());
	case NotificationRoles::Type:
	{
		bool intOK = false;
		int type = value.toInt(&intOK);
		if(intOK) {
			m_data.at(row).get()->setType(type);
			return true;
		} else {
			return false;
		}
	}
	case NotificationRoles::DateTime:
		m_data.at(row).get()->setDateTime(value.toDateTime());
	case NotificationRoles::Description:
		m_data.at(row).get()->setDescription(value.toString());
	case NotificationRoles::DeviceName:
		m_data.at(row).get()->setDeviceName(value.toString());
	case NotificationRoles::Value:
		m_data.at(row).get()->setValue(value.toString());
	default:
		return false;
	}

	// NOTE: the dataChanged signal is emitted automatically due to the BaseNotification's property change signal handlers

	return true;
}

void AllNotificationsModel::insert(const int index, BaseNotification* notification)
{
	if (index < 0 || index > m_data.count() || notification == nullptr) {
		return;
	}
	emit beginInsertRows(QModelIndex(), index, index);
	m_data.insert(index, notification);

	connect(notification, &BaseNotification::notificationIdChanged, this, &AllNotificationsModel::notificationIdChangedHandler);
	connect(notification, &BaseNotification::acknowledgedChanged,   this, &AllNotificationsModel::acknowledgedChangedHandler);
	connect(notification, &BaseNotification::activeChanged,         this, &AllNotificationsModel::activeChangedHandler);
	connect(notification, &BaseNotification::typeChanged,           this, &AllNotificationsModel::typeChangedHandler);
	connect(notification, &BaseNotification::dateTimeChanged,       this, &AllNotificationsModel::dateTimeChangedHandler);
	connect(notification, &BaseNotification::descriptionChanged,    this, &AllNotificationsModel::descriptionChangedHandler);
	connect(notification, &BaseNotification::deviceNameChanged,     this, &AllNotificationsModel::deviceNameChangedHandler);
	connect(notification, &BaseNotification::valueChanged,          this, &AllNotificationsModel::valueChangedHandler);

	emit endInsertRows();
	emit countChanged(static_cast<int>(m_data.count()));
}

void AllNotificationsModel::insertNotification(BaseNotification *notification)
{
	insert(m_data.count(), notification);
}

// void AllNotificationsModel::insertByDate(Victron::VenusOS::BaseNotification *newNotification)
// {
//     for (int i = 0; i < m_data.size(); ++i) {
//         const BaseNotification *notification = m_data.at(i);
//         if (notification && newNotification->m_dateTime > notification->m_dateTime) {
//             insert(i, newNotification);
//             return;
//         }
//     }
//     insert(count(), newNotification);
// }

void AllNotificationsModel::removeNotification(int notificationId)
{
	for (int i = 0; i < m_data.size(); ++i) {
		const BaseNotification *notification = m_data.at(i);
		if (notification && notification->notificationId() == notificationId) {
			remove(i);
			break;
		}
	}
}

void AllNotificationsModel::remove(int index)
{
	if(index < 0 || index >= m_data.count()) {
		return;
	}

	const BaseNotification *notification = m_data.at(index);
	if (notification) {

		emit beginRemoveRows(QModelIndex(), index, index);

		disconnect(notification, &BaseNotification::notificationIdChanged, this, &AllNotificationsModel::notificationIdChangedHandler);
		disconnect(notification, &BaseNotification::acknowledgedChanged,   this, &AllNotificationsModel::acknowledgedChangedHandler);
		disconnect(notification, &BaseNotification::activeChanged,         this, &AllNotificationsModel::activeChangedHandler);
		disconnect(notification, &BaseNotification::typeChanged,           this, &AllNotificationsModel::typeChangedHandler);
		disconnect(notification, &BaseNotification::dateTimeChanged,       this, &AllNotificationsModel::dateTimeChangedHandler);
		disconnect(notification, &BaseNotification::descriptionChanged,    this, &AllNotificationsModel::descriptionChangedHandler);
		disconnect(notification, &BaseNotification::deviceNameChanged,     this, &AllNotificationsModel::deviceNameChangedHandler);
		disconnect(notification, &BaseNotification::valueChanged,          this, &AllNotificationsModel::valueChangedHandler);

		m_data.removeAt(index);

		emit endRemoveRows();
		emit countChanged(static_cast<int>(m_data.count()));
	}
}

void AllNotificationsModel::reset()
{
	beginResetModel();
	m_data.clear();
	endResetModel();
	emit countChanged(static_cast<int>(m_data.count()));
}

int AllNotificationsModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_data.count());
}

QHash<int, QByteArray> AllNotificationsModel::roleNames() const
{
	return m_roleNames;
}

void AllNotificationsModel::roleChangedHandler(BaseNotification *notification, NotificationRoles role)
{
	if(notification == nullptr) {
		return;
	}
	qint32 row = m_data.indexOf(notification);
	if(row == -1) {
		return;
	}
	QModelIndex index = this->index(row, 0, QModelIndex());
	emit dataChanged(index, index, QVector<int>() << role);
}

void AllNotificationsModel::notificationIdChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::NotificationId);
}

void AllNotificationsModel::acknowledgedChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Acknowledged);
}

void AllNotificationsModel::activeChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Active);
}

void AllNotificationsModel::typeChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Type);
}

void AllNotificationsModel::dateTimeChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::DateTime);
}

void AllNotificationsModel::descriptionChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Description);
}

void AllNotificationsModel::deviceNameChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::DeviceName);
}

void AllNotificationsModel::valueChangedHandler()
{
	BaseNotification * notification = qobject_cast<BaseNotification*>(sender());
	roleChangedHandler(notification, NotificationRoles::Value);
}
