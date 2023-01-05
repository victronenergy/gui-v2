#include <veutil/qt/ve_dbus_connection.hpp>
#include <QtNetwork/QHostAddress>

#include "cmservice.h"

const QString CmService::State("State");
const QString CmService::Error("Error");
const QString CmService::Name("Name");
const QString CmService::Type("Type");
const QString CmService::Security("Security");
const QString CmService::Strength("Strength");
const QString CmService::Favorite("Favorite");
const QString CmService::Immutable("Immutable");
const QString CmService::AutoConnect("AutoConnect");
const QString CmService::Roaming("Roaming");
const QString CmService::Nameservers("Nameservers");
const QString CmService::NameserversConfig("Nameservers.Configuration");
const QString CmService::Timeservers("Timeservers");
const QString CmService::TimeserversConfig("Timeservers.Configuration");
const QString CmService::Domains("Domains");
const QString CmService::DomainsConfig("Domains.Configuration");
const QString CmService::IPv4("IPv4");
const QString CmService::IPv4Config("IPv4.Configuration");
const QString CmService::IPv6("IPv6");
const QString CmService::IPv6Config("IPv6.Configuration");
const QString CmService::Proxy("Proxy");
const QString CmService::ProxyConfig("Proxy.Configuration");
const QString CmService::Provider("Provider");
const QString CmService::Ethernet("Ethernet");

CmService::CmService(QObject *parent) :
	QObject(parent),
	connected(false),
	mService("net.connman", "/", VeDbusConnection::getConnection())
{
}

CmService::CmService(const QString& path, const QVariantMap& properties, QObject *parent) :
	QObject(parent),
	connected(false),
	mService("net.connman", path, VeDbusConnection::getConnection())
{
	mPath = path;
	mProperties = properties;
	QObject::connect(&mService, SIGNAL(PropertyChanged(const QString&, const QDBusVariant&)),
			SLOT(propertyChanged(const QString&, const QDBusVariant&)));
}

void CmService::autoConnect(const bool autoConnect)
{
	mService.SetProperty(AutoConnect, QVariant(autoConnect));
}

void CmService::nameserversConfig(const QStringList &config)
{
	mService.SetProperty(NameserversConfig, QVariant(config));
}

void CmService::timeserversConfig(const QStringList &config)
{
	mService.SetProperty(TimeserversConfig, QVariant(config));
}

void CmService::domainsConfig(const QStringList &config)
{
	mService.SetProperty(DomainsConfig, QVariant(config));
}

void CmService::ipv4Config(const QVariantMap &config)
{
	QDBusPendingReply<> reply = mService.SetProperty(IPv4Config, QVariant(config));
	QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
	QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(dbusReply(QDBusPendingCallWatcher*)));
}

void CmService::ipv6Config(const QVariantMap &config)
{
	mService.SetProperty(IPv6Config, QVariant(config));
}

void CmService::proxyConfig(const QVariantMap &config)
{
	mService.SetProperty(ProxyConfig, QVariant(config));
}

void CmService::connect()
{
	QDBusPendingReply<> reply = mService.Connect();
	QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
	QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(dbusReply(QDBusPendingCallWatcher*)));
}

void CmService::disconnect()
{
	mService.Disconnect();
}

void CmService::remove()
{
	mService.Remove();
}

QString CmService::formatIpAddress(const QString ipAddress)
{
	QString newAddress;
	QStringList bytes = ipAddress.split('.');
	if (bytes.size() != 4)
		return "000.000.000.000";

	newAddress.append(QString("%1").arg(bytes.at(0).toInt(), 3, 10, QChar('0')));
	newAddress.append('.');
	newAddress.append(QString("%1").arg(bytes.at(1).toInt(), 3, 10, QChar('0')));
	newAddress.append('.');
	newAddress.append(QString("%1").arg(bytes.at(2).toInt(), 3, 10, QChar('0')));
	newAddress.append('.');
	newAddress.append(QString("%1").arg(bytes.at(3).toInt(), 3, 10, QChar('0')));
	return newAddress;
}

QString CmService::checkIpAddress(const QString ipAddress)
{
	QHostAddress addr;
	if (addr.setAddress(ipAddress))
		return addr.toString();
	else
		return QString();
}

void CmService::updateProperty(const QString &name, const QVariant &value)
{
	if (!value.isValid())
		return;
	if (mProperties.value(name) == value)
		return;

	mProperties[name] = value;

	if (name == State)
		emit stateChanged();
	else if (name == Error)
		emit errorChanged();
	else if (name == Name)
		emit nameChanged();
	else if (name == Type)
		emit typeChanged();
	else if (name == Security)
		emit securityChanged();
	else if (name == Strength)
		emit strengthChanged();
	else if (name == Favorite)
		emit favoriteChanged();
	else if (name == Immutable)
		emit immutableChanged();
	else if (name == AutoConnect)
		emit autoConnectChanged();
	else if (name == Roaming)
		emit roamingChanged();
	else if (name == Nameservers)
		emit nameserversChanged();
	else if (name == NameserversConfig)
		emit nameserversConfigChanged();
	else if (name == Timeservers)
		emit timeserversChanged();
	else if (name == TimeserversConfig)
		emit timeserversConfigChanged();
	else if (name == Domains)
		emit domainsChanged();
	else if (name == DomainsConfig)
		emit domainsConfigChanged();
	else if (name == IPv4)
		emit ipv4Changed();
	else if (name == IPv4Config)
		emit ipv4ConfigChanged();
	else if (name == IPv6)
		emit ipv6Changed();
	else if (name == IPv6Config)
		emit ipv6ConfigChanged();
	else if (name == Proxy)
		emit proxyChanged();
	else if (name == ProxyConfig)
		emit proxyConfigChanged();
	else if (name == Provider)
		emit providerChanged();
	else if (name == Ethernet)
		emit ethernetChanged();
}

void CmService::serviceChanged(const QVariantMap &properties)
{
	QVariantMap::const_iterator i = properties.constBegin();
	QVariantMap::const_iterator end = properties.constEnd();
	for ( ; i != end; ++i)
		updateProperty(i.key(), i.value());
}

void CmService::propertyChanged(const QString &name, const QDBusVariant &value)
{
	const QVariant val(value.variant());
	updateProperty(name, val);
}

void CmService::dbusReply(QDBusPendingCallWatcher *call)
{
	QDBusPendingReply<> reply = *call;
	if (reply.isError()) {
		QDBusError replyError = reply.error();
		if (replyError.name().contains("net.connman.Error.InvalidArguments")) {
			emit propertyChangeFailed();
			emit error(replyError.message());
		}
	}
	call->deleteLater();
}
