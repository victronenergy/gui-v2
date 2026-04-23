/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QFile>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QMetaObject>
#include <QLoggingCategory>
#include <QQmlComponent>

#include "uitest.h"
#include "uitestcase.h"
#include "mockmanager.h"
#include "logging.h"

using namespace Victron::VenusOS;

UiTest* UiTest::create(QQmlEngine *, QJSEngine *)
{
	static UiTest* object = new UiTest();
	return object;
}

UiTest::UiTest(QObject *parent)
	: QObject(parent)
{
}

void UiTest::loadConfiguration(const QString &relativeTestDir)
{
	const QString confName = relativeTestDir.mid(relativeTestDir.lastIndexOf('/') + 1);
	const QString filePath = QString(":/tests/ui/%1/%2.json").arg(relativeTestDir).arg(confName);

	QFile file(filePath);
	if (!file.open(QFile::ReadOnly | QFile::Text)) {
		qCFatal(venusGuiTest) << "Failed to load test configuration! Cannot open file:" << filePath;
	}

	QJsonParseError parseError;
	QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
	if (parseError.error != QJsonParseError::NoError) {
		qCFatal(venusGuiTest) << "Failed to parse test configuration! Got parse error:"
				   << parseError.errorString() << "from file:" << filePath;
	}

	qCInfo(venusGuiTest) << "Loaded test configuration:" << filePath;

	m_settings = doc.object().toVariantMap();
	m_relativeTestDir = relativeTestDir;

	// Read general values
	const QVariant logLevel = settingValue("Logging");
	if (logLevel.isValid()) {
		qWarning() << "UI test: enable" << logLevel << "logging";
		QLoggingCategory::setFilterRules(QString("venus.gui.test.%1=true").arg(logLevel.toString()));
	}

	// Read 'Mock' values
	MockManager *mockManager = MockManager::create();
	const QVariantMap mockSettings = settingValue("Mock").toMap();
	if (mockSettings.value("Configuration").isValid()) {
		mockManager->loadConfiguration(mockSettings.value("Configuration").toString());
	}
	if (mockSettings.value("TimersActive").isValid()) {
		mockManager->setTimersActive(mockSettings.value("TimersActive").toBool());
	}
	if (mockSettings.value("UIAnimations").isValid()) {
		mockManager->setValue("com.victronenergy.settings/Settings/Gui2/UIAnimations",
				mockSettings.value("UIAnimations").toBool());
	}

	// Read 'Tests' values
	m_testFileNames = m_settings.value("Tests").toStringList();
	if (m_testFileNames.isEmpty()) {
		qCFatal(venusGuiTest) << "UiTest: no tests have been defined in test conf:" << filePath;
	}

	emit testCaseCountChanged();
	setStatus(Ready);
}

void UiTest::start()
{
	if (m_status != Ready) {
		qCWarning(venusGuiTest) << qPrintable(QStringLiteral("UI test is not in ready state!"));
		return;
	}

	qCInfo(venusGuiTest) << "Starting UI tests...";
	qCInfo(venusGuiTest) << "Image captures will be saved to" << CaptureAndCompareStep::absoluteImagePath(QString());

	m_currentTestIndex = -1;
	QTimer::singleShot(0, this, &UiTest::startNextTestCase);
}

void UiTest::startNextTestCase()
{
	if (m_status == Ready) {
		setStatus(Running);
	}
	if (m_status != Running) {
		qCWarning(venusGuiTest) << qPrintable(QStringLiteral("UiTest is not running!"));
		return;
	}

	m_currentTestIndex++;
	if (m_currentTestIndex < m_testFileNames.count()) {
		const QString &testFileName = m_testFileNames.at(m_currentTestIndex);
		UiTestCase *testCase = nullptr;
		const QUrl url = QString("qrc:/qt/qml/Victron/UiTest/tests/ui/%1/%2").arg(m_relativeTestDir).arg(testFileName);
		QQmlComponent component(qmlEngine(this), url, this);
		if (component.isError()) {
			qCWarning(venusGuiTest) << qPrintable(QStringLiteral("Failed to load test '%1', url: %2")
					.arg(testFileName).arg(component.url().toString()));
			for (const QQmlError &qmlError : component.errors()) {
				qCWarning(venusGuiTest) << qPrintable(QString("\t %1").arg(qmlError.toString()));
			}
		} else {
			QVariantMap properties;
			const QString testName = testFileName.mid(0, testFileName.lastIndexOf('.')); // strip extension
			properties.insert(QStringLiteral("name"), testName);
			QObject *testObject = component.createWithInitialProperties(properties);
			if (testObject) {
				testCase = qobject_cast<UiTestCase*>(testObject);
				if (!testCase) {
					qCWarning(venusGuiTest) << qPrintable(QStringLiteral("Root type is not TestCase in '%1', url: %2")
							.arg(testFileName).arg(component.url().toString()));
				}
			} else {
				qCWarning(venusGuiTest) << qPrintable(QStringLiteral("Failed to create TestCase object for '%1', url: %2")
						.arg(testFileName).arg(component.url().toString()));
				for (const QQmlError &qmlError : component.errors()) {
					qCWarning(venusGuiTest) << qPrintable(QString("\t %1").arg(qmlError.toString()));
				}
			}
		}
		if (testCase) {
			connect(testCase, &UiTestCase::finished, this, &UiTest::testCaseFinished);
			testCase->start();
		} else {
			qCInfo(venusGuiTest) << qPrintable(QStringLiteral("Skipping to next test!"));
			QTimer::singleShot(0, this, &UiTest::startNextTestCase);
		}
	} else {
		setStatus(Finished);
		if (exitWhenFinished()) {
			qApp->quit();
		}
	}
}

void UiTest::testCaseFinished()
{
	if (UiTestCase *testCase = qobject_cast<UiTestCase *>(sender())) {
		testCase->disconnect(this);
		testCase->deleteLater();
		startNextTestCase();
	}
}

UiTest::Status UiTest::status() const
{
	return m_status;
}

void UiTest::setStatus(Status status)
{
	if (m_status != status) {
		m_status = status;
		emit statusChanged();
	}
}

int UiTest::testCaseCount() const
{
	return m_testFileNames.count();
}

bool UiTest::exitWhenFinished() const
{
	return settingValue("ExitWhenFinished").toBool();
}

QVariant UiTest::settingValue(const QString &key, const QVariant &defaultValue) const
{
	const QVariant v = m_settings.value(key);
	return v.isValid() ? v : defaultValue;
}
