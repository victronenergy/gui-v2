#include "notificationmodel.h"

#include "backendconnection.h"
#include "enums.h"

#include <QString>
#include <QVector>
#include <QDateTime>
#include <QTimer>

using namespace Victron::VenusOS;

namespace {

VeQItem *notificationsItem()
{
	VeQItem *notifications = nullptr;

	BackendConnection *backend = BackendConnection::create();
	if (!backend || !backend->producer()) {
		return notifications;
	}

	VeQItem *servicesRoot = backend->producer()->services();
	if (!servicesRoot) {
		return notifications;
	}

	if (backend->type() == BackendConnection::MqttSource) {
		notifications = servicesRoot->itemGet(QStringLiteral("/platform/0/Notifications"));
	} else {
		const VeQItem::Children &services = servicesRoot->itemChildren();
		for (auto it = services.constBegin(); it != services.constEnd(); ++it) {
			if (backend->serviceTypeFromUid(it.value()->uniqueId()).contains(QStringLiteral("platform"))) {
				notifications = it.value()->itemGet(QStringLiteral("Notifications"));
				break;
			}
		}
	}

	return notifications;
}

}

NotificationSlot::NotificationSlot(VeQItem *notification, QObject *parent)
	: QObject(parent), m_notification(notification)
{
	if (m_notification) {
		m_description = m_notification->itemGet(QStringLiteral("Description"));
		m_deviceName = m_notification->itemGet(QStringLiteral("DeviceName"));
		m_service = m_notification->itemGet(QStringLiteral("Service"));
		m_trigger = m_notification->itemGet(QStringLiteral("Trigger"));
		m_alarmValue = m_notification->itemGet(QStringLiteral("AlarmValue"));
		m_value = m_notification->itemGet(QStringLiteral("Value"));
		m_dateTime = m_notification->itemGet(QStringLiteral("DateTime"));
		m_type = m_notification->itemGet(QStringLiteral("Type"));
		m_acknowledged = m_notification->itemGet(QStringLiteral("Acknowledged"));
		m_active = m_notification->itemGet(QStringLiteral("Active"));
		m_silenced = m_notification->itemGet(QStringLiteral("Silenced"));
		if (m_acknowledged && m_active && m_silenced && m_description) {
			connect(m_acknowledged, &VeQItem::valueChanged, this, &NotificationSlot::acknowledgedChanged);
			connect(m_active, &VeQItem::valueChanged, this, &NotificationSlot::activeChanged);
			connect(m_silenced, &VeQItem::valueChanged, this, &NotificationSlot::silencedChanged);
			connect(m_description, &VeQItem::valueChanged, this, &NotificationSlot::descriptionChanged);
			// Monitor the Active item's state to detect when the device goes offline
			// (e.g. when the device disconnects from VRM and topics are cleared).
			connect(m_active, &VeQItem::stateChanged, this, [this](VeQItem::State state) {
				if (state == VeQItem::Offline) {
					Q_EMIT offlineChanged();
				}
			});
		} else {
			qWarning() << "Invalid notification slot:" << m_notification->id();
		}
	}
}

bool NotificationSlot::offline() const
{
	return m_active && m_active->getState() == VeQItem::Offline;
}

void NotificationSlot::acknowledge()
{
	// also silence any alarm associated with the notification.
	// in future, these may be separated in the client facing API, but for now only acknowledge() exists.
	if (m_silenced && m_silenced->getValue().toInt() == 0) {
		m_silenced->setValue(1);
	}
	if (m_acknowledged && m_acknowledged->getValue().toInt() == 0) {
		m_acknowledged->setValue(1);
	}
}



NotificationModel* NotificationModel::create(QQmlEngine *engine, QJSEngine *)
{
	static NotificationModel* instance = new NotificationModel(engine);
	return instance;
}

NotificationModel::NotificationModel(QObject *parent)
	: QAbstractListModel(parent)
{
	BackendConnection *backend = BackendConnection::create();
	if (backend) {
		connect(backend, &BackendConnection::stateChanged,
			this, &NotificationModel::handleBackendStateChanged);
	}
	QMetaObject::invokeMethod(this, &NotificationModel::init, Qt::QueuedConnection);
}

