/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "plugindataitem.h"

#include "backendconnection.h"

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
public:
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
	, m_item(new BackendItem)
{
	m_item->setParent(this);
	connect(m_item, &VeQuickItem::uidChanged, this, &PluginDataItem::uidChanged);
	connect(m_item, &VeQuickItem::valueChanged, this, &PluginDataItem::valueChanged);
	connect(m_item, &VeQuickItem::isValidChanged, this, &PluginDataItem::validChanged);
	connect(m_item, &VeQuickItem::minChanged, this, &PluginDataItem::minChanged);
	connect(m_item, &VeQuickItem::maxChanged, this, &PluginDataItem::maxChanged);
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
		updateUidFromServiceTypeAndPath();
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
		updateUidFromServiceTypeAndPath();
	}
}

void PluginDataItem::updateUidFromServiceTypeAndPath()
{
	if (m_serviceType.isEmpty() && m_path.isEmpty()) {
		// The plugin sets uid itself, or no value is wanted.
		return;
	}
	if (m_serviceType.isEmpty() || m_path.isEmpty()) {
		// Wait until both are set.
		m_item->setUid(QString());
		return;
	}
	m_item->setUid(VenusOS::BackendConnection::create()->serviceUidForType(m_serviceType) + m_path);
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
