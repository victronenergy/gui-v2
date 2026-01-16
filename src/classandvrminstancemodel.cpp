/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "classandvrminstancemodel.h"
#include "allservicesmodel.h"
#include "alldevicesmodel.h"

#include <QQmlInfo>
#include <QQmlEngine>

using namespace Victron::VenusOS;

ClassAndVrmInstance::ClassAndVrmInstance(QObject *parent)
	: QObject(parent)
{
}

ClassAndVrmInstance::ClassAndVrmInstance(QObject *parent, VeQItem *instanceItem, VeQItem *customNameItem)
	: QObject(parent)
{
	initialize(instanceItem, customNameItem);
}

void ClassAndVrmInstance::initialize(VeQItem *instanceItem, VeQItem *customNameItem)
{
	if (m_item) {
		m_item->disconnect(this);
	}
	if (m_customNameItem) {
		m_customNameItem->disconnect(this);
	}

	m_item = instanceItem;
	if (instanceItem) {
		classAndVrmInstanceChanged(instanceItem->getValue());
		connect(instanceItem, &VeQItem::valueChanged, this, &ClassAndVrmInstance::classAndVrmInstanceChanged);
	}
	m_initialVrmInstance = m_vrmInstance;

	m_customNameItem = customNameItem;
	if (customNameItem) {
		connect(customNameItem, &VeQItem::valueChanged, this, &ClassAndVrmInstance::customNameChanged);
	}
	updateName();
}

void ClassAndVrmInstance::setDevice(Device *device)
{
	if (m_device) {
		m_device->disconnect(this);
	}
	m_device = device;
	connect(m_device, &Device::nameChanged, this, &ClassAndVrmInstance::updateName);
}

bool ClassAndVrmInstance::isValid() const
{
	return m_vrmInstance >= 0 && !m_deviceClass.isEmpty();
}

VeQItem *ClassAndVrmInstance::instanceItem()
{
	return m_item;
}

QString ClassAndVrmInstance::uid() const
{
	return m_item ? m_item->uniqueId() : QString();
}

void ClassAndVrmInstance::setUid(const QString &uid)
{
	if (uid != this->uid()) {
		if (VeQItem *instanceItem = VeQItems::getRoot()->itemGet(uid)) {
			initialize(instanceItem, instanceItem->itemParent()->itemGet(QStringLiteral("CustomName")));
		} else {
			qWarning() << "setUid(): cannot find VRM instance uid!" << uid;
			return;
		}
		emit uidChanged();
	}
}

QString ClassAndVrmInstance::deviceClass() const
{
	return m_deviceClass;
}

int ClassAndVrmInstance::vrmInstance() const
{
	return m_vrmInstance;
}

QString ClassAndVrmInstance::name() const
{
	return m_name;
}

bool ClassAndVrmInstance::setVrmInstance(int newVrmInstance)
{
	if (!m_item) {
		return false;
	}
	if (m_deviceClass.isEmpty()) {
		qWarning() << "Cannot set VRM instance for" << m_item->uniqueId() << "device class not set!";
		return false;
	}
	m_pendingVrmInstance = newVrmInstance;
	m_item->setValue(QStringLiteral("%1:%2").arg(m_deviceClass).arg(newVrmInstance));
	return true;
}

bool ClassAndVrmInstance::hasVrmInstanceChanges() const
{
	// Returns true if vrmInstance has changed after initialization. This may be due to
	// setVrmInstance() being called, or due to the /ClassAndVrmInstance being changed on the
	// backend by some other source.
	return m_vrmInstance != m_initialVrmInstance
			// True if setVrmInstance() has been called but the new value has not yet been written
			// to the backend.
			|| m_pendingVrmInstance >= 0;
}