void NotificationModel::reset()
{
	if (m_notifications) {
		disconnect(m_notifications, nullptr, this, nullptr);
	}


	const qsizetype oldDataSize = m_data.size();
	const int oldActiveAlarms = m_activeAlarms;
	const int oldActiveWarnings = m_activeWarnings;
	const int oldActiveInfos = m_activeInfos;
	const int oldUnacknowledgedAlarms = m_unacknowledgedAlarms;
	const int oldUnacknowledgedWarnings = m_unacknowledgedWarnings;
	const int oldUnacknowledgedInfos = m_unacknowledgedInfos;

	beginResetModel();
	m_acknowledgeAll = nullptr;
	qDeleteAll(m_slots);
	m_slots.clear();
	m_data.clear();
	m_activeAlarms = 0;
	m_activeWarnings = 0;
	m_activeInfos = 0;
	m_unacknowledgedAlarms = 0;
	m_unacknowledgedWarnings = 0;
	m_unacknowledgedInfos = 0;
	m_notifications = nullptr;
	endResetModel();

	if (oldDataSize != m_data.size()) {
		Q_EMIT countChanged();
	}

	if (oldActiveAlarms != m_activeAlarms) {
		Q_EMIT activeAlarmsChanged();
	}
	if (oldUnacknowledgedAlarms != m_unacknowledgedAlarms) {
		Q_EMIT unacknowledgedAlarmsChanged();
	}

	if (oldActiveWarnings != m_activeWarnings) {
		Q_EMIT activeWarningsChanged();
	}
	if (oldUnacknowledgedWarnings != m_unacknowledgedWarnings) {
		Q_EMIT unacknowledgedWarningsChanged();
	}

	if (oldActiveInfos != m_activeInfos) {
		Q_EMIT activeInfosChanged();
	}
	if (oldUnacknowledgedInfos != m_unacknowledgedInfos) {
		Q_EMIT unacknowledgedInfosChanged();
	}
}

void NotificationModel::handleBackendStateChanged()
{
	BackendConnection *backend = BackendConnection::create();
	if (!backend) {
		return;
	}

	if (m_notifications != nullptr &&
			(backend->state() == BackendConnection::Disconnected
			|| backend->state() == BackendConnection::Reconnecting
			|| backend->state() == BackendConnection::Failed)) {
		qInfo() << "Resetting notifications backend due to backend disconnection";
		reset();
	} else if (backend->state() == BackendConnection::Ready) {
		// Re-initialize when the connection is restored.
		// The init() call will re-discover notification slots.
		if (!m_notifications) {
			QMetaObject::invokeMethod(this, &NotificationModel::init, Qt::QueuedConnection);
		}
	}
}

void NotificationModel::init()
{
	reset();

	qInfo() << "Initialising notifications backend";
	m_notifications = notificationsItem();
	if (m_notifications) {
		m_acknowledgeAll = m_notifications->itemGet(QStringLiteral("AcknowledgeAll"));
		connect(m_notifications, &QObject::destroyed,
			this, [this] {
				m_notifications = nullptr;
				QMetaObject::invokeMethod(this, &NotificationModel::init, Qt::QueuedConnection);
			});
		connect(m_notifications, &VeQItem::childAboutToBeRemoved,
			this, &NotificationModel::unwatchSlot);
		// Use QueuedConnection when a child is added, as the "index item"
		// for the notification slot is added first, and child value items
		// are added (synchronously) afterward.
		// So we cannot enumerate the value items in a direct connection,
		// as they will not yet exist.
		connect(m_notifications, &VeQItem::childAdded,
			this, &NotificationModel::watchSlot, Qt::QueuedConnection);
		const VeQItem::Children &children = m_notifications->itemChildren();
		for (auto it = children.constBegin(); it != children.constEnd(); ++it) {
			watchSlot(it.value());
		}
	} else {
		QTimer::singleShot(2000, this, &NotificationModel::init);
	}
}

void NotificationModel::watchSlot(VeQItem *slotItem)
{
	const QString id = slotItem->id();
	bool ok = false;
	const int slotId = id.toInt(&ok);
	if (!ok || slotId > 20) {
		// Not a notification slot.  The Notifications object has other children aside from the "index" item.
		return;
	}

	bool found = false;
	for (qsizetype i = 0; i < m_slots.size(); ++i) {
		const NotificationSlot *slot = m_slots[i];
		if (slot && slot->notificationId() == id) {
			found = true;
			break;
		}
	}

	if (!found) {
		NotificationSlot *slot = new NotificationSlot(slotItem, this);
		connect(slot, &NotificationSlot::activeChanged, this, [this, slot] { handleActiveChanged(slot); });
		connect(slot, &NotificationSlot::acknowledgedChanged, this, [this, slot] { handleAcknowledgedChanged(slot); });
		connect(slot, &NotificationSlot::silencedChanged, this, [this, slot] { handleSilencedChanged(slot); });
		connect(slot, &NotificationSlot::descriptionChanged, this, [this, slot] { handleDescriptionChanged(slot); });
		connect(slot, &NotificationSlot::offlineChanged, this, [this, slot] { handleSlotOffline(slot); });
		m_slots.append(slot);
		if (!slot->offline()) {
			addAssociatedEntry(slot, slot->active());
		}
	}
}

