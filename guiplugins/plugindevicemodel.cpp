/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "plugindevicemodel.h"

#include "alldevicesmodel.h"
#include "device.h"
#include "filtereddevicemodel.h"

#include <veutil/qt/ve_quick_item.hpp>

#include <QQmlInfo>

namespace Victron {
namespace GuiPlugins {

/*
	The inner model is completed in componentComplete(), not in the constructor, so that it does
	not list every device and then drop some when QML sets serviceTypes.

	The model is never reset: when the inner model changes, rows are inserted, removed and moved to
	match it, so that a view keeps the delegates of the devices that stay.

	The inner model has no requiredPaths filter, so the wrapper applies it. It reads each path in
	the same way as a PluginDataItem, so that "valid" means the same for both.

	The inner model does not report a change of a device's fields, such as its product id, so the
	wrapper reports it for that row.

	availableServiceTypes is read from the list of every device, not from the inner model, so
	that it does not depend on serviceTypes.

	A delegate, handler or binding that runs during an update may change the model, for example
	by setting serviceTypes. The model is then updated again, from the event loop, once the
	current update has finished. If each of those updates leads to another one, that is a loop, so
	after MaxRepeatedUpdates of them in a row, the model warns and stops until a change comes from
	outside an update.
*/

namespace {

// The most updates in a row that are caused by a change made during the previous update.
constexpr int MaxRepeatedUpdates = 2;

}

PluginDeviceModel::PluginDeviceModel(QObject *parent)
	: QAbstractListModel(parent)
	, m_devices(new VenusOS::FilteredDeviceModel(this))
{
	m_devices->setSorting(VenusOS::FilteredDeviceModel::Name);
	m_devices->classBegin();

	connect(m_devices, &QAbstractItemModel::rowsInserted, this, &PluginDeviceModel::updateFromSource);
	connect(m_devices, &QAbstractItemModel::rowsRemoved, this, &PluginDeviceModel::updateFromSource);
	connect(m_devices, &QAbstractItemModel::rowsMoved, this, &PluginDeviceModel::updateFromSource);
	connect(m_devices, &QAbstractItemModel::layoutChanged, this, &PluginDeviceModel::updateFromSource);
	connect(m_devices, &QAbstractItemModel::modelReset, this, &PluginDeviceModel::updateFromSource);
	connect(m_devices, &QAbstractItemModel::dataChanged, this, &PluginDeviceModel::sourceDataChanged);

	VenusOS::AllDevicesModel *allDevices = VenusOS::AllDevicesModel::create();
	connect(allDevices, &QAbstractItemModel::rowsInserted, this, &PluginDeviceModel::updateAvailableServiceTypes);
	connect(allDevices, &QAbstractItemModel::rowsRemoved, this, &PluginDeviceModel::updateAvailableServiceTypes);
	connect(allDevices, &QAbstractItemModel::modelReset, this, &PluginDeviceModel::updateAvailableServiceTypes);
	updateAvailableServiceTypes();
}

QStringList PluginDeviceModel::serviceTypes() const
{
	return m_devices->serviceTypes();
}

void PluginDeviceModel::setServiceTypes(const QStringList &serviceTypes)
{
	if (m_devices->serviceTypes() == serviceTypes) {
		return;
	}
	m_devices->setServiceTypes(serviceTypes);
	emit serviceTypesChanged();
}

QStringList PluginDeviceModel::requiredPaths() const
{
	return m_requiredPaths;
}

void PluginDeviceModel::setRequiredPaths(const QStringList &requiredPaths)
{
	if (m_requiredPaths == requiredPaths) {
		return;
	}
	m_requiredPaths = requiredPaths;
	if (m_completed) {
		updateFromSource();
	}
	emit requiredPathsChanged();
}

QStringList PluginDeviceModel::availableServiceTypes() const
{
	return m_availableServiceTypes;
}

int PluginDeviceModel::count() const
{
	return m_rows.count();
}

QString PluginDeviceModel::serviceUidAt(int index) const
{
	const VenusOS::Device *device = deviceAt(index);
	return device ? device->serviceUid() : QString();
}

QString PluginDeviceModel::serviceTypeAt(int index) const
{
	const VenusOS::Device *device = deviceAt(index);
	return device ? device->serviceType() : QString();
}

int PluginDeviceModel::deviceInstanceAt(int index) const
{
	const VenusOS::Device *device = deviceAt(index);
	return device ? device->deviceInstance() : -1;
}

QString PluginDeviceModel::nameAt(int index) const
{
	const VenusOS::Device *device = deviceAt(index);
	return device ? device->name() : QString();
}

int PluginDeviceModel::productIdAt(int index) const
{
	const VenusOS::Device *device = deviceAt(index);
	return device ? device->productId() : -1;
}

int PluginDeviceModel::rowCount(const QModelIndex &parent) const
{
	return parent.isValid() ? 0 : m_rows.count();
}

QVariant PluginDeviceModel::data(const QModelIndex &index, int role) const
{
	const VenusOS::Device *device = deviceAt(index.row());
	if (!device || index.column() != 0) {
		return QVariant();
	}
	switch (role) {
	case ServiceUidRole:
		return device->serviceUid();
	case ServiceTypeRole:
		return device->serviceType();
	case DeviceInstanceRole:
		return device->deviceInstance();
	case NameRole:
		return device->name();
	case ProductIdRole:
		return device->productId();
	default:
		return QVariant();
	}
}

QHash<int, QByteArray> PluginDeviceModel::roleNames() const
{
	return {
		{ ServiceUidRole, "serviceUid" },
		{ ServiceTypeRole, "serviceType" },
		{ DeviceInstanceRole, "deviceInstance" },
		{ NameRole, "name" },
		{ ProductIdRole, "productId" },
	};
}

void PluginDeviceModel::classBegin()
{
}

void PluginDeviceModel::componentComplete()
{
	m_completed = true;
	m_devices->componentComplete();
	updateFromSource();
}

VenusOS::Device *PluginDeviceModel::deviceAt(int index) const
{
	if (index < 0 || index >= m_rows.count()) {
		return nullptr;
	}
	return m_rows.at(index);
}

int PluginDeviceModel::rowOf(const VenusOS::Device *device) const
{
	if (!device) {
		return -1;
	}
	for (int row = 0; row < m_rows.count(); ++row) {
		if (m_rows.at(row) == device) {
			return row;
		}
	}
	return -1;
}

void PluginDeviceModel::watchDevice(VenusOS::Device *device)
{
	if (!device) {
		return;
	}
	connect(device, &VenusOS::Device::serviceUidChanged,
			this, &PluginDeviceModel::deviceFieldChanged, Qt::UniqueConnection);
	connect(device, &VenusOS::Device::serviceTypeChanged,
			this, &PluginDeviceModel::deviceFieldChanged, Qt::UniqueConnection);
	connect(device, &VenusOS::Device::deviceInstanceChanged,
			this, &PluginDeviceModel::deviceFieldChanged, Qt::UniqueConnection);
	connect(device, &VenusOS::Device::nameChanged,
			this, &PluginDeviceModel::deviceFieldChanged, Qt::UniqueConnection);
	connect(device, &VenusOS::Device::productIdChanged,
			this, &PluginDeviceModel::deviceFieldChanged, Qt::UniqueConnection);
}

void PluginDeviceModel::deviceFieldChanged()
{
	const VenusOS::Device *device = qobject_cast<VenusOS::Device *>(sender());
	const int row = rowOf(device);
	if (row < 0) {
		return;
	}
	const QModelIndex rowIndex = index(row, 0);
	emit dataChanged(rowIndex, rowIndex);
}

void PluginDeviceModel::sourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight,
		const QList<int> &roles)
{
	Q_UNUSED(roles)
	if (!topLeft.isValid() || !bottomRight.isValid() || topLeft.parent().isValid()) {
		return;
	}
	const int last = qMin(bottomRight.row(), m_devices->rowCount() - 1);
	for (int sourceRow = qMax(topLeft.row(), 0); sourceRow <= last; ++sourceRow) {
		const int row = rowOf(m_devices->deviceAt(sourceRow));
		if (row >= 0) {
			const QModelIndex rowIndex = index(row, 0);
			emit dataChanged(rowIndex, rowIndex);
		}
	}
}

void PluginDeviceModel::updateFromSource()
{
	if (m_updating) {
		m_changedDuringUpdate = true;
		return;
	}
	m_repeatedUpdates = 0;
	runUpdate();
}

void PluginDeviceModel::updateAgain()
{
	if (!m_updateAgainPending) {
		return;
	}
	++m_repeatedUpdates;
	runUpdate();
}

void PluginDeviceModel::runUpdate()
{
	m_updating = true;
	m_changedDuringUpdate = false;
	// This update also applies a change that is waiting for updateAgain().
	m_updateAgainPending = false;
	const int previous = m_rows.count();
	updateRows(listedDevices());
	for (const QPointer<VenusOS::Device> &device : std::as_const(m_rows)) {
		watchDevice(device);
	}
	if (m_rows.count() != previous) {
		emit countChanged();
	}
	m_updating = false;

	if (!m_changedDuringUpdate) {
		return;
	}
	if (m_repeatedUpdates < MaxRepeatedUpdates) {
		m_updateAgainPending = true;
		QMetaObject::invokeMethod(this, &PluginDeviceModel::updateAgain, Qt::QueuedConnection);
	} else {
		qmlWarning(this) << "Loop detected: the model was changed during " << MaxRepeatedUpdates + 1
				<< " updates in a row, so it has stopped updating. Look for a delegate, handler or"
				<< " binding that changes serviceTypes or requiredPaths whenever the rows change.";
	}
}

// Returns the devices of the inner model, in its order, that have the required paths.
QList<QPointer<VenusOS::Device>> PluginDeviceModel::listedDevices()
{
	QList<QPointer<VenusOS::Device>> devices;
	QSet<QString> watchedUids;
	for (int sourceRow = 0; sourceRow < m_devices->rowCount(); ++sourceRow) {
		VenusOS::Device *device = m_devices->deviceAt(sourceRow);
		if (device && hasRequiredPaths(device, &watchedUids)) {
			devices.append(device);
		}
	}
	for (auto it = m_requiredItems.begin(); it != m_requiredItems.end();) {
		if (watchedUids.contains(it.key())) {
			++it;
		} else {
			// Delete it later: this update can be running inside that item's own signal.
			it.value()->disconnect(this);
			it.value()->deleteLater();
			it = m_requiredItems.erase(it);
		}
	}
	return devices;
}

// Removes, moves and inserts rows, one at a time, until they are the same as devices.
void PluginDeviceModel::updateRows(const QList<QPointer<VenusOS::Device>> &devices)
{
	QSet<const VenusOS::Device *> listed;
	for (const QPointer<VenusOS::Device> &device : devices) {
		listed.insert(device.data());
	}
	for (int row = m_rows.count() - 1; row >= 0; --row) {
		if (!m_rows.at(row) || !listed.contains(m_rows.at(row).data())) {
			beginRemoveRows(QModelIndex(), row, row);
			m_rows.removeAt(row);
			endRemoveRows();
		}
	}

	// The rows before row already match, so a device that is listed further down is moved up.
	for (int row = 0; row < devices.count(); ++row) {
		if (row < m_rows.count() && m_rows.at(row) == devices.at(row)) {
			continue;
		}
		int from = -1;
		for (int other = row + 1; other < m_rows.count(); ++other) {
			if (m_rows.at(other) == devices.at(row)) {
				from = other;
				break;
			}
		}
		if (from >= 0) {
			beginMoveRows(QModelIndex(), from, from, QModelIndex(), row);
			m_rows.move(from, row);
			endMoveRows();
		} else {
			beginInsertRows(QModelIndex(), row, row);
			m_rows.insert(row, devices.at(row));
			endInsertRows();
		}
	}

	// Rows are left over only if the inner model listed a device twice.
	if (m_rows.count() > devices.count()) {
		beginRemoveRows(QModelIndex(), devices.count(), m_rows.count() - 1);
		m_rows.resize(devices.count());
		endRemoveRows();
	}
}

// Returns whether each required path on the device has a valid value, and adds the uids that
// it read to watchedUids. Each path is read, even after one is not valid, so that a change of
// any of them updates the rows.
bool PluginDeviceModel::hasRequiredPaths(const VenusOS::Device *device, QSet<QString> *watchedUids)
{
	bool hasAll = true;
	for (const QString &path : std::as_const(m_requiredPaths)) {
		const QString relativePath = path.startsWith('/') ? path.mid(1) : path;
		if (relativePath.isEmpty()) {
			continue;
		}
		const QString uid = device->serviceUid() + '/' + relativePath;
		watchedUids->insert(uid);
		VeQuickItem *item = m_requiredItems.value(uid);
		if (!item) {
			item = new VeQuickItem(false);
			item->setParent(this);
			item->setUid(uid);
			m_requiredItems.insert(uid, item);
			connect(item, &VeQuickItem::isValidChanged, this, &PluginDeviceModel::updateFromSource);
		}
		hasAll = hasAll && item->getIsValid();
	}
	return hasAll;
}

void PluginDeviceModel::updateAvailableServiceTypes()
{
	const VenusOS::AllDevicesModel *allDevices = VenusOS::AllDevicesModel::create();
	QStringList serviceTypes;
	for (int i = 0; i < allDevices->count(); ++i) {
		if (const VenusOS::Device *device = allDevices->deviceAt(i)) {
			serviceTypes.append(device->serviceType());
		}
	}
	serviceTypes.removeDuplicates();
	serviceTypes.sort();
	if (m_availableServiceTypes != serviceTypes) {
		m_availableServiceTypes = serviceTypes;
		emit availableServiceTypesChanged();
	}
}

} // namespace GuiPlugins
} // namespace Victron
