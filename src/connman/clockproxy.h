/*
 * This file was generated by qdbusxml2cpp version 0.7
 * Command line was: qdbusxml2cpp -c ClockProxy connman-clock.xml -p clockproxy
 *
 * qdbusxml2cpp is Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
 *
 * This is an auto-generated file.
 * Do not edit! All changes made to it will be lost.
 */

#ifndef CLOCKPROXY_H_1307042690
#define CLOCKPROXY_H_1307042690

#include <QtCore/QObject>
#include <QtCore/QByteArray>
#include <QtCore/QList>
#include <QtCore/QMap>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>
#include <QtDBus/QtDBus>

/*
 * Proxy class for interface net.connman.Clock
 */
class ClockProxy: public QDBusAbstractInterface
{
	Q_OBJECT
public:
	static inline const char *staticInterfaceName()
	{ return "net.connman.Clock"; }

public:
	ClockProxy(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent = 0);

	~ClockProxy();

public Q_SLOTS: // METHODS
	inline QDBusPendingReply<QVariantMap> GetProperties()
	{
		QList<QVariant> argumentList;
		return asyncCallWithArgumentList(QLatin1String("GetProperties"), argumentList);
	}

	inline QDBusPendingReply<> SetProperty(const QString &in0, const QDBusVariant &in1)
	{
		QList<QVariant> argumentList;
        argumentList << QVariant::fromValue(in0) << QVariant::fromValue(in1);
		return asyncCallWithArgumentList(QLatin1String("SetProperty"), argumentList);
	}

Q_SIGNALS: // SIGNALS
	void PropertyChanged(const QString &in0, const QDBusVariant &in1);
};

namespace net {
	namespace connman {
		typedef ::ClockProxy Clock;
	}
}
#endif
