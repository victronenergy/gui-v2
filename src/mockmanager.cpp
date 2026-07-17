/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QFile>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QQmlInfo>
#include <QVariantMap>

#include "mockmanager.h"
#include "mocktimerworker.h"
#include "mockvalueapplier.h"
#include "backendconnection.h"
#include "veqitemmockproducer.h"

using namespace Victron::VenusOS;

namespace {

QJsonDocument loadJsonDocumentFromFile(const QString &fileName)
{
	QFile file(fileName);
	if (!file.open(QFile::ReadOnly | QFile::Text)) {
		qWarning() << "Unable to open JSON file:" << fileName;
		return QJsonDocument();
	}

	QJsonParseError parseError;
	QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
	if (parseError.error != QJsonParseError::NoError) {
		file.seek(std::max(0, parseError.offset - 128));
		qWarning() << "Failed to parse JSON from" << fileName
				   << "with error:" << parseError.errorString()
				   << "and offset:" << parseError.offset
				   << "\nCheck end of this line:\n" << file.read(128);
		return QJsonDocument();
	}

	return doc;
}

// Store all parsed numbers as doubles. Otherwise, if a number can be floating-point but is written
// without a decimal in the JSON, it will be stored as an int, and then veutil will prevent it from
// being saved as a double in order to preserve the original type.
QVariant jsonValueToVariant(const QJsonValue &jsonValue)
{
	return jsonValue.isDouble() ? jsonValue.toDouble() : jsonValue.toVariant();
}

}


MockManager* MockManager::create(QQmlEngine *, QJSEngine *)
{
	static MockManager* object = new MockManager();
	return object;
}

MockManager::MockManager(QObject *parent)
	: QObject(parent)
{
	if (!producer()) {
		qFatal("MockManager can only be used when VeQItemMockProducer is available!");
	}
	initWorker();
}

void MockManager::initWorker()
{
	// Both objects stay on the GUI thread. The calculation is cheap; the stall
	// is the paced setValue() that follows, which cannot leave this thread.
	m_timerWorker = new MockTimerWorker(this);
	m_valueApplier = new MockValueApplier(this);
	connect(m_timerWorker, &MockTimerWorker::valuesReady,
			m_valueApplier, &MockValueApplier::applyValues);
	// VeQuickItem::setValue() writes the item directly. MockManager::setValue()
	// calls onExternalWrite() itself and does not emit this signal.
	connect(producer(), &VeQItemMockProducer::valueWritten,
			this, &MockManager::onExternalWrite);
}

bool MockManager::timersActive() const
{
	return m_timersActive;
}

void MockManager::setTimersActive(bool active)
{
	if (active != m_timersActive) {
		m_timersActive = active;
		if (m_timerWorker) {
			m_timerWorker->setAllTimersActive(active);
		}
		Q_EMIT timersActiveChanged();
	}
}

void MockManager::setValue(const QString &uid, const QVariant &value)
{
	// If the value is 'null', set it as the equivalent of an 'undefined' value instead. This is
	// because a null value in a JSON values file may be used to mean undefined, as JSON does not
	// support undefined as a value. This is an important distinction as VeQuickItem::valid returns
	// true if the value is null, but false if it is undefined.
	const QVariant effectiveValue = value.isNull() ? QVariant() : value;
	producer()->setValue(uid, effectiveValue);
	onExternalWrite(uid);
}

void MockManager::applyWorkerUpdatesForTest(const QVariantList &updates)
{
	if (!m_valueApplier) {
		return;
	}
	MockValueUpdateList batch;
	batch.reserve(updates.size());
	for (const QVariant &entry : updates) {
		const QVariantMap map = entry.toMap();
		const QString uid = normalizedMockUid(map.value(QStringLiteral("uid")).toString());
		if (uid.isEmpty()) {
			continue;
		}
		batch.append({uid, map.value(QStringLiteral("value"))});
	}
	m_valueApplier->applyValues(batch);
}

void MockManager::registerStepperForTest(const QString &uid, qreal interval)
{
	if (!m_timerWorker) {
		return;
	}
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty()) {
		return;
	}
	MockAnimatorConfig config;
	config.animatorId = -1;
	config.type = MockAnimatorConfig::Stepper;
	config.uids = { normalized };
	config.interval = interval;
	config.stepSize = 1.0;
	config.repeat = true;
	m_timerWorker->registerAnimator(config);
}

QVariant MockManager::value(const QString &uid) const
{
	return producer()->value(uid);
}

