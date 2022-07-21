#include "notificationsmodel.h"

#include <QString>
#include <QTimer>

using namespace Victron::VenusOS;

Notification::Notification(const Notification& other) :
	acknowledged(other.acknowledged),
	active(other.active),
	type(other.type),
	deviceName(other.deviceName),
	dateTime(other.dateTime),
	description(other.description),
	value(other.value)
{
}

Notification& Notification::operator=(const Notification &other) {
	acknowledged = other.acknowledged;
	active = other.active;
	type = other.type;
	deviceName = other.deviceName;
	dateTime = other.dateTime;
	description = other.description;
	value = other.value;

	return *this;
}

Notification::Notification(const bool _acknowledged, const bool _active, const Enums::Notification_Type _type, const QString& _deviceName, const QDateTime& _dateTime, const QString& _description) :
	acknowledged(_acknowledged),
	active(_active),
	type(_type),
	deviceName(_deviceName),
	dateTime(_dateTime),
	description(_description)
{
}

NotificationsModel::NotificationsModel(QObject *parent)
	: QAbstractListModel(parent),
	  m_maxNotifications(20)
{
	m_roleNames[AcknowledgedRole] = "acknowledged";
	m_roleNames[ActiveRole] = "active";
	m_roleNames[TypeRole] = "type";
	m_roleNames[ServiceRole] = "service";
	m_roleNames[DateTimeRole] = "dateTime";
	m_roleNames[DescriptionRole] = "description";
	m_roleNames[ValueRole] = "value";
}

NotificationsModel::~NotificationsModel()
{
}

void NotificationsModel::append(const Notification& notification)
{
	insert(count(), notification);
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
	const Notification& notification = m_data.at(row);
	switch (role)
	{
	case AcknowledgedRole:
		return notification.acknowledged;
	case ActiveRole:
		return notification.active;
	case TypeRole:
		return notification.type;
	case ServiceRole:
		return notification.deviceName;
	case DateTimeRole:
		return notification.dateTime;
	case DescriptionRole:
		return notification.description;
	case ValueRole:
		return notification.value;
	default:
		return QVariant();
	}
}

void NotificationsModel::insert(const int index, const Notification& notification)
{
	if (index < 0 || index > m_data.count()) {
		return;
	}
	if (static_cast<int>(m_data.count()) == m_maxNotifications)
	{
		remove(static_cast<int>(m_data.count() - 1));
	}

	emit beginInsertRows(QModelIndex(), index, index);
	m_data.insert(index, notification);
	emit endInsertRows();
	emit countChanged(static_cast<int>(m_data.count()));
}

void NotificationsModel::insertByDate(const Victron::VenusOS::Notification& newNotification)
{
	for (int i = 0; i < m_data.size(); ++i)
	{
		const Notification& notification = m_data.at(i);

		if (newNotification.dateTime > notification.dateTime)
		{
			insert(i, newNotification);
			return;
		}
	}
	append(newNotification);
}

void NotificationsModel::insertByDate(
		bool acknowledged,
		const bool active,
		const Enums::Notification_Type type,
		const QString& name,
		const QDateTime& date,
		const QString& description)
{
	Notification notification(acknowledged, active, type, name, date, description);
	insertByDate(notification);
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

void NotificationsModel::deactivateSingleAlarm() // testing only
{
	for (int i = 0; i < m_data.count(); ++i)
	{
		const Notification& notification = m_data.at(i);
		if (notification.active)
		{
			setData(createIndex(i, 0), false, ActiveRole);
			break;
		}
	}
}

ActiveNotificationsModel::ActiveNotificationsModel(QObject *parent)
	: NotificationsModel(parent)
{
	bool result = connect(this, &ActiveNotificationsModel::countChanged, this, &ActiveNotificationsModel::handleChanges);
	Q_ASSERT(result);
	result = connect(this, &ActiveNotificationsModel::dataChanged, this, &ActiveNotificationsModel::handleChanges);
	Q_ASSERT(result);
}

ActiveNotificationsModel::~ActiveNotificationsModel()
{
}

void ActiveNotificationsModel::addOrUpdateNotification(Enums::Notification_Type type, const QString &devicename, const QString &description, const QString &/*value*/)
{
	for (int i = 0; i < m_data.count(); ++i)
	{
		const Notification& n = m_data.at(i);
		if ((n.deviceName == devicename) && (n.description == description))
		{
			QModelIndex index(createIndex(i, 0));
			if (type == Enums::Notification_Inactive)
			{
				setData(index, false, ActiveRole);
				return;
			}
			setData(index, true, ActiveRole);
			setData(index, type, TypeRole);
			return;
		}
	}
	if (type != Enums::Notification_Inactive)
	{
		insertByDate(Notification(false, true, type, devicename, QDateTime::currentDateTime(), description));
	}
}

ActiveNotificationsModel* ActiveNotificationsModel::instance(QObject* parent)
{
	static ActiveNotificationsModel* model = nullptr;
	if (model == nullptr)
	{
		model = new ActiveNotificationsModel(parent);
	}
	return model;
}

bool ActiveNotificationsModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
	if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
	{
		return false;
	}

	Notification& notification = m_data[index.row()];
	switch (role)
	{
	case AcknowledgedRole:
		notification.acknowledged = value.toBool();
		if (notification.acknowledged && !notification.active)
		{
			HistoricalNotificationsModel::instance()->insertByDate(notification);
			remove(index.row());
		}
		break;
	case ActiveRole:
		notification.active = value.toBool();
		if (notification.acknowledged && !notification.active)
		{
			HistoricalNotificationsModel::instance()->insertByDate(notification);
			remove(index.row());
		}
		break;
	case TypeRole:
		notification.type = value.value<Enums::Notification_Type>();
		break;
	default: {
			return false;
		}
	}

	emit dataChanged(index, index, { role } );
	return true ;
}

bool ActiveNotificationsModel::hasNewNotifications() const
{
	return m_hasNewNotifications;
}

void ActiveNotificationsModel::setHasNewNotifications(const bool hasNewNotifications)
{
	if (hasNewNotifications != m_hasNewNotifications)
	{
		m_hasNewNotifications = hasNewNotifications;
		emit hasNewNotificationsChanged();
	}
}

void ActiveNotificationsModel::handleChanges()
{
	bool hasNewNotifications = false;
	for (int i = 0; i < m_data.count(); ++i)
	{
		const Notification& n = m_data.at(i);
		if (!n.acknowledged)
		{
			hasNewNotifications = true;
		}
	}
	setHasNewNotifications(hasNewNotifications);
}

HistoricalNotificationsModel::HistoricalNotificationsModel(QObject *parent)
	: NotificationsModel(parent)
{
}

HistoricalNotificationsModel::~HistoricalNotificationsModel()
{
}

HistoricalNotificationsModel* HistoricalNotificationsModel::instance(QObject* parent)
{
	static HistoricalNotificationsModel* model = nullptr;
	if (model == nullptr)
	{
		model = new HistoricalNotificationsModel(parent);
	}
	return model;
}

bool HistoricalNotificationsModel::setData(const QModelIndex &/*index*/, const QVariant &/*value*/, int /*role*/)
{
	return false; // we can't edit history
}
