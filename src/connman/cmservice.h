#ifndef CMSERVICE_H
#define CMSERVICE_H

#include <QObject>
#include "cmservice_interface.h"

class CmService : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString state READ state NOTIFY stateChanged)
	Q_PROPERTY(QString error READ error NOTIFY errorChanged)
	Q_PROPERTY(QVariant name READ name NOTIFY nameChanged)
	Q_PROPERTY(QString type READ type NOTIFY typeChanged)
	Q_PROPERTY(QStringList security READ security NOTIFY securityChanged)
	Q_PROPERTY(uint strength READ strength NOTIFY strengthChanged)
	Q_PROPERTY(bool favorite READ favorite NOTIFY favoriteChanged)
	Q_PROPERTY(bool immutable READ immutable NOTIFY immutableChanged)
	Q_PROPERTY(bool autoConnect READ autoConnect WRITE autoConnect NOTIFY autoConnectChanged)
	Q_PROPERTY(bool roaming READ roaming NOTIFY roamingChanged)
	Q_PROPERTY(QStringList nameservers READ nameservers NOTIFY nameserversChanged)
	Q_PROPERTY(QStringList nameserversConfig READ nameserversConfig WRITE nameserversConfig NOTIFY nameserversConfigChanged)
	Q_PROPERTY(QStringList timeservers READ timeservers NOTIFY timeserversChanged)
	Q_PROPERTY(QStringList timeserversConfig READ timeserversConfig WRITE timeserversConfig NOTIFY timeserversConfigChanged)
	Q_PROPERTY(QStringList domains READ domains NOTIFY domainsChanged)
	Q_PROPERTY(QStringList domainsConfig READ domainsConfig WRITE domainsConfig NOTIFY domainsConfigChanged)
	Q_PROPERTY(QVariantMap ipv4 READ ipv4 NOTIFY ipv4Changed)
	Q_PROPERTY(QVariantMap ipv4Config READ ipv4Config WRITE ipv4Config NOTIFY ipv4ConfigChanged)
	Q_PROPERTY(QVariantMap ipv6 READ ipv6 NOTIFY ipv6Changed)
	Q_PROPERTY(QVariantMap ipv6Config READ ipv6Config WRITE ipv6Config NOTIFY ipv6ConfigChanged)
	Q_PROPERTY(QVariantMap proxy READ proxy NOTIFY proxyChanged)
	Q_PROPERTY(QVariantMap proxyConfig READ proxyConfig WRITE proxyConfig NOTIFY proxyConfigChanged)
	Q_PROPERTY(QVariantMap provider READ provider NOTIFY providerChanged)
	Q_PROPERTY(QVariantMap ethernet READ ethernet NOTIFY ethernetChanged)

public:
	CmService(QObject *parent = 0);
	CmService(const QString& path, const QVariantMap& properties, QObject *parent = 0);

	Q_INVOKABLE void connect();
	Q_INVOKABLE void disconnect();
	Q_INVOKABLE void remove();
	Q_INVOKABLE void moveBefore() {;}
	Q_INVOKABLE void moveAfter() {;}
	Q_INVOKABLE void resetCounters() {;}
	Q_INVOKABLE QString formatIpAddress(const QString ipAddress);
	Q_INVOKABLE QString checkIpAddress(const QString ipAddress);

	const QString path() const { return mPath; }

	const QString state() const { return mProperties[State].toString(); }
	const QString error() const { return mProperties[Error].toString(); }
	const QVariant name() const { return mProperties[Name]; }
	const QString type() const { return mProperties[Type].toString(); }
	const QStringList security() const { return mProperties[Security].toStringList(); }
	uint strength() const { return mProperties[Strength].toUInt(); }
	bool favorite() const { return mProperties[Favorite].toBool(); }
	bool immutable() const { return mProperties[Immutable].toBool(); }
	bool autoConnect() const { return mProperties[AutoConnect].toBool(); }
	void autoConnect(const bool autoConnect);
	bool roaming() const { return mProperties[Roaming].toBool(); }
	const QStringList nameservers() const { return mProperties[Nameservers].toStringList(); }
	const QStringList nameserversConfig() const { return mProperties[NameserversConfig].toStringList(); }
	void nameserversConfig(const QStringList &config);
	const QStringList timeservers() const { return mProperties[Timeservers].toStringList(); }
	const QStringList timeserversConfig() const { return mProperties[TimeserversConfig].toStringList(); }
	void timeserversConfig(const QStringList &config);
	const QStringList domains() const { return mProperties[Domains].toStringList(); }
	const QStringList domainsConfig() const { return mProperties[DomainsConfig].toStringList(); }
	void domainsConfig(const QStringList &config);
	const QVariantMap ipv4() const { return qdbus_cast<QVariantMap>(mProperties.value(IPv4)); }
	const QVariantMap ipv4Config() const { return qdbus_cast<QVariantMap>(mProperties.value(IPv4Config)); }
	void ipv4Config(const QVariantMap &config);
	const QVariantMap ipv6() const { return qdbus_cast<QVariantMap>(mProperties.value(IPv6)); }
	const QVariantMap ipv6Config() const { return qdbus_cast<QVariantMap>(mProperties.value(IPv6Config)); }
	void ipv6Config(const QVariantMap &config);
	const QVariantMap proxy() const { return qdbus_cast<QVariantMap>(mProperties.value(Proxy)); }
	const QVariantMap proxyConfig() const { return qdbus_cast<QVariantMap>(mProperties.value(ProxyConfig)); }
	void proxyConfig(const QVariantMap &config);
	const QVariantMap provider() const { return qdbus_cast<QVariantMap>(mProperties.value(Provider)); }
	const QVariantMap ethernet() const { return qdbus_cast<QVariantMap>(mProperties.value(Ethernet)); }

public slots:
	void serviceChanged(const QVariantMap &properties);

signals:
	void stateChanged();
	void errorChanged();
	void nameChanged();
	void typeChanged();
	void securityChanged();
	void strengthChanged();
	void favoriteChanged();
	void immutableChanged();
	void autoConnectChanged();
	void roamingChanged();
	void nameserversChanged();
	void nameserversConfigChanged();
	void timeserversChanged();
	void timeserversConfigChanged();
	void domainsChanged();
	void domainsConfigChanged();
	void ipv4Changed();
	void ipv4ConfigChanged();
	void ipv6Changed();
	void ipv6ConfigChanged();
	void proxyChanged();
	void proxyConfigChanged();
	void providerChanged();
	void ethernetChanged();
	void error(const QString &message);
	void propertyChangeFailed();

private slots:
	void propertyChanged(const QString &name, const QDBusVariant &value);
	void dbusReply(QDBusPendingCallWatcher *call);

private:
	void updateProperty(const QString &name, const QVariant &properties);

	static const QString State;
	static const QString Error;
	static const QString Name;
	static const QString Type;
	static const QString Security;
	static const QString Strength;
	static const QString Favorite;
	static const QString Immutable;
	static const QString AutoConnect;
	static const QString Roaming;
	static const QString Nameservers;
	static const QString NameserversConfig;
	static const QString Timeservers;
	static const QString TimeserversConfig;
	static const QString Domains;
	static const QString DomainsConfig;
	static const QString IPv4;
	static const QString IPv4Config;
	static const QString IPv6;
	static const QString IPv6Config;
	static const QString Proxy;
	static const QString ProxyConfig;
	static const QString Provider;
	static const QString Ethernet;

	bool connected;
	QString mPath;
	QVariantMap mProperties;
	CmServiceInterface mService;
};

#endif // CMSERVICE_H
