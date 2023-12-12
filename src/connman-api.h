/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef CONNMAN_MOCK_API
#define CONNMAN_MOCK_API

#include <QObject>
#include <QStringList>
#include <QVariantMap>
#include <qqmlintegration.h>

// These are dummy classes that mimic the QML APIs provided by src/connman, so that the API is
// available even when the connman backend is not.

class QQmlEngine;
class QJSEngine;

class CmAgent : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString path MEMBER m_path CONSTANT)
	Q_PROPERTY(QString passphrase MEMBER m_passphrase CONSTANT)

private:
	QString m_path;
	QString m_passphrase;
};

class CmService : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString state MEMBER m_state CONSTANT)
	Q_PROPERTY(QString error MEMBER m_error CONSTANT)
	Q_PROPERTY(QVariant name MEMBER m_name CONSTANT)
	Q_PROPERTY(QString type MEMBER m_type CONSTANT)
	Q_PROPERTY(QStringList security MEMBER m_security CONSTANT)
	Q_PROPERTY(uint strength MEMBER m_strength CONSTANT)
	Q_PROPERTY(bool favorite MEMBER m_favorite CONSTANT)
	Q_PROPERTY(bool immutable MEMBER m_immutable CONSTANT)
	Q_PROPERTY(bool autoConnect MEMBER m_autoConnect CONSTANT)
	Q_PROPERTY(bool roaming MEMBER m_roaming CONSTANT)
	Q_PROPERTY(QStringList nameservers MEMBER m_nameservers CONSTANT)
	Q_PROPERTY(QStringList nameserversConfig MEMBER m_nameserversConfig CONSTANT)
	Q_PROPERTY(QStringList timeservers MEMBER m_timeservers CONSTANT)
	Q_PROPERTY(QStringList timeserversConfig MEMBER m_timeserversConfig CONSTANT)
	Q_PROPERTY(QStringList domains MEMBER m_domains CONSTANT)
	Q_PROPERTY(QStringList domainsConfig MEMBER m_domainsConfig CONSTANT)
	Q_PROPERTY(QVariantMap ipv4 MEMBER m_ipv4 CONSTANT)
	Q_PROPERTY(QVariantMap ipv4Config MEMBER m_ipv4Config CONSTANT)
	Q_PROPERTY(QVariantMap ipv6 MEMBER m_ipv6 CONSTANT)
	Q_PROPERTY(QVariantMap ipv6Config MEMBER m_ipv6Config CONSTANT)
	Q_PROPERTY(QVariantMap proxy MEMBER m_proxy CONSTANT)
	Q_PROPERTY(QVariantMap proxyConfig MEMBER m_proxyConfig CONSTANT)
	Q_PROPERTY(QVariantMap provider MEMBER m_provider CONSTANT)
	Q_PROPERTY(QVariantMap ethernet MEMBER m_ethernet CONSTANT)

public:
	Q_INVOKABLE void connect() {}
	Q_INVOKABLE void disconnect() {}
	Q_INVOKABLE void remove() {}
	Q_INVOKABLE void moveBefore() {}
	Q_INVOKABLE void moveAfter() {}
	Q_INVOKABLE void resetCounters() {}
	Q_INVOKABLE QString formatIpAddress(const QString &) { return QString(); }
	Q_INVOKABLE QString checkIpAddress(const QString &) { return QString(); }

private:
	QString m_state;
	QString m_error;
	QVariant m_name;
	QString m_type;
	QStringList m_security;
	uint m_strength = 0;
	bool m_favorite = false;
	bool m_immutable = false;
	bool m_autoConnect = false;
	bool m_roaming = false;
	QStringList m_nameservers;
	QStringList m_nameserversConfig;
	QStringList m_timeservers;
	QStringList m_timeserversConfig;
	QStringList m_domains;
	QStringList m_domainsConfig;
	QVariantMap m_ipv4;
	QVariantMap m_ipv4Config;
	QVariantMap m_ipv6;
	QVariantMap m_ipv6Config;
	QVariantMap m_proxy;
	QVariantMap m_proxyConfig;
	QVariantMap m_provider;
	QVariantMap m_ethernet;
};

class CmTechnology : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString name MEMBER m_name CONSTANT)
	Q_PROPERTY(QString type MEMBER m_type CONSTANT)
	Q_PROPERTY(bool connected MEMBER m_connected CONSTANT)
	Q_PROPERTY(bool powered MEMBER m_powered CONSTANT)
	Q_PROPERTY(bool tethering MEMBER m_tethering CONSTANT)

public:
	Q_INVOKABLE void scan() {}

private:
	QString m_name;
	QString m_type;
	bool m_connected = false;
	bool m_powered = false;
	bool m_tethering = false;
};

class CmManager : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(QString state MEMBER m_state CONSTANT)
	Q_PROPERTY(QStringList technologyList MEMBER m_technologyList CONSTANT)
	Q_PROPERTY(QStringList serviceList MEMBER m_serviceList CONSTANT)

public:
	static CmManager* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr) {
		static CmManager *obj = nullptr;
		if (obj == nullptr) {
			obj = new CmManager(nullptr);
		}
		return obj;
	}

	CmManager(QObject* parent)
		: QObject(parent)
	{
	}

	Q_INVOKABLE CmTechnology* getTechnology(const QString &) const { return nullptr; }
	Q_INVOKABLE QStringList getServiceList(const QString &) const { return QStringList(); }
	Q_INVOKABLE CmService* getService(const QString &) const { return nullptr; }
	Q_INVOKABLE CmAgent* registerAgent(const QString &) { return nullptr; }
	Q_INVOKABLE void unRegisterAgent(const QString &) { }

private:
	QString m_state;
	QStringList m_technologyList;
	QStringList m_serviceList;
};

#endif
