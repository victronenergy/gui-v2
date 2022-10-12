#include <velib/qt/v_busitems.h>

#include "cmmanager.h"

const QString CmManager::State("State");
const QString CmManager::OfflineMode("OfflineMode");
const QString CmManager::SessionMode("SessionMode");

CmManager* CmManager::instance(QObject *parent)
{
	static CmManager *instance = new CmManager(parent);
	return instance;
}

CmManager::CmManager(QObject *parent) :
	QObject(parent),
	connected(false),
	mManager("net.connman", "/", VBusItems::getConnection()),
	mWatcher("net.connman", VBusItems::getConnection(),
			 QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration),
	mAgent(parent)
{
	registerConnmanDataTypes();

	QObject::connect(&mWatcher, SIGNAL(serviceRegistered(const QString&)),SLOT(connmanRegistered(const QString&)));
	QObject::connect(&mWatcher, SIGNAL(serviceUnregistered(const QString&)), SLOT(connmanUnregistered(const QString&)));

	if(mManager.isValid()) {
		if (getProperties()) connect();
	} else {
		QDBusError err = mManager.lastError ();
		qCritical() << "Connman connect error: " << err.message();
	}
}

CmManager::~CmManager()
{
	foreach (const CmTechnology *tech, mTechnologies)
		delete tech;
	foreach (const CmService *service, mServices)
		delete service;
}

void CmManager::connect()
{
	connected = true;

	QObject::connect(&mManager, SIGNAL(PropertyChanged(const QString&, const QDBusVariant&)),
					 SLOT(propertyChanged(const QString&, const QDBusVariant&)));

	if (getTechnologies())
		connectTechnologies();
	if (getServices())
		connectServices();
}

void CmManager::connectTechnologies()
{
	QObject::connect(&mManager, SIGNAL(TechnologyAdded(const QDBusObjectPath &, const QVariantMap &)),
					 SLOT(technologyAdded(const QDBusObjectPath &, const QVariantMap &)));
	QObject::connect(&mManager, SIGNAL(TechnologyRemoved(const QDBusObjectPath &)),
					 SLOT(technologyRemoved(const QDBusObjectPath &)));
}

void CmManager::connectServices()
{
	QObject::connect(&mManager, SIGNAL(ServicesChanged(ConnmanObjectList,QList<QDBusObjectPath>)),
					 SLOT(servicesChanged(ConnmanObjectList,QList<QDBusObjectPath>)));
}

void CmManager::disconnect()
{
	connected = false;

	foreach (CmTechnology *tech, mTechnologies) {
		mTechnologies.remove(tech->path());
		delete (tech);
	}
	emit technologyListChanged();
	disconnectTechnologies();

	mServicesOrderList.clear();
	foreach (CmService *service, mServices) {
		mServices.remove(service->path());
		emit serviceRemoved(service->path());
		delete (service);
	}
	emit serviceListChanged();
	disconnectServices();
}

void CmManager::disconnectTechnologies()
{
	QObject::disconnect(&mManager, SIGNAL(TechnologyAdded(const QDBusObjectPath &, const QVariantMap &)),
			this, SLOT(technologyAdded(const QDBusObjectPath &, const QVariantMap &)));
	QObject::disconnect(&mManager, SIGNAL(TechnologyRemoved(const QDBusObjectPath &)),
			this, SLOT(technologyRemoved(const QDBusObjectPath &)));
}

void CmManager::disconnectServices()
{
	QObject::disconnect(&mManager, SIGNAL(ServicesChanged(ConnmanObjectList,QList<QDBusObjectPath>)),
						this, SLOT(servicesChanged(ConnmanObjectList,QList<QDBusObjectPath>)));
}

bool CmManager::getProperties()
{
	QDBusPendingReply<QVariantMap> reply = mManager.GetProperties();
	reply.waitForFinished();
	if (reply.isValid()) {
		mProperties = reply.value();
		emit stateChanged();
		return true;
	}
	return false;
}

bool CmManager::getTechnologies()
{
	QDBusPendingReply<ConnmanObjectList> reply = mManager.GetTechnologies();
	reply.waitForFinished();
	if (reply.isValid()) {
		const ConnmanObjectList list = reply.value();
		foreach (const ConnmanObject &object, list)
			addTechnology(object.path.path(), object.properties);
		return true;
	}
	return false;
}

bool CmManager::getServices()
{
	QDBusPendingReply<ConnmanObjectList> reply = mManager.GetServices();
	reply.waitForFinished();
	if (reply.isValid()) {
		const ConnmanObjectList list = reply.value();
		foreach (const ConnmanObject &object, list)
			addService(object.path.path(), object.properties);
		return true;
	}
	return false;
}

