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

	Set one of:
	- serviceType and path, such as "settings" and "/Settings/Gui/DemoMode", for a service with
	  one instance (settings, system, platform, or the plugin's own service). Leave deviceInstance
	  unset. The uid is then BackendConnection::serviceUidForType(serviceType) + path.
	- serviceType, deviceInstance and path, for one device, such as "battery", 1 and
	  "/Dc/0/Voltage". 0 is a real instance. The service uid cannot be built from the type and
	  instance: on D-Bus and mock it has a suffix, and on MQTT the instance is part of the uid.
	  AllDevicesModel already has the real service uid, so the data item watches that model and
	  uses the matching device's serviceUid + path. uid stays empty until the device is there,
	  and updates when that device appears, disappears or its service uid changes. If two devices
	  have the same type and instance, the first one is used.
	- uid, the full uid, such as serviceUid + "/Dc/0/Voltage" on a PluginDevicePage.

	min and max are the lowest and highest values that the system allows. Each is NaN when the
	system does not give it, so a minimum of 0 can be told apart from no minimum.

	Two data items with the same uid share one backend value, so a PluginDataItem and the internal
	list item that shows the same uid do not subscribe twice.
*/
class PluginDataItem : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int deviceInstance READ deviceInstance WRITE setDeviceInstance NOTIFY deviceInstanceChanged FINAL)
	Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged FINAL)
	Q_PROPERTY(QString serviceType READ serviceType WRITE setServiceType NOTIFY serviceTypeChanged FINAL)
	Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
	Q_PROPERTY(QVariant value READ value NOTIFY valueChanged FINAL)
	Q_PROPERTY(bool valid READ valid NOTIFY validChanged FINAL)
	Q_PROPERTY(double min READ min NOTIFY minChanged FINAL)
	Q_PROPERTY(double max READ max NOTIFY maxChanged FINAL)

public:
	explicit PluginDataItem(QObject *parent = nullptr);
	~PluginDataItem() override;

	int deviceInstance() const;
	void setDeviceInstance(int deviceInstance);

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
	void deviceInstanceChanged();
	void uidChanged();
	void serviceTypeChanged();
	void pathChanged();
	void valueChanged();
	void validChanged();
	void minChanged();
	void maxChanged();

private:
	class DeviceWatcher;

	void updateResolvedUid();
	void applyResolvedUid();

	class BackendItem;
	BackendItem *m_item = nullptr;
	DeviceWatcher *m_watcher = nullptr;
	QString m_serviceType;
	QString m_path;
	int m_deviceInstance = -1;
};

} // namespace GuiPlugins
} // namespace Victron

#endif // VICTRON_GUIPLUGINS_PLUGINDATAITEM_H
