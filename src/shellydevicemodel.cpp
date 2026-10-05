/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "shellydevicemodel.h"
#include "allservicesmodel.h"
#include "backendconnection.h"

#include <veutil/qt/ve_qitem.hpp>

#include <algorithm>

using namespace Victron::VenusOS;

namespace {

static inline QString shellyServiceUid()
{
	return BackendConnection::create()->serviceUidForType(QStringLiteral("shelly"));
}

static inline bool isChannelItem(VeQItem *item)
{
	bool ok = false;
	item->id().toInt(&ok);
	return ok;
}

static void disconnectItemTree(VeQItem *item, QObject *receiver)
{
	item->disconnect(receiver);
	for (VeQItem *child : item->itemChildren()) {
		disconnectItemTree(child, receiver);
	}
}

}

ShellyDeviceModel::ShellyDeviceModel(QObject *parent)
	: QAbstractListModel(parent)
{
	AllServicesModel *allServicesModel = AllServicesModel::create();
	connect(allServicesModel, &AllServicesModel::serviceAdded,
			this, &ShellyDeviceModel::serviceAdded);
	connect(allServicesModel, &AllServicesModel::serviceAboutToBeRemoved,
			this, &ShellyDeviceModel::serviceAboutToBeRemoved);

	setServiceItem(allServicesModel->itemAt(allServicesModel->indexOf(shellyServiceUid())));
}

void ShellyDeviceModel::serviceAdded(VeQItem *serviceItem)
{
	if (serviceItem->uniqueId() == shellyServiceUid()) {
		setServiceItem(serviceItem);
	}
}

void ShellyDeviceModel::serviceAboutToBeRemoved(VeQItem *serviceItem)
{
	if (serviceItem->uniqueId() == shellyServiceUid()) {
		setServiceItem(nullptr);
	}
}

void ShellyDeviceModel::setServiceItem(VeQItem *serviceItem)
{
	if (m_devicesItem) {
		disconnectItemTree(m_devicesItem, this);
	}
	m_devicesItem.clear();

	if (serviceItem) {
		m_devicesItem = serviceItem->itemGetOrCreate(QStringLiteral("Devices"));
		for (VeQItem *deviceItem : m_devicesItem->itemChildren()) {
			deviceItemAdded(deviceItem);
		}
		connect(m_devicesItem, &VeQItem::childAdded, this, &ShellyDeviceModel::deviceItemAdded);
		connect(m_devicesItem, &VeQItem::childRemoved, this, &ShellyDeviceModel::scheduleUpdate);
	}

	// Clear the model if the service was removed, or refresh it with the new items.
	update();
}

void ShellyDeviceModel::deviceItemAdded(VeQItem *deviceItem)
{
	for (const QString &path : { QStringLiteral("Model"), QStringLiteral("Name"), QStringLiteral("Mac"),
			QStringLiteral("Reachable"), QStringLiteral("Supported") }) {
		deviceItem->itemGetOrCreate(path)->getValueAndChanges(this, &ShellyDeviceModel::scheduleUpdate);
	}

	// Watch the /Enabled value of each channel, to count the number of enabled channels.
	for (VeQItem *childItem : deviceItem->itemChildren()) {
		deviceChildItemAdded(childItem);
	}
	connect(deviceItem, &VeQItem::childAdded, this, &ShellyDeviceModel::deviceChildItemAdded);
	connect(deviceItem, &VeQItem::childRemoved, this, &ShellyDeviceModel::scheduleUpdate);

	scheduleUpdate();
}

void ShellyDeviceModel::deviceChildItemAdded(VeQItem *childItem)
{
	if (isChannelItem(childItem)) {
		childItem->itemGetOrCreate(QStringLiteral("Enabled"))->getValueAndChanges(this, &ShellyDeviceModel::scheduleUpdate);
	}
}

int ShellyDeviceModel::count() const
{
	return m_devices.count();
}

int ShellyDeviceModel::rowCount(const QModelIndex &) const
{
	return m_devices.count();
}

QVariant ShellyDeviceModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();

	if (row < 0 || row >= m_devices.count()) {
		return QVariant();
	}

	const ShellyDevice &device = m_devices.at(row);
	switch (role) {
	case UidRole:
		return device.uid;
	case NameRole:
		return device.name;
	default:
		return QVariant();
	}
}

QHash<int, QByteArray> ShellyDeviceModel::roleNames() const
{
	static const QHash<int, QByteArray> roles = {
		{ UidRole, "uid" },
		{ NameRole, "name" }
	};
	return roles;
}

void ShellyDeviceModel::scheduleUpdate()
{
	// Many values may change at once (e.g. when a scan is done), so only update once they are done.
	if (!m_updateScheduled) {
		m_updateScheduled = true;
		QMetaObject::invokeMethod(this, &ShellyDeviceModel::update, Qt::QueuedConnection);
	}
}

void ShellyDeviceModel::update()
{
	m_updateScheduled = false;
	const int prevCount = m_devices.count();

	// Find all devices with a valid /Model.
	QList<ShellyDevice> devices;
	if (m_devicesItem) {
		for (VeQItem *deviceItem : m_devicesItem->itemChildren()) {
			VeQItem *modelItem = deviceItem->itemGet(QStringLiteral("Model"));
			if (!modelItem || !modelItem->getValue().isValid()) {
				continue;
			}

			ShellyDevice device;
			device.uid = deviceItem->uniqueId();
			if (VeQItem *nameItem = deviceItem->itemGet(QStringLiteral("Name"))) {
				device.name = nameItem->getValue().toString();
			}
			if (device.name.isEmpty()) {
				VeQItem *macItem = deviceItem->itemGet(QStringLiteral("Mac"));
				device.name = QStringLiteral("%1 [%2]")
						.arg(modelItem->getValue().toString(),
							 macItem ? macItem->getValue().toString() : QString());
			}
			devices.append(device);
		}
	}

	// Remove devices that have been dropped.
	for (int i = m_devices.count() - 1; i >= 0; --i) {
		const QString &uid = m_devices.at(i).uid;
		if (std::none_of(devices.cbegin(), devices.cend(),
				[&uid](const ShellyDevice &d) { return d.uid == uid; })) {
			beginRemoveRows(QModelIndex(), i, i);
			m_devices.removeAt(i);
			endRemoveRows();
		}
	}

	// Update existing devices, and insert newly discovered devices.
	for (const ShellyDevice &device : std::as_const(devices)) {
		bool found = false;

		for (int j = 0; j < m_devices.count(); ++j) {
			ShellyDevice &existing = m_devices[j];
			if (existing.uid != device.uid) {
				continue;
			}
			found = true;
			QList<int> changedRoles;
			if (existing.name != device.name) {
				existing.name = device.name;
				changedRoles.append(NameRole);
			}
			if (!changedRoles.empty()) {
				emit dataChanged(index(j), index(j), changedRoles);
			}
			break;
		}

		if (!found) {
			const int insertPos = m_devices.count();
			beginInsertRows(QModelIndex(), insertPos, insertPos);
			m_devices.insert(insertPos, device);
			endInsertRows();
		}
	}

	if (prevCount != m_devices.count()) {
		emit countChanged();
	}
}

SortedShellyDeviceModel::SortedShellyDeviceModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	setDynamicSortFilter(true);
	setSortLocaleAware(true);
	setSortRole(ShellyDeviceModel::NameRole);
	sort(0, Qt::AscendingOrder);
}
