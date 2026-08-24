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
#include <QQmlEngine>

#include "veutil/qt/ve_qitem.hpp"

#include "uitest.h"
#include "uitestresultutils.h"
#include "uitestutils.h"
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

bool UiTestConfiguration::exists(const QString &dirName) const
{
	if (dirName.isEmpty()) {
		return false;
	}

	const QString confName = dirName.mid(dirName.lastIndexOf('/') + 1);
	const QString filePath = QString(":/tests/ui/%1/%2.json").arg(dirName).arg(confName);
	return QFile::exists(filePath);
}

// Build an ad-hoc ui-test configuration that opens one target page via a statically resolved click route.
void UiTestConfiguration::loadTargetPageNavigation(const QString &targetPage)
{
	if (targetPage.isEmpty()) {
		qCFatal(venusGuiTest) << "Cannot load empty target page!";
	}

	const QString normalizedTargetPage = UiTestUtils::normalizePageUrl(targetPage);
	if (normalizedTargetPage.isEmpty()) {
		qCFatal(venusGuiTest) << "Invalid value for --ui-test:" << targetPage
				<< "- not a known test configuration directory, and not a valid page path."
				<< "Page paths must start with /pages/ and end with .qml"
				<< "(e.g. /pages/settings/PageSettingsConnectivity.qml).";
	}

	QString entryNavText;
	QList<UiTestUtils::RouteStep> resolvedSteps;
	if (!UiTestUtils::resolveTargetRoute(normalizedTargetPage, &entryNavText, &resolvedSteps)) {
		qCFatal(venusGuiTest) << "Unable to resolve navigation route to target page:" << normalizedTargetPage
				<< "- the page may not be reachable from any root page."
				<< "Root pages (e.g. SettingsPage.qml, OverviewPage.qml) cannot be targeted directly.";
	}

	// Serialize route steps as QVariantList of { type, values, expectedPage } maps for QML.
	QVariantList routeSteps;
	for (const UiTestUtils::RouteStep &step : resolvedSteps) {
		QString typeName;
		switch (step.identifier.type) {
		case UiTestUtils::ClickIdentifier::Text: typeName = QStringLiteral("text"); break;
		case UiTestUtils::ClickIdentifier::Title: typeName = QStringLiteral("title"); break;
		case UiTestUtils::ClickIdentifier::IconSource: typeName = QStringLiteral("iconSource"); break;
		case UiTestUtils::ClickIdentifier::ObjectName: typeName = QStringLiteral("objectName"); break;
		}
		routeSteps.append(QVariantMap{
			{ QStringLiteral("type"), typeName },
			{ QStringLiteral("values"), step.identifier.values },
			{ QStringLiteral("expectedPage"), step.expectedPageUrl },
		});
	}

	m_dirName = QStringLiteral("target-page");
	m_settings = {
		{ QStringLiteral("ExitWhenFinished"), true },
		{ QStringLiteral("Logging"), QStringLiteral("info") },
		{ QStringLiteral("TargetPage"), normalizedTargetPage },
		{ QStringLiteral("RouteEntryLabel"), entryNavText },
		{ QStringLiteral("RouteSteps"), routeSteps },
		{ QStringLiteral("Tests"), QStringList{ QStringLiteral("tst_target_page.qml") } },
		{ QStringLiteral("Steps"), QVariantMap{
			{ QStringLiteral("WaitUntil"), QVariantMap{
				{ QStringLiteral("DefaultTimeout"), 5000 },
			}},
		}},
	};

	qCInfo(venusGuiTest) << "Using single-page UI navigation mode for target page:" << normalizedTargetPage
			<< "with" << routeSteps.count() << "route steps";
}

QString UiTestConfiguration::dirName() const
{
	return m_dirName;
}

const QVariantMap &UiTestConfiguration::settingsMap() const
{
	return m_settings;
}

