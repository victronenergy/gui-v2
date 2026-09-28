/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UITESTUTILS_H
#define VICTRON_GUIV2_UITESTUTILS_H

#include <QHash>
#include <QList>
#include <QQmlError>
#include <QSet>
#include <QString>
#include <QStringList>

namespace Victron {
namespace VenusOS {
namespace UiTestUtils {

struct ClickIdentifier
{
	enum Type {
		Text,       // match by text property value
		Title,      // match by title property value
		IconSource, // match by icon.source grouped property value
		ObjectName, // match by objectName
	};
	Type type = Text;
	QStringList values; // ordered candidate values to try for this identifier type
};

struct RouteEdge
{
	QString childPageUrl;
	ClickIdentifier identifier;
};

struct RouteStep
{
	enum VerifyMode {
		StackPage, // the click pushes a PageStack page; verify topPageUrl
		ShownType, // the click constructs/shows a QML type; verify the type is in the tree
	};

	ClickIdentifier identifier;
	QString expectedPageUrl; // the page or type URL that should be shown after this click
	VerifyMode verifyMode = StackPage;
};

// Convert supported page URL/path forms into canonical "/pages/...qml", or return empty if invalid.
QString normalizePageUrl(const QString &raw);

// Scan QML pages and build source->destination edges with the trigger identifier used to click that edge.
QHash<QString, QList<RouteEdge>> buildPageGraph();

// Find a deterministic click path that constructs and shows the target QML type.
// Swipe-view root pages need only a nav-bar click (empty extra steps). Overlay types
// (StatusBar icons / Loaders) and LevelsPage tabs use static identifiers and
// ShownType verification. PageStack destinations use the pushPage() graph from
// Settings/Overview. Returns false if no static route can be found.
bool resolveTargetRoute(const QString &targetPageUrl, QString *entryNavText,
		QList<RouteStep> *routeSteps);

QStringList normalizeUiTestArguments(const QStringList &arguments);
QString parseUiTestValueFromArgs(const QStringList &arguments);

// Parse a "WxH" window resolution (for example "480x800"). Returns false and
// sets errorMessage when the value is empty, malformed, or not a positive size.
bool parseResolution(const QString &value, int *width, int *height, QString *errorMessage = nullptr);

int countNewRuntimeWarningTexts(
		const QStringList &warningTexts,
		QSet<QString> *recordedWarnings,
		QStringList *newWarningTexts = nullptr);

int countNewRuntimeQmlWarnings(
		const QList<QQmlError> &warnings,
		QSet<QString> *recordedWarnings,
		QStringList *newWarningTexts = nullptr);

int exitCodeForFailures(int stepFailures, int runtimeQmlErrors);

} // namespace UiTestUtils
} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_UITESTUTILS_H
