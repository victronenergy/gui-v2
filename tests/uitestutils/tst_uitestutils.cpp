/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>
#include <QQmlContext>
#include <QSet>

#include "testutils.h"
#include "uitestargutils.h"
#include "uitestcase.h"
#include "uitestresultutils.h"
#include "uitestutils.h"

class UiTestUtilsTestHelper : public QObject
{
	Q_OBJECT

public:
	explicit UiTestUtilsTestHelper(QObject *parent = nullptr) : QObject(parent) {}

	Q_INVOKABLE QString normalizePageUrl(const QString &raw) const
	{
		return Victron::VenusOS::UiTestUtils::normalizePageUrl(raw);
	}

	Q_INVOKABLE QVariantMap buildPageGraphSummary() const
	{
		const auto graph = Victron::VenusOS::UiTestUtils::buildPageGraph();
		QVariantMap result;
		result.insert(QStringLiteral("pageCount"), graph.size());
		int totalEdges = 0;
		for (auto it = graph.cbegin(); it != graph.cend(); ++it) {
			totalEdges += it.value().size();
		}
		result.insert(QStringLiteral("edgeCount"), totalEdges);

		// Include a few known pages to verify they appear in the graph.
		QStringList knownPages;
		for (auto it = graph.cbegin(); it != graph.cend(); ++it) {
			knownPages.append(it.key());
		}
		result.insert(QStringLiteral("pages"), knownPages);
		return result;
	}

	Q_INVOKABLE QVariantMap findRouteEdge(const QString &sourcePageUrl, const QString &targetPageUrl) const
	{
		const auto graph = Victron::VenusOS::UiTestUtils::buildPageGraph();
		const QString source = Victron::VenusOS::UiTestUtils::normalizePageUrl(sourcePageUrl);
		const QString target = Victron::VenusOS::UiTestUtils::normalizePageUrl(targetPageUrl);

		QVariantMap result;
		result.insert(QStringLiteral("exists"), false);
		result.insert(QStringLiteral("sourceEdgeCount"), 0);
		result.insert(QStringLiteral("type"), QString());
		result.insert(QStringLiteral("values"), QVariantList());

		const QList<Victron::VenusOS::UiTestUtils::RouteEdge> sourceEdges = graph.value(source);
		result.insert(QStringLiteral("sourceEdgeCount"), sourceEdges.count());
		for (const Victron::VenusOS::UiTestUtils::RouteEdge &edge : sourceEdges) {
			if (edge.childPageUrl != target) {
				continue;
			}

			QString typeName;
			switch (edge.identifier.type) {
			case Victron::VenusOS::UiTestUtils::ClickIdentifier::Text: typeName = QStringLiteral("text"); break;
			case Victron::VenusOS::UiTestUtils::ClickIdentifier::Title: typeName = QStringLiteral("title"); break;
			case Victron::VenusOS::UiTestUtils::ClickIdentifier::IconSource: typeName = QStringLiteral("iconSource"); break;
			case Victron::VenusOS::UiTestUtils::ClickIdentifier::ObjectName: typeName = QStringLiteral("objectName"); break;
			}
			result.insert(QStringLiteral("exists"), true);
			result.insert(QStringLiteral("type"), typeName);
			result.insert(QStringLiteral("values"), edge.identifier.values);
			return result;
		}

		return result;
	}

	Q_INVOKABLE QVariantMap resolveTargetRoute(const QString &targetPageUrl) const
	{
		using Victron::VenusOS::UiTestUtils::RouteStep;
		QString entryNavText;
		QList<RouteStep> resolvedSteps;
		const bool ok = Victron::VenusOS::UiTestUtils::resolveTargetRoute(
				targetPageUrl, &entryNavText, &resolvedSteps);
		QVariantMap result;
		result.insert(QStringLiteral("success"), ok);
		result.insert(QStringLiteral("entryNavText"), entryNavText);

		// Serialize steps as QVariantList of { type, values, expectedPage } for QML.
		QVariantList steps;
		QStringList labels; // first text label candidate from each text step
		for (const RouteStep &step : resolvedSteps) {
			QString typeName;
			switch (step.identifier.type) {
			case Victron::VenusOS::UiTestUtils::ClickIdentifier::Text: typeName = QStringLiteral("text"); break;
			case Victron::VenusOS::UiTestUtils::ClickIdentifier::Title: typeName = QStringLiteral("title"); break;
			case Victron::VenusOS::UiTestUtils::ClickIdentifier::IconSource: typeName = QStringLiteral("iconSource"); break;
			case Victron::VenusOS::UiTestUtils::ClickIdentifier::ObjectName: typeName = QStringLiteral("objectName"); break;
			}
			steps.append(QVariantMap{
				{ QStringLiteral("type"), typeName },
				{ QStringLiteral("values"), step.identifier.values },
				{ QStringLiteral("expectedPage"), step.expectedPageUrl },
			});
			if (step.identifier.type == Victron::VenusOS::UiTestUtils::ClickIdentifier::Text
					&& !step.identifier.values.isEmpty()) {
				labels.append(step.identifier.values.first());
			}
		}
		result.insert(QStringLiteral("routeSteps"), steps);
		result.insert(QStringLiteral("routeLabels"), labels);
		return result;
	}

	Q_INVOKABLE QStringList normalizeUiTestArguments(const QStringList &arguments) const
	{
		return Victron::VenusOS::UiTestArgUtils::normalizeUiTestArguments(arguments);
	}

	Q_INVOKABLE QString parseUiTestValueFromArgs(const QStringList &arguments) const
	{
		return Victron::VenusOS::UiTestArgUtils::parseUiTestValueFromArgs(arguments);
	}

	Q_INVOKABLE QVariantMap countRuntimeWarningTexts(
			const QStringList &warningTexts,
			const QStringList &alreadyRecorded = QStringList()) const
	{
		QSet<QString> recorded;
		for (const QString &warningText : alreadyRecorded) {
			recorded.insert(warningText);
		}
		QStringList newWarnings;
		const int added = Victron::VenusOS::UiTestResultUtils::countNewRuntimeWarningTexts(
				warningTexts, &recorded, &newWarnings);

		QVariantMap result;
		result.insert(QStringLiteral("addedCount"), added);
		result.insert(QStringLiteral("recordedCount"), recorded.count());
		result.insert(QStringLiteral("newWarnings"), newWarnings);
		return result;
	}

	Q_INVOKABLE int uiTestExitCode(int stepFailures, int runtimeQmlErrors) const
	{
		return Victron::VenusOS::UiTestResultUtils::exitCodeForFailures(stepFailures, runtimeQmlErrors);
	}

	Q_INVOKABLE QObject *findObjectByProperties(
			QObject *sourceObject,
			const QVariantMap &params,
			const QString &typeName = QString()) const
	{
		Victron::VenusOS::UiTestCase testCase;
		return testCase.findObject(sourceObject, params, typeName);
	}

public slots:
	void qmlEngineAvailable(QQmlEngine *engine)
	{
		engine->rootContext()->setContextProperty(
				QStringLiteral("UiTestUtilsHelper"), this);
	}
};

int main(int argc, char **argv)
{
	UiTestUtilsTestHelper helper;

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main_with_setup(argc, argv, "tst_uitestutils",
			resolveTestSourceDir("uitestutils", argv[0]).toLocal8Bit().constData(), &helper);
}

#include "tst_uitestutils.moc"
