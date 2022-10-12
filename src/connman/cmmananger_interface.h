#ifndef CMMANANGER_INTERFACE_H
#define CMMANANGER_INTERFACE_H

#include <QDBusAbstractInterface>
#include <QDBusPendingReply>
#include "connmandbustypes.h"

class CmManangerInterface : public QDBusAbstractInterface
{
	Q_OBJECT
public:
	static inline const char *staticInterfaceName()	{ return "net.connman.Manager"; }
	CmManangerInterface(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent = 0);

public slots:
	inline QDBusPendingReply<QVariantMap> GetProperties()
	{
		return asyncCall("GetProperties");
	}

	inline QDBusPendingReply<ConnmanObjectList> GetTechnologies()
	{
		return asyncCall("GetTechnologies");
	}

	inline QDBusPendingReply<ConnmanObjectList> GetServices()
	{
		return asyncCall("GetServices");
	}

	inline QDBusPendingReply<> RegisterAgent(const QDBusObjectPath &path)
	{
		return asyncCall("RegisterAgent", QVariant::fromValue(path));
	}

	inline QDBusPendingReply<> UnRegisterAgent(const QDBusObjectPath &path)
	{
		return asyncCall("UnregisterAgent", QVariant::fromValue(path));
	}

	inline QDBusPendingReply<> RegisterCounter(const QDBusObjectPath &path, const quint32 accuracy, quint32 period)
	{
		return asyncCall("RegisterCounter", QVariant::fromValue(path), accuracy, period);
	}

	inline QDBusPendingReply<> UnregisterCounter(const QDBusObjectPath &path)
	{
		return asyncCall("UnregisterCounter", QVariant::fromValue(path));
	}

signals:
	void PropertyChanged(const QString &name, const QDBusVariant &value);
	void SavedServicesChanged(ConnmanObjectList changed);
	void ServicesChanged(ConnmanObjectList changed, const QList<QDBusObjectPath> &removed);
	void TechnologyAdded(const QDBusObjectPath &technology, const QVariantMap &properties);
	void TechnologyRemoved(const QDBusObjectPath &technology);
};

#endif // CMMANANGER_INTERFACE_H