void ClassAndVrmInstance::classAndVrmInstanceChanged(QVariant variant)
{
	const QString prevDeviceClass = m_deviceClass;
	const int prevVrmInstance = m_vrmInstance;
	const bool prevValid = isValid();

	m_deviceClass.clear();
	m_vrmInstance = -1;
	m_pendingVrmInstance = -1;
	if (variant.isValid()) {
		const QStringList classAndInstance = variant.toString().split(':');
		bool instanceOk = false;
		m_deviceClass = classAndInstance.value(0);
		m_vrmInstance = classAndInstance.value(1).toInt(&instanceOk);
		if (m_deviceClass.isEmpty() || !instanceOk) {
			qWarning() << "Unable to parse device class and VRM instance from variant:" << variant;
		}
	}

	// Try to find/create a Device in order to fetch the device name. Once initialized,
	// it can remain the same, since the device is determined by the 'real' device
	// instance, rather than the VRM instance number.
	if (!isValid()) {
		if (m_device) {
			m_device->disconnect(this);
		}
		m_device = nullptr;
	} else if (!m_device) {
		AllDevicesModel *deviceModel = AllDevicesModel::create();
		for (int i = 0; i < deviceModel->count(); ++i) {
			if (Device *device = deviceModel->deviceAt(i)) {
				if (device->serviceType() == m_deviceClass
						&& device->deviceInstance() == m_vrmInstance) {
					setDevice(device);
					break;
				}
			}
		}
		connect(deviceModel, &AllDevicesModel::deviceAdded, this, [this](Device* device) {
			if (!m_device
					&& device->serviceType() == m_deviceClass
					&& device->deviceInstance() == m_vrmInstance) {
				setDevice(device);
			}
		});
		connect(deviceModel, &AllDevicesModel::deviceAboutToBeRemoved, this, [this](Device* device) {
			if (m_device == device) {
				m_device->disconnect(this);
				m_device = nullptr;
				updateName();
			}
		});
	}

	if (prevValid != isValid()) {
		emit validChanged();
	}
	if (prevDeviceClass != m_deviceClass) {
		emit deviceClassChanged();
	}
	if (prevVrmInstance != m_vrmInstance) {
		emit vrmInstanceChanged();
	}
}

void ClassAndVrmInstance::customNameChanged(QVariant variant)
{
	Q_UNUSED(variant);
	updateName();
}

void ClassAndVrmInstance::updateName()
{
	QString name = m_customNameItem ? m_customNameItem->getValue().toString() : QString();
	if (name.isEmpty() && m_device) {
		name = m_device->name();
	}
	if (name != m_name) {
		m_name = name;
		emit nameChanged();
	}
}


ClassAndVrmInstanceModel::ClassAndVrmInstanceModel(QObject *parent)
	: QAbstractListModel(parent)
{
	AllServicesModel *servicesModel = AllServicesModel::create();
	for (int i = 0; i < servicesModel->count(); ++i) {
		if (servicesModel->data(servicesModel->index(i, 0),
					AllServicesModel::ServiceTypeRole).toString() == QStringLiteral("settings")) {
			// This is the "com.victronenergy.settings" service on D-Bus, or "settings" on MQTT.
			// Look at the /Settings/Devices sub-path to find the /ClassAndVrmInstance children.
			if (VeQItem *settingsItem = servicesModel->itemAt(i)) {
				if (VeQItem *devicesItem = settingsItem->itemGetOrCreate(QStringLiteral("Settings/Devices"))) {
					for (auto it = devicesItem->itemChildren().constBegin(); it != devicesItem->itemChildren().constEnd(); ++it) {
						addInstanceForParentItem(it.value());
					}
					connect(devicesItem, &VeQItem::childAdded, this, &ClassAndVrmInstanceModel::addInstanceForParentItem);
					connect(devicesItem, &VeQItem::childAboutToBeRemoved, this, &ClassAndVrmInstanceModel::instanceParentAboutToBeRemoved);
				}
			}
			break;
		}
	}
}

int ClassAndVrmInstanceModel::count() const
{
	return m_instances.count();
}

QVariant ClassAndVrmInstanceModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_instances.count()) {
		return QVariant();
	}

	const ClassAndVrmInstance *info = m_instances.at(row);
	switch (role)
	{
	case ValidRole:
		return info->isValid();
	case UidRole:
		return info->uid();
	case VrmInstanceRole:
		return info->vrmInstance();
	case DeviceClassRole:
		return info->deviceClass();
	case NameRole:
		return info->name();
	}
	return QVariant();
}

int ClassAndVrmInstanceModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> ClassAndVrmInstanceModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ ValidRole, "valid" },
		{ UidRole, "uid" },
		{ VrmInstanceRole, "vrmInstance" },
		{ DeviceClassRole, "deviceClass" },
		{ NameRole, "name" },
	};
	return roles;
}

QString ClassAndVrmInstanceModel::findInstanceUid(const QString &deviceClass, int vrmInstance) const
{
	for (int i = 0; i < m_instances.count(); ++i) {
		if (m_instances.at(i)->vrmInstance() == vrmInstance
				&& m_instances.at(i)->deviceClass() == deviceClass) {
			return m_instances.at(i)->instanceItem()->uniqueId();
		}
	}
	return QString();
}

int ClassAndVrmInstanceModel::maximumVrmInstance(const QString &deviceClass) const
{
	int maxInstance = -1;
	for (int i = 0; i < m_instances.count(); ++i) {
		if (m_instances.at(i)->deviceClass() == deviceClass) {
			maxInstance = std::max(maxInstance, m_instances.at(i)->vrmInstance());
		}
	}
	return maxInstance;
}

bool ClassAndVrmInstanceModel::setVrmInstance(const QString &instanceUid, int newVrmInstance)
{
	for (int i = 0; i < m_instances.count(); ++i) {
		if (m_instances.at(i)->instanceItem()->uniqueId() == instanceUid) {
			if (m_instances.at(i)->setVrmInstance(newVrmInstance)) {
				return true;
			}
		}
	}
	return false;
}

bool ClassAndVrmInstanceModel::hasVrmInstanceChanges() const
{
	for (int i = 0; i < m_instances.count(); ++i) {
		if (m_instances.at(i)->hasVrmInstanceChanges()) {
			return true;
		}
	}
	return false;
}

void ClassAndVrmInstanceModel::addInstanceForParentItem(VeQItem *instanceParentItem)
{
	Q_ASSERT(instanceParentItem);

	if (VeQItem *instanceItem = instanceParentItem->itemGet(QStringLiteral("ClassAndVrmInstance"))) {
		beginInsertRows(QModelIndex(), m_instances.count(), m_instances.count());
		ClassAndVrmInstance *instance = new ClassAndVrmInstance(this, instanceItem,
				instanceParentItem->itemGet(QStringLiteral("CustomName")));
		connect(instance, &ClassAndVrmInstance::validChanged, this, [this, instance]() {
			emitRoleChanged(instance, ValidRole);
		});
		connect(instance, &ClassAndVrmInstance::uidChanged, this, [this, instance]() {
			emitRoleChanged(instance, UidRole);
		});
		connect(instance, &ClassAndVrmInstance::deviceClassChanged, this, [this, instance]() {
			emitRoleChanged(instance, DeviceClassRole);
		});
		connect(instance, &ClassAndVrmInstance::vrmInstanceChanged, this, [this, instance]() {
			emitRoleChanged(instance, VrmInstanceRole);
		});
		connect(instance, &ClassAndVrmInstance::nameChanged, this, [this, instance]() {
			emitRoleChanged(instance, NameRole);
		});
		m_instances.append(instance);
		endInsertRows();
		emit countChanged();
	}
}

void ClassAndVrmInstanceModel::instanceParentAboutToBeRemoved(VeQItem *serviceItem)
{
	for (int i = 0; i < m_instances.count(); ++i) {
		if (m_instances.at(i)->instanceItem()->itemParent() == serviceItem) {
			beginRemoveRows(QModelIndex(), i, i);
			delete m_instances.takeAt(i);
			endRemoveRows();
			emit countChanged();
			break;
		}
	}
}

void ClassAndVrmInstanceModel::emitRoleChanged(ClassAndVrmInstance *instance, Role role)
{
	if (const int index = m_instances.indexOf(instance); index >= 0) {
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { role });
	}
}


