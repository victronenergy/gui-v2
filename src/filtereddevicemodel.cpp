/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "filtereddevicemodel.h"
#include "alldevicesmodel.h"
#include "basedevice.h"

#include <QPointer>
#include <QQmlInfo>
#include <QQmlContext>
#include <QJSEngine>

#include <veutil/qt/ve_qitem.hpp>

using namespace Victron::VenusOS;

class ChildFilterHandler : public QObject
{
	Q_OBJECT
public:
	ChildFilterHandler(FilteredDeviceModel *model, const QVariantMap &childFilterIds);
	~ChildFilterHandler();

	bool filterAcceptsDevice(Device *device, const QJSValue &callable);

private:
	void addChildrenOfDevice(Device *device, bool initialized);
	void removeChildrenOfDevice(Device *device);
	void deviceChildAdded(VeQItem *child);
	void addFilteredChild(VeQItem *child);
	void deviceChildAboutToBeRemoved(VeQItem *child);
	void removeAllDeviceChildren();

	// Map of { childUid -> VeQItem }. These are the children of devices that have been added to
	// FilteredDeviceModel, which will be passed as the childFilterFunction function arguments.
	QMap<QString, VeQItem *> m_childItems;

	// Map of { serviceType -> QStringList }. These are the string lists from the child filter ids,
	// cached here for use by filterAcceptsDevice().
	QMap<QString, QStringList> m_filterIds;

	FilteredDeviceModel *m_model = nullptr;
	QJSEngine *m_jsEngine = nullptr;
	bool m_initialized = false;
};

ChildFilterHandler::ChildFilterHandler(FilteredDeviceModel *model, const QVariantMap &childFilterIds)
	: QObject(model)
	, m_model(model)
{
	if (QQmlContext *context = QQmlEngine::contextForObject(model)) {
		m_jsEngine = reinterpret_cast<QJSEngine*>(context->engine());
	}

	for (auto it = childFilterIds.constBegin(); it != childFilterIds.constEnd(); ++it) {
		m_filterIds.insert(it.key(), it.value().toStringList());
	}

	// Add the relevant children of each Device serviceItem required by the filtered model.
	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	for (int i = 0; i < allDevicesModel->count(); ++i) {
		if (Device *device = allDevicesModel->deviceAt(i)) {
			addChildrenOfDevice(device, false);
		}
	}
	connect(allDevicesModel, &AllDevicesModel::deviceAdded, this, [this](Device *device) {
		addChildrenOfDevice(device, true);
	});
	connect(allDevicesModel, &AllDevicesModel::deviceAboutToBeRemoved,
			this, &ChildFilterHandler::removeChildrenOfDevice);
}

ChildFilterHandler::~ChildFilterHandler()
{
	removeAllDeviceChildren();
}

bool ChildFilterHandler::filterAcceptsDevice(Device *device, const QJSValue &callable)
{
	if (m_filterIds.isEmpty()) {
		// There are no child ids to be filtered.
		return true;
	}

	if (!callable.isCallable()) {
		// Service filter function is set to undefined, so no filter is applied.
		return true;
	}

	if (!m_jsEngine) {
		qmlWarning(m_model) << "JSEngine not available, filter is ignored!";
		return true;
	}

	// If the service type needs filtering, call the childFilterFunction.
	if (auto it = m_filterIds.constFind(device->serviceType()); it != m_filterIds.constEnd()) {
		const QStringList &childIdList = it.value();
		if (childIdList.count() > 0) {
			// Make a { childId: childItems } map to be passed to the filter function.
			QJSValue childrenObject = m_jsEngine->newObject();
			for (const QString &childId : childIdList) {
				if (VeQItem *childItem = m_childItems.value(device->serviceUid() + "/" + childId)) {
					childrenObject.setProperty(childItem->id(), m_jsEngine->toScriptValue(childItem));
				} else {
					childrenObject.setProperty(childId, QJSValue());
				}
			}
			const QJSValueList args = { m_jsEngine->toScriptValue(device), childrenObject };
			return callable.call(args).toBool();
		}
	}

	// The service type is accepted without any need to filter.
	return true;
}

void ChildFilterHandler::addChildrenOfDevice(Device *device, bool initialized)
{
	if (!device || !device->serviceItem()) {
		qmlWarning(m_model) << "Device" << device->serviceUid() << "has invalid service item, cannot use child id filter!";
		return;
	}

	// If the device's serviceType is listed in the filter childIds, then look for those child items
	// (as children of the device's serviceItem).
	if (auto it = m_filterIds.find(device->serviceType()); it != m_filterIds.end()) {
		const QStringList childIds = it.value();
		for (const QString &childId : childIds) {
			if (VeQItem *item = device->serviceItem()->itemGet(childId)) {
				addFilteredChild(item);
			}
		}

		if (initialized && m_model->dynamicSortFilter()) {
			m_model->invalidate();
		}

		// Be notified when childItems are added/removed, so that they can be disconnected on
		// removal, or added if they do not yet exist.
		connect(device->serviceItem(), &VeQItem::childAdded,
				this, &ChildFilterHandler::deviceChildAdded,
				Qt::UniqueConnection);
		connect(device->serviceItem(), &VeQItem::childAboutToBeRemoved,
				this, &ChildFilterHandler::deviceChildAboutToBeRemoved,
				Qt::UniqueConnection);
	}
}