void NotificationModel::unwatchSlot(VeQItem *slotItem)
{
	const QString id = slotItem->id();
	bool ok = false;
	const int slotId = id.toInt(&ok);
	if (!ok || slotId > 20) {
		// Not a notification slot.  The Notifications object has other children aside from the "index" item.
		return;
	}

	bool found = false;
	for (qsizetype i = 0; i < m_slots.size(); ++i) {
		NotificationSlot *slot = m_slots[i];
		if (slot && slot->notificationId() == id) {
			breakAssociation(slot);
			m_slots.removeAt(i);
			slot->disconnect();
			slot->deleteLater();
			break;
		}
	}
}

void NotificationModel::breakAssociation(NotificationSlot *slot)
{
	// reverse-iterate as newer data entries are more likely to have associated slots.
	const QString slotId = slot->notificationId();
	for (qsizetype i = m_data.size() - 1; i >= 0; --i) {
		notificationData &data = m_data[i];
		if (data.notificationId == slotId) {
			data.notificationId.clear();
			return;
		}
	}
}

void NotificationModel::addAssociatedEntry(NotificationSlot *slot, bool isNew)
{
	notificationData entry;
	entry.notificationId = slot->notificationId();
	entry.description = slot->description(); // this will usually be wrong at this point, due to venus-platform quirk...
	entry.deviceName = slot->deviceName();
	entry.service = slot->service();
	entry.trigger = slot->trigger();
	entry.alarmValue = slot->alarmValue();
	entry.value = slot->value();
	entry.dateTime = slot->dateTime();
	entry.modelId = ++m_modelId;
	entry.type = slot->type();

	entry.acknowledged = slot->acknowledged();
	entry.silenced = slot->silenced();
	if (isNew) {
		entry.active = true;
	} else {
		entry.active = slot->active();
	}

	if (entry.type != Enums::Notification_Alarm
			&& entry.type != Enums::Notification_Warning
			&& entry.type != Enums::Notification_Info) {
		qWarning() << "Refusing to add unknown notification type:" << entry.type;
		// early return; slot contains invalid notification.
		return;
	}

	// We don't want to store infinite history.
	// Make some room by removing the oldest non-slot-associated row.
	if (m_data.size() >= m_maximumRows) {
		for (qsizetype i = 0; i < m_data.size(); ++i) {
			if (m_data[i].notificationId.isEmpty()) {
				// Found a non-associated entry.  Remove it.
				const notificationData entry = m_data[i];
				beginRemoveRows(QModelIndex(), i, i);
				m_data.removeAt(i);
				endRemoveRows();
				Q_EMIT countChanged();
				Q_EMIT removed(entry.modelId);
				if (!entry.acknowledged) {
					switch (entry.type) {
						case Enums::Notification_Alarm:
							m_unacknowledgedAlarms -= 1;
							Q_EMIT unacknowledgedAlarmsChanged();
							break;
						case Enums::Notification_Warning:
							m_unacknowledgedWarnings -= 1;
							Q_EMIT unacknowledgedWarningsChanged();
							break;
						case Enums::Notification_Info:
							m_unacknowledgedInfos -= 1;
							Q_EMIT unacknowledgedInfosChanged();
							break;
						default: break;
					}
				}
				break;
			}
		}
	}

	beginInsertRows(QModelIndex(), m_data.size(), m_data.size());
	m_data.append(entry);
	endInsertRows();
	Q_EMIT countChanged();
	Q_EMIT added(entry.modelId);

	switch (entry.type) {
		case Enums::Notification_Alarm:
			if (entry.active) {
				m_activeAlarms += 1;
				Q_EMIT activeAlarmsChanged();
			}
			if (!entry.acknowledged) {
				m_unacknowledgedAlarms += 1;
				Q_EMIT unacknowledgedAlarmsChanged();
			}
			break;
		case Enums::Notification_Warning:
			if (entry.active) {
				m_activeWarnings += 1;
				Q_EMIT activeWarningsChanged();
			}
			if (!entry.acknowledged) {
				m_unacknowledgedWarnings += 1;
				Q_EMIT unacknowledgedWarningsChanged();
			}
			break;
		case Enums::Notification_Info:
			if (entry.active) {
				m_activeInfos += 1;
				Q_EMIT activeInfosChanged();
			}
			if (!entry.acknowledged) {
				m_unacknowledgedInfos += 1;
				Q_EMIT unacknowledgedInfosChanged();
			}
			break;
		default:
			break;
	}
}

