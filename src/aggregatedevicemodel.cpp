/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "aggregatedevicemodel.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

AggregateDeviceModel::DeviceInfo::DeviceInfo(BaseDevice *d, BaseDeviceModel *m)
	: id(infoId(d, m))
	, device(d)
	, sourceModel(m)
	, cachedDeviceName(d ? d->name() : QString())
{
	if (device && cachedDeviceName.isEmpty()) {
		cachedDeviceName = device->serviceUid();
	}
}

AggregateDeviceModel::DeviceInfo::~DeviceInfo()
{
}

bool AggregateDeviceModel::DeviceInfo::isConnected() const
{
	return device && device->isValid();
}

QString AggregateDeviceModel::DeviceInfo::infoId(BaseDevice *device, BaseDeviceModel *sourceModel)
{
	if (!device || !sourceModel) {
		qWarning() << "Cannot create DeviceInfo, invalid device or model!";
		return QString();
	}
	return sourceModel->modelId() + device->serviceUid();
}


AggregateDeviceModel::AggregateDeviceModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_roleNames[DeviceRole] = "device";
	m_roleNames[SourceModelRole] = "sourceModel";
	m_roleNames[ConnectedRole] = "connected";
	m_roleNames[CachedDeviceNameRole] = "cachedDeviceName";
}

AggregateDeviceModel::~AggregateDeviceModel()
{
	cleanUp();
}

QVariantList AggregateDeviceModel::sourceModels() const
{
	return m_sourceModels;
}

void AggregateDeviceModel::setSourceModels(const QVariantList &models)
{
	if (m_sourceModels == models) {
		return;
	}

	const bool wasEmpty = count() == 0;
	const int prevDisconnectedDeviceCount = m_disconnectedDeviceCount;

	beginResetModel();
	cleanUp();

	for (const QVariant &modelVariant : models) {
		if (!modelVariant.canConvert<BaseDeviceModel*>()) {
			qmlInfo(this) << "expected BaseDeviceModel* but model type is:" << modelVariant.userType() << " " << modelVariant.typeName();
			continue;
		}
		BaseDeviceModel *model = modelVariant.value<BaseDeviceModel*>();
		if (model->modelId().isEmpty()) {
			qmlInfo(this) << "cannot use BaseDeviceModel* with empty modelId value:" << modelVariant.userType() << " " << modelVariant.typeName();
			continue;
		}

		for (int i = 0; i < model->count(); ++i) {
			BaseDevice *device = model->deviceAt(i);
			m_deviceInfos.insert(insertionIndex(device), DeviceInfo(device, model));
			connect(device, &BaseDevice::nameChanged, this, &AggregateDeviceModel::deviceNameChanged);
			connect(device, &BaseDevice::validChanged, this, &AggregateDeviceModel::deviceValidChanged);
		}
		connect(model, &BaseDeviceModel::rowsInserted, this, &AggregateDeviceModel::sourceModelRowsInserted);
		connect(model, &BaseDeviceModel::rowsAboutToBeRemoved, this, &AggregateDeviceModel::sourceModelRowsAboutToBeRemoved);
	}
	m_sourceModels = models;

	endResetModel();
	emit sourceModelsChanged();

	if (wasEmpty) {
		emit countChanged();
	}
	m_disconnectedDeviceCount = 0;
	if (prevDisconnectedDeviceCount != m_disconnectedDeviceCount) {
		emit disconnectedDeviceCountChanged();
	}
}

int AggregateDeviceModel::count() const
{
	return static_cast<int>(m_deviceInfos.count());
}

int AggregateDeviceModel::disconnectedDeviceCount() const
{
	return m_disconnectedDeviceCount;
}

QVariant AggregateDeviceModel::data(const QModelIndex &index, int role) const
{
	int row = index.row();

	if(row < 0 || row >= m_deviceInfos.count()) {
		return QVariant();
	}
	const DeviceInfo& deviceInfo = m_deviceInfos.at(row);
	switch (role)
	{
	case DeviceRole:
		return QVariant::fromValue<BaseDevice *>(deviceInfo.device.data());
	case SourceModelRole:
		return QVariant::fromValue<BaseDeviceModel *>(deviceInfo.sourceModel.data());
	case ConnectedRole:
		return deviceInfo.isConnected();
	case CachedDeviceNameRole:
		return deviceInfo.cachedDeviceName;
	default:
		return QVariant();
	}
}

int AggregateDeviceModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_deviceInfos.count());
}

