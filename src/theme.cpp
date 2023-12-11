/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "theme.h"

#include <QQmlComponent>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QVariant>
#include <QColor>
#include <QGuiApplication>
#include <QScreen>

namespace {
	QRegularExpression optimizeExpression(const QString &expression)
	{
		QRegularExpression regexp(expression);
		regexp.optimize();
		return regexp;
	}
}

namespace Victron {
namespace VenusOS {

Theme::Theme(QObject *parent)
	: QQmlPropertyMap(this, parent)
{
#if !defined(VENUS_WEBASSEMBLY_BUILD)
	const QSizeF physicalScreenSize = QGuiApplication::primaryScreen()->physicalSize();
	const int screenDiagonalMm = static_cast<int>(sqrt((physicalScreenSize.width() * physicalScreenSize.width())
			+ (physicalScreenSize.height() * physicalScreenSize.height())));
	Theme::ScreenSize screenSize = (round(screenDiagonalMm / 10 / 2.5) == 7)
			? Theme::SevenInch
			: Theme::FiveInch;
	load(screenSize, ColorScheme::Dark);
#else
	load(Theme::ScreenSize::SevenInch, ColorScheme::Dark);
#endif
}

Theme::~Theme()
{
}

Theme::ScreenSize Theme::screenSize() const
{
	return m_screenSize;
}

Theme::ColorScheme Theme::colorScheme() const
{
	return m_colorScheme;
}

bool Theme::load(ScreenSize screenSize, ColorScheme colorScheme)
{
	bool typographyDesign = parseTheme(QStringLiteral(":/themes/typography/TypographyDesign.json"));
	bool typography = parseTheme(QStringLiteral(":/themes/typography/%1.json")
			.arg(QMetaEnum::fromType<Theme::ScreenSize>().valueToKey(screenSize)));

	bool geometry = parseTheme(QStringLiteral(":/themes/geometry/%1.json")
			.arg(QMetaEnum::fromType<Theme::ScreenSize>().valueToKey(screenSize)));

	bool colorDesign = parseTheme(QStringLiteral(":/themes/color/ColorDesign.json"));
	bool color = parseTheme(QStringLiteral(":/themes/color/%1.json")
			.arg(QMetaEnum::fromType<Theme::ColorScheme>().valueToKey(colorScheme)));

	bool animation = parseTheme(QStringLiteral(":/themes/animation/Animation.json"));

	if (m_screenSize != screenSize) {
		m_screenSize = screenSize;
		emit screenSizeChanged();
	}

	if (m_colorScheme != colorScheme) {
		m_colorScheme = colorScheme;
		emit colorSchemeChanged();
	}

	return typographyDesign && typography && geometry && colorDesign && color && animation;
}

QVariant Theme::resolvedValue(const QString &key, bool *found, bool warnOnFailure) const
{
	if (found) *found = false;
	const QString resolvedSubTree = key.mid(0, key.lastIndexOf(QLatin1Char('.')));
	if (!m_subTrees.contains(resolvedSubTree)) {
		if (warnOnFailure) qWarning() << "Theme: unable to resolve:" << key << ": subtree does not exist.";
	} else {
		QQmlPropertyMap *subtree = m_subTrees[resolvedSubTree];
		const QString valueKey = key.mid(resolvedSubTree.length()+1);
		if (!subtree->contains(valueKey)) {
			if (warnOnFailure) qWarning() << "Theme: unable to resolve:" << key << ": subtree does not contain key.";
		} else {
			if (found) *found = true;
			return subtree->value(valueKey);
		}
	}
	return QVariant();
}

QColor Theme::resolvedColor(const QString &value) const
{
	static const QRegularExpression hexColor = ::optimizeExpression(
			QStringLiteral("^#[0-9a-fA-F]{6,8}$"));
	static const QRegularExpression rgbaColor = ::optimizeExpression(
			QStringLiteral("^rgba\\((\\d+), (\\d+), (\\d+), (\\d+(?:\\.\\d+)?)\\)$"));

	if (value == "transparent") {
		return QColor(value);
	}

	QRegularExpressionMatch match = hexColor.match(value);
	if (match.hasMatch()) {
		return QColor(value);
	}

	match = rgbaColor.match(value);
	if (match.hasMatch()) {
		return QColor(
			match.captured(1).toInt(),
			match.captured(2).toInt(),
			match.captured(3).toInt(),
			qRound(255 * match.captured(4).toDouble()));
	}

	return {};
}

QVariant Theme::parseValue(const QJsonValue &value, const QString &key, bool defer)
{
	if (value.isString()) {
		const QString valueStr = value.toString();

		QColor color = resolvedColor(valueStr);
		if (color.isValid())
			return QVariant::fromValue(color);

		// Check to see if the value should resolve to a pre-existing theme value.
		if (!valueStr.contains('.')) {
			return valueStr; // no, just a string value.
		}

		bool found = false;
		const QVariant var = resolvedValue(valueStr, &found, !defer);
		if (found) {
			if (var.isNull()) {
				// Still not resolved - try again
				m_deferred.push_back({ key, value });
			}
			return var;
		} else if (defer) {
			m_deferred.push_back({ key, value });
			return QVariant();
		}

		return valueStr;
	} else {
		return value.toVariant();
	}
}

void Theme::insertValue(
		QQmlPropertyMap *tree,
		const QString &key,
		const QJsonValue &value,
		int depth,
		bool defer)
{
	const int dot = static_cast<int>(key.indexOf(QLatin1Char('.'), depth));
	if (dot == -1) {
		const QString name = key.mid(depth);
		tree->insert(name, parseValue(value, key, defer));
		return;
	}

	const QString subtreeKey = key.mid(0, dot);
	QQmlPropertyMap *subtree = nullptr;
	if (m_subTrees.contains(subtreeKey)) {
		subtree = m_subTrees[subtreeKey];
	} else {
		subtree = new QQmlPropertyMap(this);
		m_subTrees.insert(subtreeKey, subtree);
		tree->insert(key.mid(depth, dot-depth), QVariant::fromValue(subtree));
	}
	insertValue(subtree, key, value, dot+1, defer);
}

bool Theme::parseTheme(const QString &themeFile)
{
	QFile file(themeFile);
	if (!file.open(QIODevice::ReadOnly)) {
		qWarning() << "Error opening theme file:" << themeFile
			<< ":" << file.errorString();
		return false;
	}

	QJsonParseError err;
	const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &err);
	if (doc.isNull()) {
		qWarning() << "Error parsing JSON:" << themeFile
			<< ":" << qPrintable(err.errorString());
		return false;
	}

	const QJsonObject obj = doc.object();
	for (auto it = obj.constBegin(); it != obj.constEnd(); ++it) {
		insertValue(this, it.key(), it.value());
	}

	// Process any previously deferred values
	while (!m_deferred.empty()) {
		const auto &pair(m_deferred.front());
		insertValue(this, pair.first, pair.second, 0, false);
		m_deferred.pop_front();
	}

	return true;
}

QColor Theme::statusColorValue(StatusLevel level, bool darkColor) const
{
	const QString key = (level == Ok && darkColor) ? QStringLiteral("color.darkOk")
			: (level == Ok) ? QStringLiteral("color.ok")
			: (level == Warning && darkColor) ? QStringLiteral("color.darkWarning")
			: (level == Warning) ? QStringLiteral("color.warning")
			: (level == Critical && darkColor) ? QStringLiteral("color.darkCritical")
			: QStringLiteral("color.critical");
	const QVariant c = resolvedValue(key);
	return c.typeId() == QMetaType::QColor ? c.value<QColor>() : QColor(c.value<QString>());
}

} // VenusOS
} // Victron