void CmManager::addTechnology(const QString &path, const QVariantMap &properties)
{
	if (!mTechnologies.contains(path)) {
		CmTechnology *tech = new CmTechnology(path, properties, this);
		mTechnologies.insert(path, tech);
		emit technologyListChanged();
	}
}

void CmManager::addService(const QString &path, const QVariantMap &properties)
{
	if (!mServices.contains(path)) {
		CmService *service = new CmService(path, properties, this);
		mServices.insert(path, service);
	}
	mServicesOrderList.append(path);
}

const QStringList CmManager::getTechnologyList() const
{
	QStringList techList;
	foreach (const CmTechnology *tech, mTechnologies)
		techList << tech->type();
	return techList;
}

CmTechnology *CmManager::getTechnology(const QString& type) const
{
	foreach (const CmTechnology *tech, mTechnologies)
		if (tech->type() == type) return const_cast<CmTechnology *>(tech);
	return 0;
}

const QStringList CmManager::getServiceList() const
{
	return mServicesOrderList;
}

QStringList CmManager::getServiceList(const QString& type) const
{
	QStringList serviceList;
	const int size = mServicesOrderList.size();
	for (int i = 0; i < size; i++) {
		const QString &path = mServicesOrderList.at(i);
		const CmService *service = mServices.value(path);
		if (service->type() == type)
			serviceList << path;
	}
	return serviceList;
}

CmService *CmManager::getService(const QString &path) const
{
	return mServices[path];
}

const QString CmManager::getFavoriteService() const
{
	foreach (const CmService *service, mServices)
		if (service->favorite())
			return service->path();
	return QString();
}

CmAgent *CmManager::registerAgent(const QString &path)
{
	QDBusPendingReply<> reply = mManager.RegisterAgent(QDBusObjectPath(path));
	QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
	QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(dbusReply(QDBusPendingCallWatcher*)));
	mAgent.path(path);
	return &mAgent;
}

void CmManager::unRegisterAgent(const QString &path)
{
	QDBusPendingReply<> reply = mManager.UnRegisterAgent(QDBusObjectPath(path));
	QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
	QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(dbusReply(QDBusPendingCallWatcher*)));
	mAgent.path(path);
}

void CmManager::connmanRegistered(const QString& serviceName)
{
	Q_UNUSED(serviceName);
	connect();
}

void CmManager::connmanUnregistered(const QString& serviceName)
{
	Q_UNUSED(serviceName);
	disconnect();
}

void CmManager::propertyChanged(const QString &name, const QDBusVariant &value)
{
	QVariant var = value.variant();

	if (var.isValid()) {
		mProperties[name] = var;
		if (name == State) {
			emit stateChanged();
		}
	}
}

void CmManager::technologyAdded(const QDBusObjectPath &objectPath, const QVariantMap &properties)
{
	addTechnology(objectPath.path(), properties);
	emit technologyListChanged();
}

void CmManager::technologyRemoved(const QDBusObjectPath &objectPath)
{
	const QString path = objectPath.path();
	if (mTechnologies.contains(path)) {
		const CmTechnology * tech = mTechnologies.value(path);
		delete tech;
		mTechnologies.remove(path);
		emit technologyListChanged();
	}
}

void CmManager::servicesChanged(const ConnmanObjectList &changed, const QList<QDBusObjectPath> &removed)
{
	// Removed services
	foreach (const QDBusObjectPath &oPath, removed) {
		const QString &path = oPath.path();
		if (!mServices.contains(path)) {
			qCritical() << "service " << path << " was removed but was not found in the services list";
		} else {
			delete (mServices.value(path));
			mServices.remove(path);
		}
		emit serviceRemoved(path);
	}

	// Changed services
	mServicesOrderList.clear();
	foreach (const ConnmanObject &object, changed) {
		const QString &path = object.path.path();
		const QVariantMap &properties = object.properties;
		if (mServices.contains(path)) {
			mServicesOrderList.append(path);
			if (!properties.isEmpty())
				mServices.value(path)->serviceChanged(properties);
		} else {
			addService(path, properties);
			emit serviceAdded(path);
		}
	}
	emit serviceListChanged();
}

void CmManager::dbusReply(QDBusPendingCallWatcher *call)
{
	QDBusPendingReply<> reply = *call;
	if (reply.isError()) {
		QDBusError replyError = reply.error();
		qCritical() << "dbusReply:" << replyError.name() << replyError.message() << replyError.type();
	}
	call->deleteLater();
}