QHash<int, QByteArray> AggregateDeviceModel::roleNames() const
{
	return m_roleNames;
}

void AggregateDeviceModel::removeDisconnectedDevices()
{
	if (m_disconnectedDeviceCount == 0) {
		return;
	}

	using IndexPair = QPair<int,int>;   // list of <firstIndex, lastIndex> pairs

	QList<IndexPair> removedIndexes;
	for (qsizetype i = 0; i < m_deviceInfos.count(); ++i) {
		if (!m_deviceInfos[i].isConnected()) {
			if (!removedIndexes.isEmpty()
					&& removedIndexes.last().second == i - 1) {
				removedIndexes.last() = qMakePair(removedIndexes.last().first, i);
			} else {
				removedIndexes << qMakePair(i, i);
			}
		}
	}

	for (auto it = removedIndexes.crbegin(); it != removedIndexes.crend(); ++it) {
		const IndexPair &pair = *it;
		emit beginRemoveRows(QModelIndex(), pair.first, pair.second);
		if (pair.first == pair.second) {
			m_deviceInfos.removeAt(pair.first);
		} else {
			for (int i = pair.second; i >= pair.first; --i) {
				m_deviceInfos.removeAt(i);
			}
		}
		emit endRemoveRows();
	}

	emit countChanged();
	m_disconnectedDeviceCount = 0;
	emit disconnectedDeviceCountChanged();
}

int AggregateDeviceModel::indexOf(const QString &deviceInfoId) const
{
	for (int i = 0; i < m_deviceInfos.count(); ++i) {
		if (deviceInfoId == m_deviceInfos[i].id) {
			return i;
		}
	}
	return -1;
}

int AggregateDeviceModel::indexOf(const BaseDevice *device) const
{
	if (device) {
		for (int i = 0; i < m_deviceInfos.count(); ++i) {
			if (device == m_deviceInfos[i].device) {
				return i;
			}
		}
	}
	return -1;
}

int AggregateDeviceModel::insertionIndex(BaseDevice *newDevice) const
{
	for (int i = 0; i < m_deviceInfos.count(); ++i) {
		BaseDevice *device = m_deviceInfos[i].device;
		if (device && newDevice->name().localeAwareCompare(m_deviceInfos[i].cachedDeviceName) < 0) {
			return i;
		}
	}
	return static_cast<int>(m_deviceInfos.count());
}

void AggregateDeviceModel::cleanUp()
{
	for (const DeviceInfo &deviceInfo : m_deviceInfos) {
		if (deviceInfo.device) {
			deviceInfo.device->disconnect(this);
		}
		if (deviceInfo.sourceModel) {
			deviceInfo.sourceModel->disconnect(this);
		}
	}
	m_deviceInfos.clear();
}

void AggregateDeviceModel::sourceModelRowsAboutToBeRemoved(const QModelIndex &, int first, int last)
{
	BaseDeviceModel *sourceModel = qobject_cast<BaseDeviceModel *>(sender());
	if (!sourceModel) {
		qmlInfo(this) << "rowsRemoved() signal was not from a BaseDeviceModel!";
		return;
	}

	const int prevCount = count();

	// If a source model is about to remove a valid device, then remove it from this aggregate
	// model. (If the device is invalid, do not remove it; in that case, it should remain in this
	// model but be marked as "Not connected", as per deviceValidChanged().)
	for (int i = last; i >= first; --i) {
		BaseDevice *device = sourceModel->deviceAt(i);
		if (!device) {
			qmlInfo(this) << "cannot find device to remove at index " << i << " from model "
						  << sourceModel->objectName() << " with count:" << sourceModel->count();
			continue;
		}
		if (device->isValid()) {
			const int removalIndex = indexOf(DeviceInfo::infoId(device, sourceModel));
			if (removalIndex < 0) {
				qmlInfo(this) << "cannot find device" << device->serviceUid() << "in this aggregate model!";
				continue;
			}
			device->disconnect(this);
			beginRemoveRows(QModelIndex(), removalIndex, removalIndex);
			m_deviceInfos.removeAt(removalIndex);
			endRemoveRows();
		}
	}

	if (prevCount != count()) {
		emit countChanged();
	}
}

