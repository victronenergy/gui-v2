#include <dbus_service.h>
#include <dbus_services.h>

void DBusServices::initialScan()
{
	connect(mQItemServices, SIGNAL(childAdded(VeQItem*)), SLOT(onServiceAdded(VeQItem*)));

	foreach (VeQItem *service, mQItemServices->itemChildren())
		onServiceAdded(service);
}

DBusService *DBusServices::get(const QString &name)
{
	for (DBusService *service : mServices)
		if (service->getName() == name)
			return service;

	return nullptr;
}

void DBusServices::onServiceAdded(VeQItem *serviceItem)
{
	DBusService *service;

	service = DBusService::createInstance(serviceItem);
	if (service == 0)
		return;
	service->setParent(this);
	connect(service, SIGNAL(serviceDestroyed()), SLOT(onServiceDestoyed()));
	connect(service, SIGNAL(initialized()), SLOT(onServiceInitialized()));
}

void DBusServices::onServiceDestoyed()
{
	DBusService *service = qobject_cast<DBusService *>(sender());

	for (auto it = mServices.begin(); it != mServices.end(); ) {
		if (*it == service) {
			int n = mVector.indexOf(service->item());
			remove(n);
			it = mServices.erase(it);
		} else {
			it++;
		}
	}
}

void DBusServices::onConnectedChanged(DBusService *service)
{
	if (service->getConnected())
		emit dbusServiceConnected(service);
	else
		emit dbusServiceDisconnected(service);
}

void DBusServices::onServiceInitialized()
{
	DBusService *service = static_cast<DBusService *>(sender());

	QString name = service->getName();
	mServices.insert(name, service);
	VeQItem *serviceItem = service->item();
	setupValueChanges(serviceItem);
	emit dbusServiceFound(service);
	onConnectedChanged(service);
}