void NotificationModel::updateAssociatedEntry(NotificationSlot *slot, NotificationRoles role)
{
	// Reverse-iterate as newer data entries are more likely to have associated slots.
	const QString slotId = slot->notificationId();
	for (qsizetype i = m_data.size() - 1; i >= 0; --i) {
		notificationData &data = m_data[i];
		if (data.notificationId == slotId) {
			// Only the active/acknowledged/silenced values can change dynamically.
			// However, the description value can change ONCE after construction,
			// due to a quirk in venus-platform (setting description value after active value).
			const int oldType = data.type;
			switch (role) {
				case NotificationRoles::Active:
					if (data.active == slot->active()) {
						return; // not an actual change.
					}
					data.active = slot->active();
					break;
				case NotificationRoles::Acknowledged:
					if (data.acknowledged == slot->acknowledged()) {
						return; // not an actual change.
					}
					data.acknowledged = slot->acknowledged();
					break;
				case NotificationRoles::Silenced:
					if (data.silenced == slot->silenced()) {
						return; // not an actual change.
					}
					data.silenced = slot->silenced();
					break;
				case NotificationRoles::Description:
					if (data.description == slot->description()) {
						return; // not an actual change.
					}
					// venus-platform sets the description value last when
					// populating (or recycling) a notification slot.
					// Re-read all fields here, as they may have been
					// stale when addAssociatedEntry() captured them.
					data.description = slot->description();
					data.deviceName = slot->deviceName();
					data.service = slot->service();
					data.trigger = slot->trigger();
					data.alarmValue = slot->alarmValue();
					data.value = slot->value();
					data.dateTime = slot->dateTime();
					data.type = slot->type();
					break;
				default:
					qWarning() << "Unknown notification slot data change";
					return;
			}
			QList<int> changedRoles;
			changedRoles.append(static_cast<int>(role));
			if (role == NotificationRoles::Active || role == NotificationRoles::Acknowledged) {
				changedRoles.append(static_cast<int>(NotificationRoles::Section));
			} else if (role == NotificationRoles::Description) {
				// All fields were refreshed alongside description.
				changedRoles.append(static_cast<int>(NotificationRoles::DeviceName));
				changedRoles.append(static_cast<int>(NotificationRoles::Service));
				changedRoles.append(static_cast<int>(NotificationRoles::Trigger));
				changedRoles.append(static_cast<int>(NotificationRoles::AlarmValue));
				changedRoles.append(static_cast<int>(NotificationRoles::Value));
				changedRoles.append(static_cast<int>(NotificationRoles::DateTime));
				changedRoles.append(static_cast<int>(NotificationRoles::Type));
				changedRoles.append(static_cast<int>(NotificationRoles::Section));
			}
			Q_EMIT dataChanged(createIndex(i, 0), createIndex(i, 0), changedRoles);
			Q_EMIT changed(data.modelId, changedRoles);

			// If the type changed during a description refresh, move the
			// counters from the old type bucket to the new type bucket.
			if (role == NotificationRoles::Description && oldType != data.type) {
				auto adjustCounters = [&](int type, int delta) {
					switch (type) {
						case Enums::Notification_Alarm:
							if (data.active) {
								m_activeAlarms = std::max(0, m_activeAlarms + delta);
								Q_EMIT activeAlarmsChanged();
							}
							if (!data.acknowledged) {
								m_unacknowledgedAlarms = std::max(0, m_unacknowledgedAlarms + delta);
								Q_EMIT unacknowledgedAlarmsChanged();
							}
							break;
						case Enums::Notification_Warning:
							if (data.active) {
								m_activeWarnings = std::max(0, m_activeWarnings + delta);
								Q_EMIT activeWarningsChanged();
							}
							if (!data.acknowledged) {
								m_unacknowledgedWarnings = std::max(0, m_unacknowledgedWarnings + delta);
								Q_EMIT unacknowledgedWarningsChanged();
							}
							break;
						case Enums::Notification_Info:
							if (data.active) {
								m_activeInfos = std::max(0, m_activeInfos + delta);
								Q_EMIT activeInfosChanged();
							}
							if (!data.acknowledged) {
								m_unacknowledgedInfos = std::max(0, m_unacknowledgedInfos + delta);
								Q_EMIT unacknowledgedInfosChanged();
							}
							break;
						default: break;
					}
				};
				adjustCounters(oldType, -1);   // remove from old type
				adjustCounters(data.type, +1); // add to new type
			}

			switch (data.type) {
				case Enums::Notification_Alarm: {
					switch (role) {
						case NotificationRoles::Active:
							m_activeAlarms = data.active ? m_activeAlarms+1 : std::max(0, m_activeAlarms-1);
							Q_EMIT activeAlarmsChanged();
							break;
						case NotificationRoles::Acknowledged:
							m_unacknowledgedAlarms = data.acknowledged ? m_unacknowledgedAlarms-1 : m_unacknowledgedAlarms+1;
							Q_EMIT unacknowledgedAlarmsChanged();
							break;
						default: break;
					}
					break;
				}
				case Enums::Notification_Warning: {
					switch (role) {
						case NotificationRoles::Active:
							m_activeWarnings = data.active ? m_activeWarnings+1 : m_activeWarnings-1;
							Q_EMIT activeWarningsChanged();
							break;
						case NotificationRoles::Acknowledged:
							m_unacknowledgedWarnings = data.acknowledged ? m_unacknowledgedWarnings-1 : m_unacknowledgedWarnings+1;
							Q_EMIT unacknowledgedWarningsChanged();
							break;
						default: break;
					}
					break;
				}
				case Enums::Notification_Info: {
					switch (role) {
						case NotificationRoles::Active:
							m_activeInfos = data.active ? m_activeInfos+1 : m_activeInfos-1;
							Q_EMIT activeInfosChanged();
							break;
						case NotificationRoles::Acknowledged:
							m_unacknowledgedInfos = data.acknowledged ? m_unacknowledgedInfos-1 : m_unacknowledgedInfos+1;
							Q_EMIT unacknowledgedInfosChanged();
							break;
						default: break;
					}
					break;
				}
				default:
					qWarning() << "Updated unknown notification type:" << data.type;
					break;
			}

			return; // successfully updated the entry.
		}
	}
}

