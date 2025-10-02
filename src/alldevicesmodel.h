/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_ALLDEVICESMODEL_H
#define VICTRON_GUIV2_ALLDEVICESMODEL_H

#include <QPointer>
#include <QHash>
#include <QAbstractListModel>
#include <QQmlEngine>
#include <qqmlintegration.h>

#include <veutil/qt/ve_qitem.hpp>

#include "device.h"

namespace Victron {
namespace VenusOS {

/*
	A model of all device-type services that are available on the current backend.

	These are all of the services from AllServiceModel that represent devices, according to
	BaseDevice::isValid().
*/
class AllDevicesModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
	enum Role {
		DeviceRole = Qt::UserRole
	};
	Q_ENUM(Role)

	~AllDevicesModel();

	int count() const;

	QVariant data(const QModelIndex& index, int role) const override;
	int rowCount(const QModelIndex &parent) const override;

	Q_INVOKABLE int indexOf(const QString &uid) const;
	Q_INVOKABLE Device *findDevice(const QString &uid) const;  // Note: object has CppOwnership
	Q_INVOKABLE Device *deviceAt(int index) const; // Note: object has CppOwnership

	static AllDevicesModel* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void countChanged();

	// These Device* pointers are owned by the model and should not be deleted.
	void deviceAdded(Device *device);
	void deviceAboutToBeRemoved(Device *device);

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	explicit AllDevicesModel(QObject *parent);

	Device *newDeviceCandidate(VeQItem *item);
	void deviceValidChanged();
	void serviceAdded(VeQItem *item);
	void serviceAboutToBeRemoved(VeQItem *item);
	void servicesAboutToBeReset();
	void servicesReset();
	int indexOf(const QString &serviceType, int deviceInstance) const;
	void cleanUp();

	QHash<QString, Device *> m_allDeviceCandidates; // all known services, as device objects
	QList<Device *> m_devices; // all services that are known to be devices

};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_ALLDEVICESMODEL_H
