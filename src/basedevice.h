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

class BaseDevice : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(bool valid READ isValid NOTIFY validChanged)
	Q_PROPERTY(QString serviceUid READ serviceUid WRITE setServiceUid NOTIFY serviceUidChanged)
	Q_PROPERTY(int deviceInstance READ deviceInstance WRITE setDeviceInstance NOTIFY deviceInstanceChanged)
	Q_PROPERTY(int productId READ productId WRITE setProductId NOTIFY productIdChanged)
	Q_PROPERTY(QString productName READ productName WRITE setProductName NOTIFY productNameChanged)
	Q_PROPERTY(QString customName READ customName WRITE setCustomName NOTIFY customNameChanged)
	Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

public:
	explicit BaseDevice(QObject *parent = nullptr);

	bool isValid() const;

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

Q_SIGNALS:
	void validChanged();
	void serviceUidChanged();
	void deviceInstanceChanged();
	void productNameChanged();
	void customNameChanged();
	void productIdChanged();
	void nameChanged();

private:
	void maybeEmitValidChanged(const std::function<void()>& propertyChangeFunc);

	QString m_serviceUid;
	QString m_name;
	QString m_productName;
	QString m_customName;
	int m_deviceInstance = -1;
	int m_productId = 0;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_BASEDEVICE_H
