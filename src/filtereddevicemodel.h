/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_FILTEREDDEVICEMODEL_H
#define VICTRON_GUIV2_FILTEREDDEVICEMODEL_H

#include <QStringList>
#include <QVariantMap>
#include <QJSValue>
#include <QSortFilterProxyModel>
#include <QQmlParserStatus>
#include <qqmlintegration.h>

class QJSEngine;
class ChildFilterHandler;

namespace Victron {
namespace VenusOS {

class BaseDevice;
class Device;

/*
	Provides a sorted/filtered view of AllDevicesModel.

	Basic usage:

	- Delegates have access to all roles provided by AllDevicesModel.
	- Set serviceTypes to specify the types of devices to be included in the model.
	- Sort by service type, device instance and/or name (default is sort by name).

	Advanced filtering:

	The model can be filtered to only show devices with specific child values, by setting:

	- childFilterIds: a map of the service types to be filtered, and the child ids for those
	  services that affect whether a device of that service type will be included in the model
	- childFilterFunction: a function that is called with (Device*, list<VeQItem*>) whenever the
	  model is re-filtered. The first argument is the Device* entry being filtered, and the second
	  is a list of the child items for that device, as specified by childFilterIds. The function
	  should return true if the device is allowed in the model.

	For example, the model below includes generator, vebus and tank devices on
	the system, but the generator and vebus services are filtered depending on child values:

	FilteredDeviceModel {
		// Include generator, vebus and tank devices on the system.
		serviceTypes: ["generator", "vebus", "tank"]

		// For generators, check the value of com.victronenergy.generator.<suffix>/Enabled and
		// com.victronenergy.generator.<suffix>/Active. For vebus services, check the value of
		// com.victronenergy.vebus.<suffix>/DeviceInstance.
		childFilterIds: { "generator": ["Enabled", "Active"], "vebus": ["DeviceInstance"] }

		// When filtering, return true if the device is allowed in the model, and false otherwise.
		childFilterFunction: (device, childItems) => {
			if (device.serviceType === "generator") {
				// Allow generator devices if both Enabled=1 and Active=1.
				return childItems["Enabled"]?.value === 1 && childItems["Active"]?.value === 1
			} else if (device.serviceType === "vebus") {
				// Allow vebus devices if the DeviceInstance=0.
				return childItems["DeviceInstance"]?.value === 0
			} else {
				// This code should not be reached; the function is not called for tanks, as there
				// are no child id filters set for tank types, so tanks are automatically allowed
				// into the model.
				return false
			}
		}
	}

	Note: the child ids used in the filter map must be direct children. "ChildValue" is supported,
	but not "Some/Deeper/ChildValue".
*/
class FilteredDeviceModel : public QSortFilterProxyModel, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(Device *firstObject READ firstObject NOTIFY firstObjectChanged FINAL)
	Q_PROPERTY(int sorting READ sorting WRITE setSorting NOTIFY sortingChanged FINAL)
	Q_PROPERTY(QStringList serviceTypes READ serviceTypes WRITE setServiceTypes NOTIFY serviceTypesChanged FINAL)
	Q_PROPERTY(QVariantMap childFilterIds READ childFilterIds WRITE setChildFilterIds NOTIFY childFilterIdsChanged FINAL)
	Q_PROPERTY(QJSValue childFilterFunction READ childFilterFunction WRITE setChildFilterFunction NOTIFY childFilterFunctionChanged FINAL)

public:
	enum SortFlag {
		Unsorted,

		// If multiple sort flags are set, they are applied in order of their sort enum value.
		ServiceTypeOrder = 0x1, // Sort by the index of the type in the serviceTypes list
		DeviceInstance = 0x2, // Sort by Device::deviceInstance
		Name = 0x4, // Sort by Device::name
	};
	Q_ENUM(SortFlag)
	Q_DECLARE_FLAGS(SortFlags, SortFlag)

	explicit FilteredDeviceModel(QObject *parent = nullptr);

	int count() const;
	Device *firstObject() const;

	void setSorting(int sorting);
	int sorting() const;

	QStringList serviceTypes() const;
	void setServiceTypes(const QStringList &serviceTypes);

	QVariantMap childFilterIds() const;
	void setChildFilterIds(const QVariantMap &childFilterIds);

	QJSValue childFilterFunction() const;
	void setChildFilterFunction(const QJSValue &childFilterFunction);

	void classBegin() override;
	void componentComplete() override;

	Q_INVOKABLE Device *deviceAt(int index) const;

	// Returns the first device in the model found with this device instance.
	Q_INVOKABLE Device *deviceForDeviceInstance(int deviceInstance) const;

Q_SIGNALS:
	void countChanged();
	void firstObjectChanged();
	void sortingChanged();
	void serviceTypesChanged();
	void childFilterIdsChanged();
	void childFilterFunctionChanged();

protected:
	bool filterAcceptsRow(int sourceRow, const QModelIndex & sourceParent) const override;
	bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

private:
	void filteredDeviceInserted(const QModelIndex &parent, int first, int last);
	void filteredDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	void filteredDevicesAboutToBeReset();
	void filteredDevicesReset();
	void resetChildFilter();
	void initializeFilteredDevice(BaseDevice *device);
	void updateCount();

	QStringList m_serviceTypes;
	QString m_firstUid;
	QVariantMap m_childFilterIds;
	QJSValue m_childFilterFunction;
	ChildFilterHandler * m_childFilterHandler = nullptr;
	int m_sorting = Name;
	int m_count = 0;
	bool m_completed = false;
};

} /* VenusOS */
} /* Victron */

Q_DECLARE_OPERATORS_FOR_FLAGS(Victron::VenusOS::FilteredDeviceModel::SortFlags)

#endif // VICTRON_GUIV2_FILTEREDDEVICEMODEL_H