void NotificationModel::handleActiveChanged(NotificationSlot *slot)
{
	if (slot->offline()) {
		return;
	}

	if (slot->active() == true) {
		// This may be a NEW notification, so we need to
		// create a new entry and associate it with this slot.
		// However, it may just be the first-time-value-set
		// for a previously newly-added slot.
		// Reverse-iterate as newer data entries are more likely to have associated slots.
		const QString slotId = slot->notificationId();
		bool found = false;
		for (qsizetype i = m_data.size() - 1; i >= 0; --i) {
			if (m_data[i].notificationId == slotId) {
				found = true;
				break;
			}
		}
		if (found) {
			updateAssociatedEntry(slot, NotificationRoles::Active);
		} else {
			addAssociatedEntry(slot, true);
		}

	} else if (slot->active() == false && slot->acknowledged() == true) {
		// Consider this notification as "removed".
		// future changes to this notification slot will NOT affect
		// the currently associated entry, but instead
		// will affect some NEW entry.
		updateAssociatedEntry(slot, NotificationRoles::Active);
		breakAssociation(slot);

	} else {
		updateAssociatedEntry(slot, NotificationRoles::Active);
	}
}

void NotificationModel::handleAcknowledgedChanged(NotificationSlot *slot)
{
	if (slot->offline()) {
		return;
	}

	if (slot->acknowledged() == true && slot->active() == false) {
		// Consider this notification as "removed".
		// future changes to this notification slot will NOT affect
		// the currently associated entry, but instead
		// will affect some NEW entry.
		updateAssociatedEntry(slot, NotificationRoles::Acknowledged);
		breakAssociation(slot);
	} else {
		updateAssociatedEntry(slot, NotificationRoles::Acknowledged);
	}
}

void NotificationModel::handleSilencedChanged(NotificationSlot *slot)
{
	if (slot->offline()) {
		return;
	}

	updateAssociatedEntry(slot, NotificationRoles::Silenced);
}

void NotificationModel::handleDescriptionChanged(NotificationSlot *slot)
{
	if (slot->offline()) {
		return;
	}

	// Description is set last by venus-platform.
	// If we skipped adding the row earlier (e.g. slot was offline)
	// ensure we create an entry once the slot is populated;
	// otherwise, update the associated entry as per normal.
	const QString slotId = slot->notificationId();
	for (qsizetype i = m_data.size() - 1; i >= 0; --i) {
		if (m_data[i].notificationId == slotId) {
			updateAssociatedEntry(slot, NotificationRoles::Description);
			return;
		}
	}
	addAssociatedEntry(slot, slot->active());
}