void ChildFilterHandler::removeChildrenOfDevice(Device *device)
{
	// Disconnect the signals that were connected in addChildrenOfDevice().
	// If disconnect() fails (i.e. this is not a monitored device), then no action will occur.
	if (device
			&& device->serviceItem()
			&& device->serviceItem()->disconnect(m_model)) {
		// Remove any saved VeQItem children of the device serviceItem.
		for (auto it = m_childItems.begin(); it != m_childItems.end();) {
			if (it.value()->itemParent() == device->serviceItem()) {
				it.value()->disconnect(m_model);
				it = m_childItems.erase(it);
			} else {
				++it;
			}
		}
		if (m_model->dynamicSortFilter()) {
			m_model->invalidate();
		}
	}
}

void ChildFilterHandler::deviceChildAdded(VeQItem *child)
{
	// When a new child is added to a device whose serviceType is in the filter map: if the child id
	// matches an id that needs to be monitored, then add it to the map of child items.
	const QString serviceType = BaseDevice::serviceTypeFromUid(child->itemParent()->uniqueId());
	if (m_filterIds.value(serviceType).contains(child->id())) {
		addFilteredChild(child);
		if (m_initialized && m_model->dynamicSortFilter()) {
			m_model->invalidate();
		}
	}
}

void ChildFilterHandler::addFilteredChild(VeQItem *child)
{
	m_childItems.insert(child->uniqueId(), child);
	connect(child, &VeQItem::valueChanged, m_model, &FilteredDeviceModel::invalidate, Qt::UniqueConnection);
}

void ChildFilterHandler::deviceChildAboutToBeRemoved(VeQItem *child)
{
	// This is called when any childItem is removed from the device's serviceItem, so it may not
	// exist in the item list.
	if (m_childItems.remove(child->uniqueId()) > 0) {
		child->disconnect(m_model);
		if (m_initialized && m_model->dynamicSortFilter()) {
			m_model->invalidate();
		}
	}
}

void ChildFilterHandler::removeAllDeviceChildren()
{
	AllDevicesModel::create()->disconnect(this);

	// Disconnect from all Device serviceItems, and clear the map of VeQItem children.
	for (auto it = m_childItems.begin(); it != m_childItems.end(); ++it) {
		if (VeQItem *childItem = it.value()) {
			if (VeQItem *serviceItem = childItem->itemParent()) {
				serviceItem->disconnect(m_model);
			}
		}
	}
	m_childItems.clear();
}


FilteredDeviceModel::FilteredDeviceModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	connect(this, &FilteredDeviceModel::rowsInserted, this, &FilteredDeviceModel::filteredDeviceInserted);
	connect(this, &FilteredDeviceModel::rowsAboutToBeRemoved, this, &FilteredDeviceModel::filteredDeviceAboutToBeRemoved);
	connect(this, &FilteredDeviceModel::modelAboutToBeReset, this, &FilteredDeviceModel::filteredDevicesAboutToBeReset);
	connect(this, &FilteredDeviceModel::modelReset, this, &FilteredDeviceModel::filteredDevicesReset);

	connect(this, &FilteredDeviceModel::rowsRemoved, this, &FilteredDeviceModel::updateCount);
	connect(this, &FilteredDeviceModel::layoutChanged, this, &FilteredDeviceModel::updateCount);
}

int FilteredDeviceModel::count() const
{
	return m_count;
}

Device *FilteredDeviceModel::firstObject() const
{
	return deviceAt(0);
}

int FilteredDeviceModel::sorting() const
{
	return m_sorting;
}

void FilteredDeviceModel::setSorting(int sorting)
{
	if (m_sorting != sorting) {
		m_sorting = sorting;
		if (m_completed) {
			invalidate();
		}
		emit sortingChanged();
	}
}

QStringList FilteredDeviceModel::serviceTypes() const
{
	return m_serviceTypes;
}

void FilteredDeviceModel::setServiceTypes(const QStringList &serviceTypes)
{
	if (m_serviceTypes != serviceTypes) {
		m_serviceTypes = serviceTypes;
		if (m_completed) {
			invalidate();
		}
		emit serviceTypesChanged();
	}
}

QVariantMap FilteredDeviceModel::childFilterIds() const
{
	return m_childFilterIds;
}

void FilteredDeviceModel::setChildFilterIds(const QVariantMap &childFilterIds)
{
	if (m_childFilterIds != childFilterIds) {
		m_childFilterIds = childFilterIds;
		if (m_completed) {
			resetChildFilter();
			invalidate();
		}
		emit childFilterIdsChanged();
	}
}

QJSValue FilteredDeviceModel::childFilterFunction() const
{
	return m_childFilterFunction;
}

