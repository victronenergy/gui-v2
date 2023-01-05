#include <QDebug>

#include <veutil/qt/ve_dbus_connection.hpp>
#include "cmagent.h"

CmAgent::CmAgent(QObject *parent) :
	QObject(parent),
	mAgent(this)
{
}

CmAgent::CmAgent(const QString &objectPath, QObject *parent) :
	QObject(parent),
	mAgent(this)
{
	path(objectPath);
}

CmAgent::~CmAgent()
{
	if (!mPath.isEmpty())
		VeDbusConnection::getConnection().unregisterObject(mPath);
}

void CmAgent::path(const QString &objectPath)
{
	mPath = objectPath;
	VeDbusConnection::getConnection().registerObject(objectPath,this);
}

void CmAgent::release()
{
}

void CmAgent::reportError(const QDBusObjectPath &path, const QString &error)
{
	qCritical() << "[CmAgent] Report error" << path.path() << error;
}

void CmAgent::requestBrowser(const QDBusObjectPath &path, const QString &url)
{
	qCritical() << "[CmAgent] Request Browser" << path.path() << url;
}

QVariantMap CmAgent::requestInput(const QDBusObjectPath &path, const QVariantMap &fields)
{
	Q_UNUSED(fields);
	Q_UNUSED(path);
	QVariantMap map;

	map.insert("Passphrase", QVariant(mPassPhrase));
	return map;
}

void CmAgent::cancel()
{
}