void MockManager::setProperty(const QString &uid, const QString &name, const QVariant &value)
{
	producer()->setProperty(uid, name, value);
}

void MockManager::removeValue(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	// Pause writers and drop queued updates before the unlink. A later setValue()
	// resumes them. Applying a paused write would call itemGetOrCreate() and
	// recreate the service.
	if (!normalized.isEmpty()) {
		QSet<QString> dropped;
		if (m_timerWorker) {
			dropped = m_timerWorker->forgetUidPrefix(normalized);
		}
		if (m_valueApplier) {
			dropped.unite(m_valueApplier->dropPrefix(normalized));
		}
		propagateCancellation(dropped);
	}
	producer()->removeValue(uid);
	// A watched source is gone. Rerun after the unlink, so the calculation
	// reads the missing value instead of writing the removed path back.
	if (!normalized.isEmpty() && m_timerWorker && hasWatchedSourceUnder(normalized)) {
		m_timerWorker->scheduleCalculatorFlush();
	}
}

void MockManager::removeServices(const QString &serviceType)
{
	const QString prefix = QStringLiteral("com.victronenergy.%1.").arg(serviceType);
	const VeQItem::Children children = producer()->services()->itemChildren();
	QStringList serviceUids;
	for (auto it = children.constBegin(); it != children.constEnd(); ++it) {
		if (it.key().startsWith(prefix)) {
			serviceUids.append(it.key());
		}
	}
	for (const QString &uid : serviceUids) {
		removeValue(uid);
	}
}

bool MockManager::setValuesFromJson(const QString &fileName)
{
	QJsonDocument doc = loadJsonDocumentFromFile(fileName);
	if (doc.isNull()) {
		return false;
	}
	const QJsonObject object = doc.object();
	if (object.isEmpty()) {
		qmlWarning(this) << "JSON file " << fileName << " is not a map, or is empty!";
		return false;
	}

	setServiceValues(object);
	return true;
}

bool MockManager::loadConfiguration(const QString &fileName)
{
	qInfo() << "Loading mock configuration:" << fileName;

	QJsonDocument doc = loadJsonDocumentFromFile(fileName);
	if (doc.isNull()) {
		return false;
	}
	const QJsonObject object = doc.object();
	const QJsonArray files = object.value(QStringLiteral("files")).toArray();
	for (auto it = files.constBegin(); it != files.constEnd(); ++it) {
		setValuesFromJson(it->toString());
	}

	setServiceValues(object.value(QStringLiteral("setup")).toObject());
	m_confFileName = fileName;

	return true;
}

QString MockManager::configurationFileName() const
{
	return m_confFileName;
}

/*
	Sets the path values for all services in the given object, which might look something like:
	{
		"com.victronenergy.system": {
			"/Ac/In/0/Connected": 0,
			"/Ac/In/0/DeviceInstance": 257,
			"/Ac/In/0/ServiceType": "vebus",
			"/Ac/In/0/ServiceName": "com.victronenergy.vebus.ttyO1"
		},
		"com.victronenergy.settings": {
			"/Settings/SystemSetup/AcInput1": 2,
			"/Settings/SystemSetup/AcInput2": 0,
		}
	}

	A path value may also be given as an object, in order to set additional properties (such as
	"min", "max" or "defaultValue") on the item, alongside (or instead of) its plain "value":
	{
		"com.victronenergy.vebus.ttyS2": {
			"/MicroGrid/DroopModeParameters/F0/Value": { "value": 50.5, "min": 45, "max": 65, "defaultValue": 50 }
		}
	}
*/
void MockManager::setServiceValues(const QJsonObject &object)
{
	for (auto serviceIterator = object.constBegin(); serviceIterator != object.constEnd(); ++serviceIterator) {
		const QString &serviceUid = serviceIterator.key();
		const QJsonObject &paths =  serviceIterator.value().toObject();
		for (auto valueIterator = paths.constBegin(); valueIterator != paths.constEnd(); ++valueIterator) {
			const QString path = serviceUid + valueIterator.key();
			const QJsonValue jsonValue = valueIterator.value();
			if (jsonValue.isObject()) {
				setPropertyValues(path, jsonValue.toObject());
				continue;
			}
			if (value(path).isValid()) {
				qInfo() << "Warning: changing value of" << path << "from" << value(path)
						<< "to" << jsonValue.toVariant();
			}
			setValue(path, jsonValueToVariant(jsonValue));
		}
	}
}

