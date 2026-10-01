/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "uitestutils.h"

#include "themeobjects.h"

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
	static const QString boatQrcPrefix = QStringLiteral("qrc:/qt/qml/Victron/Boat");
	static const QString boatResourcePrefix = QStringLiteral(":/qt/qml/Victron/Boat");
	if (page.startsWith(qrcPrefix)) {
		page = page.mid(qrcPrefix.length());
	} else if (page.startsWith(resourcePrefix)) {
		page = page.mid(resourcePrefix.length());
	} else if (page.startsWith(boatQrcPrefix)) {
		page = QStringLiteral("/pages/boat") + page.mid(boatQrcPrefix.length());
	} else if (page.startsWith(boatResourcePrefix)) {
		page = QStringLiteral("/pages/boat") + page.mid(boatResourcePrefix.length());
	} else if (const int pagesIndex = page.indexOf(QStringLiteral("/pages/")); pagesIndex >= 0) {
		page = page.mid(pagesIndex);
	}

	if (!page.startsWith('/')) {
		if (page.startsWith(QStringLiteral("pages/"))) {
			page.prepend('/');
		} else if (page.endsWith(QStringLiteral(".qml")) && !page.contains('/')) {
			// Bare filename: search compiled QML resources for a unique match.
			const QString pagesRoot = QStringLiteral(":/qt/qml/Victron/VenusOS/pages");
			const QString boatRoot = QStringLiteral(":/qt/qml/Victron/Boat");
			QStringList matches;
			QDirIterator it(pagesRoot, QStringList() << page, QDir::Files, QDirIterator::Subdirectories);
			while (it.hasNext()) {
				matches.append(QStringLiteral("/pages") + it.next().mid(pagesRoot.length()));
			}
			QDirIterator boatIt(boatRoot, QStringList() << page, QDir::Files, QDirIterator::Subdirectories);
			while (boatIt.hasNext()) {
				matches.append(QStringLiteral("/pages/boat/") + QFileInfo(boatIt.next()).fileName());
			}
			if (matches.size() == 1) {
				page = matches.first();
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

QString rootTypeName(const QString &content)
{
	const QStringList lines = content.split('\n');
	bool inBlockComment = false;
	for (const QString &line : lines) {
		const QString trimmed = line.trimmed();
		if (inBlockComment) {
			if (trimmed.contains(QStringLiteral("*/"))) {
				inBlockComment = false;
			}
			continue;
		}
		if (trimmed.startsWith(QStringLiteral("/*"))) {
			inBlockComment = !trimmed.contains(QStringLiteral("*/"));
			continue;
		}
		if (trimmed.startsWith(QStringLiteral("//"))
				|| trimmed.startsWith(QStringLiteral("import "))
				|| trimmed.startsWith(QStringLiteral("pragma "))
				|| trimmed.isEmpty()) {
			continue;
		}
		static const QRegularExpression re(R"REGEX(^([A-Za-z_][A-Za-z0-9_.]*)\s*\{)REGEX");
		if (const QRegularExpressionMatch match = re.match(trimmed); match.hasMatch()) {
			return match.captured(1);
		}
		return QString();
	}
	return QString();
}

QString extractTitleFromContent(const QString &content, const QHash<QString, QString> &commonWordsLabels)
{
	static const QRegularExpression sourceTextRe(R"REGEX(^\s*//%\s*"([^"]+)")REGEX");
	static const QRegularExpression titleAssignRe(R"REGEX(^\s*title\s*:\s*(.+)$)REGEX");

	QString pendingSourceText;
	int depth = 0;
	bool passedRoot = false;
	const QStringList lines = content.split('\n');
	for (const QString &line : lines) {
		if (!passedRoot) {
			if (line.contains('{')) {
				passedRoot = true;
				depth = countChar(line, '{') - countChar(line, '}');
			}
			continue;
		}
		depth += countChar(line, '{') - countChar(line, '}');
		if (const QRegularExpressionMatch sourceMatch = sourceTextRe.match(line); sourceMatch.hasMatch()) {
			pendingSourceText = sourceMatch.captured(1).trimmed();
		}
		if (depth == 1) {
			if (const QRegularExpressionMatch titleMatch = titleAssignRe.match(line); titleMatch.hasMatch()) {
				const QStringList labels = resolveLabelExpressionCandidates(
						titleMatch.captured(1).trimmed(), pendingSourceText, commonWordsLabels);
				if (!labels.isEmpty()) {
					return labels.first();
				}
			}
		}
		if (depth <= 0) {
			break;
		}
	}
	return QString();
}

QList<RootRoute> scanSwipeRootPages(const QHash<QString, QString> &commonWordsLabels)
{
	QList<RootRoute> roots;
	const QStringList resourceRoots = {
		QStringLiteral(":/qt/qml/Victron/VenusOS/pages"),
		QStringLiteral(":/qt/qml/Victron/Boat"),
	};
	for (const QString &pagesRoot : resourceRoots) {
		QDirIterator it(pagesRoot, QStringList() << QStringLiteral("*.qml"), QDir::Files);
		while (it.hasNext()) {
			const QString filePath = it.next();
			QFile file(filePath);
			if (!file.open(QFile::ReadOnly | QFile::Text)) {
				continue;
			}
			const QString content = QString::fromUtf8(file.readAll());
			if (rootTypeName(content) != QStringLiteral("SwipeViewPage")) {
				continue;
			}
			const QString url = normalizePageUrl(filePath);
			const QString title = extractTitleFromContent(content, commonWordsLabels);
			if (url.isEmpty() || title.isEmpty()) {
				continue;
			}
			roots.append(RootRoute{ url, title });
		}
	}
	return roots;
}

void parseStatusBarActivations(const QString &filePath, QHash<QString, ClickIdentifier> *signalToClick)
{
	QFile file(filePath);
	if (!file.open(QFile::ReadOnly | QFile::Text)) {
		return;
	}

	static const QRegularExpression svgRe(R"REGEX("([^"]+\.svg)")REGEX");
	static const QRegularExpression signalRe(
			R"REGEX(\b(controlCardsActivated|auxCardsActivated|sidePanelToggled)\s*\()REGEX");

	const QStringList lines = QString::fromUtf8(file.readAll()).split('\n');
	bool inButton = false;
	int depth = 0;
	QStringList icons;
	QStringList emittedSignals;

	const auto flushButton = [&]() {
		if (emittedSignals.isEmpty() || icons.isEmpty()) {
			return;
		}
		QStringList offIcons;
		QStringList otherIcons;
		for (const QString &icon : icons) {
			if (icon.contains(QStringLiteral("_off_"))) {
				offIcons.append(icon);
			} else if (!icon.contains(QStringLiteral("_on_"))
					&& !icon.contains(QStringLiteral("icon_back_"))
					&& !icon.contains(QStringLiteral("icon_plus"))
					&& !icon.contains(QStringLiteral("icon_refresh"))) {
				otherIcons.append(icon);
			}
		}
		const QStringList preferred = !offIcons.isEmpty() ? offIcons : otherIcons;
		if (preferred.isEmpty()) {
			return;
		}
		for (const QString &signalName : emittedSignals) {
			ClickIdentifier &identifier = (*signalToClick)[signalName];
			identifier.type = ClickIdentifier::IconSource;
			for (const QString &icon : preferred) {
				appendUniqueNonEmpty(&identifier.values, icon);
			}
		}
	};

	for (const QString &line : lines) {
		if (!inButton) {
			if (!line.contains(QStringLiteral("StatusBarButton"))) {
				continue;
			}
			inButton = true;
			depth = countChar(line, '{') - countChar(line, '}');
			icons.clear();
			emittedSignals.clear();
			if (depth <= 0) {
				inButton = false;
			}
			continue;
		}

		depth += countChar(line, '{') - countChar(line, '}');
		QRegularExpressionMatchIterator svgMatches = svgRe.globalMatch(line);
		while (svgMatches.hasNext()) {
			appendUniqueNonEmpty(&icons, svgMatches.next().captured(1));
		}
		QRegularExpressionMatchIterator signalMatches = signalRe.globalMatch(line);
		while (signalMatches.hasNext()) {
			appendUniqueNonEmpty(&emittedSignals, signalMatches.next().captured(1));
		}
		if (depth <= 0) {
			flushButton();
			inButton = false;
		}
	}
}

QHash<QString, ClickIdentifier> scanStatusBarActivations()
{
	QHash<QString, ClickIdentifier> signalToClick;
	parseStatusBarActivations(
			QStringLiteral(":/qt/qml/Victron/VenusOS/components/StatusBar_Landscape.qml"),
			&signalToClick);
	parseStatusBarActivations(
			QStringLiteral(":/qt/qml/Victron/VenusOS/components/StatusBar_Portrait.qml"),
			&signalToClick);
	return signalToClick;
}

struct ShownTypeRoute
{
	QString typeUrl;
	QString entryNavText;
	QList<RouteStep> extraClicks;
};

QString uniquePageUrlForTypeName(const QHash<QString, QStringList> &qmlFilesByTypeName, const QString &typeName)
{
	const QStringList files = qmlFilesByTypeName.value(typeName);
	if (files.size() != 1) {
		return QString();
	}
	return normalizePageUrl(files.first());
}

bool isPortraitLayout()
{
	return ThemeSingleton::create()->screenSize() == Theme::Portrait;
}

// Layout loaders pick one of a *_Portrait / *_Landscape pair from
// Theme.screenSize (see .github/layout-modes.md). The inactive file is not
// instantiated, so it must not get a shown-type route.
bool isActiveOrientationType(const QString &typeName, bool portraitLayout)
{
	if (typeName.endsWith(QStringLiteral("_Portrait"))) {
		return portraitLayout;
	}
	if (typeName.endsWith(QStringLiteral("_Landscape"))) {
		return !portraitLayout;
	}
	return true;
}

// True when the TypeName { block has a property-level visible: binding
// that is not unconditionally true. Nested children's visible: lines are
// ignored. Used to skip constructed-but-hidden types, except LevelsPage
// tab children which get an explicit TabBar click.
bool instantiationHasConditionalVisible(const QStringList &lines, int startIndex)
{
	static const QRegularExpression visibleRe(R"REGEX(^\s*visible\s*:)REGEX");
	static const QRegularExpression visibleTrueRe(R"REGEX(^\s*visible\s*:\s*true\b)REGEX");

	int depth = 0;
	for (int i = startIndex; i < lines.size(); ++i) {
		const QString &line = lines.at(i);
		if (i > startIndex && depth == 1 && visibleRe.match(line).hasMatch()) {
			return !visibleTrueRe.match(line).hasMatch();
		}
		depth += countChar(line, '{') - countChar(line, '}');
		if (depth <= 0) {
			break;
		}
	}
	return false;
}

// LevelsPage TabBar model labels from //% source text, in model order.
QStringList parseLevelsTabBarLabels(const QStringList &lines)
{
	static const QRegularExpression tabBarStartRe(R"REGEX(^\s*TabBar\s*\{)REGEX");
	static const QRegularExpression sourceTextRe(R"REGEX(^\s*//%\s*"([^"]+)")REGEX");

	QStringList labels;
	bool inTabBar = false;
	int depth = 0;
	for (const QString &line : lines) {
		if (!inTabBar) {
			if (tabBarStartRe.match(line).hasMatch()) {
				inTabBar = true;
				depth = countChar(line, '{') - countChar(line, '}');
			}
			continue;
		}
		if (const QRegularExpressionMatch match = sourceTextRe.match(line); match.hasMatch()) {
			labels.append(match.captured(1).trimmed());
		}
		depth += countChar(line, '{') - countChar(line, '}');
		if (depth <= 0) {
			break;
		}
	}
	return labels;
}

// visible: tabBar.currentIndex === N on the TypeName { block, or -1.
int levelsTabVisibleIndex(const QStringList &lines, int startIndex)
{
	static const QRegularExpression indexRe(
			R"REGEX(^\s*visible\s*:\s*tabBar\.currentIndex\s*===\s*(\d+)\b)REGEX");

	int depth = 0;
	for (int i = startIndex; i < lines.size(); ++i) {
		const QString &line = lines.at(i);
		if (i > startIndex && depth == 1) {
			if (const QRegularExpressionMatch match = indexRe.match(line); match.hasMatch()) {
				return match.captured(1).toInt();
			}
		}
		depth += countChar(line, '{') - countChar(line, '}');
		if (depth <= 0) {
			break;
		}
	}
	return -1;
}

QList<ShownTypeRoute> scanShownTypeRoutes(const QList<RootRoute> &swipeRoots)
{
	QHash<QString, QStringList> qmlFilesByTypeName;
	QDirIterator fileIt(
			QStringLiteral(":/qt/qml/Victron/VenusOS/pages"),
			QStringList() << QStringLiteral("*.qml"),
			QDir::Files,
			QDirIterator::Subdirectories);
	while (fileIt.hasNext()) {
		const QString path = fileIt.next();
		qmlFilesByTypeName[QFileInfo(path).baseName()].append(path);
	}

	QHash<QString, QStringList> typeToContainerTypes;
	QSet<QString> onDemandTypes;
	QSet<QString> typesWithToggleSidePanel;
	QHash<QString, QString> mainViewComponentIdToType;
	QHash<QString, QString> mainViewSignalToComponentId;
	QHash<QString, ClickIdentifier> tabActivationByType;

	static const QRegularExpression sourceComponentRe(
			R"REGEX(^\s*sourceComponent\s*:\s*([A-Z][A-Za-z0-9_]*))REGEX");
	static const QRegularExpression loaderStartRe(R"REGEX(\bLoader\s*\{)REGEX");
	static const QRegularExpression componentStartRe(R"REGEX(^\s*Component\s*\{)REGEX");
	static const QRegularExpression componentIdRe(R"REGEX(^\s*id\s*:\s*([A-Za-z_][A-Za-z0-9_]*))REGEX");
	static const QRegularExpression typeBraceRe(R"REGEX(^\s*([A-Z][A-Za-z0-9_]*)\s*\{)REGEX");
	static const QRegularExpression cardsShowRe(
			R"REGEX(on([A-Za-z]+)\s*:\s*cardsLoader\.show\((\w+)\))REGEX");
	static const QRegularExpression toggleSidePanelRe(R"REGEX(\btoggleSidePanel\s*\()REGEX");

	const bool portraitLayout = isPortraitLayout();
	const auto recordInstantiation = [&](const QString &typeName, const QString &containerType) {
		if (typeName.isEmpty() || containerType.isEmpty() || typeName == containerType) {
			return;
		}
		// Skip the inactive orientation's layout type, and types that only
		// appear inside that file. Recording both Component branches of
		// `sourceComponent: Theme.screenSize === Theme.Portrait ? ...`
		// would give the unused type a zero-click route that times out.
		if (!isActiveOrientationType(typeName, portraitLayout)
				|| !isActiveOrientationType(containerType, portraitLayout)) {
			return;
		}
		QStringList &containers = typeToContainerTypes[typeName];
		if (!containers.contains(containerType)) {
			containers.append(containerType);
		}
	};

	QDirIterator pageIt(
			QStringLiteral(":/qt/qml/Victron/VenusOS/pages"),
			QStringList() << QStringLiteral("*.qml"),
			QDir::Files,
			QDirIterator::Subdirectories);
	while (pageIt.hasNext()) {
		const QString filePath = pageIt.next();
		QFile file(filePath);
		if (!file.open(QFile::ReadOnly | QFile::Text)) {
			continue;
		}
		const QString containerType = QFileInfo(filePath).baseName();
		const QString content = QString::fromUtf8(file.readAll());
		const QStringList lines = content.split('\n');
		const bool isMainView = containerType == QStringLiteral("MainView");
		if (toggleSidePanelRe.match(content).hasMatch()) {
			typesWithToggleSidePanel.insert(containerType);
		}

		// Record inline page types, but not constructed-and-hidden children
		// unless LevelsPage tab activation is known (Tanks / Environment).
		const QStringList levelsTabLabels = containerType == QStringLiteral("LevelsPage")
				? parseLevelsTabBarLabels(lines)
				: QStringList();
		static const QRegularExpression typeStartRe(
				R"REGEX(^\s*([A-Z][A-Za-z0-9_]*)\s*\{)REGEX");
		for (int i = 0; i < lines.size(); ++i) {
			const QString &line = lines.at(i);
			if (const QRegularExpressionMatch typeMatch = typeStartRe.match(line); typeMatch.hasMatch()) {
				const QString typeName = typeMatch.captured(1);
				if (!qmlFilesByTypeName.contains(typeName)) {
					continue;
				}
				const int tabIndex = levelsTabLabels.isEmpty()
						? -1
						: levelsTabVisibleIndex(lines, i);
				if (tabIndex >= 0 && tabIndex < levelsTabLabels.size()) {
					recordInstantiation(typeName, containerType);
					tabActivationByType.insert(typeName, ClickIdentifier{
						ClickIdentifier::Text,
						QStringList{ levelsTabLabels.at(tabIndex) },
					});
					continue;
				}
				if (!instantiationHasConditionalVisible(lines, i)) {
					recordInstantiation(typeName, containerType);
				}
			}
		}

		QRegularExpressionMatchIterator showMatches = cardsShowRe.globalMatch(content);
		while (showMatches.hasNext()) {
			const QRegularExpressionMatch match = showMatches.next();
			QString signalName = match.captured(1);
			if (!signalName.isEmpty()) {
				signalName[0] = signalName[0].toLower();
			}
			mainViewSignalToComponentId.insert(signalName, match.captured(2));
		}

		bool inLoader = false;
		bool inComponent = false;
		int depth = 0;
		QString loaderType;
		bool loaderActiveFalse = false;
		QString componentId;
		QString componentType;

		for (const QString &line : lines) {
			if (!inLoader && !inComponent) {
				if (loaderStartRe.match(line).hasMatch()) {
					inLoader = true;
					depth = countChar(line, '{') - countChar(line, '}');
					loaderType.clear();
					loaderActiveFalse = false;
				} else if (componentStartRe.match(line).hasMatch()) {
					inComponent = true;
					depth = countChar(line, '{') - countChar(line, '}');
					componentId.clear();
					componentType.clear();
				} else {
					continue;
				}
				if (depth <= 0) {
					inLoader = false;
					inComponent = false;
				}
				continue;
			}

			depth += countChar(line, '{') - countChar(line, '}');
			if (inLoader) {
				if (const QRegularExpressionMatch typeMatch = sourceComponentRe.match(line); typeMatch.hasMatch()) {
					loaderType = typeMatch.captured(1);
				}
				if (line.contains(QStringLiteral("active")) && line.contains(QStringLiteral("false"))) {
					static const QRegularExpression activeFalseRe(R"REGEX(^\s*active\s*:\s*false\b)REGEX");
					if (activeFalseRe.match(line).hasMatch()) {
						loaderActiveFalse = true;
					}
				}
				if (depth <= 0) {
					if (!loaderType.isEmpty()) {
						recordInstantiation(loaderType, containerType);
						if (loaderActiveFalse
								&& isActiveOrientationType(loaderType, portraitLayout)
								&& isActiveOrientationType(containerType, portraitLayout)) {
							onDemandTypes.insert(loaderType);
						}
					}
					inLoader = false;
				}
			} else if (inComponent) {
				if (componentId.isEmpty()) {
					if (const QRegularExpressionMatch idMatch = componentIdRe.match(line); idMatch.hasMatch()) {
						componentId = idMatch.captured(1);
					}
				}
				if (componentType.isEmpty()) {
					if (const QRegularExpressionMatch typeMatch = typeBraceRe.match(line); typeMatch.hasMatch()) {
						componentType = typeMatch.captured(1);
					}
				}
				if (depth <= 0) {
					if (!componentType.isEmpty()) {
						recordInstantiation(componentType, containerType);
						if (isMainView && !componentId.isEmpty()) {
							mainViewComponentIdToType.insert(componentId, componentType);
						}
					}
					inComponent = false;
				}
			}
		}
	}

	QHash<QString, QString> swipeRootByUrl;
	QHash<QString, RootRoute> swipeRootByType;
	for (const RootRoute &root : swipeRoots) {
		swipeRootByUrl.insert(root.rootPageUrl, root.entryNavText);
		const QString typeName = QFileInfo(root.rootPageUrl).baseName();
		swipeRootByType.insert(typeName, root);
	}

	QString briefEntry;
	for (const RootRoute &root : swipeRoots) {
		if (root.rootPageUrl.endsWith(QStringLiteral("/BriefPage.qml"))) {
			briefEntry = root.entryNavText;
			break;
		}
	}
	if (briefEntry.isEmpty() && !swipeRoots.isEmpty()) {
		briefEntry = swipeRoots.first().entryNavText;
	}

	const QHash<QString, ClickIdentifier> signalToClick = scanStatusBarActivations();
	QList<ShownTypeRoute> routes;
	QSet<QString> seenUrls;

	const auto appendRoute = [&](const ShownTypeRoute &route) {
		if (route.typeUrl.isEmpty() || route.entryNavText.isEmpty() || seenUrls.contains(route.typeUrl)) {
			return;
		}
		seenUrls.insert(route.typeUrl);
		routes.append(route);
	};

	for (auto it = mainViewSignalToComponentId.cbegin(); it != mainViewSignalToComponentId.cend(); ++it) {
		const QString typeName = mainViewComponentIdToType.value(it.value());
		const QString typeUrl = uniquePageUrlForTypeName(qmlFilesByTypeName, typeName);
		const ClickIdentifier identifier = signalToClick.value(it.key());
		if (typeUrl.isEmpty() || identifier.values.isEmpty() || briefEntry.isEmpty()) {
			continue;
		}
		appendRoute(ShownTypeRoute{
			typeUrl,
			briefEntry,
			QList<RouteStep>{ RouteStep{ identifier, typeUrl, RouteStep::ShownType } },
		});
	}

	const auto findSwipeRoot = [&](const QString &typeName) -> RootRoute {
		QSet<QString> visited;
		QQueue<QString> queue;
		queue.enqueue(typeName);
		while (!queue.isEmpty()) {
			const QString current = queue.dequeue();
			if (visited.contains(current)) {
				continue;
			}
			visited.insert(current);
			if (swipeRootByType.contains(current)) {
				return swipeRootByType.value(current);
			}
			for (const QString &container : typeToContainerTypes.value(current)) {
				if (!visited.contains(container)) {
					queue.enqueue(container);
				}
			}
		}
		return RootRoute{};
	};

	const auto chainHasToggleSidePanel = [&](const QString &typeName) {
		QSet<QString> visited;
		QQueue<QString> queue;
		queue.enqueue(typeName);
		while (!queue.isEmpty()) {
			const QString current = queue.dequeue();
			if (visited.contains(current)) {
				continue;
			}
			visited.insert(current);
			if (typesWithToggleSidePanel.contains(current)) {
				return true;
			}
			for (const QString &container : typeToContainerTypes.value(current)) {
				if (!visited.contains(container)) {
					queue.enqueue(container);
				}
			}
		}
		return false;
	};

	for (auto it = typeToContainerTypes.cbegin(); it != typeToContainerTypes.cend(); ++it) {
		const QString typeName = it.key();
		const QString typeUrl = uniquePageUrlForTypeName(qmlFilesByTypeName, typeName);
		if (typeUrl.isEmpty() || swipeRootByUrl.contains(typeUrl)) {
			continue;
		}

		const RootRoute host = findSwipeRoot(typeName);
		if (host.rootPageUrl.isEmpty()) {
			continue;
		}

		QList<RouteStep> extraClicks;
		if (tabActivationByType.contains(typeName)) {
			extraClicks.append(RouteStep{
				tabActivationByType.value(typeName),
				typeUrl,
				RouteStep::ShownType,
			});
		} else if (onDemandTypes.contains(typeName)) {
			if (!chainHasToggleSidePanel(typeName)) {
				continue;
			}
			const ClickIdentifier identifier = signalToClick.value(QStringLiteral("sidePanelToggled"));
			if (identifier.values.isEmpty()) {
				continue;
			}
			extraClicks.append(RouteStep{ identifier, typeUrl, RouteStep::ShownType });
		}

		// LevelsTab is the shared base of TanksTab/EnvironmentTab, not a
		// navigable view. A zero-click route would match whichever tab
		// instance findObject hits first.
		if (extraClicks.isEmpty() && typeName == QStringLiteral("LevelsTab")) {
			continue;
		}

		appendRoute(ShownTypeRoute{ typeUrl, host.entryNavText, extraClicks });
	}

	return routes;
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
	if (!entryNavText || !routeSteps) {
		return false;
	}
	entryNavText->clear();
	routeSteps->clear();

	const QHash<QString, QString> commonWordsLabels = parseCommonWordsLabels();
	const QList<RootRoute> swipeRoots = scanSwipeRootPages(commonWordsLabels);
	for (const RootRoute &root : swipeRoots) {
		if (targetPageUrl == root.rootPageUrl) {
			*entryNavText = root.entryNavText;
			return true;
		}
	}

	const QList<RootRoute> pushPageRoots = {
		{
			QStringLiteral("/pages/SettingsPage.qml"),
			QStringLiteral("Settings"),
		},
		{
			isPortraitLayout()
				? QStringLiteral("/pages/OverviewPage_Portrait.qml")
				: QStringLiteral("/pages/OverviewPage_Landscape.qml"),
			QStringLiteral("Overview"),
		},
	};

	const QHash<QString, QList<RouteEdge>> graph = buildPageGraph();

	for (const RootRoute &root : pushPageRoots) {
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

	const QList<ShownTypeRoute> shownTypes = scanShownTypeRoutes(swipeRoots);
	for (const ShownTypeRoute &shown : shownTypes) {
		if (shown.typeUrl != targetPageUrl) {
			continue;
		}
		*entryNavText = shown.entryNavText;
		*routeSteps = shown.extraClicks;
		return true;
	}

	return false;
}

QStringList normalizeUiTestArguments(const QStringList &arguments)
{
	QStringList normalized;
	normalized.reserve(arguments.count());

	for (int i = 0; i < arguments.count(); ++i) {
		const QString &arg = arguments.at(i);
		if ((arg == QStringLiteral("--ui-test") || arg == QStringLiteral("-uit"))
				&& (i + 1) < arguments.count()) {
			const QString &value = arguments.at(i + 1);
			if (value.startsWith('/')) {
				normalized << QStringLiteral("%1=%2").arg(arg, value);
				++i;
				continue;
			}
		}
		normalized << arg;
	}

	return normalized;
}

QString parseUiTestValueFromArgs(const QStringList &arguments)
{
	for (int i = 0; i < arguments.count(); ++i) {
		const QString &arg = arguments.at(i);
		if (arg == QStringLiteral("--ui-test") || arg == QStringLiteral("-uit")) {
			return (i + 1) < arguments.count() ? arguments.at(i + 1) : QString();
		}
		if (arg.startsWith(QStringLiteral("--ui-test="))) {
			return arg.mid(QStringLiteral("--ui-test=").length());
		}
		if (arg.startsWith(QStringLiteral("-uit="))) {
			return arg.mid(QStringLiteral("-uit=").length());
		}
	}
	return QString();
}

bool parseResolution(const QString &value, int *width, int *height, QString *errorMessage)
{
	const auto setError = [errorMessage](const QString &message) {
		if (errorMessage) {
			*errorMessage = message;
		}
	};

	if (!width || !height) {
		setError(QStringLiteral("Width and height outputs are required"));
		return false;
	}

	*width = 0;
	*height = 0;

	const QString trimmed = value.trimmed();
	static const QRegularExpression pattern(QStringLiteral("^(\\d+)[xX](\\d+)$"));
	const QRegularExpressionMatch match = pattern.match(trimmed);
	if (!match.hasMatch()) {
		setError(QStringLiteral("Expected WxH (for example 480x800)"));
		return false;
	}

	bool widthOk = false;
	bool heightOk = false;
	const int parsedWidth = match.captured(1).toInt(&widthOk);
	const int parsedHeight = match.captured(2).toInt(&heightOk);
	if (!widthOk || !heightOk || parsedWidth <= 0 || parsedHeight <= 0) {
		setError(QStringLiteral("Width and height must be positive integers"));
		return false;
	}

	*width = parsedWidth;
	*height = parsedHeight;
	return true;
}

int countNewRuntimeWarningTexts(
		const QStringList &warningTexts,
		QSet<QString> *recordedWarnings,
		QStringList *newWarningTexts)
{
	if (!recordedWarnings) {
		return 0;
	}

	int newCount = 0;
	for (const QString &warningTextRaw : warningTexts) {
		const QString warningText = warningTextRaw.trimmed();
		if (warningText.isEmpty() || recordedWarnings->contains(warningText)) {
			continue;
		}
		recordedWarnings->insert(warningText);
		if (newWarningTexts) {
			newWarningTexts->append(warningText);
		}
		++newCount;
	}
	return newCount;
}

int countNewRuntimeQmlWarnings(
		const QList<QQmlError> &warnings,
		QSet<QString> *recordedWarnings,
		QStringList *newWarningTexts)
{
	QStringList warningTexts;
	warningTexts.reserve(warnings.count());
	for (const QQmlError &warning : warnings) {
		warningTexts.append(warning.toString());
	}
	return countNewRuntimeWarningTexts(warningTexts, recordedWarnings, newWarningTexts);
}

int exitCodeForFailures(int stepFailures, int runtimeQmlErrors)
{
	return (stepFailures + runtimeQmlErrors) > 0 ? 1 : 0;
}

} // namespace UiTestUtils
} // namespace VenusOS
} // namespace Victron
