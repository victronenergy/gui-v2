/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "uitestutils.h"

#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QQueue>
#include <QRegularExpression>
#include <QSet>

namespace Victron {
namespace VenusOS {
namespace UiTestUtils {

namespace {

struct RootRoute
{
	QString rootPageUrl;
	QString entryNavText;
};

struct ComponentNavigationBehavior
{
	QString label; // static text label for this component (from title: or text:)
	ClickIdentifier::Type labelType = ClickIdentifier::Text; // whether label came from text: or title:
	QString destinationLiteral;
	QString destinationProperty;
	QStringList allDestinationLiterals; // all pushPage literal URLs found
};

} // anonymous namespace

QString normalizePageUrl(const QString &raw)
{
	QString page = raw.trimmed();
	if (page.isEmpty()) {
		return QString();
	}

	page.replace('\\', '/');

	static const QString qrcPrefix = QStringLiteral("qrc:/qt/qml/Victron/VenusOS");
	static const QString resourcePrefix = QStringLiteral(":/qt/qml/Victron/VenusOS");
	if (page.startsWith(qrcPrefix)) {
		page = page.mid(qrcPrefix.length());
	} else if (page.startsWith(resourcePrefix)) {
		page = page.mid(resourcePrefix.length());
	} else if (const int pagesIndex = page.indexOf(QStringLiteral("/pages/")); pagesIndex >= 0) {
		page = page.mid(pagesIndex);
	}

	if (!page.startsWith('/')) {
		if (page.startsWith(QStringLiteral("pages/"))) {
			page.prepend('/');
		} else if (page.endsWith(QStringLiteral(".qml")) && !page.contains('/')) {
			// Bare filename: search compiled QML resources for a unique match.
			const QString pagesRoot = QStringLiteral(":/qt/qml/Victron/VenusOS/pages");
			QStringList matches;
			QDirIterator it(pagesRoot, QStringList() << page, QDir::Files, QDirIterator::Subdirectories);
			while (it.hasNext()) {
				QString match = it.next();
				match = match.mid(pagesRoot.length()); // strip resource prefix, keep /subdir/File.qml
				matches.append(match);
			}
			if (matches.size() == 1) {
				page = QStringLiteral("/pages") + matches.first();
			} else {
				// Ambiguous or not found; reject the bare filename.
				return QString();
			}
		}
	}

	if (!page.startsWith(QStringLiteral("/pages/")) || !page.endsWith(QStringLiteral(".qml"))) {
		return QString();
	}
	return page;
}

namespace {

// Count occurrences of a specific brace character in one line for lightweight block parsing.
int countChar(const QString &line, QChar c)
{
	int count = 0;
	for (QChar ch : line) {
		if (ch == c) {
			++count;
		}
	}
	return count;
}

void appendUniqueNonEmpty(QStringList *values, const QString &value)
{
	const QString trimmed = value.trimmed();
	if (!trimmed.isEmpty() && !values->contains(trimmed)) {
		values->append(trimmed);
	}
}

// Resolve static label candidates from a label expression.
// Supports quoted literals, CommonWords.xyz references, and qsTrId() with preceding //% text.
QStringList resolveLabelExpressionCandidates(const QString &expr, const QString &pendingSourceText,
		const QHash<QString, QString> &commonWordsLabels)
{
	QStringList candidates;
	const QString trimmed = expr.trimmed();

	// qsTrId with preceding //% source text
	if (trimmed.startsWith(QStringLiteral("qsTrId(")) && !pendingSourceText.isEmpty()) {
		appendUniqueNonEmpty(&candidates, pendingSourceText);
		return candidates;
	}

	// Never treat translation IDs inside qsTrId("...") as rendered text labels.
	// If source text (//%) is unavailable, strip qsTrId calls and only keep any
	// other static literals that may still exist in surrounding expressions.
	QString withoutQsTrId = trimmed;
	static const QRegularExpression qsTrIdRe(
			R"REGEX(qsTrId\s*\(\s*"[^"]*"\s*(?:,\s*[^)]*)?\))REGEX");
	withoutQsTrId.replace(qsTrIdRe, QString());

