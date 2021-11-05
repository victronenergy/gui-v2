#include <QDBusMessage>
#include <QDBusVariant>
#include <QtDebug>
#include <velib/qt/ve_qitem.hpp>
#include <velib/qt/ve_qitem_dbus_publisher.hpp>
#include "ve_qitem_dbus_virtual_object.hpp"

VeQItemDbusPublisher::VeQItemDbusPublisher(VeQItem *root, QObject *parent):
	QObject(parent),
	mRoot(root)
{
	connect(mRoot, SIGNAL(childAdded(VeQItem *)), this, SLOT(onChildAdded(VeQItem *)));
	connect(mRoot, SIGNAL(childAboutToBeRemoved(VeQItem *)), this, SLOT(onChildRemoved(VeQItem *)));
}

bool VeQItemDbusPublisher::open(const QString &address)
{
	mDbusAddress = address;
	addServices();
	return true;
}

void VeQItemDbusPublisher::onChildAdded(VeQItem *item)
{
	connect(item, SIGNAL(stateChanged(VeQItem *, State)),
			this, SLOT(onRootStateChanged(VeQItem *)));
	if (item->getState() != VeQItem::Offline && item->getState() != VeQItem::Idle)
		addChild(item);
}

void VeQItemDbusPublisher::onChildRemoved(VeQItem *item)
{
	disconnect(item);
	removeChild(item);
}

void VeQItemDbusPublisher::onRootStateChanged(VeQItem *item)
{
	if (item->getState() == VeQItem::Offline || item->getState() == VeQItem::Idle) {
		removeChild(item);
	} else {
		addChild(item);
	}
}

void VeQItemDbusPublisher::addServices()
{
	for (int i=0; ; ++i) {
		VeQItem *item = mRoot->itemChild(i);
		if (item == 0)
			break;
		onChildAdded(item);
	}
}

void VeQItemDbusPublisher::addChild(VeQItem *item)
{
	foreach (VeQItemDbusVirtualObject *service, mServices) {
		if (service->root() == item)
			return;
	}
	QDBusConnection connection = getConnection(mDbusAddress, item->id());
	if (!connection.isConnected()) {
		qDebug() << "[VeQItemDbusPublisher] Could not connect to D-Bus. Address:" << mDbusAddress
				 << "bus name:" << item->id();
	}
	VeQItemDbusVirtualObject *service = new VeQItemDbusVirtualObject(connection, item, this);
	mServices.append(service);
	if (service->registerService())
		qDebug() << "[VeQItemDbusPublisher] Registered service" << item->id();
	else
		qDebug() << "[VeQItemDbusPublisher] Could not register service" << item->id();
}

void VeQItemDbusPublisher::removeChild(VeQItem *item)
{
	foreach (VeQItemDbusVirtualObject *service, mServices) {
		if (service->root() == item) {
			mServices.removeOne(service);
			if (service->unregisterService())
				qDebug() << "[VeQItemDbusPublisher] Unregistered service" << item->id();
			else
				qDebug() << "[VeQItemDbusPublisher] Could not unregister service" << item->id();
			delete service;
			break;
		}
	}
}

QDBusConnection VeQItemDbusPublisher::getConnection(const QString &address,
													const QString &qtDbusName)
{
	// FIXME: find non blocking version, all signals / slots are stalled for
	// 30 secs or so if this fails when connection by tcp/ip...
	if (address == "session")
		return QDBusConnection::connectToBus(QDBusConnection::SessionBus, qtDbusName);
	if (address == "system")
		return QDBusConnection::connectToBus(QDBusConnection::SystemBus, qtDbusName);
	return QDBusConnection::connectToBus(address, qtDbusName);
}
