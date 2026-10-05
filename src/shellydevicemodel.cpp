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

	const QString shellyServiceUid = BackendConnection::create()->serviceUidForType(QStringLiteral("shelly"));
	setServiceItem(allServicesModel->itemAt(allServicesModel->indexOf(shellyServiceUid)));
}

void ShellyDeviceModel::serviceAdded(VeQItem *serviceItem)
{
	if (serviceItem->uniqueId() == BackendConnection::create()->serviceUidForType(QStringLiteral("shelly"))) {
		setServiceItem(serviceItem);
	}
}

void ShellyDeviceModel::serviceAboutToBeRemoved(VeQItem *serviceItem)
{
	if (serviceItem->uniqueId() == BackendConnection::create()->serviceUidForType(QStringLiteral("shelly"))) {
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

int ShellyDeviceModel::indexOf(const QString &uid) const
{
	for (int i = 0; i < m_devices.count(); ++i) {
		if (m_devices.at(i).uid == uid) {
			return i;
		}
	}
	return -1;
}

int ShellyDeviceModel::countEnabledChannels(VeQItem *deviceItem) const
{
	if (!deviceItem) {
		return 0;
	}

	int enabledChannelCount = 0;
	for (VeQItem *channelItem : deviceItem->itemChildren()) {
		bool ok = false;
		channelItem->id().toInt(&ok);
		if (ok) {
			VeQItem *channelEnabledItem = channelItem->itemGet(QStringLiteral("Enabled"));
			if (channelEnabledItem && channelEnabledItem->getValue().toInt() == 1) {
				enabledChannelCount++;
			}
		}
	}
	return enabledChannelCount;
}

QString ShellyDeviceModel::generateDeviceName(VeQItem *deviceItem)
{
	if (!deviceItem) {
		return QString();
	}

	VeQItem *modelItem = deviceItem->itemGetOrCreate(QStringLiteral("Model"));
	const QString model = modelItem ? modelItem->getValue().toString() : QString();
	if (model.isEmpty()) {
		return QString();
	}

	QString name;
	if (VeQItem *nameItem = deviceItem->itemGetOrCreate(QStringLiteral("Name"))) {
		name = nameItem->getValue().toString();
	}
	if (name.isEmpty()) {
		if (VeQItem *macItem = deviceItem->itemGetOrCreate(QStringLiteral("Mac"))) {
			const QString macAddress = macItem->getValue().toString();
			if (macAddress.isEmpty()) {
				name = model;
			} else {
				name = QStringLiteral("%1 [%2]").arg(model, macAddress);
			}
		}
	}
	return name;
}

void ShellyDeviceModel::deviceItemAdded(VeQItem *deviceItem)
{
	// When /Name, /Supported or /Reachable change, only update the affected row. If the device is
	// not yet in the model, or its /Model is no longer valid (e.g. after a scan), do a full update
	// instead, as the device may need to be added or removed.
	const QString uid = deviceItem->uniqueId();

	if (VeQItem *modelItem = deviceItem->itemGetOrCreate(QStringLiteral("Model"))) {
		// The /Model should not change, but if its value arrives later than expected, then update
		// the model.
		connect(modelItem, &VeQItem::valueChanged, this, &ShellyDeviceModel::scheduleUpdate);
	}

	VeQItem *nameItem = deviceItem->itemGetOrCreate(QStringLiteral("Name"));
	connect(nameItem, &VeQItem::valueChanged, this, [this, deviceItem, uid](QVariant value) {
		const int deviceIndex = indexOf(uid);
		VeQItem *modelItem = deviceItem->itemGetOrCreate(QStringLiteral("Model"));
		if (deviceIndex < 0 || !modelItem || modelItem->getValue().toString().isEmpty()) {
			scheduleUpdate();
			return;
		}
		const QString name = generateDeviceName(deviceItem);
		if (m_devices.at(deviceIndex).name != name) {
			m_devices[deviceIndex].name = name;
			emit dataChanged(index(deviceIndex), index(deviceIndex), { NameRole });
		}
	});

	VeQItem *macItem = deviceItem->itemGetOrCreate(QStringLiteral("Mac"));
	connect(macItem, &VeQItem::valueChanged, this, [this, deviceItem, uid](QVariant value) {
		const int deviceIndex = indexOf(uid);
		VeQItem *modelItem = deviceItem->itemGetOrCreate(QStringLiteral("Model"));
		if (deviceIndex < 0 || !modelItem || modelItem->getValue().toString().isEmpty()) {
			scheduleUpdate();
			return;
		}
		const QString name = generateDeviceName(deviceItem);
		if (m_devices.at(deviceIndex).name != name) {
			m_devices[deviceIndex].name = name;
			emit dataChanged(index(deviceIndex), index(deviceIndex), { NameRole });
		}
	});

	VeQItem *supportedItem = deviceItem->itemGetOrCreate(QStringLiteral("Supported"));
	connect(supportedItem, &VeQItem::valueChanged, this, [this, deviceItem, uid](QVariant value) {
		const int deviceIndex = indexOf(uid);
		VeQItem *modelItem = deviceItem->itemGetOrCreate(QStringLiteral("Model"));
		if (deviceIndex < 0 || !modelItem || modelItem->getValue().toString().isEmpty()) {
			scheduleUpdate();
			return;
		}
		const bool supported = value.isValid() ? value.toInt() == 1 : true;
		if (m_devices.at(deviceIndex).supported != supported) {
			m_devices[deviceIndex].supported = supported;
			emit dataChanged(index(deviceIndex), index(deviceIndex), { SupportedRole });
		}
	});

	VeQItem *reachableItem = deviceItem->itemGetOrCreate(QStringLiteral("Reachable"));
	connect(reachableItem, &VeQItem::valueChanged, this, [this, deviceItem, uid](QVariant value) {
		const int deviceIndex = indexOf(uid);
		VeQItem *modelItem = deviceItem->itemGetOrCreate(QStringLiteral("Model"));
		if (deviceIndex < 0 || !modelItem || modelItem->getValue().toString().isEmpty()) {
			scheduleUpdate();
			return;
		}
		const bool reachable = value.isValid() ? value.toInt() == 1 : true;
		if (m_devices.at(deviceIndex).reachable != reachable) {
			m_devices[deviceIndex].reachable = reachable;
			emit dataChanged(index(deviceIndex), index(deviceIndex), { ReachableRole });
		}
	});

	// Watch the /Enabled value of each channel, to count the number of enabled channels.
	for (VeQItem *childItem : deviceItem->itemChildren()) {
		deviceChildItemAdded(childItem);
	}
	connect(deviceItem, &VeQItem::childAdded, this, &ShellyDeviceModel::deviceChildItemAdded);
	connect(deviceItem, &VeQItem::childRemoved, this, [this, deviceItem](VeQItem *childItem) {
		bool isInt = false;
		childItem->id().toInt(&isInt);
		if (isInt) {
			updateEnabledCountForDevice(deviceItem);
		}
	});

	scheduleUpdate();
}

void ShellyDeviceModel::deviceChildItemAdded(VeQItem *childItem)
{
	// If the child id is a number (i.e. this is a parent node for a channel), then check if the
	// child has its own /Enabled child. If so, set the overall device's enabledChannelCount
	// according to the number of children with /Enabled=true, and watch for later /Enabled changes
	// so that enabledChannelCount can be updated accordingly.
	bool isInt = false;
	childItem->id().toInt(&isInt);
	if (isInt) {
		VeQItem *deviceItem = childItem->itemParent();
		updateEnabledCountForDevice(deviceItem);

		VeQItem *enabledItem = childItem->itemGetOrCreate(QStringLiteral("Enabled"));
		connect(enabledItem, &VeQItem::valueChanged, this, [this, deviceItem]() {
			updateEnabledCountForDevice(deviceItem);
		});
	}
}

void ShellyDeviceModel::updateEnabledCountForDevice(VeQItem *deviceItem)
{
	if (!deviceItem) {
		scheduleUpdate();
		return;
	}

	const int deviceIndex = indexOf(deviceItem->uniqueId());
	VeQItem *modelItem = deviceItem->itemGetOrCreate(QStringLiteral("Model"));
	if (deviceIndex < 0 || !modelItem || modelItem->getValue().toString().isEmpty()) {
		scheduleUpdate();
		return;
	}

	const int enabledChannelCount = countEnabledChannels(deviceItem);
	if (m_devices.at(deviceIndex).enabledChannelCount != enabledChannelCount) {
		m_devices[deviceIndex].enabledChannelCount = enabledChannelCount;
		emit dataChanged(index(deviceIndex), index(deviceIndex), { EnabledChannelCountRole });
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
	case ReachableRole:
		return device.reachable;
	case SupportedRole:
		return device.supported;
	case EnabledChannelCountRole:
		return device.enabledChannelCount;
	default:
		return QVariant();
	}
}

QHash<int, QByteArray> ShellyDeviceModel::roleNames() const
{
	static const QHash<int, QByteArray> roles = {
		{ UidRole, "uid" },
		{ NameRole, "name" },
		{ ReachableRole, "reachable" },
		{ SupportedRole, "supported" },
		{ EnabledChannelCountRole, "enabledChannelCount" }
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
			VeQItem *modelItem = deviceItem->itemGetOrCreate(QStringLiteral("Model"));
			if (!modelItem || modelItem->getValue().toString().isEmpty()) {
				continue;
			}

			ShellyDevice device;
			device.uid = deviceItem->uniqueId();
			device.name = generateDeviceName(deviceItem);

			// Use itemGet() for /Reachable and /Supported as it may not be present.
			if (VeQItem *reachableItem = deviceItem->itemGet(QStringLiteral("Reachable"))) {
				const QVariant value = reachableItem->getValue();
				device.reachable = value.isValid() ? value.toInt() == 1 : true;
			}
			if (VeQItem *supportedItem = deviceItem->itemGet(QStringLiteral("Supported"))) {
				const QVariant value = supportedItem->getValue();
				device.supported = value.isValid() ? value.toInt() == 1 : true;
			}
			device.enabledChannelCount = countEnabledChannels(deviceItem);
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

	// Insert newly discovered devices, and update existing ones if needed.
	for (const ShellyDevice &device : std::as_const(devices)) {
		const int deviceIndex = indexOf(device.uid);
		if (deviceIndex < 0) {
			const int insertPos = m_devices.count();
			beginInsertRows(QModelIndex(), insertPos, insertPos);
			m_devices.insert(insertPos, device);
			endInsertRows();
		} else {
			ShellyDevice &current = m_devices[deviceIndex];
			QList<int> changedRoles;
			if (current.name != device.name) {
				changedRoles.append(NameRole);
			}
			if (current.reachable != device.reachable) {
				changedRoles.append(ReachableRole);
			}
			if (current.supported != device.supported) {
				changedRoles.append(SupportedRole);
			}
			if (current.enabledChannelCount != device.enabledChannelCount) {
				changedRoles.append(EnabledChannelCountRole);
			}
			if (!changedRoles.isEmpty()) {
				current = device; // update the entry in m_devices
				emit dataChanged(index(deviceIndex), index(deviceIndex), changedRoles);
			}
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
	sort(0, Qt::AscendingOrder);
}

bool SortedShellyDeviceModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	// Sort by:
	// 1. Supported: show "supported" devices first, then "unsupported"
	// 2. Device name

	const bool leftSupported = sourceModel()->data(sourceLeft, ShellyDeviceModel::SupportedRole).toBool();
	const bool rightSupported = sourceModel()->data(sourceRight, ShellyDeviceModel::SupportedRole).toBool();

	if (leftSupported == rightSupported) {
		// Sort by name.
		return sourceModel()->data(sourceLeft, ShellyDeviceModel::NameRole).toString()
				.localeAwareCompare(sourceModel()->data(sourceRight, ShellyDeviceModel::NameRole).toString()) < 0;
	} else {
		return leftSupported;
	}
}
