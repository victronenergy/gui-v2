/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIPLUGINS_DEVICEWATCHER_H
#define VICTRON_GUIPLUGINS_DEVICEWATCHER_H

#include <QList>
#include <QObject>
#include <QPointer>
#include <QString>

namespace Victron {
namespace VenusOS {
class AllDevicesModel;
class Device;
}

namespace GuiPlugins {

/*
	Finds the device with a service type and a device instance, and keeps its service uid current.
	PluginDataItem and PluginDataPathModel use it to build a uid from serviceType and
	deviceInstance. It is not part of the plugin API.
*/
class DeviceWatcher : public QObject
{
	Q_OBJECT

public:
	explicit DeviceWatcher(QObject *parent = nullptr);
	~DeviceWatcher() override;

	void watch(const QString &serviceType, int deviceInstance);
	void stop();

	QString serviceUid() const;

Q_SIGNALS:
	void serviceUidChanged();

private:
	void setActive(bool active);
	void refresh();
	bool isWatched(VenusOS::Device *device) const;
	void watchDevice(VenusOS::Device *device);
	void unwatchDevice(VenusOS::Device *device);
	void unwatchAll();

	QPointer<VenusOS::AllDevicesModel> m_model;
	QPointer<VenusOS::Device> m_device;
	QList<QPointer<VenusOS::Device>> m_watched;
	QString m_serviceType;
	QString m_serviceUid;
	int m_deviceInstance = -1;
	bool m_active = false;
};

} // namespace GuiPlugins
} // namespace Victron

#endif // VICTRON_GUIPLUGINS_DEVICEWATCHER_H
