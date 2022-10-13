#include "uidhelper.h"

namespace Victron {

namespace VenusOS {

UidHelper::UidHelper(QObject *parent)
	: QObject(parent)
{
}

void UidHelper::setActiveTopics(const QSet<QString> &topics)
{
	if (m_activeTopics != topics) {
		m_activeTopics = topics;
		emit activeTopicsChanged();
	}
}

QSet<QString> UidHelper::activeTopics() const
{
	return m_activeTopics;
}

QObject* UidHelper::instance(QQmlEngine *, QJSEngine *)
{
	// only construct one.  the QML engine will take ownership of it.
	static QPointer<UidHelper> ret(new UidHelper);
	return ret.data();
}

//--

SingleUidHelper::SingleUidHelper(QObject *parent)
	: QObject(parent)
	, m_uidHelper(qobject_cast<UidHelper*>(UidHelper::instance(nullptr, nullptr)))
{
	if (m_uidHelper.data()) {
		connect(m_uidHelper.data(), &UidHelper::activeTopicsChanged,
				this, &SingleUidHelper::recalculateMqttUid);
	}
}

void SingleUidHelper::setDBusUid(const QString &uid)
{
	if (m_dbusUid != uid) {
		m_dbusUid = uid;
		recalculateMqttUid();
		emit dbusUidChanged();
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

void SingleUidHelper::recalculateMqttUid()
{
	// the dbus uid will be of the form:
	// "dbus/com.victronenergy.<service>/<path>"
	// whereas the mqtt uid will be of the form:
	// "mqtt/<service>/<deviceId>/<path>"

	// step one, decompose the dbus uid into <service> + <path>
	static const qsizetype dbusUidPrefixLength = QStringLiteral("dbus/com.victronenergy.").size();
	const QString dbusServiceAndPath = m_dbusUid.mid(dbusUidPrefixLength);
	const QString dbusService = dbusServiceAndPath.indexOf('/') > 0 ? dbusServiceAndPath.split('/').first() : QString();
	const QString dbusPath = dbusServiceAndPath.mid(dbusService.size() + 1);

	if (dbusService.isEmpty() || dbusPath.isEmpty()) {
		qWarning() << "Invalid DBus uid specified: " << m_dbusUid;
		return;
	}

	// step two, look for any active topics which match
	QSet<QString> matchingTopics;
	QString smallestMatchingTopic;
	const QSet<QString> activeTopics = m_uidHelper.data() ? m_uidHelper->activeTopics() : QSet<QString>();
	for (const QString &topic : activeTopics) {
		// each active topic is of the form <service>/<deviceId>/<path>
		if (topic.startsWith(dbusService) && (topic.endsWith(dbusPath) || topic.endsWith(QStringLiteral("%1/").arg(dbusPath)))) {
			matchingTopics.insert(topic);
			if (smallestMatchingTopic.isEmpty() || (topic.size() < smallestMatchingTopic.size())) {
				smallestMatchingTopic = topic;
			}
		}
	}

	// step three, build a fallback uid with a "default assumption" of deviceId = 0.
	const QString fallbackUid = QStringLiteral("mqtt/%1/0/%2").arg(dbusService, dbusPath);

	// step four, check to see if the "new" uid differs from the "old" uid and update if necessary.
	// -> if the old uid was a fallback or empty, and we have a matching new topic, use that new one.
	// -> if the old uid was empty, and we have no matching new topic, use the fallback.
	// -> otherwise, keep the old uid as the one we use.
	// TODO: what about the case where: the old uid was not a fallback, but it no longer exists in the matching topics?
	const bool hasMatchingTopic = !smallestMatchingTopic.isEmpty();
	if (m_uidIsFallback && hasMatchingTopic) {
		m_mqttUid = QStringLiteral("mqtt/%1").arg(smallestMatchingTopic);
		m_uidIsFallback = false;
//qWarning() << "XXXXXXXXXXXXXXXXX calculated mqtt uid:" << m_mqttUid << "from dbus service: " << dbusService << ", path: " << dbusPath << "; matches: " << matchingTopics;
		emit mqttUidChanged();
	} else if (m_mqttUid.isEmpty()) {
		m_mqttUid = fallbackUid;
//qWarning() << "XXXXXXXXXXXXXXXXX fallback mqtt uid:" << m_mqttUid << "from dbus service: " << dbusService << ", path: " << dbusPath;
		emit mqttUidChanged();
	}
}

} /* VenusOS */

} /* Victron */

