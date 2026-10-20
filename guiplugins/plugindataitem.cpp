/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "plugindataitem.h"

#include "alldevicesmodel.h"
#include "backendconnection.h"

#include <veutil/qt/ve_quick_item.hpp>

#include <QList>
#include <QPointer>

#include <QtNumeric>

namespace Victron {
namespace GuiPlugins {

/*
	A VeQuickItem that can also read the minimum and maximum that the system gives. VeQuickItem's
	own min and max are 0 and INT_MAX when the system gives none, so they cannot tell a minimum of
	0 from no minimum.
*/
class PluginDataItem::BackendItem : public VeQuickItem
{
	Q_OBJECT
public:
	explicit BackendItem(QObject *parent)
		: VeQuickItem()
	{
		setParent(parent);
	}

	// Returns the system's "min" or "max" for the value, or NaN if the system does not give it.
	double systemLimit(const char *name) const
	{
		if (!mItem) {
			return qQNaN();
		}
		bool ok = false;
		const double limit = mItem->itemProperty(name).toDouble(&ok);
		return ok ? limit : qQNaN();
	}
};

/*
	Finds the device named by serviceType and deviceInstance, and keeps its service uid current.

	AllDevicesModel is the existing lookup. It is not reimplemented here. A device is not in that
	model until it has a device instance and a name, and a service that is not a device (settings,
	system, platform) is never in it.
*/
class PluginDataItem::DeviceWatcher
{
public:
	explicit DeviceWatcher(PluginDataItem *item)
		: m_item(item)
	{
	}

	~DeviceWatcher()
	{
		setActive(false);
	}

