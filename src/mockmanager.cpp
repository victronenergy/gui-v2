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
	initWorkerThread();
}

MockManager::~MockManager()
{
#if QT_CONFIG(thread)
	if (m_workerThread) {
		if (m_timerWorker) {
			m_timerWorker->deleteLater();
			m_timerWorker = nullptr;
		}
		m_workerThread->quit();
		m_workerThread->wait();
		delete m_workerThread;
		m_workerThread = nullptr;
	}
#else
	delete m_timerWorker;
	m_timerWorker = nullptr;
#endif
	delete m_valueApplier;
}

void MockManager::initWorkerThread()
{
	// Register metatypes for cross-thread signal/slot connections
	qRegisterMetaType<Victron::VenusOS::MockAnimatorConfig>(
		"Victron::VenusOS::MockAnimatorConfig");
	qRegisterMetaType<Victron::VenusOS::MockValueUpdateList>(
		"Victron::VenusOS::MockValueUpdateList");
	qRegisterMetaType<Victron::VenusOS::MockValueCache>(
		"MockValueCache");
	qRegisterMetaType<Victron::VenusOS::MockValueCache>(
		"Victron::VenusOS::MockValueCache");
	qRegisterMetaType<Victron::VenusOS::MockConsumptionConfig>(
		"Victron::VenusOS::MockConsumptionConfig");

	// Create worker and GUI-thread value applier
	m_timerWorker = new MockTimerWorker(); // no parent — will be moved to thread (or stays on main thread for WASM)
	m_valueApplier = new MockValueApplier(this);

#if QT_CONFIG(thread)
	qDebug() << "Initialising mock manager in multi-threaded mode";

	// Create worker thread and move worker to it
	m_workerThread = new QThread();
	m_workerThread->setObjectName(QStringLiteral("MockTimerWorkerThread"));
	m_timerWorker->moveToThread(m_workerThread);

	// Connect worker output to GUI-thread applier (queued automatically due to thread affinity)
	connect(m_timerWorker, &MockTimerWorker::valuesReady,
			m_valueApplier, &MockValueApplier::applyValues);

	// Connect notification signals to targeted dispatch (avoids O(N²) broadcast)
	connect(m_timerWorker, &MockTimerWorker::notifyUpdate,
			m_valueApplier, &MockValueApplier::dispatchNotifyUpdate);
	connect(m_timerWorker, &MockTimerWorker::notifyTotal,
			m_valueApplier, &MockValueApplier::dispatchNotifyTotal);

	// Start the worker thread
	m_workerThread->start();
#else
	qDebug() << "Initialising mock manager in single-threaded mode";

	// Single-threaded mode (e.g. WASM): worker stays on the main thread.
	// Timer events fire in the main event loop. Connections are direct since
	// both objects share the same thread.
	connect(m_timerWorker, &MockTimerWorker::valuesReady,
			m_valueApplier, &MockValueApplier::applyValues);
	connect(m_timerWorker, &MockTimerWorker::notifyUpdate,
			m_valueApplier, &MockValueApplier::dispatchNotifyUpdate);
	connect(m_timerWorker, &MockTimerWorker::notifyTotal,
			m_valueApplier, &MockValueApplier::dispatchNotifyTotal);
#endif
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
			if (active) {
				// Restart from the producer, not the cache captured at registration.
				MockValueCache snapshot;
				for (auto it = m_watches.constBegin(); it != m_watches.constEnd(); ++it) {
					snapshot.insert(it.key(), producer()->value(it.key()));
				}
				if (!snapshot.isEmpty()) {
					QMetaObject::invokeMethod(m_timerWorker, "updateValues",
						Qt::QueuedConnection, Q_ARG(MockValueCache, snapshot));
				}
			}
			QMetaObject::invokeMethod(m_timerWorker, "setAllTimersActive",
				Qt::QueuedConnection, Q_ARG(bool, active));
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
	// Watched items forward the change from valueChanged, including while timers
	// are off. Unwatched paths (JSON load) are not queued to the worker.
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
	producer()->removeValue(uid);
}

void MockManager::removeServices(const QString &serviceType)
{
	producer()->removeServices(serviceType);
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

void MockManager::watchUids(const QStringList &uids, MockWatchRole role)
{
	for (const QString &rawUid : uids) {
		if (rawUid.isEmpty()) {
			continue;
		}
		const QString uid = normalizedMockUid(rawUid);
		if (uid.isEmpty()) {
			continue;
		}
		UidWatch &watch = m_watches[uid];
		const bool alreadyWatching = watch.animatorRefs + watch.calculatorRefs > 0;
		if (role == MockWatchRole::AnimatorInput) {
			++watch.animatorRefs;
		} else {
			++watch.calculatorRefs;
		}
		if (alreadyWatching) {
			continue;
		}
		VeQItem *item = producer()->itemForUid(uid, true);
		if (!item) {
			continue;
		}
		watch.connection = connect(item, &VeQItem::valueChanged, this,
				[this, uid](const QVariant &value) {
			onWatchedValueChanged(uid, value);
		});
	}
}

void MockManager::unwatchUids(const QStringList &uids, MockWatchRole role)
{
	for (const QString &rawUid : uids) {
		if (rawUid.isEmpty()) {
			continue;
		}
		const QString uid = normalizedMockUid(rawUid);
		auto it = m_watches.find(uid);
		if (it == m_watches.end()) {
			continue;
		}
		int &refs = role == MockWatchRole::AnimatorInput ? it->animatorRefs : it->calculatorRefs;
		if (refs > 0) {
			--refs;
		}
		if (it->animatorRefs + it->calculatorRefs > 0) {
			continue;
		}
		QObject::disconnect(it->connection);
		m_watches.erase(it);
	}
}

void MockManager::setSuppressWorkerSync(bool suppress)
{
	if (suppress) {
		++m_suppressWorkerSync;
	} else if (m_suppressWorkerSync > 0) {
		--m_suppressWorkerSync;
	}
}

void MockManager::onWatchedValueChanged(const QString &uid, const QVariant &value)
{
	if (m_suppressWorkerSync > 0 || !m_timerWorker) {
		return;
	}
	const auto it = m_watches.constFind(uid);
	if (it == m_watches.constEnd()) {
		return;
	}
	QMetaObject::invokeMethod(m_timerWorker, "updateValue",
		Qt::QueuedConnection, Q_ARG(QString, uid), Q_ARG(QVariant, value));
	if (it->calculatorRefs > 0) {
		QMetaObject::invokeMethod(m_timerWorker, "scheduleCalculatorFlush",
			Qt::QueuedConnection);
	}
}

VeQItemMockProducer *MockManager::producer() const
{
	return qobject_cast<VeQItemMockProducer *>(BackendConnection::create()->producer());
}
