/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "devicewatcher.h"

#include "alldevicesmodel.h"

namespace Victron {
namespace GuiPlugins {

/*
	AllDevicesModel is the existing lookup. It is not reimplemented here. A device is not in that
	model until it has a device instance and a name, and a service that is not a device (settings,
	system, platform) is never in it.

	serviceUid() is empty until the device becomes available, and serviceUidChanged() is emitted
	when that device appears, disappears or its service uid changes. If two devices have the same
	type and instance, the first one is used.
*/

DeviceWatcher::DeviceWatcher(QObject *parent)
	: QObject(parent)
{
}

DeviceWatcher::~DeviceWatcher()
{
	setActive(false);
}

void DeviceWatcher::watch(const QString &serviceType, int deviceInstance)
{
	m_serviceType = serviceType;
	m_deviceInstance = deviceInstance;
	setActive(true);
	refresh();
}

void DeviceWatcher::stop()
{
	setActive(false);
}

QString DeviceWatcher::serviceUid() const
{
	return m_serviceUid;
}

void DeviceWatcher::setActive(bool active)
{
	if (m_active == active) {
		return;
	}
	m_active = active;
	if (!m_active) {
		unwatchAll();
		if (m_model) {
			disconnect(m_model, nullptr, this, nullptr);
			m_model = nullptr;
		}
		return;
	}

	m_model = VenusOS::AllDevicesModel::create();
	VenusOS::AllDevicesModel *model = m_model;
	connect(model, &VenusOS::AllDevicesModel::deviceAdded, this, [this](VenusOS::Device *device) {
		watchDevice(device);
		refresh();
	});
	// The device is still in the model during deviceAboutToBeRemoved, and it is deleted just after
	// rowsRemoved. Drop its signals now, but keep the pointer until refresh() can see that it is
	// gone.
	connect(model, &VenusOS::AllDevicesModel::deviceAboutToBeRemoved, this, &DeviceWatcher::unwatchDevice);
	connect(model, &QAbstractItemModel::rowsRemoved, this, &DeviceWatcher::refresh);
	connect(model, &QAbstractItemModel::modelAboutToBeReset, this, [this] {
		const bool hadDevice = !m_device.isNull();
		unwatchAll();
		if (hadDevice) {
			emit serviceUidChanged();
		}
	});
	connect(model, &QAbstractItemModel::modelReset, this, [this] {
		if (!m_model) {
			return;
		}
		for (int i = 0; i < m_model->count(); ++i) {
			watchDevice(m_model->deviceAt(i));
		}
		refresh();
	});

	for (int i = 0; i < model->count(); ++i) {
		watchDevice(model->deviceAt(i));
	}
}

void DeviceWatcher::refresh()
{
	VenusOS::Device *device = nullptr;
	if (m_active && m_model) {
		device = m_model->findDeviceWithTypeAndInstance(m_serviceType, m_deviceInstance);
	}
	// Read the previous uid from the cache. The device has already changed its service uid by the
	// time serviceUidChanged is delivered, so reading it again would hide the change.
	const QString nextUid = device ? device->serviceUid() : QString();
	const bool changed = m_device != device || m_serviceUid != nextUid;
	m_device = device;
	m_serviceUid = nextUid;
	if (changed) {
		emit serviceUidChanged();
	}
}

bool DeviceWatcher::isWatched(VenusOS::Device *device) const
{
	for (const QPointer<VenusOS::Device> &watched : m_watched) {
		if (watched == device) {
			return true;
		}
	}
	return false;
}

void DeviceWatcher::watchDevice(VenusOS::Device *device)
{
	if (!device || isWatched(device)) {
		return;
	}
	m_watched.append(device);
	connect(device, &VenusOS::BaseDevice::serviceUidChanged, this, &DeviceWatcher::refresh);
	connect(device, &VenusOS::BaseDevice::serviceTypeChanged, this, &DeviceWatcher::refresh);
	connect(device, &VenusOS::BaseDevice::deviceInstanceChanged, this, &DeviceWatcher::refresh);
}

void DeviceWatcher::unwatchDevice(VenusOS::Device *device)
{
	if (!device) {
		return;
	}
	disconnect(device, nullptr, this, nullptr);
	for (int i = m_watched.count() - 1; i >= 0; --i) {
		if (m_watched.at(i) == device) {
			m_watched.removeAt(i);
		}
	}
}

void DeviceWatcher::unwatchAll()
{
	const QList<QPointer<VenusOS::Device>> watched = m_watched;
	for (const QPointer<VenusOS::Device> &device : watched) {
		if (device) {
			disconnect(device, nullptr, this, nullptr);
		}
	}
	m_watched.clear();
	m_device = nullptr;
	m_serviceUid.clear();
}

} // namespace GuiPlugins
} // namespace Victron
