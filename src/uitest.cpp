/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QFile>
#include <QDir>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QMetaObject>
#include <QLoggingCategory>
#include <QQmlComponent>

#include "veutil/qt/ve_qitem.hpp"

#include "uitest.h"
#include "uitestcase.h"
#include "backendconnection.h"
#include "mockmanager.h"
#include "logging.h"
#include "clocktime.h"

using namespace Victron::VenusOS;

UiTestConfiguration::UiTestConfiguration()
{
}

UiTestConfiguration::~UiTestConfiguration()
{
}

void UiTestConfiguration::load(const QString &dirName)
{
	if (dirName.isEmpty()) {
		qCFatal(venusGuiTest) << "Cannot load empty test configuration!";
	}

	const QString confName = dirName.mid(dirName.lastIndexOf('/') + 1);
	const QString filePath = QString(":/tests/ui/%1/%2.json").arg(dirName).arg(confName);

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

	m_dirName = dirName;
	m_settings = doc.object().toVariantMap();

	qCInfo(venusGuiTest) << "Loaded test configuration:" << filePath;
}

QString UiTestConfiguration::dirName() const
{
	return m_dirName;
}

const QVariantMap &UiTestConfiguration::settingsMap() const
{
	return m_settings;
}

QString UiTestConfiguration::mockConfiguration() const
{
	// An empty value is not a configuration; treating it as one would suppress the default
	// configuration and leave the mock backend with no values at all.
	return m_settings.value("MockConfiguration").toString();
}

UiTest* UiTest::create(QQmlEngine *, QJSEngine *)
{
	static UiTest* object = new UiTest();
	return object;
}

UiTest::UiTest(QObject *parent)
	: QObject(parent)
{
}

void UiTest::loadConfiguration(const UiTestConfiguration &conf)
{
	m_settings = conf.settingsMap();
	m_relativeTestDir = conf.dirName();

	// Read general configuration values.
	const QVariant logLevel = settingValue("Logging");
	if (logLevel.isValid()) {
		qWarning() << "UI test: enable" << logLevel << "logging";
		QLoggingCategory::setFilterRules(QString("venus.gui.test.%1=true").arg(logLevel.toString()));
	}

	BackendConnection *backend = BackendConnection::create();
	if (backend->type() == BackendConnection::MockSource) {
		MockManager *mockManager = MockManager::create();
		const QString mockConfiguration = conf.mockConfiguration();
		if (!mockConfiguration.isEmpty() && !mockManager->loadConfiguration(mockConfiguration)) {
			// Nothing else will load a configuration: main() skips the default because this test
			// names one. Without this the test would run against an empty mock backend, and a
			// capture sweep would happily photograph a thousand blank screens and report no
			// failures.
			qCFatal(venusGuiTest) << "UI test" << conf.dirName()
					<< "specifies a mock configuration that could not be loaded:" << mockConfiguration;
		}

		// Mock timers are always off during a UI test: the mock data randomizers would otherwise
		// change values between runs, and the image comparisons of captured screens would fail.
		mockManager->setTimersActive(false);
	}

	// Disable UI animations for tests. Do this after any mock values have been applied, to override
	// any value set by a mock configuration.
	if (backend->type() != BackendConnection::UnknownSource && VeQItems::getRoot()) {
		if (VeQItem *uiAnimationsItem = VeQItems::getRoot()->itemGet(
					backend->serviceUidForType("settings") + "/Settings/Gui2/UIAnimations")) {
			uiAnimationsItem->setValue(0);
		}
	}

	// Read 'Tests' configuration values.
	m_testFileNames = m_settings.value("Tests").toStringList();
	if (m_testFileNames.isEmpty()) {
		qCFatal(venusGuiTest) << "UiTest: no tests have been defined in test:" << conf.dirName();
	}

	emit testCaseCountChanged();
	setStatus(Ready);
}

void UiTest::start()
{
	if (m_status != Ready) {
		qCWarning(venusGuiTest) << "UI test is not in ready state!";
		return;
	}

	// Stop ClockTime updates so that the time changes do not interfere with test image comparisons.
	ClockTime::create()->setUpdatesActive(false);
	ClockTime::create()->setClockTime(1);

	qCInfo(venusGuiTest) << "Starting UI tests...";

	QDir imageDir(CaptureAndCompareStep::absoluteImagePath(QString()));
	const QString imageDirPath = imageDir.absolutePath();
	qCInfo(venusGuiTest) << "Image captures will be saved to" << imageDirPath;
	if (!imageDir.isEmpty()) {
		// The image directory is non-empty. Clear it if it seems safe to do so, i.e. if its parent
		// is the application working directory, and not an arbitrary directory on the filesystem.
		const QString appWorkingDir = QDir().absolutePath();
		const QString dirName = imageDir.dirName();
		if (imageDir.cdUp() && imageDir.absolutePath() == appWorkingDir) {
			qCInfo(venusGuiTest) << "Image capture directory is non-empty, clearing contents...";
			if (!imageDir.cd(dirName) || !imageDir.removeRecursively()) {
				qCFatal(venusGuiTest) << "Failed to delete directory!";
			}
			if (!imageDir.mkpath(imageDirPath)) {
				qCFatal(venusGuiTest) << "Failed to re-make image capture path:" << imageDirPath;
			}
		} else {
			qCFatal(venusGuiTest) << qPrintable(QStringLiteral("Cannot capture images, directory %1 is not empty and cannot be auto-deleted!")
					.arg(imageDirPath));
		}
	}

	m_currentTestIndex = -1;
	QTimer::singleShot(0, this, &UiTest::startNextTestCase);
}

void UiTest::startNextTestCase()
{
	if (m_status == Ready) {
		setStatus(Running);
	}
	if (m_status != Running) {
		qCWarning(venusGuiTest) << "UiTest is not running!";
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
			qCInfo(venusGuiTest) << "Skipping to next test!";
			QTimer::singleShot(0, this, &UiTest::startNextTestCase);
		}
	} else {
		const int totalSeconds = m_elapsed / 1000;
		const QString durationText = totalSeconds <= 0
				? QStringLiteral("%1ms").arg(m_elapsed)
				: QStringLiteral("%1m %2s")
					.arg(totalSeconds / 60)
					.arg(totalSeconds < 60 ? totalSeconds : totalSeconds % 60);
		qCInfo(venusGuiTest) << qPrintable(QStringLiteral("All tests finished: %1 steps passed, %2 steps failed, in %3")
				.arg(m_passCount)
				.arg(m_failCount)
				.arg(durationText));
		qCInfo(venusGuiTest) << "********************************************************";
		setStatus(Finished);
		if (exitWhenFinished()) {
			qApp->quit();
		}
	}
}

void UiTest::testCaseFinished(int passCount, int failCount, int elapsed)
{
	m_passCount += passCount;
	m_failCount += failCount;
	m_elapsed += elapsed;

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
