/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "uidhelper.h"

namespace {

static const QString ServiceMappingPath = QStringLiteral("system/0/ServiceMapping");
static const QString ServiceMappingPathWithPath = ServiceMappingPath + '/';

}

namespace Victron {

namespace VenusOS {

UidHelper::UidHelper(QObject *parent)
	: QObject(parent)
{
}

int UidHelper::deviceInstanceForService(const QString &service) const
{
	auto it = m_serviceDeviceInstances.constFind(service);
	return it == m_serviceDeviceInstances.constEnd() ? -1 : it.value();
}

void UidHelper::addServiceMapping(const QString &serviceMappingKey, const QString &service)
{
	const qsizetype lastSepIndex = serviceMappingKey.lastIndexOf('_');
	if (lastSepIndex < 0) {
		qWarning() << "Malformed ServiceMapping key:" << serviceMappingKey;
		return;
	}
	bool ok = false;
	const int deviceInstance = serviceMappingKey.mid(lastSepIndex + 1).toInt(&ok);
	if (!ok) {
		qWarning() << "ServiceMapping key does not end with device instance:" << serviceMappingKey;
		return;
	}
	m_serviceMappings.insert(serviceMappingKey, service);
	m_serviceDeviceInstances.insert(service, deviceInstance);
	emit serviceRegistered(service, deviceInstance);
}

void UidHelper::removeServiceMapping(const QString &serviceMappingKey)
{
	auto mapping = m_serviceMappings.constFind(serviceMappingKey);
	if (mapping == m_serviceMappings.constEnd()) {
		qWarning() << "Cannot remove ServiceMapping" << serviceMappingKey << ", no previous entry found";
		return;
	}
	const QString &service = mapping.value();
	m_serviceDeviceInstances.remove(service);
	m_serviceMappings.erase(mapping);
	Q_EMIT serviceUnregistered(service);
}

void UidHelper::onMessageReceived(const QString &path, const QVariant &message)
{
	static const QString ServiceMappingPath = QStringLiteral("system/0/ServiceMapping");
	static const QString ServiceMappingPathWithPath = ServiceMappingPath + '/';

	if (path == ServiceMappingPath) {
		if (message.metaType() != QMetaType::fromType<QVariantMap>()) {
			qWarning() << "Error: expected ServiceMapping QVariantMap but type was" << message.metaType().name();
		} else {
			// The Map contains entries like this:
			//    "com_victronenergy_battery_288" -> QVariant(QString, "com.victronenergy.battery.ttyUSB0")
			//    "com_victronenergy_dcsystem_40" -> QVariant(QString, "com.victronenergy.dcsystem.ttyS5")
			//    "com_victronenergy_generator_0" -> QVariant(QString, "com.victronenergy.generator.startstop0")
			//    "com_victronenergy_temperature_28" -> QVariant(QString, "com.victronenergy.temperature.ruuvi_f00f00d00001")

			const QVariantMap newMappings = message.toMap();
			for (auto it = m_serviceMappings.constBegin(); it != m_serviceMappings.constEnd(); ++it) {
				if (!newMappings.contains(it.key())) {
					removeServiceMapping(it.key());
				}
			}
			for (auto it = newMappings.constBegin(); it != newMappings.constEnd(); ++it) {
				addServiceMapping(it.key(), it.value().toString());
			}

		}
	} else if (path.startsWith(ServiceMappingPathWithPath)) {
		addServiceMapping(path.mid(ServiceMappingPathWithPath.length()), message.toString());
	}
}

void UidHelper::onNullMessageReceived(const QString &path)
{
	if (path.startsWith(ServiceMappingPathWithPath)) {
		removeServiceMapping(path.mid(ServiceMappingPathWithPath.length()));
	}
}

UidHelper* UidHelper::create(QQmlEngine *, QJSEngine *)
{
	// only construct one.  the QML engine will take ownership of it.
	static QPointer<UidHelper> ret(new UidHelper(nullptr));
	return qobject_cast<UidHelper *>(ret.data());
}

//--

SingleUidHelper::SingleUidHelper(QObject *parent)
	: QObject(parent)
	, m_uidHelper(UidHelper::create())
{
	if (m_uidHelper.data()) {
		connect(m_uidHelper.data(), &UidHelper::serviceRegistered,
				this, &SingleUidHelper::onServiceRegistered);
		connect(m_uidHelper.data(), &UidHelper::serviceUnregistered,
				this, &SingleUidHelper::onServiceUnregistered);
	}
}

void SingleUidHelper::setDBusUid(const QString &uid)
{
	// the dbus uid will be of the form:
	// "dbus/<service>/<path>"
	// whereas the mqtt uid will be of the form:
	// "mqtt/<service>/<deviceInstance>/<path>"
	if (m_dbusUid != uid) {
		m_dbusUid = uid;
		m_serviceName.clear();
		m_remainderPath.clear();
		m_deviceInstance = -1;

		if (uid.isEmpty()) {
			m_mqttUid.clear();
			Q_EMIT mqttUidChanged();
			return;
		}

		// calculate the MQTT device path based on the service name
		const QStringList parts = m_dbusUid.split('/');
		if (parts.length() < 2) {
			qWarning() << "Malformed DBus uid, no service name:" << uid;
			Q_EMIT dbusUidChanged();
			return;
		}

		const QString prefix = QStringLiteral("%1/%2").arg(parts[0], parts[1]);
		m_serviceName = parts[1];
		m_remainderPath = uid.mid(prefix.length() + 1);

		if (m_serviceName.split('.').size() == 3) {
			// Service name is of the form com.victronenergy.xyz rather than
			// com.victronenergy.xyz.abc, so we can assume the device instance is 0.
			m_deviceInstance = 0;
		} else {
			const int deviceInstance = m_uidHelper.data()->deviceInstanceForService(m_serviceName);
			if (deviceInstance >= 0) {
				m_deviceInstance = deviceInstance;
			} else {
				// No ServiceMapping available yet for this service, wait for the UidHelper signal.
				m_deviceInstance = -1;
			}
		}

		updateMqttUid();
		Q_EMIT dbusUidChanged();
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

void SingleUidHelper::updateMqttUid()
{
	QString mqttUid;

	if (m_deviceInstance >= 0) {
		// m_serviceName is com.victronenergy.abc[.xyz] where <abc> is the service type to be extracted.
		const QStringList dotParts = m_serviceName.split('.');
		if (dotParts.size() < 3) {
			qWarning() << "updateMqttUid() failed, malformed service name!" << m_serviceName;
		} else {
			mqttUid = QStringLiteral("mqtt/%1/%2/%3").arg(dotParts.at(2), QString::number(m_deviceInstance), m_remainderPath);
		}
	}

	if (mqttUid != m_mqttUid) {
		m_mqttUid = mqttUid;
		Q_EMIT mqttUidChanged();
	}
}

void SingleUidHelper::onServiceRegistered(const QString &service, int deviceInstance)
{
	if (service == m_serviceName && deviceInstance != m_deviceInstance) {
		m_deviceInstance = deviceInstance;
		updateMqttUid();
	}
}

void SingleUidHelper::onServiceUnregistered(const QString &service)
{
	if (service == m_serviceName) {
		m_deviceInstance = -1;
		updateMqttUid();
	}
}


} /* VenusOS */

} /* Victron */

