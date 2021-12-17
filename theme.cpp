#include "theme.h"

#include <QQmlComponent>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QVariant>
#include <QColor>

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

QObject* Theme::instance(QQmlEngine *engine, QJSEngine *)
{
	Theme *theme = new Theme;
	const Theme::ScreenSize screenSize = engine->property("screenSize").value<Theme::ScreenSize>();
	const Theme::ColorScheme colorScheme = engine->property("colorScheme").value<Theme::ColorScheme>();
qWarning() << "XXXXXXXXXXXXXXXX initial theme load with :" << screenSize << "," << colorScheme;
	theme->load(screenSize, colorScheme);
	return theme;
}

Theme::Theme(QObject *parent)
	: QQmlPropertyMap(this, parent)
{
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
	bool geometry = parseTheme(QStringLiteral(":/themes/geometry/%1.json")
			.arg(QMetaEnum::fromType<Theme::ScreenSize>().valueToKey(screenSize)));
	bool geometry_resolved = parseTheme(QStringLiteral(":/themes/geometry/%1-resolved.json")
			.arg(QMetaEnum::fromType<Theme::ScreenSize>().valueToKey(screenSize)));
	bool color = parseTheme(QStringLiteral(":/themes/color/%1.json")
			.arg(QMetaEnum::fromType<Theme::ColorScheme>().valueToKey(colorScheme)));
	bool color_resolved = parseTheme(QStringLiteral(":/themes/color/%1-resolved.json")
			.arg(QMetaEnum::fromType<Theme::ColorScheme>().valueToKey(colorScheme)));
	bool typography = parseTheme(QStringLiteral(":/themes/typography/Typography.json"));

	if (m_screenSize != screenSize) {
		m_screenSize = screenSize;
		emit screenSizeChanged();
	}

	if (m_colorScheme != colorScheme) {
		m_colorScheme = colorScheme;
		emit colorSchemeChanged();
	}

	return geometry && geometry_resolved && color && color_resolved && typography;
}

QVariant Theme::resolvedValue(const QString &key, bool *found) const
{
	if (found) *found = false;
	const QString resolvedSubTree = key.mid(0, key.lastIndexOf(QLatin1Char('.')));
	if (!m_subTrees.contains(resolvedSubTree)) {
		qWarning() << "Theme: unable to resolve:" << key << ": subtree does not exist.";
	} else {
		QQmlPropertyMap *subtree = m_subTrees[resolvedSubTree];
		const QString valueKey = key.mid(resolvedSubTree.length()+1);
		if (!subtree->contains(valueKey)) {
			qWarning() << "Theme: unable to resolve:" << key << ": subtree does not contain key.";
		} else {
			if (found) *found = true;
			return subtree->value(valueKey);
		}
	}
	return QVariant();
}

QVariant Theme::parseValue(const QJsonValue &value)
{
	if (value.isString()) {
		const QString valueStr = value.toString();

		static const QRegularExpression hexColor = ::optimizeExpression(
				QStringLiteral("^#[0-9a-fA-F]{6}$"));
		static const QRegularExpression rgbaColor = ::optimizeExpression(
				QStringLiteral("^rgba\\((\\d+), (\\d+), (\\d+), (\\d+(?:\\.\\d+)?)\\)$"));

		QRegularExpressionMatch match = hexColor.match(valueStr);
		if (match.hasMatch()) {
			return QColor(valueStr);
		}

		match = rgbaColor.match(valueStr);
		if (match.hasMatch()) {
			return QColor(
				match.captured(1).toInt(),
				match.captured(2).toInt(),
				match.captured(3).toInt(),
				qRound(255 * match.captured(4).toDouble()));
		}

		// Check to see if the value should resolve to a pre-existing theme value.
		if (valueStr.startsWith(QStringLiteral("geometry."))
				|| valueStr.startsWith(QStringLiteral("color."))
				|| valueStr.startsWith(QStringLiteral("font."))) {
			bool found = false;
			const QVariant value = resolvedValue(valueStr, &found);
			if (found) {
				return value;
			}
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
		int depth)
{
	const int dot = key.indexOf(QLatin1Char('.'), depth);
	if (dot == -1) {
		const QString name = key.mid(depth);
		tree->insert(name, parseValue(value));
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
	insertValue(subtree, key, value, dot+1);
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

}
}