	// Quoted literals (including quoted ternary branches, e.g. "Hub-4").
	static const QRegularExpression quotedRe(R"REGEX("([^"]*)")REGEX");
	QRegularExpressionMatchIterator quotedMatches = quotedRe.globalMatch(withoutQsTrId);
	while (quotedMatches.hasNext()) {
		appendUniqueNonEmpty(&candidates, quotedMatches.next().captured(1));
	}

	// CommonWords.xyz (including embedded references in larger expressions).
	// Embedded matching allows data-dependent labels like:
	//   text: systemType.value === "Hub-4" ? systemType.value : CommonWords.ess
	// to expose both static candidates ("Hub-4", "ESS") for graph building.
	static const QRegularExpression commonWordsRe(R"REGEX(CommonWords\.([A-Za-z_][A-Za-z0-9_]*))REGEX");
	QRegularExpressionMatchIterator commonWordsMatches = commonWordsRe.globalMatch(trimmed);
	while (commonWordsMatches.hasNext()) {
		const QRegularExpressionMatch m = commonWordsMatches.next();
		appendUniqueNonEmpty(&candidates, commonWordsLabels.value(m.captured(1).trimmed()));
	}

	return candidates;
}

// Extract the best click identifier from a block: tries text/title first, then icon.source, then objectName.
ClickIdentifier parseIdentifierFromBlock(const QStringList &blockLines, const QHash<QString, QString> &commonWordsLabels = {})
{
	static const QRegularExpression sourceTextRe(R"REGEX(^\s*//%\s*"([^"]+)")REGEX");
	static const QRegularExpression textAssignRe(R"REGEX(^\s*text\s*:\s*(.+)$)REGEX");
	static const QRegularExpression titleAssignRe(R"REGEX(^\s*title\s*:\s*(.+)$)REGEX");
	static const QRegularExpression iconSourceRe(R"REGEX(^\s*icon\.source\s*:\s*"([^"]+)")REGEX");
	static const QRegularExpression objectNameRe(R"REGEX(^\s*objectName\s*:\s*"([^"]+)")REGEX");

	QString pendingSourceText;
	QString iconSource;
	QString objectName;

	for (const QString &line : blockLines) {
		if (const QRegularExpressionMatch sourceMatch = sourceTextRe.match(line); sourceMatch.hasMatch()) {
			pendingSourceText = sourceMatch.captured(1).trimmed();
		}

		if (const QRegularExpressionMatch textMatch = textAssignRe.match(line); textMatch.hasMatch()) {
			const QStringList resolved = resolveLabelExpressionCandidates(
					textMatch.captured(1), pendingSourceText, commonWordsLabels);
			if (!resolved.isEmpty()) {
				return ClickIdentifier{ ClickIdentifier::Text, resolved };
			}
		}

		if (const QRegularExpressionMatch titleMatch = titleAssignRe.match(line); titleMatch.hasMatch()) {
			const QStringList resolved = resolveLabelExpressionCandidates(
					titleMatch.captured(1), pendingSourceText, commonWordsLabels);
			if (!resolved.isEmpty()) {
				return ClickIdentifier{ ClickIdentifier::Title, resolved };
			}
		}

		if (iconSource.isEmpty()) {
			if (const QRegularExpressionMatch iconMatch = iconSourceRe.match(line); iconMatch.hasMatch()) {
				iconSource = iconMatch.captured(1).trimmed();
			}
		}

		if (objectName.isEmpty()) {
			if (const QRegularExpressionMatch nameMatch = objectNameRe.match(line); nameMatch.hasMatch()) {
				objectName = nameMatch.captured(1).trimmed();
			}
		}
	}

	// Fall back to icon.source, then objectName
	if (!iconSource.isEmpty()) {
		return ClickIdentifier{ ClickIdentifier::IconSource, QStringList{ iconSource } };
	}
	if (!objectName.isEmpty()) {
		return ClickIdentifier{ ClickIdentifier::ObjectName, QStringList{ objectName } };
	}

	return ClickIdentifier{};
}

// Resolve all destination pages from pushPage(...) in a navigation block, including property indirection.
QStringList parseDestinationsFromBlock(const QStringList &blockLines)
{
	const QString blockText = blockLines.join('\n');

	static const QRegularExpression pushPageLiteralRe(R"REGEX(pushPage\(\s*"([^"]+)")REGEX");
	static const QRegularExpression pushPagePropertyRe(R"REGEX(pushPage\(\s*([A-Za-z_][A-Za-z0-9_]*)\b)REGEX");
	static const QRegularExpression propertyAssignReTemplate(
			R"REGEX(^\s*%1\s*:\s*"([^"]+)")REGEX",
			QRegularExpression::MultilineOption);

	QStringList destinations;

	// Collect all literal pushPage destinations.
	QRegularExpressionMatchIterator pushMatches = pushPageLiteralRe.globalMatch(blockText);
	while (pushMatches.hasNext()) {
		const QString dest = normalizePageUrl(pushMatches.next().captured(1));
		if (!dest.isEmpty() && !destinations.contains(dest)) {
			destinations.append(dest);
		}
	}

	// If no literal destinations found, try property indirection for a single destination.
	if (destinations.isEmpty()) {
		if (const QRegularExpressionMatch pushPropertyMatch = pushPagePropertyRe.match(blockText); pushPropertyMatch.hasMatch()) {
			const QString propertyName = pushPropertyMatch.captured(1).trimmed();
			if (!propertyName.isEmpty()) {
				const QRegularExpression propertyAssignRe(
						propertyAssignReTemplate.pattern().arg(QRegularExpression::escape(propertyName)),
						QRegularExpression::MultilineOption);
				if (const QRegularExpressionMatch propertyMatch = propertyAssignRe.match(blockText); propertyMatch.hasMatch()) {
					const QString dest = normalizePageUrl(propertyMatch.captured(1));
					if (!dest.isEmpty()) {
						destinations.append(dest);
					}
				}
			}
		}
	}

	return destinations;
}

// Pre-parse CommonWords.qml to build a map of property name → source text string.
// Parses patterns like:
//   //% "Battery"\n  readonly property string battery: qsTrId(...)
//   //% "AC Sensors"\n property string ac_sensors: qsTrId(...)
QHash<QString, QString> parseCommonWordsLabels()
{
	QHash<QString, QString> labels;
	QFile file(QStringLiteral(":/qt/qml/Victron/VenusOS/components/CommonWords.qml"));
	if (!file.open(QFile::ReadOnly | QFile::Text)) {
		return labels;
	}

	static const QRegularExpression sourceTextRe(R"REGEX(^\s*//%\s*"([^"]+)")REGEX");
	static const QRegularExpression propertyRe(
			R"REGEX(^\s*(?:readonly\s+)?property\s+string\s+([A-Za-z_][A-Za-z0-9_]*)\s*:)REGEX");

	QString pendingSourceText;
	const QStringList lines = QString::fromUtf8(file.readAll()).split('\n');
	for (const QString &line : lines) {
		if (const QRegularExpressionMatch sourceMatch = sourceTextRe.match(line); sourceMatch.hasMatch()) {
			pendingSourceText = sourceMatch.captured(1).trimmed();
		} else if (const QRegularExpressionMatch propMatch = propertyRe.match(line); propMatch.hasMatch()) {
			if (!pendingSourceText.isEmpty()) {
				labels.insert(propMatch.captured(1).trimmed(), pendingSourceText);
			}
			pendingSourceText.clear();
		} else {
			pendingSourceText.clear();
		}
	}
	return labels;
}

// Pre-scan component files to build a global map of type name → navigation behavior.
// Scans top-level components/ (e.g. SystemBatteryDelegate) and components/widgets/.
QHash<QString, ComponentNavigationBehavior> scanExternalComponents(const QHash<QString, QString> &commonWordsLabels)
{
	QHash<QString, ComponentNavigationBehavior> behaviors;

	static const QStringList scanDirs = {
		QStringLiteral(":/qt/qml/Victron/VenusOS/components"),
		QStringLiteral(":/qt/qml/Victron/VenusOS/components/widgets"),
	};

	static const QRegularExpression sourceTextRe(R"REGEX(^\s*//%\s*"([^"]+)")REGEX");
	static const QRegularExpression textAssignRe(R"REGEX(^\s*text\s*:\s*(.+)$)REGEX");
	static const QRegularExpression titleAssignRe(R"REGEX(^\s*title\s*:\s*(.+)$)REGEX");
	static const QRegularExpression pushPageLiteralRe(R"REGEX(pushPage\(\s*"([^"]+)")REGEX");

	for (const QString &dir : scanDirs) {
		QDirIterator it(dir, QStringList() << QStringLiteral("*.qml"), QDir::Files);
		while (it.hasNext()) {
			const QString filePath = it.next();
			QFile file(filePath);
			if (!file.open(QFile::ReadOnly | QFile::Text)) {
				continue;
			}

			// Derive type name from filename (e.g. "BatteryWidget.qml" → "BatteryWidget")
			const QString typeName = QFileInfo(filePath).baseName();
			const QString content = QString::fromUtf8(file.readAll());
			const QStringList lines = content.split('\n');

			ComponentNavigationBehavior behavior;

			// Find the first title/text label at root level
			QString pendingSourceText;
			int depth = 0;
			bool passedRoot = false;
			for (const QString &line : lines) {
				if (!passedRoot) {
					if (line.contains('{')) {
						passedRoot = true;
						depth = countChar(line, '{') - countChar(line, '}');
					}
					continue;
				}
				depth += countChar(line, '{') - countChar(line, '}');

				if (const QRegularExpressionMatch srcMatch = sourceTextRe.match(line); srcMatch.hasMatch()) {
					pendingSourceText = srcMatch.captured(1).trimmed();
				} else if (depth == 1 && behavior.label.isEmpty()) {
					// Only match title/text at root level of the component (depth 1)
					if (const QRegularExpressionMatch textMatch = textAssignRe.match(line); textMatch.hasMatch()) {
						const QStringList labels = resolveLabelExpressionCandidates(
								textMatch.captured(1).trimmed(), pendingSourceText, commonWordsLabels);
						behavior.label = labels.isEmpty() ? QString() : labels.first();
						behavior.labelType = ClickIdentifier::Text;
						pendingSourceText.clear();
					} else if (const QRegularExpressionMatch titleMatch = titleAssignRe.match(line); titleMatch.hasMatch()) {
						const QStringList labels = resolveLabelExpressionCandidates(
								titleMatch.captured(1).trimmed(), pendingSourceText, commonWordsLabels);
						behavior.label = labels.isEmpty() ? QString() : labels.first();
						behavior.labelType = ClickIdentifier::Title;
						pendingSourceText.clear();
					}
				}
			}

			// Find all pushPage literal destinations
			QRegularExpressionMatchIterator pushMatches = pushPageLiteralRe.globalMatch(content);
			while (pushMatches.hasNext()) {
				const QRegularExpressionMatch m = pushMatches.next();
				const QString dest = normalizePageUrl(m.captured(1));
				if (!dest.isEmpty() && !behavior.allDestinationLiterals.contains(dest)) {
					behavior.allDestinationLiterals.append(dest);
				}
			}

			if (!behavior.allDestinationLiterals.isEmpty()) {
				behavior.destinationLiteral = behavior.allDestinationLiterals.first();
			}

			if (!behavior.label.isEmpty() && !behavior.allDestinationLiterals.isEmpty()) {
				behaviors.insert(typeName, behavior);
			}
		}
	}

	return behaviors;
}

} // anonymous namespace

QHash<QString, QList<RouteEdge>> buildPageGraph()
{
	QHash<QString, QList<RouteEdge>> graph;

	// Pre-parse CommonWords and external component files (widgets) for label/destination resolution.
	const QHash<QString, QString> commonWordsLabels = parseCommonWordsLabels();
	const QHash<QString, ComponentNavigationBehavior> externalBehaviors = scanExternalComponents(commonWordsLabels);

	QDirIterator it(
			QStringLiteral(":/qt/qml/Victron/VenusOS/pages"),
			QStringList() << QStringLiteral("*.qml"),
			QDir::Files,
			QDirIterator::Subdirectories);

	while (it.hasNext()) {
		const QString filePath = it.next();
		QFile file(filePath);
		if (!file.open(QFile::ReadOnly | QFile::Text)) {
			continue;
		}

		const QString sourcePageUrl = normalizePageUrl(filePath);
		if (sourcePageUrl.isEmpty()) {
			continue;
		}

		const QStringList lines = QString::fromUtf8(file.readAll()).split('\n');

		QHash<QString, ComponentNavigationBehavior> componentBehaviors;
		static const QRegularExpression componentStartRe(
				R"REGEX(^\s*component\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*[A-Za-z_][A-Za-z0-9_]*\s*\{)REGEX");
		{
			bool inComponentBlock = false;
			int componentBraceDepth = 0;
			QString componentName;
			QStringList componentLines;

			for (const QString &line : lines) {
				if (!inComponentBlock) {
					const QRegularExpressionMatch componentStartMatch = componentStartRe.match(line);
					if (componentStartMatch.hasMatch()) {
						inComponentBlock = true;
						componentName = componentStartMatch.captured(1).trimmed();
						componentBraceDepth = countChar(line, '{') - countChar(line, '}');
						componentLines = QStringList{ line };
						if (componentBraceDepth <= 0) {
							inComponentBlock = false;
						}
					}
					continue;
				}

				componentLines.append(line);
				componentBraceDepth += countChar(line, '{') - countChar(line, '}');
				if (componentBraceDepth > 0) {
					continue;
				}

				inComponentBlock = false;
				if (componentName.isEmpty()) {
					continue;
				}

				const QString componentText = componentLines.join('\n');
				static const QRegularExpression pushPageLiteralRe(R"REGEX(pushPage\(\s*"([^"]+)")REGEX");
				static const QRegularExpression pushPagePropertyRe(
						R"REGEX(pushPage\(\s*([A-Za-z_][A-Za-z0-9_]*)\b)REGEX");

				ComponentNavigationBehavior behavior;
				if (const QRegularExpressionMatch pushLiteralMatch = pushPageLiteralRe.match(componentText);
						pushLiteralMatch.hasMatch()) {
					behavior.destinationLiteral = pushLiteralMatch.captured(1).trimmed();
				} else if (const QRegularExpressionMatch pushPropertyMatch = pushPagePropertyRe.match(componentText);
						pushPropertyMatch.hasMatch()) {
					behavior.destinationProperty = pushPropertyMatch.captured(1).trimmed();
				}

				if (!behavior.destinationLiteral.isEmpty() || !behavior.destinationProperty.isEmpty()) {
					componentBehaviors.insert(componentName, behavior);
				}
			}
		}

		bool inNavBlock = false;
		int braceDepth = 0;
		QStringList blockLines;
		QString blockTypeName;

		// Scan for navigable component blocks at any nesting depth. Only track blocks whose
		// type name matches a known navigable type (ListNavigation, ListQuantityGroupNavigation,
		// inline component instances, or external component types).
		// Container types (Page, Column, ListView, etc.) are NOT tracked, so the scanner
		// descends into them and finds nav items inside.
		// Note: DeviceListDelegate variants are NOT included here. They are dynamically loaded
		// by DeviceListPage via ListItemLoader with computed URLs, and their text labels are
		// data-dependent, so they cannot be statically resolved. See README for details.
		static const QRegularExpression navStartRe(
				R"REGEX(^\s*((?:List|Settings)(?:Navigation|Button|TextItem)|ListQuantityGroupNavigation)\s*\{)REGEX");
		static const QRegularExpression typeStartRe(R"REGEX(^\s*([A-Za-z_][A-Za-z0-9_]*)\s*\{)REGEX");
		for (const QString &line : lines) {
			if (!inNavBlock) {
				const QRegularExpressionMatch typeStartMatch = typeStartRe.match(line);
				if (!typeStartMatch.hasMatch()) {
					continue;
				}
				const QString typeName = typeStartMatch.captured(1).trimmed();
				// Only track this block if it's a known navigable type.
				const bool isKnownNavType = navStartRe.match(line).hasMatch()
						|| componentBehaviors.contains(typeName)
						|| externalBehaviors.contains(typeName);
				if (!isKnownNavType) {
					continue;
				}
				inNavBlock = true;
				blockTypeName = typeName;
				braceDepth = countChar(line, '{') - countChar(line, '}');
				blockLines = QStringList{ line };
				if (braceDepth <= 0) {
					inNavBlock = false;
				}
				continue;
			}

			blockLines.append(line);
			braceDepth += countChar(line, '{') - countChar(line, '}');
			if (braceDepth > 0) {
				continue;
			}

			inNavBlock = false;
			ClickIdentifier identifier = parseIdentifierFromBlock(blockLines, commonWordsLabels);
			QStringList destinationPageUrls = parseDestinationsFromBlock(blockLines);

			// Check inline component behaviors (component X : Y { ... })
			if (destinationPageUrls.isEmpty() && componentBehaviors.contains(blockTypeName)) {
				const ComponentNavigationBehavior behavior = componentBehaviors.value(blockTypeName);
				if (!behavior.destinationLiteral.isEmpty()) {
					const QString dest = normalizePageUrl(behavior.destinationLiteral);
					if (!dest.isEmpty()) {
						destinationPageUrls.append(dest);
					}
				} else if (!behavior.destinationProperty.isEmpty()) {
					const QString propertyPattern = QStringLiteral(R"REGEX(^\s*%1\s*:\s*"([^"]+)")REGEX")
							.arg(QRegularExpression::escape(behavior.destinationProperty));
					const QRegularExpression propertyRe(propertyPattern);
					for (const QString &blockLine : blockLines) {
						const QRegularExpressionMatch propertyMatch = propertyRe.match(blockLine);
						if (!propertyMatch.hasMatch()) {
							continue;
						}
						const QString dest = normalizePageUrl(propertyMatch.captured(1));
						if (!dest.isEmpty()) {
							destinationPageUrls.append(dest);
							break;
						}
					}
				}
				if (identifier.values.isEmpty() && !behavior.label.isEmpty()) {
					identifier = ClickIdentifier{ behavior.labelType, QStringList{ behavior.label } };
				}
			}

			// Check external component behaviors (widgets, etc.)
			if (externalBehaviors.contains(blockTypeName)) {
				const ComponentNavigationBehavior &extBehavior = externalBehaviors.value(blockTypeName);
				if (identifier.values.isEmpty() && !extBehavior.label.isEmpty()) {
					identifier = ClickIdentifier{ extBehavior.labelType, QStringList{ extBehavior.label } };
				}
				if (!identifier.values.isEmpty()) {
						// Add edges for ALL destinations from the external component.
						// At runtime, only one destination will be reachable depending on
						// data state; the target-page test verifies the correct page opened.
						for (const QString &dest : extBehavior.allDestinationLiterals) {
							if (!dest.isEmpty()) {
								graph[sourcePageUrl].append(RouteEdge{
									.childPageUrl = dest,
									.identifier = identifier,
								});
							}
						}
						continue; // skip the multi-edge logic below
				}
			}

			// Add edges for all destinations from the navigation block.
			// Runtime branches (e.g. if/else with different pushPage calls) produce
			// multiple destinations; the expected-page check validates the active branch.
			if (!identifier.values.isEmpty()) {
				for (const QString &dest : destinationPageUrls) {
					graph[sourcePageUrl].append(RouteEdge{
						.childPageUrl = dest,
						.identifier = identifier,
					});
				}
			}
		}
	}

	return graph;
}

bool resolveTargetRoute(const QString &targetPageUrl, QString *entryNavText,
		QList<RouteStep> *routeSteps)
{
	static const QList<RootRoute> roots = {
		{
			QStringLiteral("/pages/SettingsPage.qml"),
			QStringLiteral("Settings"),
		},
		{
			QStringLiteral("/pages/OverviewPage_Landscape.qml"),
			QStringLiteral("Overview"),
		},
		{
			QStringLiteral("/pages/OverviewPage_Portrait.qml"),
			QStringLiteral("Overview"),
		},
	};

	const QHash<QString, QList<RouteEdge>> graph = buildPageGraph();

	for (const RootRoute &root : roots) {
		if (targetPageUrl == root.rootPageUrl) {
			continue;
		}

		if (!graph.contains(root.rootPageUrl)) {
			continue;
		}

		QQueue<QString> queue;
		QSet<QString> visited;
		QHash<QString, QString> parentByChild;
		QHash<QString, ClickIdentifier> identifierByChild;
		queue.enqueue(root.rootPageUrl);
		visited.insert(root.rootPageUrl);

		while (!queue.isEmpty()) {
			const QString current = queue.dequeue();
			const QList<RouteEdge> edges = graph.value(current);
			for (const RouteEdge &edge : edges) {
				if (visited.contains(edge.childPageUrl)) {
					continue;
				}
				visited.insert(edge.childPageUrl);
				parentByChild.insert(edge.childPageUrl, current);
				identifierByChild.insert(edge.childPageUrl, edge.identifier);
				if (edge.childPageUrl == targetPageUrl) {
					queue.clear();
					break;
				}
				queue.enqueue(edge.childPageUrl);
			}
		}

		if (!parentByChild.contains(targetPageUrl)) {
			continue;
		}

		// Reconstruct the route from root to target.
		// Walk backwards: each child knows its parent and the identifier used to reach it.
		QList<RouteStep> reversedSteps;
		QString current = targetPageUrl;
		while (current != root.rootPageUrl) {
			reversedSteps.append(RouteStep{
				.identifier = identifierByChild.value(current),
				.expectedPageUrl = current,
			});
			current = parentByChild.value(current);
			if (current.isEmpty()) {
				break;
			}
		}

		if (current != root.rootPageUrl) {
			continue;
		}

		*entryNavText = root.entryNavText;
		routeSteps->clear();
		for (auto it = reversedSteps.crbegin(); it != reversedSteps.crend(); ++it) {
			routeSteps->append(*it);
		}
		return true;
	}

	return false;
}

} // namespace UiTestUtils
} // namespace VenusOS
} // namespace Victron
