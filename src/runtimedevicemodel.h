/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_RUNTIMEDEVICEMODEL_H
#define VICTRON_GUIV2_RUNTIMEDEVICEMODEL_H

#include <QPointer>
#include <QList>
#include <QSortFilterProxyModel>
#include <qqmlintegration.h>

#include "basedevice.h"

class QQmlEngine;
class QJSEngine;

namespace Victron {
namespace VenusOS {

/*
	Provides a model of devices seen during the application runtime, for the Device List page.

	This model includes devices that have been disconnected, as opposed to AllDevicesModel, which
	only shows connected devices.

	If a device is disconnected, then calling data() for the row will return:
	- DeviceRole -> nullptr
	- CachedDeviceNameRole -> the last valid BaseDevice::name() seen for the device
	- ConnectedRole -> false

	Call removeDisconnectedDevices() to remove disconnected devices from the model.
*/
class RuntimeDeviceModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(int disconnectedDeviceCount READ disconnectedDeviceCount NOTIFY disconnectedDeviceCountChanged)

public:
	enum Role {
		DeviceRole = Qt::UserRole,
		CachedDeviceNameRole,
		ConnectedRole
	};
	Q_ENUM(Role)

	int count() const;
	int disconnectedDeviceCount() const;

	QVariant data(const QModelIndex& index, int role) const override;
	int rowCount(const QModelIndex &parent) const override;

	Q_INVOKABLE BaseDevice *deviceAt(int index) const; // Note: object has CppOwnership
	Q_INVOKABLE void removeDisconnectedDevices();

	static RuntimeDeviceModel* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void countChanged();
	void disconnectedDeviceCountChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	explicit RuntimeDeviceModel(QObject *parent);

	typedef QPair<QString, int> DeviceId;

	struct DeviceInfo {
		BaseDevice *device = nullptr;
		DeviceId id;
		QString cachedName;
	};

	int indexOf(const QString &serviceType, int deviceInstance) const;
	int indexOfKnownDevice(BaseDevice *device) const;
	void deviceNameChanged();
	void sourceDeviceAdded(const QModelIndex &parent, int first, int last);
	void sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	void sourceDevicesAboutToBeReset();
	void addDeviceInfo(BaseDevice *device);

	QList<DeviceInfo> m_devices;
	QSet<DeviceId> m_disconnectedDevices;
};

/*
	Provides a sorted RuntimeDeviceModel.

	Devices are sorted by their cached device name.
*/
class SortedRuntimeDeviceModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit SortedRuntimeDeviceModel(QObject *parent = nullptr);
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_RUNTIMEDEVICEMODEL_H