void NotificationModel::handleSlotOffline(NotificationSlot *slot)
{
	// The device has disconnected from VRM and the broker has cleared the
	// notification topics.  Remove the associated model entry so that the
	// view doesn't display stale/empty notification delegates.
	const QString slotId = slot->notificationId();
	for (qsizetype i = m_data.size() - 1; i >= 0; --i) {
		notificationData &data = m_data[i];
		if (data.notificationId == slotId) {
			const notificationData entry = data;
			// Break the association first, then remove.
			data.notificationId.clear();

			beginRemoveRows(QModelIndex(), i, i);
			m_data.removeAt(i);
			endRemoveRows();
			Q_EMIT countChanged();
			Q_EMIT removed(entry.modelId);

			if (entry.active) {
				switch (entry.type) {
					case Enums::Notification_Alarm:
						m_activeAlarms = std::max(0, m_activeAlarms - 1);
						Q_EMIT activeAlarmsChanged();
						break;
					case Enums::Notification_Warning:
						m_activeWarnings = std::max(0, m_activeWarnings - 1);
						Q_EMIT activeWarningsChanged();
						break;
					case Enums::Notification_Info:
						m_activeInfos = std::max(0, m_activeInfos - 1);
						Q_EMIT activeInfosChanged();
						break;
					default: break;
				}
			}
			if (!entry.acknowledged) {
				switch (entry.type) {
					case Enums::Notification_Alarm:
						m_unacknowledgedAlarms = std::max(0, m_unacknowledgedAlarms - 1);
						Q_EMIT unacknowledgedAlarmsChanged();
						break;
					case Enums::Notification_Warning:
						m_unacknowledgedWarnings = std::max(0, m_unacknowledgedWarnings - 1);
						Q_EMIT unacknowledgedWarningsChanged();
						break;
					case Enums::Notification_Info:
						m_unacknowledgedInfos = std::max(0, m_unacknowledgedInfos - 1);
						Q_EMIT unacknowledgedInfosChanged();
						break;
					default: break;
				}
			}
			return;
		}
	}
}

void NotificationModel::acknowledge(quint32 modelId)
{
	for (qsizetype i = 0; i < m_data.size(); ++i) {
		if (m_data[i].modelId == modelId) {
			acknowledgeRow(i);
			return;
		}
	}
	qWarning() << "Unable to acknowledge unknown notification: " << modelId;
}

void NotificationModel::acknowledgeRow(int row)
{
	if (row < 0 || row >= m_data.size() || m_data[row].acknowledged) {
		return;
	}

	const QString &id = m_data[row].notificationId;
	for (qsizetype i = 0; i < m_slots.size() && !id.isEmpty(); ++i) {
		if (m_slots[i]->notificationId() == id) {
			m_slots[i]->acknowledge();
			return;
		}
	}

	if (id.isEmpty()) {
		qWarning() << "Attempting to acknowledge a disassociated notification!";
	} else {
		qWarning() << "Attempting to acknowledge an invalidly associated notification!";
	}

	m_data[row].acknowledged = true;
	Q_EMIT dataChanged(createIndex(row, 0), createIndex(row, 0),
			{ static_cast<int>(NotificationRoles::Acknowledged),
			  static_cast<int>(NotificationRoles::Section) });
}

void NotificationModel::acknowledgeType(int type)
{
	for (qsizetype i = 0; i < m_data.size(); ++i) {
		if (!m_data[i].acknowledged && m_data[i].type == type) {
			acknowledgeRow(static_cast<int>(i));
		}
	}
}

void NotificationModel::acknowledgeAllInactive()
{
	for (qsizetype i = 0; i < m_data.size(); ++i) {
		if (!m_data[i].acknowledged && !m_data[i].active) {
			acknowledgeRow(static_cast<int>(i));
		}
	}
}

void NotificationModel::acknowledgeAll()
{
	if (m_acknowledgeAll) {
		m_acknowledgeAll->setValue(1);
	}
}

bool NotificationModel::removeRow(int row)
{
	// Note: can only remove rows which aren't associated with a current slot.
	if (row < 0 || row >= m_data.size() || !m_data[row].notificationId.isEmpty()) {
		return false;
	}

	const notificationData entry = m_data[row];
	beginRemoveRows(QModelIndex(), row, row);
	m_data.removeAt(row);
	endRemoveRows();
	Q_EMIT countChanged();
	Q_EMIT removed(entry.modelId);
	if (!entry.acknowledged) {
		switch (entry.type) {
			case static_cast<int>(Enums::Notification_Alarm):
				m_unacknowledgedAlarms -= 1;
				Q_EMIT unacknowledgedAlarmsChanged();
				break;
			case static_cast<int>(Enums::Notification_Warning):
				m_unacknowledgedWarnings -= 1;
				Q_EMIT unacknowledgedWarningsChanged();
				break;
			case static_cast<int>(Enums::Notification_Info):
				m_unacknowledgedInfos -= 1;
				Q_EMIT unacknowledgedInfosChanged();
				break;
			default: break;
		}
	}

	return true;
}

