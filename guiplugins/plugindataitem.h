/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIPLUGINS_PLUGINDATAITEM_H
#define VICTRON_GUIPLUGINS_PLUGINDATAITEM_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <qqmlintegration.h>

namespace Victron {
namespace GuiPlugins {

/*
	A value on the Venus OS backend, for plugins. It holds a VeQuickItem and exposes only the
	members that plugins are promised, so that the rest of VeQuickItem's API (which belongs to the
	shared veutil code) can change without breaking plugins.

	Set either:
	- uid, to the full uid of the value, such as serviceUid + "/Dc/0/Voltage" on a
	  PluginDevicePage, or
	- serviceType and path, such as "settings" and "/Settings/Gui/DemoMode", for a service that
	  has a single instance (settings, system, platform, or the plugin's own service). The data
	  item then builds the uid for the backend in use (D-Bus, MQTT or mock), and uid returns it.

	min and max are the lowest and highest values that the system allows. Each is NaN when the
	system does not give it, so a minimum of 0 can be told apart from no minimum.

	Two data items with the same uid share one backend value, so a PluginDataItem and the internal
	row that shows the same uid do not subscribe twice.
*/
class PluginDataItem : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged FINAL)
	Q_PROPERTY(QString serviceType READ serviceType WRITE setServiceType NOTIFY serviceTypeChanged FINAL)
	Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
	Q_PROPERTY(QVariant value READ value NOTIFY valueChanged FINAL)
	Q_PROPERTY(bool valid READ valid NOTIFY validChanged FINAL)
	Q_PROPERTY(double min READ min NOTIFY minChanged FINAL)
	Q_PROPERTY(double max READ max NOTIFY maxChanged FINAL)

public:
	explicit PluginDataItem(QObject *parent = nullptr);

	QString uid() const;
	void setUid(const QString &uid);

	QString serviceType() const;
	void setServiceType(const QString &serviceType);

	QString path() const;
	void setPath(const QString &path);

	QVariant value() const;
	bool valid() const;
	double min() const;
	double max() const;

	// Writes the value to the backend.
	Q_INVOKABLE void setValue(const QVariant &value);

Q_SIGNALS:
	void uidChanged();
	void serviceTypeChanged();
	void pathChanged();
	void valueChanged();
	void validChanged();
	void minChanged();
	void maxChanged();

private:
	void updateUidFromServiceTypeAndPath();

	class BackendItem;
	BackendItem *m_item = nullptr;
	QString m_serviceType;
	QString m_path;
};

} // namespace GuiPlugins
} // namespace Victron

#endif // VICTRON_GUIPLUGINS_PLUGINDATAITEM_H
