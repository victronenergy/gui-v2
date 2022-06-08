#include "notificationsmodel.h"

#include <QString>

using namespace Victron::VenusOS;

Notification::Notification() :
	m_acknowledged(false),
	m_active(true),
	m_type(Enums::Notification_Alarm),
	m_deviceName(""),
	m_dateTime(QDateTime::currentDateTime()),
	m_description(""),
	m_value("")
{
}

Notification::Notification(const Notification& other) :
	m_acknowledged(other.m_acknowledged),
	m_active(other.m_active),
	m_type(other.m_type),
	m_deviceName(other.m_deviceName),
	m_dateTime(other.m_dateTime),
	m_description(other.m_description),
	m_value(other.m_value)
{
}

Notification::Notification(const bool acknowledged, const bool active, const Enums::Notification_Type type, const QString &deviceName, const QDateTime& dateTime, const QString &description) :
	m_acknowledged(acknowledged),
	m_active(active),
	m_type(type),
	m_deviceName(deviceName),
	m_dateTime(dateTime),
	m_description(description)
{
}

bool Notification::acknowledged() const
{
	return m_acknowledged;
}

void Notification::setAcknowledged(const bool acknowledged)
{
	if (acknowledged != m_acknowledged) {
		m_acknowledged = acknowledged;
	}
}

bool Notification::active() const
{
	return m_active;
}

void Notification::setActive(const bool active)
{
	if (active != m_active) {
		m_active = active;
	}
}

Enums::Notification_Type Notification::type() const
{
	return m_type;
}

void Notification::setType(Enums::Notification_Type type)
{
	if (type != m_type) {
		m_type = type;
	}
}

QString Notification::serviceName() const
{
	return m_deviceName;
}
void Notification::setServiceName(const QString service)
{
	m_deviceName = service;
}

QDateTime Notification::dateTime() const
{
	return m_dateTime;
}
void Notification::setDateTime(const QDateTime date)
{
	m_dateTime = date;
}

QString Notification::description()const
{
	return m_description;
}
void Notification::setDescription(const QString description)
{
	m_description = description;
}

QString Notification::value() const
{
	return m_value;
}

void Notification::setValue(const QString &value)
{
	if (value != m_value) {
		m_value = value;
	}
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
		return notification.acknowledged();
	case ActiveRole:
		return notification.active();
	case TypeRole:
		return notification.type();
	case ServiceRole:
		return notification.serviceName();
	case DateTimeRole:
		return notification.dateTime();
	case DescriptionRole:
		return notification.description();
	case ValueRole:
		return notification.value();
	default: {
			return QVariant();
		}
	}
}

void NotificationsModel::insert(const int index, const Notification& newNotification)
{
	if(index < 0 || index > m_data.count()) {
		return;
	}
	if (static_cast<int>(m_data.count()) == m_maxNotifications)
	{
		remove(static_cast<int>(m_data.count() - 1));
	}
	Notification notification(newNotification);

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

		if (newNotification.dateTime() > notification.dateTime())
		{
			insert(i, newNotification);
			return;
		}
	}
	append(newNotification);
}

void NotificationsModel::insertByDate(bool acknowledged,
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
		if (notification.active())
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

	Notification &notification = m_data[index.row()];
	switch (role)
	{
	case AcknowledgedRole:
		notification.setAcknowledged(value.toBool());
		if (notification.acknowledged() && !notification.active())
		{
			HistoricalNotificationsModel::instance()->insertByDate(notification);
			remove(index.row());
		}
		break;
	case ActiveRole:
		notification.setActive(value.toBool());
		if (notification.acknowledged() && !notification.active())
		{
			HistoricalNotificationsModel::instance()->insertByDate(notification);
			remove(index.row());
		}
		break;
	default: {
			return false;
		}
	}

	emit dataChanged(index, index, { role } );
	return true ;
}

bool ActiveNotificationsModel::newNotifications() const
{
	return m_newNotifications;
}

void ActiveNotificationsModel::setNewNotifications(const bool newNotifications)
{
	if (newNotifications != m_newNotifications)
	{
		m_newNotifications = newNotifications;
		emit newNotificationsChanged();
	}
}

void ActiveNotificationsModel::handleChanges()
{
	bool newNotifications = false;
	for (int i = 0; i < m_data.count(); ++i)
	{
		const Notification& n = m_data.at(i);
		if (!n.acknowledged())
		{
			newNotifications = true;
		}
	}
	setNewNotifications(newNotifications);
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