SortedClassAndVrmInstanceModel::SortedClassAndVrmInstanceModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	sort(0, Qt::AscendingOrder);
}

bool SortedClassAndVrmInstanceModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	ClassAndVrmInstanceModel *model = qobject_cast<ClassAndVrmInstanceModel*>(sourceModel());
	if (!model) {
		return QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
	}

	return model->data(model->index(sourceRow, 0), ClassAndVrmInstanceModel::ValidRole).toBool();
}

bool SortedClassAndVrmInstanceModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	ClassAndVrmInstanceModel *model = qobject_cast<ClassAndVrmInstanceModel*>(sourceModel());
	if (!model) {
		return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
	}

	// Sort by connected devices first (i.e. those with a name), then by device class, then by VRM
	// instance.
	const QModelIndex leftIndex = model->index(sourceLeft.row(), sourceLeft.column());
	const QModelIndex rightIndex = model->index(sourceRight.row(), sourceRight.column());

	const QString leftName = model->data(leftIndex, ClassAndVrmInstanceModel::NameRole).toString();
	const QString rightName = model->data(rightIndex, ClassAndVrmInstanceModel::NameRole).toString();
	if (leftName != rightName) {
		if (leftName.isEmpty()) {
			return false;
		} else if (rightName.isEmpty()) {
			return true;
		} else {
			return leftName.localeAwareCompare(rightName) < 0;
		}
	}

	const QString leftDeviceClass = model->data(leftIndex, ClassAndVrmInstanceModel::DeviceClassRole).toString();
	const QString rightDeviceClass = model->data(rightIndex, ClassAndVrmInstanceModel::DeviceClassRole).toString();
	if (leftDeviceClass != rightDeviceClass) {
		return leftDeviceClass.localeAwareCompare(rightDeviceClass) < 0;
	}

	return model->data(leftIndex, ClassAndVrmInstanceModel::VrmInstanceRole).toInt()
			< model->data(rightIndex, ClassAndVrmInstanceModel::VrmInstanceRole).toInt();
}

FilteredClassAndVrmInstanceModel::FilteredClassAndVrmInstanceModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	connect(this, &QSortFilterProxyModel::rowsInserted, this, &FilteredClassAndVrmInstanceModel::updateCount);
	connect(this, &QSortFilterProxyModel::rowsRemoved, this, &FilteredClassAndVrmInstanceModel::updateCount);
	connect(this, &QSortFilterProxyModel::modelReset, this, &FilteredClassAndVrmInstanceModel::updateCount);
	connect(this, &QSortFilterProxyModel::layoutChanged, this, &FilteredClassAndVrmInstanceModel::updateCount);
}

int FilteredClassAndVrmInstanceModel::count() const
{
	return m_count;
}

QStringList FilteredClassAndVrmInstanceModel::deviceClasses() const
{
	return m_deviceClasses;
}

void FilteredClassAndVrmInstanceModel::setDeviceClasses(const QStringList &deviceClasses)
{
	if (m_deviceClasses != deviceClasses) {
		m_deviceClasses = deviceClasses;
		invalidateFilter();
		emit deviceClassesChanged();
	}
}

bool FilteredClassAndVrmInstanceModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	ClassAndVrmInstanceModel *model = qobject_cast<ClassAndVrmInstanceModel*>(sourceModel());
	if (!model) {
		return QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
	}

	if (m_deviceClasses.isEmpty()) {
		return true;
	}

	return m_deviceClasses.contains(model->data(model->index(sourceRow, 0),
												ClassAndVrmInstanceModel::DeviceClassRole)
										.toString()) &&
		   model->data(model->index(sourceRow, 0), ClassAndVrmInstanceModel::ValidRole).toBool();
}

void FilteredClassAndVrmInstanceModel::updateCount()
{
	const int prevCount = m_count;
	m_count = rowCount();

	if (m_count != prevCount) {
		emit countChanged();
	}
}