/*
	Sets the "value" (if present) and any other named properties (e.g. "min", "max", "defaultValue")
	given in the object for the item at the given path.
*/
void MockManager::setPropertyValues(const QString &path, const QJsonObject &properties)
{
	for (auto propertyIterator = properties.constBegin(); propertyIterator != properties.constEnd(); ++propertyIterator) {
		const QVariant propertyValue = jsonValueToVariant(propertyIterator.value());
		if (propertyIterator.key() == QStringLiteral("value")) {
			if (value(path).isValid()) {
				qInfo() << "Warning: changing value of" << path << "from" << value(path)
						<< "to" << propertyValue;
			}
			setValue(path, propertyValue);
		} else {
			setProperty(path, propertyIterator.key(), propertyValue);
		}
	}
}

void MockManager::dumpValues()
{
	qInfo() << "--- Begin value dump ---";
	producer()->dumpValues();
	qInfo() << "--- End value dump ---";
}

MockTimerWorker *MockManager::timerWorker() const
{
	return m_timerWorker;
}

MockValueApplier *MockManager::valueApplier() const
{
	return m_valueApplier;
}

void MockManager::finishAppliesForTest()
{
	if (m_valueApplier) {
		m_valueApplier->drainPendingForTest();
	}
}

void MockManager::queueTimerUpdateForTest(const QString &uid, const QVariant &value)
{
	if (m_timerWorker) {
		m_timerWorker->queueUpdateForTest(uid, value);
	}
}

void MockManager::tickAnimatorsForTest()
{
	if (m_timerWorker) {
		m_timerWorker->tickAnimatorsForTest();
	}
}

void MockManager::flushPendingForTest()
{
	if (m_timerWorker) {
		m_timerWorker->flushPendingForTest();
	}
}

int MockManager::queuedTickCountForTest() const
{
	return m_valueApplier ? m_valueApplier->queuedTickCountForTest() : 0;
}

bool MockManager::hasItemForTest(const QString &uid) const
{
	return producer() && producer()->hasItem(uid);
}

void MockManager::watchCalculatorSources(const QStringList &uids)
{
	for (const QString &uid : uids) {
		const QString normalized = normalizedMockUid(uid);
		if (!normalized.isEmpty()) {
			++m_calculatorSources[normalized];
		}
	}
}

void MockManager::unwatchCalculatorSources(const QStringList &uids)
{
	for (const QString &uid : uids) {
		auto it = m_calculatorSources.find(normalizedMockUid(uid));
		if (it != m_calculatorSources.end() && --it.value() <= 0) {
			m_calculatorSources.erase(it);
		}
	}
}

void MockManager::onExternalWrite(const QString &uid)
{
	const QString normalized = normalizedMockUid(uid);
	if (normalized.isEmpty() || !m_timerWorker || !m_valueApplier) {
		return;
	}
	// A batched or queued timer update for this uid is older than this write.
	// Drop the whole tick, not just this uid, so calculated outputs go with it.
	propagateCancellation({normalized});
	// A write under a removed path resumes writers paused for that path.
	// A write of a surviving output does not.
	m_timerWorker->noteUidWritten(normalized);
	if (m_calculatorSources.contains(normalized)) {
		m_timerWorker->scheduleCalculatorFlush();
	}
}

void MockManager::propagateCancellation(const QSet<QString> &uids)
{
	if (!m_timerWorker || !m_valueApplier || uids.isEmpty()) {
		return;
	}
	// Check the unflushed batch and the applier queue, then check again with
	// whatever those drops cancelled. A later tick may have read an output that
	// only the other side still had.
	QSet<QString> pending = uids;
	QSet<QString> seen;
	while (!pending.isEmpty()) {
		QSet<QString> next;
		for (const QString &uid : pending) {
			const QString normalized = normalizedMockUid(uid);
			if (normalized.isEmpty() || seen.contains(normalized)) {
				continue;
			}
			seen.insert(normalized);
			next.unite(m_timerWorker->dropPendingUpdate(normalized));
			next.unite(m_valueApplier->supersede(normalized));
		}
		pending = next;
	}
}

bool MockManager::hasWatchedSourceUnder(const QString &prefix) const
{
	if (prefix.isEmpty()) {
		return false;
	}
	for (auto it = m_calculatorSources.constBegin(); it != m_calculatorSources.constEnd(); ++it) {
		if (mockUidUnderPrefix(it.key(), prefix)) {
			return true;
		}
	}
	return false;
}

VeQItemMockProducer *MockManager::producer() const
{
	return qobject_cast<VeQItemMockProducer *>(BackendConnection::create()->producer());
}
