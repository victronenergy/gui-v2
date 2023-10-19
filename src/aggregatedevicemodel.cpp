#include "aggregatedevicemodel.h"
#include <stdlib.h>

#include <QQmlInfo>

using namespace Victron::VenusOS;

AggregateDeviceModel::AggregateDeviceModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_roleNames[DeviceRole] = "device";
	m_roleNames[SourceModelRole] = "sourceModel";
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

	beginResetModel();
	cleanUp();

	for (const QVariant &modelVariant : models) {
		if (!modelVariant.canConvert<BaseDeviceModel*>()) {
			qmlInfo(this) << "expected BaseDeviceModel* but model type is:" << modelVariant.userType() << " " << modelVariant.typeName();
			continue;
		}
		BaseDeviceModel *model = modelVariant.value<BaseDeviceModel*>();
		for (int i = 0; i < model->count(); ++i) {
			BaseDevice *device = model->deviceAt(i);
			m_deviceInfos.insert(insertionIndex(device), DeviceInfo{ device, model });
			connect(device, &BaseDevice::descriptionChanged, this, &AggregateDeviceModel::deviceDescriptionChanged);
		}
		connect(model, &BaseDeviceModel::rowsInserted, this, &AggregateDeviceModel::sourceModelRowsInserted);
		connect(model, &BaseDeviceModel::rowsAboutToBeRemoved, this, &AggregateDeviceModel::sourceModelRowsAboutToBeRemoved);
	}
	m_sourceModels = models;

	endResetModel();
	emit sourceModelsChanged();
	emit countChanged();
}

int AggregateDeviceModel::count() const
{
	return static_cast<int>(m_deviceInfos.count());
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
		if (device && newDevice->description().localeAwareCompare(device->description()) < 0) {
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

void AggregateDeviceModel::sourceModelRowsInserted(const QModelIndex &, int first, int last)
{
	BaseDeviceModel *sourceModel = qobject_cast<BaseDeviceModel *>(sender());
	if (!sourceModel) {
		qmlInfo(this) << "rowsInserted() signal was not from a BaseDeviceModel!";
		return;
	}

	for (int i = first; i <= last; ++i) {
		BaseDevice *device = sourceModel->deviceAt(i);
		if (!device) {
			qmlInfo(this) << "cannot find device to add at index " << i << " from model "
					<< sourceModel->objectName() << " with count:" << sourceModel->count();
			continue;
		}
		const int index = insertionIndex(device);
		emit beginInsertRows(QModelIndex(), index, index);
		m_deviceInfos.insert(index, DeviceInfo{ device, sourceModel });
		emit endInsertRows();
		connect(device, &BaseDevice::descriptionChanged, this, &AggregateDeviceModel::deviceDescriptionChanged);
	}
	emit countChanged();
}

void AggregateDeviceModel::sourceModelRowsAboutToBeRemoved(const QModelIndex &, int first, int last)
{
	BaseDeviceModel *sourceModel = qobject_cast<BaseDeviceModel *>(sender());
	if (!sourceModel) {
		qmlInfo(this) << "rowsInserted() signal was not from a BaseDeviceModel!";
		return;
	}

	QVector<int> removedIndexes;
	for (int i = first; i <= last; ++i) {
		BaseDevice *device = sourceModel->deviceAt(i);
		if (!device) {
			qmlInfo(this) << "cannot find device to remove at index " << i << " from model "
					<< sourceModel->objectName() << " with count:" << sourceModel->count();
			continue;
		}
		const int index = indexOf(device);
		if (index >= 0) {
			removedIndexes.append(index);
		}
	}

	// Remove relevant rows from this model, starting from the end
	std::sort(removedIndexes.begin(), removedIndexes.end(), std::greater<int>());
	for (int i : removedIndexes) {
		emit beginRemoveRows(QModelIndex(), i, i);
		BaseDevice *device = m_deviceInfos.takeAt(i).device;
		if (device) {
			device->disconnect(this);
		}
		emit endRemoveRows();
	}
	emit countChanged();
}

void AggregateDeviceModel::deviceDescriptionChanged()
{
	BaseDevice *changedDevice = qobject_cast<BaseDevice *>(sender());
	if (!changedDevice) {
		qmlInfo(this) << "descriptionChanged() signal was not from a BaseDevice!";
		return;
	}

	const int fromIndex = indexOf(changedDevice);
	if (fromIndex < 0 || m_deviceInfos.count() == 0) {
		return;
	}

	int toIndex = count() - 1;
	for (int i = 0; i < m_deviceInfos.count(); ++i) {
		BaseDevice *device = m_deviceInfos[i].device;
		if (device && changedDevice->description().localeAwareCompare(device->description()) < 0) {
			toIndex = i;
			break;
		}
	}

	beginMoveRows(QModelIndex(), fromIndex, fromIndex, QModelIndex(), toIndex);
	m_deviceInfos.swapItemsAt(fromIndex, toIndex);
	endMoveRows();
}
