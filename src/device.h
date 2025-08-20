/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_DEVICE_H
#define VICTRON_GUIV2_DEVICE_H

#include "basedevice.h"

#include <QStringList>
#include <qqmlintegration.h>

#include <veutil/qt/ve_qitem.hpp>

namespace Victron {
namespace VenusOS {

/*
	Provides a Device with property values fetched from the current backend.
*/
class Device : public BaseDevice
{
	Q_OBJECT
	QML_ELEMENT
public:
	// Initializes a Device with the specified service item, and sets the device properties
	// according to the values from the item. The Device does not take ownership of the item.
	Device(QObject *parent, VeQItem *serviceItem);

	// Initializes a Device without a service; the service item will be set when serviceUid is set.
	explicit Device(QObject *parent = nullptr);

	// The service that defines the device. The pointer is owned by the backend producer.
	VeQItem *serviceItem() const;

private:
	void setServiceItem(VeQItem *serviceItem);
	void serviceChildAdded(VeQItem *child);
	void serviceChildAboutToBeRemoved(VeQItem *child);
	void refreshName();
	void initializeFromServiceUid();

	VeQItem *m_serviceItem = nullptr;
	VeQItem *m_customNameItem = nullptr;
	VeQItem *m_productNameItem = nullptr;
	int m_fluidType = -1;
};


} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_DEVICE_H
