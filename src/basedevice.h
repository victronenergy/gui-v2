/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_BASEDEVICE_H
#define VICTRON_GUIV2_BASEDEVICE_H

#include <QObject>
#include <qqmlintegration.h>

#include <functional>

namespace Victron {
namespace VenusOS {

/*
	Provides the essential properties for a device, without any default values.

	A device is defined by a service that provides device-type sub-paths like /DeviceInstance,
	/ProductName, and /ProductId.

	Each device is identified by the service's unique id, service type and device instance. For
	example, for a solarcharger device, the service uid may be:

	- D-Bus: dbus/com.victronenergy.solarcharger.ttyO1 (where ttyO1 is a system-provided suffix)
	- MQTT: mqtt/solarcharger/255 (where 255 is the device instance)
	- Mock: mock/com.victronenergy.solarcharger.mock_123 (where mock_123 is an arbitrary suffix)

	Here, the service type is "solarcharger". On MQTT, the device instance is encoded into the
	service uid, whereas on D-Bus and Mock, it is only accessible via the /DeviceInstance sub-path.

	Typically the uid, service type and device instance do not change during the application
	lifetime. However, when a service is disconnected and reconnected, the uid may have a different
	suffix on a D-Bus backend if it is reconnected using a different port.

	The isValid() method returns true if serviceUid and deviceInstance are set, as well as either
	productName() or customName().
*/
class BaseDevice : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(bool valid READ isValid NOTIFY validChanged)
	Q_PROPERTY(QString serviceUid READ serviceUid WRITE setServiceUid NOTIFY serviceUidChanged)
	Q_PROPERTY(QString serviceType READ serviceType NOTIFY serviceTypeChanged)
	Q_PROPERTY(int deviceInstance READ deviceInstance WRITE setDeviceInstance NOTIFY deviceInstanceChanged)
	Q_PROPERTY(int productId READ productId WRITE setProductId NOTIFY productIdChanged)
	Q_PROPERTY(QString productName READ productName WRITE setProductName NOTIFY productNameChanged)
	Q_PROPERTY(QString customName READ customName WRITE setCustomName NOTIFY customNameChanged)
	Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

public:
	explicit BaseDevice(QObject *parent = nullptr);

	bool isValid() const;
	QString serviceType() const;

	QString serviceUid() const;
	void setServiceUid(const QString &serviceUid);

	int deviceInstance() const;
	void setDeviceInstance(int deviceInstance);

	int productId() const;
	void setProductId(int productId);

	QString productName() const;
	void setProductName(const QString &productName);

	QString customName() const;
	void setCustomName(const QString &customName);

	QString name() const;
	void setName(const QString &name);

	static QString serviceTypeFromUid(const QString &uid);

Q_SIGNALS:
	void validChanged();
	void serviceUidChanged();
	void serviceTypeChanged();
	void deviceInstanceChanged();
	void productNameChanged();
	void customNameChanged();
	void productIdChanged();
	void nameChanged();

private:
	void maybeEmitValidChanged(const std::function<void()>& propertyChangeFunc);

	QString m_serviceUid;
	QString m_serviceType;
	QString m_name;
	QString m_productName;
	QString m_customName;
	int m_deviceInstance = -1;
	int m_productId = 0;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_BASEDEVICE_H