	void setActive(bool active)
	{
		if (m_active == active) {
			return;
		}
		m_active = active;
		if (!m_active) {
			unwatchAll();
			if (m_model) {
				disconnect(m_model, nullptr, m_item, nullptr);
				m_model = nullptr;
			}
			return;
		}

		m_model = VenusOS::AllDevicesModel::create();
		VenusOS::AllDevicesModel *model = m_model;
		connect(model, &VenusOS::AllDevicesModel::deviceAdded, m_item,
				[this](VenusOS::Device *device) {
			watchDevice(device);
			refresh();
		});
		// The device is still in the model during deviceAboutToBeRemoved, and it is deleted just
		// after rowsRemoved. Drop its signals now, but keep the pointer until refresh() can see
		// that it is gone.
		connect(model, &VenusOS::AllDevicesModel::deviceAboutToBeRemoved, m_item,
				[this](VenusOS::Device *device) {
			unwatchDevice(device);
		});
		connect(model, &QAbstractItemModel::rowsRemoved, m_item, [this] { refresh(); });
		connect(model, &QAbstractItemModel::modelAboutToBeReset, m_item, [this] {
			const bool hadDevice = !m_device.isNull();
			unwatchAll();
			if (hadDevice) {
				m_item->applyResolvedUid();
			}
		});
		connect(model, &QAbstractItemModel::modelReset, m_item, [this] {
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

	void refresh()
	{
		VenusOS::Device *device = nullptr;
		if (m_active && m_model) {
			device = m_model->findDeviceWithTypeAndInstance(
					m_item->serviceType(), m_item->deviceInstance());
		}
		// Read the previous uid from the cache. The device has already changed its service uid
		// by the time serviceUidChanged is delivered, so reading it again would hide the change.
		const QString nextUid = device ? device->serviceUid() : QString();
		const bool changed = m_device != device || m_serviceUid != nextUid;
		m_device = device;
		m_serviceUid = nextUid;
		if (changed) {
			m_item->applyResolvedUid();
		}
	}

	VenusOS::Device *device() const
	{
		return m_device;
	}

private:
	bool isWatched(VenusOS::Device *device) const
	{
		for (const QPointer<VenusOS::Device> &watched : m_watched) {
			if (watched == device) {
				return true;
			}
		}
		return false;
	}

	void watchDevice(VenusOS::Device *device)
	{
		if (!device || isWatched(device)) {
			return;
		}
		m_watched.append(device);
		connect(device, &VenusOS::BaseDevice::serviceUidChanged, m_item, [this] { refresh(); });
		connect(device, &VenusOS::BaseDevice::serviceTypeChanged, m_item, [this] { refresh(); });
		connect(device, &VenusOS::BaseDevice::deviceInstanceChanged, m_item, [this] { refresh(); });
	}

	void unwatchDevice(VenusOS::Device *device)
	{
		if (!device) {
			return;
		}
		disconnect(device, nullptr, m_item, nullptr);
		for (int i = m_watched.count() - 1; i >= 0; --i) {
			if (m_watched.at(i) == device) {
				m_watched.removeAt(i);
			}
		}
	}

	void unwatchAll()
	{
		const QList<QPointer<VenusOS::Device>> watched = m_watched;
		for (const QPointer<VenusOS::Device> &device : watched) {
			if (device) {
				disconnect(device, nullptr, m_item, nullptr);
			}
		}
		m_watched.clear();
		m_device = nullptr;
		m_serviceUid.clear();
	}

	PluginDataItem *m_item = nullptr;
	QPointer<VenusOS::AllDevicesModel> m_model;
	QPointer<VenusOS::Device> m_device;
	QString m_serviceUid;
	QList<QPointer<VenusOS::Device>> m_watched;
	bool m_active = false;
};

PluginDataItem::PluginDataItem(QObject *parent)
	: QObject(parent)
	, m_item(new BackendItem(this))
{
	connect(m_item, &VeQuickItem::uidChanged, this, &PluginDataItem::uidChanged);
	connect(m_item, &VeQuickItem::valueChanged, this, &PluginDataItem::valueChanged);
	connect(m_item, &VeQuickItem::isValidChanged, this, &PluginDataItem::validChanged);
	connect(m_item, &VeQuickItem::minChanged, this, &PluginDataItem::minChanged);
	connect(m_item, &VeQuickItem::maxChanged, this, &PluginDataItem::maxChanged);
}

PluginDataItem::~PluginDataItem()
{
	delete m_watcher;
}

int PluginDataItem::deviceInstance() const
{
	return m_deviceInstance;
}

void PluginDataItem::setDeviceInstance(int deviceInstance)
{
	if (m_deviceInstance != deviceInstance) {
		m_deviceInstance = deviceInstance;
		emit deviceInstanceChanged();
		updateResolvedUid();
	}
}

QString PluginDataItem::uid() const
{
	return m_item->getUid();
}

void PluginDataItem::setUid(const QString &uid)
{
	m_item->setUid(uid);
}

QString PluginDataItem::serviceType() const
{
	return m_serviceType;
}

void PluginDataItem::setServiceType(const QString &serviceType)
{
	if (m_serviceType != serviceType) {
		m_serviceType = serviceType;
		emit serviceTypeChanged();
		updateResolvedUid();
	}
}

QString PluginDataItem::path() const
{
	return m_path;
}

void PluginDataItem::setPath(const QString &path)
{
	if (m_path != path) {
		m_path = path;
		emit pathChanged();
		updateResolvedUid();
	}
}

void PluginDataItem::updateResolvedUid()
{
	// An empty serviceType and path, and no device instance, means the plugin sets uid itself.
	if (m_serviceType.isEmpty() && m_path.isEmpty() && m_deviceInstance < 0) {
		if (m_watcher) {
			m_watcher->setActive(false);
		}
		return;
	}

	const bool watch = m_deviceInstance >= 0 && !m_serviceType.isEmpty();
	if (watch) {
		if (!m_watcher) {
			m_watcher = new DeviceWatcher(this);
		}
		m_watcher->setActive(true);
		m_watcher->refresh();
	} else if (m_watcher) {
		m_watcher->setActive(false);
	}
	applyResolvedUid();
}

void PluginDataItem::applyResolvedUid()
{
	if (m_serviceType.isEmpty() || m_path.isEmpty()) {
		m_item->setUid(QString());
		return;
	}
	if (m_deviceInstance < 0) {
		m_item->setUid(VenusOS::BackendConnection::create()->serviceUidForType(m_serviceType) + m_path);
		return;
	}
	const VenusOS::Device *device = m_watcher ? m_watcher->device() : nullptr;
	const QString serviceUid = device ? device->serviceUid() : QString();
	m_item->setUid(serviceUid.isEmpty() ? QString() : serviceUid + m_path);
}

QVariant PluginDataItem::value() const
{
	return m_item->getValue();
}

bool PluginDataItem::valid() const
{
	return m_item->getIsValid();
}

double PluginDataItem::min() const
{
	return m_item->systemLimit("min");
}

double PluginDataItem::max() const
{
	return m_item->systemLimit("max");
}

void PluginDataItem::setValue(const QVariant &value)
{
	m_item->setValue(value);
}

} // namespace GuiPlugins
} // namespace Victron

#include "plugindataitem.moc"
