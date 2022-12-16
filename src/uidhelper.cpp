#include "uidhelper.h"

namespace Victron {

namespace VenusOS {

UidHelper::UidHelper(QObject *parent)
	: QObject(parent)
{
}

QHash<QString, QString> UidHelper::serviceNamesToPaths() const
{
	return m_serviceNamesToPaths;
}

void UidHelper::setServiceNamesToPaths(const QHash<QString, QString> &hash)
{
	if (m_serviceNamesToPaths != hash) {
		m_serviceNamesToPaths = hash;
		emit serviceNamesToPathsChanged();
	}
}

void UidHelper::onMessageReceived(const QString &path, const QVariant &message)
{
	static const QString serviceNameSuffix(QStringLiteral("/ServiceName"));
	if (path.endsWith(serviceNameSuffix)) {
		const QString serviceName = message.toString();
		m_pathToServiceName.insert(path, serviceName);
		const QString devicePath = path.mid(0, path.length() - (serviceNameSuffix.length()-1));
		m_serviceNamesToPaths.insert(serviceName, devicePath);
		Q_EMIT pathForServiceNameChanged(serviceName, devicePath);
	}
}

void UidHelper::onNullMessageReceived(const QString &path)
{
	if (m_pathToServiceName.contains(path)) {
		const QString serviceName = m_pathToServiceName.value(path);
		m_pathToServiceName.remove(path);
		m_serviceNamesToPaths.remove(serviceName);
		Q_EMIT pathForServiceNameChanged(serviceName, QString());
	}
}

QString UidHelper::pathForServiceName(const QString &serviceName) const
{
	return m_serviceNamesToPaths.value(serviceName);
}

UidHelper* UidHelper::instance(QQmlEngine *, QJSEngine *)
{
	// only construct one.  the QML engine will take ownership of it.
	static QPointer<UidHelper> ret(new UidHelper);
	return qobject_cast<UidHelper *>(ret.data());
}

//--

SingleUidHelper::SingleUidHelper(QObject *parent)
	: QObject(parent)
	, m_uidHelper(UidHelper::instance())
{
	if (m_uidHelper.data()) {
		connect(m_uidHelper.data(), &UidHelper::pathForServiceNameChanged,
				this, &SingleUidHelper::onPathForServiceNameChanged);
	}
}

void SingleUidHelper::setDBusUid(const QString &uid)
{
	if (uid.isEmpty()) {
		m_dbusUid = uid;
		m_mqttUid.clear();
		Q_EMIT mqttUidChanged();
		Q_EMIT dbusUidChanged();
		return;
	}

	// the dbus uid will be of the form:
	// "dbus/<service>/<path>"
	// whereas the mqtt uid will be of the form:
	// "mqtt/<service>/<deviceInstance>/<path>"
	if (m_dbusUid != uid) {
		m_dbusUid = uid;

		// calculate the MQTT device path based on the service name
		const QStringList parts = m_dbusUid.split('/');
		if (parts.length() < 2) {
			qWarning() << "Malformed DBus uid, no service name:" << uid;
			Q_EMIT dbusUidChanged();
			return;
		}

		const QString prefix = QStringLiteral("%1/%2").arg(parts[0], parts[1]);
		m_remainderPath = uid.mid(prefix.length() + 1);
		m_serviceName = parts[1];
		m_mqttDevicePath = m_uidHelper.data()->pathForServiceName(m_serviceName);
		if (m_mqttDevicePath.endsWith(QChar('/'))) {
			m_mqttDevicePath.chop(1);
		}
		if (m_mqttDevicePath.isEmpty() || m_mqttDevicePath.startsWith(QStringLiteral("modbustcp"))) {
			// try to guess it.  we will receive a signal from the provider, later.
			const QStringList dotParts = parts[1].split('.');
			if (dotParts.size() == 3) {
				// the guess should succeed, as it's of the form com.victronenergy.xyz
				// rather than of the form com.victronenergy.xyz.abc
				m_mqttDevicePath = QStringLiteral("%1/0").arg(dotParts[2]);
			}
		}
		if (!m_mqttDevicePath.isEmpty()) {
			// we are able to construct an MQTT uid that we're confident is correct.
			m_mqttUid = QStringLiteral("%1/%2/%3").arg(QStringLiteral("mqtt"), m_mqttDevicePath, m_remainderPath);
			Q_EMIT dbusUidChanged();
			Q_EMIT mqttUidChanged();
		} else {
			Q_EMIT dbusUidChanged();
		}
	}
}

QString SingleUidHelper::dbusUid() const
{
	return m_dbusUid;
}

QString SingleUidHelper::mqttUid() const
{
	return m_mqttUid;
}

void SingleUidHelper::onPathForServiceNameChanged(const QString &serviceName, const QString &path)
{
	if (m_serviceName == serviceName && !path.startsWith(QStringLiteral("modbustcp"))) {
		m_mqttDevicePath = path;
		m_mqttUid = QStringLiteral("%1/%2/%3").arg(QStringLiteral("mqtt"), m_mqttDevicePath, m_remainderPath);
		Q_EMIT mqttUidChanged();
	}
}

} /* VenusOS */

} /* Victron */