void AggregateDeviceModel::sourceModelRowsInserted(const QModelIndex &, int first, int last)
{
	BaseDeviceModel *sourceModel = qobject_cast<BaseDeviceModel *>(sender());
	if (!sourceModel) {
		qmlInfo(this) << "rowsInserted() signal was not from a BaseDeviceModel!";
		return;
	}

	const int prevCount = count();
	const int prevDisconnectedDeviceCount = m_disconnectedDeviceCount;

	for (int i = first; i <= last; ++i) {
		BaseDevice *device = sourceModel->deviceAt(i);
		if (!device) {
			qmlInfo(this) << "cannot find device to add at index " << i << " from model "
					<< sourceModel->objectName() << " with count:" << sourceModel->count();
			continue;
		}

		int index = indexOf(DeviceInfo::infoId(device, sourceModel));
		if (index >= 0) {
			// The device is already in the list, i.e. it was disconnected then reconnected.
			QList<int> roles = { ConnectedRole };
			if (m_deviceInfos[index].device != device) {
				m_deviceInfos[index].device = device;
				roles << DeviceRole;
			}
			if (!device->name().isEmpty()
					&& device->name() != m_deviceInfos[index].cachedDeviceName) {
				m_deviceInfos[index].cachedDeviceName = device->name();
				roles << CachedDeviceNameRole;
			}
			m_disconnectedDeviceCount--;
			emit dataChanged(createIndex(index, 0), createIndex(index, 0), roles);
		} else {
			// Add the device to the list.
			index = insertionIndex(device);
			emit beginInsertRows(QModelIndex(), index, index);
			m_deviceInfos.insert(index, DeviceInfo(device, sourceModel));
			emit endInsertRows();
		}

		// Be notified when the name changes, so that the list order can be updated.
		connect(device, &BaseDevice::nameChanged, this, &AggregateDeviceModel::deviceNameChanged);
		connect(device, &BaseDevice::validChanged, this, &AggregateDeviceModel::deviceValidChanged);
	}

	if (prevCount != count()) {
		emit countChanged();
	}
	if (prevDisconnectedDeviceCount != m_disconnectedDeviceCount) {
		emit disconnectedDeviceCountChanged();
	}
}

void AggregateDeviceModel::deviceNameChanged()
{
	BaseDevice *changedDevice = qobject_cast<BaseDevice *>(sender());
	if (!changedDevice) {
		qmlInfo(this) << "nameChanged() signal was not from a BaseDevice!";
		return;
	}

	const QString newName = changedDevice->name();
	if (newName.isEmpty()) {
		// Don't set the cached name to an empty string
		return;
	}

	const int fromIndex = indexOf(changedDevice);
	if (fromIndex < 0 || m_deviceInfos.count() == 0) {
		return;
	}

	// Update the cached name
	m_deviceInfos[fromIndex].cachedDeviceName = newName;
	static const QList<int> roles = { CachedDeviceNameRole };
	emit dataChanged(createIndex(fromIndex, 0), createIndex(fromIndex, 0), roles);

	// Update the list order if needed
	int toIndex = count() - 1;
	for (int i = 0; i < m_deviceInfos.count(); ++i) {
		if (newName.localeAwareCompare(m_deviceInfos[i].cachedDeviceName) < 0) {
			if (i > 0 && m_deviceInfos[i - 1].device == changedDevice) {
				// The device at the previous index is this changed device, so it is already at
				// the correct index.
				return;
			}
			// Move the entry to be immediately before this item.
			toIndex = i > fromIndex ? i - 1 : i;
			break;
		}
	}

	if (fromIndex != toIndex) {
		const int destIndex = toIndex > fromIndex ? toIndex + 1 : toIndex;
		beginMoveRows(QModelIndex(), fromIndex, fromIndex, QModelIndex(), destIndex);
		m_deviceInfos.move(fromIndex, toIndex);
		endMoveRows();
	}
}

void AggregateDeviceModel::deviceValidChanged()
{
	BaseDevice *device = qobject_cast<BaseDevice *>(sender());
	if (!device) {
		qmlInfo(this) << "validChanged() signal was not from a BaseDevice!";
		return;
	}

	const int prevDisconnectedDeviceCount = m_disconnectedDeviceCount;
	for (int i = 0; i < m_deviceInfos.count(); ++i) {
		DeviceInfo &deviceInfo = m_deviceInfos[i];
		if (deviceInfo.device == device) {
			emit dataChanged(createIndex(i, 0), createIndex(i, 0), { ConnectedRole });
			if (!device->isValid()) {
				m_disconnectedDeviceCount++;
			}
		}
	}
	if (prevDisconnectedDeviceCount != m_disconnectedDeviceCount) {
		emit disconnectedDeviceCountChanged();
	}
}
