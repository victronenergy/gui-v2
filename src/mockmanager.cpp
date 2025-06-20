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
	connect(producer(), &VeQItemMockProducer::hasValuesChanged, this, &MockManager::hasValuesChanged);
}

bool MockManager::hasValues() const
{
	return producer()->hasValues();
}

QString MockManager::lastConfiguration() const
{
	return m_lastConfig;
}

void MockManager::setValue(const QString &uid, const QVariant &value)
{
	producer()->setValue(uid, value);
}

QVariant MockManager::value(const QString &uid) const
{
	return producer()->value(uid);
}

void MockManager::removeValue(const QString &uid)
{
	producer()->removeValue(uid);
}

void MockManager::removeAllValues()
{
	producer()->removeAllValues();
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

	removeAllValues();

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

	if (m_lastConfig != fileName) {
		m_lastConfig = fileName;
		Q_EMIT lastConfigurationChanged();
	}
	return true;
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
*/
void MockManager::setServiceValues(const QJsonObject &object)
{
	for (auto serviceIterator = object.constBegin(); serviceIterator != object.constEnd(); ++serviceIterator) {
		const QString &serviceUid = serviceIterator.key();
		const QJsonObject &paths =  serviceIterator.value().toObject();
		for (auto valueIterator = paths.constBegin(); valueIterator != paths.constEnd(); ++valueIterator) {
			setValue(serviceUid + valueIterator.key(), valueIterator.value().toVariant());
		}
	}
}

VeQItemMockProducer *MockManager::producer() const
{
	return qobject_cast<VeQItemMockProducer *>(BackendConnection::create()->producer());
}