notificationData NotificationModel::at(int row) const
{
	if (row < 0 || row >= m_data.size()) {
		return notificationData();
	}

	return m_data[row];
}

notificationData NotificationModel::get(quint32 modelId) const
{
	for (qsizetype i = 0; i < m_data.size(); ++i) {
		if (m_data[i].modelId == modelId) {
			return m_data[i];
		}
	}

	qWarning() << "Unable to get unknown notification";
	return notificationData();
}

int NotificationModel::getSection(quint32 modelId) const
{
	const notificationData data = get(modelId);
	return data.dateTime < 0 ? -1
		: data.active ? 0
		: !data.acknowledged ? 1
		: 2;
}

int NotificationModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_data.size());
}

QVariant NotificationModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_data.size()) {
		return QVariant();
	}

	switch (role)
	{
		case static_cast<int>(NotificationRoles::Description):
			return m_data[row].description;
		case static_cast<int>(NotificationRoles::DeviceName):
			return m_data[row].deviceName;
		case static_cast<int>(NotificationRoles::Service):
			return m_data[row].service;
		case static_cast<int>(NotificationRoles::Trigger):
			return m_data[row].trigger;
		case static_cast<int>(NotificationRoles::AlarmValue):
			return m_data[row].alarmValue;
		case static_cast<int>(NotificationRoles::Value):
			return m_data[row].value;
		case static_cast<int>(NotificationRoles::DateTime):
			return QDateTime::fromMSecsSinceEpoch(m_data[row].dateTime * 1000);
		case static_cast<int>(NotificationRoles::ModelId):
			return m_data[row].modelId;
		case static_cast<int>(NotificationRoles::Type):
			return m_data[row].type;
		case static_cast<int>(NotificationRoles::Acknowledged):
			return m_data[row].acknowledged;
		case static_cast<int>(NotificationRoles::Active):
			return m_data[row].active;
		case static_cast<int>(NotificationRoles::Silenced):
			return m_data[row].silenced;
		case static_cast<int>(NotificationRoles::Section):
			return m_data[row].dateTime < 0 ? -1
				: m_data[row].active ? 0
				: !m_data[row].acknowledged ? 1
				: 2;
		default: return QVariant();
	}
}

QHash<int, QByteArray> NotificationModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ static_cast<int>(NotificationRoles::Description), "description" },
		{ static_cast<int>(NotificationRoles::DeviceName), "deviceName" },
		{ static_cast<int>(NotificationRoles::Service), "service" },
		{ static_cast<int>(NotificationRoles::Trigger), "trigger" },
		{ static_cast<int>(NotificationRoles::AlarmValue), "alarmValue" },
		{ static_cast<int>(NotificationRoles::Value), "value" },
		{ static_cast<int>(NotificationRoles::DateTime), "dateTime" },
		{ static_cast<int>(NotificationRoles::ModelId), "modelId" },
		{ static_cast<int>(NotificationRoles::Type), "type" },
		{ static_cast<int>(NotificationRoles::Acknowledged), "acknowledged" },
		{ static_cast<int>(NotificationRoles::Active), "active" },
		{ static_cast<int>(NotificationRoles::Silenced), "silenced" },
		{ static_cast<int>(NotificationRoles::Section), "section" },
	};
	return roles;
}


ToastModel* ToastModel::create(QQmlEngine *engine, QJSEngine *)
{
	static ToastModel* instance = new ToastModel(engine);
	return instance;
}

ToastModel::ToastModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

quint32 ToastModel::addNotification(quint32 notificationModelId, int type, const QString &text, int autoCloseInterval)
{
	toastData toast;
	toast.modelId = ++m_modelId;
	toast.notificationModelId = notificationModelId;
	toast.type = type;
	toast.description = text;
	toast.autoCloseInterval = autoCloseInterval;

	// insert in appropriate sort order, highest prio first.
	for (qsizetype i = 0; i < m_data.size(); ++i) {
		if (type == Enums::Notification_Alarm
				|| m_data[i].type == type
				|| m_data[i].type == Enums::Notification_Info) {
			beginInsertRows(QModelIndex(), i, i);
			m_data.insert(i, toast);
			endInsertRows();
			Q_EMIT countChanged();
			return toast.modelId;
		}
	}

	beginInsertRows(QModelIndex(), m_data.size(), m_data.size());
	m_data.append(toast);
	endInsertRows();
	Q_EMIT countChanged();
	return toast.modelId;
}

