/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UITESTUTILS_H
#define VICTRON_GUIV2_UITESTUTILS_H

#include <QHash>
#include <QList>
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
	ClickIdentifier identifier;
	QString expectedPageUrl; // the page that should open after this click
};

// Convert supported page URL/path forms into canonical "/pages/...qml", or return empty if invalid.
QString normalizePageUrl(const QString &raw);

// Scan QML pages and build source->destination edges with the trigger identifier used to click that edge.
QHash<QString, QList<RouteEdge>> buildPageGraph();

// Find a deterministic click path from a known root page to the target page and return
// the steps (identifier + expected destination) for each hop. Returns false if the target
// page is a root page itself (not reachable via pushPage), or if no route can be found.
bool resolveTargetRoute(const QString &targetPageUrl, QString *entryNavText,
		QList<RouteStep> *routeSteps);

} // namespace UiTestUtils
} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_UITESTUTILS_H
