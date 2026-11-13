/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "plugindataitem.h"

#include "backendconnection.h"
#include "devicewatcher.h"

#include <veutil/qt/ve_quick_item.hpp>

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
			m_watcher->stop();
		}
		return;
	}

	if (m_deviceInstance >= 0 && !m_serviceType.isEmpty()) {
		if (!m_watcher) {
			m_watcher = new DeviceWatcher(this);
			connect(m_watcher, &DeviceWatcher::serviceUidChanged, this, &PluginDataItem::applyResolvedUid);
		}
		m_watcher->watch(m_serviceType, m_deviceInstance);
	} else if (m_watcher) {
		m_watcher->stop();
	}
	applyResolvedUid();
}

void PluginDataItem::applyResolvedUid()
{
	if (m_serviceType.isEmpty() || m_path.isEmpty()) {
		m_item->setUid(QString());
		return;
	}
	QString serviceUid;
	if (m_deviceInstance < 0) {
		serviceUid = VenusOS::BackendConnection::create()->serviceUidForType(m_serviceType);
	} else {
		serviceUid = m_watcher ? m_watcher->serviceUid() : QString();
	}
	if (serviceUid.isEmpty()) {
		m_item->setUid(QString());
		return;
	}
	const QString relativePath = m_path.startsWith('/') ? m_path.mid(1) : m_path;
	m_item->setUid(relativePath.isEmpty() ? serviceUid : serviceUid + '/' + relativePath);
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
