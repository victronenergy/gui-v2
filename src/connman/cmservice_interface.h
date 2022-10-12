#ifndef CMSERVICE_INTERFACE_H
#define CMSERVICE_INTERFACE_H

#include <QDBusAbstractInterface>
#include <QDBusPendingReply>

class CmServiceInterface : public QDBusAbstractInterface
{
	Q_OBJECT
public:
	static inline const char *staticInterfaceName()	{ return "net.connman.Service"; }
	CmServiceInterface(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent = 0);

public slots:
	inline QDBusPendingReply<> ClearProperty(const QString &name)
	{
		QList<QVariant> argumentList;
		argumentList << QVariant::fromValue(name);
		return asyncCallWithArgumentList(QLatin1String("ClearProperty"), argumentList);
	}

	inline QDBusPendingReply<> Connect()
	{
		QList<QVariant> argumentList;
		return asyncCallWithArgumentList(QLatin1String("Connect"), argumentList);
	}

	inline QDBusPendingReply<> Disconnect()
	{
		QList<QVariant> argumentList;
		return asyncCallWithArgumentList(QLatin1String("Disconnect"), argumentList);
	}

	inline QDBusPendingReply<> MoveAfter(const QDBusObjectPath &service)
	{
		QList<QVariant> argumentList;
		argumentList << QVariant::fromValue(service);
		return asyncCallWithArgumentList(QLatin1String("MoveAfter"), argumentList);
	}

	inline QDBusPendingReply<> MoveBefore(const QDBusObjectPath &service)
	{
		QList<QVariant> argumentList;
		argumentList << QVariant::fromValue(service);
		return asyncCallWithArgumentList(QLatin1String("MoveBefore"), argumentList);
	}

	inline QDBusPendingReply<> Remove()
	{
		QList<QVariant> argumentList;
		return asyncCallWithArgumentList(QLatin1String("Remove"), argumentList);
	}

	inline QDBusPendingReply<> ResetCounters()
	{
		QList<QVariant> argumentList;
		return asyncCallWithArgumentList(QLatin1String("ResetCounters"), argumentList);
	}

	inline QDBusPendingReply<> SetProperty(const QString &name, const QVariant &value)
	{
		return asyncCall("SetProperty", name, QVariant::fromValue(QDBusVariant(value)));
	}

signals:
	void PropertyChanged(const QString &name, const QDBusVariant &value);
};

#endif // CMSERVICE_INTERFACE_H