void FilteredDeviceModel::setChildFilterFunction(const QJSValue &childFilterFunction)
{
	if (!childFilterFunction.isCallable() && !childFilterFunction.isNull() && !childFilterFunction.isUndefined()) {
		qmlWarning(this) << "childFilterFunction must be either a callable or null/undefined";
		return;
	}

	if (!m_childFilterFunction.equals(childFilterFunction)) {
		m_childFilterFunction = childFilterFunction;
		if (m_completed) {
			resetChildFilter();
			invalidate();
		}
		emit childFilterFunctionChanged();
	}
}

void FilteredDeviceModel::classBegin()
{
}

void FilteredDeviceModel::componentComplete()
{
	// Delay initialization until the serviceTypes and childFilter properties are set, to avoid
	// unnecessary filtering.
	m_completed = true;
	sort(0, Qt::AscendingOrder);
	setSourceModel(AllDevicesModel::create());

	for (int i = 0; i < count(); ++i) {
		initializeFilteredDevice(deviceAt(i));
	}
}

void FilteredDeviceModel::filteredDevicesAboutToBeReset()
{
	delete m_childFilterHandler;
	m_childFilterHandler = nullptr;
}

void FilteredDeviceModel::filteredDevicesReset()
{
	resetChildFilter();
	updateCount();
}

Device *FilteredDeviceModel::deviceAt(int index) const
{
	return AllDevicesModel::create()->deviceAt(mapToSource(this->index(index, 0)).row());
}

Device *FilteredDeviceModel::deviceForDeviceInstance(int deviceInstance) const
{
	for (int i = 0; i < count(); ++i) {
		if (Device *device = deviceAt(i)) {
			if (device->deviceInstance() == deviceInstance) {
				return device;
			}
		}
	}
	return nullptr;
}

bool FilteredDeviceModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	Q_UNUSED(sourceParent)

	if (!m_completed) {
		return false;
	}

	Device *device = AllDevicesModel::create()->deviceAt(sourceModel()->index(sourceRow, 0).row());
	if (!device) {
		return false;
	}

	if (!m_serviceTypes.isEmpty() && !m_serviceTypes.contains(device->serviceType())) {
		return false;
	}
	if (m_childFilterHandler) {
		return m_childFilterHandler->filterAcceptsDevice(device, m_childFilterFunction);
	}

	return true;
}

bool FilteredDeviceModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	Device *leftDevice = AllDevicesModel::create()->deviceAt(
				sourceModel()->index(sourceLeft.row(), sourceLeft.column()).row());
	Device *rightDevice = AllDevicesModel::create()->deviceAt(
				sourceModel()->index(sourceRight.row(), sourceRight.column()).row());

	if (leftDevice && rightDevice) {
		// Sort by serviceType -> deviceInstance -> name.
		if ((m_sorting & ServiceTypeOrder) && leftDevice->serviceType() != rightDevice->serviceType()) {
			return m_serviceTypes.indexOf(leftDevice->serviceType()) < m_serviceTypes.indexOf(rightDevice->serviceType());
		}
		if ((m_sorting & DeviceInstance) && leftDevice->deviceInstance() != rightDevice->deviceInstance()) {
			return leftDevice->deviceInstance() < rightDevice->deviceInstance();
		}
		if ((m_sorting & Name) && leftDevice->name() != rightDevice->name()) {
			return leftDevice->name().localeAwareCompare(rightDevice->name()) < 0;
		}
	}

	return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
}

void FilteredDeviceModel::filteredDeviceInserted(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	updateCount();

	for (int i = first; i <= last; ++i) {
		initializeFilteredDevice(deviceAt(i));
	}
}

void FilteredDeviceModel::filteredDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	for (int i = first; i <= last; ++i) {
		if (Device *device = deviceAt(i)) {
			device->disconnect(this);
		}
	}
}

void FilteredDeviceModel::resetChildFilter()
{
	if (!m_completed) {
		return;
	}

	delete m_childFilterHandler;
	m_childFilterHandler = nullptr;

	if (m_childFilterFunction.isCallable()) {
		m_childFilterHandler = new ChildFilterHandler(this, m_childFilterIds);
	}
}

void FilteredDeviceModel::initializeFilteredDevice(BaseDevice *device)
{
	if (device) {
		// Re-apply the filter if these device properties change.
		connect(device, &BaseDevice::deviceInstanceChanged, this, &FilteredDeviceModel::invalidate);
		connect(device, &BaseDevice::nameChanged, this, &FilteredDeviceModel::invalidate);
	}
}

void FilteredDeviceModel::updateCount()
{
	const QString prevFirstUid = m_firstUid;
	const BaseDevice *firstDevice = deviceAt(0);
	m_firstUid = firstDevice ? firstDevice->serviceUid() : QString();

	const int prevCount = m_count;
	m_count = rowCount();

	// Delay emitting the change signals until after both members are set, so that QML connections
	// to either of the change signals will get the updated values for both properties.
	if (m_count != prevCount) {
		emit countChanged();
	}
	if (m_firstUid != prevFirstUid) {
		emit firstObjectChanged();
	}
}

#include "filtereddevicemodel.moc"