bool UiTestConfiguration::hasMockConfiguration() const
{
	return m_settings.contains("Mock");
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
	setTargetPageWarningMonitoringEnabled(false);

	m_settings = conf.settingsMap();
	m_relativeTestDir = conf.dirName();
	m_passCount = 0;
	m_failCount = 0;
	m_runtimeQmlErrorCount = 0;
	m_elapsed = 0;
	m_recordedQmlWarnings.clear();

	// Read general configuration values.
	const QVariant logLevel = settingValue("Logging");
	if (logLevel.isValid()) {
		qWarning() << "UI test: enable" << logLevel << "logging";
		QLoggingCategory::setFilterRules(QString("venus.gui.test.%1=true").arg(logLevel.toString()));
	}

	BackendConnection *backend = BackendConnection::create();
	if (backend->type() == BackendConnection::MockSource) {
		// Read 'Mock' configuration values.
		MockManager *mockManager = MockManager::create();
		const QVariantMap mockSettings = settingValue("Mock").toMap();
		if (mockSettings.value("Configuration").isValid()) {
			mockManager->loadConfiguration(mockSettings.value("Configuration").toString());
		}
		if (mockSettings.value("TimersActive").isValid()) {
			mockManager->setTimersActive(mockSettings.value("TimersActive").toBool());
		}
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
	setTargetPageWarningMonitoringEnabled(isTargetPageMode());

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
		bool failedToLoad = false;
		const QUrl url = QString("qrc:/qt/qml/Victron/UiTest/tests/ui/%1/%2").arg(m_relativeTestDir).arg(testFileName);
		QQmlComponent component(qmlEngine(this), url, this);
		if (component.isError()) {
			failedToLoad = true;
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
					failedToLoad = true;
					qCWarning(venusGuiTest) << qPrintable(QStringLiteral("Root type is not TestCase in '%1', url: %2")
							.arg(testFileName).arg(component.url().toString()));
				}
			} else {
				failedToLoad = true;
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
			if (failedToLoad) {
				++m_failCount;
			}
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
		qCInfo(venusGuiTest) << qPrintable(QStringLiteral("All tests finished: %1 steps passed, %2 steps failed, %3 runtime QML errors, in %4")
				.arg(m_passCount)
				.arg(m_failCount)
				.arg(m_runtimeQmlErrorCount)
				.arg(durationText));
		qCInfo(venusGuiTest) << "********************************************************";
		setTargetPageWarningMonitoringEnabled(false);
		setStatus(Finished);
		if (exitWhenFinished()) {
			qApp->exit(UiTestResultUtils::exitCodeForFailures(m_failCount, m_runtimeQmlErrorCount));
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

bool UiTest::isTargetPageMode() const
{
	return m_relativeTestDir == QStringLiteral("target-page")
			&& m_settings.contains(QStringLiteral("TargetPage"));
}

void UiTest::setTargetPageWarningMonitoringEnabled(bool enabled)
{
	if (enabled) {
		if (m_qmlWarningsConnection) {
			return;
		}
		if (QQmlEngine *engine = qmlEngine(this)) {
			m_qmlWarningsConnection = connect(engine, &QQmlEngine::warnings, this, &UiTest::onQmlWarnings);
		}
	} else if (m_qmlWarningsConnection) {
		disconnect(m_qmlWarningsConnection);
		m_qmlWarningsConnection = QMetaObject::Connection();
	}
}

void UiTest::onQmlWarnings(const QList<QQmlError> &warnings)
{
	if (!isTargetPageMode()) {
		return;
	}

	QStringList newWarnings;
	m_runtimeQmlErrorCount += UiTestResultUtils::countNewRuntimeQmlWarnings(
			warnings, &m_recordedQmlWarnings, &newWarnings);
	for (const QString &warningText : newWarnings) {
		qCWarning(venusGuiTest) << qPrintable(QStringLiteral("Target-page runtime QML error: %1").arg(warningText));
	}
}

QVariant UiTest::settingValue(const QString &key, const QVariant &defaultValue) const
{
	const QVariant v = m_settings.value(key);
	return v.isValid() ? v : defaultValue;
}