void ToastModel::updateNotification(quint32 notificationModelId, const QString &text)
{
	for (qsizetype i = 0; i < m_data.size(); ++i) {
		if (m_data[i].notificationModelId == notificationModelId) {
			m_data[i].description = text;
			Q_EMIT dataChanged(createIndex(i, 0), createIndex(i, 0), QList<int>() << static_cast<int>(ToastModel::ToastRoles::Description));
			return;
		}
	}
}

bool ToastModel::removeNotification(quint32 notificationModelId)
{
	for (qsizetype i = 0; i < m_data.size(); ++i) {
		if (m_data[i].notificationModelId == notificationModelId) {
			const quint32 modelId = m_data[i].modelId;
			beginRemoveRows(QModelIndex(), i, i);
			m_data.remove(i);
			endRemoveRows();
			Q_EMIT removed(modelId);
			Q_EMIT countChanged();
			return true;
		}
	}

	return false;
}

quint32 ToastModel::add(int type, const QString &text, int autoCloseInterval)
{
	return addNotification(0, type, text, autoCloseInterval);
}

bool ToastModel::remove(quint32 modelId)
{
	for (qsizetype i = 0; i < m_data.size(); ++i) {
		if (m_data[i].modelId == modelId) {
			beginRemoveRows(QModelIndex(), i, i);
			m_data.remove(i);
			endRemoveRows();
			Q_EMIT removed(modelId);
			Q_EMIT countChanged();
			return true;
		}
	}

	return false;
}

bool ToastModel::removeFirst()
{
	if (m_data.isEmpty()) {
		return false;
	}

	const quint32 modelId = m_data[0].modelId;
	beginRemoveRows(QModelIndex(), 0, 0);
	m_data.removeFirst();
	endRemoveRows();
	Q_EMIT removed(modelId);
	Q_EMIT countChanged();
	return true;
}

bool ToastModel::removeRow(int row)
{
	if (row < 0 || row >= m_data.size()) {
		return false;
	}

	const quint32 modelId = m_data[row].modelId;
	beginRemoveRows(QModelIndex(), row, row);
	m_data.remove(row);
	endRemoveRows();
	Q_EMIT removed(modelId);
	Q_EMIT countChanged();
	return true;
}

void ToastModel::removeAllInfoExcept(quint32 modelId)
{
	for (qsizetype i = m_data.size() - 1; i >= 0; --i) {
		const quint32 currModelId = m_data[i].modelId;
		if (m_data[i].type == Enums::Notification_Info && currModelId != modelId) {
			beginRemoveRows(QModelIndex(), i, i);
			m_data.remove(i);
			endRemoveRows();
			Q_EMIT removed(currModelId);
			Q_EMIT countChanged();
		}
	}
}

void ToastModel::requestDismiss(quint32 modelId)
{
	Q_EMIT dismissRequested(modelId);
	remove(modelId);
}

void ToastModel::requestClose(quint32 modelId)
{
	Q_EMIT closeRequested(modelId);
	// TODO: view should momentarily disable animations for the close operation.
	remove(modelId);
}

QVariant ToastModel::data(const QModelIndex& index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_data.size()) {
		return QVariant();
	}

	switch (role)
	{
		case static_cast<int>(ToastRoles::ModelId):
			return m_data[row].modelId;
		case static_cast<int>(ToastRoles::NotificationModelId):
			return m_data[row].notificationModelId;
		case static_cast<int>(ToastRoles::Type):
			return m_data[row].type;
		case static_cast<int>(ToastRoles::Description):
			return m_data[row].description;
		case static_cast<int>(ToastRoles::AutoCloseInterval):
			return m_data[row].autoCloseInterval;
		default: break;
	}
	return QVariant();
}

int ToastModel::rowCount(const QModelIndex &) const
{
	return m_data.count();
}

QHash<int, QByteArray> ToastModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ static_cast<int>(ToastRoles::ModelId), "modelId" },
		{ static_cast<int>(ToastRoles::NotificationModelId), "notificationModelId" },
		{ static_cast<int>(ToastRoles::Type), "type" },
		{ static_cast<int>(ToastRoles::Description), "description" },
		{ static_cast<int>(ToastRoles::AutoCloseInterval), "autoCloseInterval" },
	};
	return roles;
}

