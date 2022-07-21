/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_THEME_H
#define VICTRON_VENUSOS_GUI_V2_THEME_H

#include <QQmlEngine>
#include <QQmlPropertyMap>
#include <QObject>
#include <QJsonValue>
#include <QHash>
#include <QString>
#include <QColor>

#include <deque>

namespace Victron {
namespace VenusOS {

class Theme : public QQmlPropertyMap
{
	Q_OBJECT
	Q_PROPERTY(ScreenSize screenSize READ screenSize NOTIFY screenSizeChanged)
	Q_PROPERTY(ColorScheme colorScheme READ colorScheme NOTIFY colorSchemeChanged)

public:
	enum ScreenSize {
		FiveInch = 0,
		SevenInch
	};
	Q_ENUM(ScreenSize)

	enum ColorScheme {
		Dark = 0,
		Light
	};
	Q_ENUM(ColorScheme)

	enum StatusLevel {
		Ok = 0,
		Warning,
		Critical
	};
	Q_ENUM(StatusLevel)

	explicit Theme(QObject *parent = nullptr);
	~Theme() override;

	ScreenSize screenSize() const;
	ColorScheme colorScheme() const;

	Q_INVOKABLE bool load(ScreenSize screenSize, ColorScheme colorScheme);
	static QObject* instance(QQmlEngine *engine, QJSEngine *);

	Q_INVOKABLE QColor statusColorValue(StatusLevel level, bool darkColor = false) const;

Q_SIGNALS:
	void screenSizeChanged();
	void colorSchemeChanged();

private:
	bool parseTheme(const QString &themeFile);
	QVariant parseValue(const QJsonValue &value, const QString &key, bool defer = true);
	void insertValue(
		QQmlPropertyMap *tree,
		const QString &key,
		const QJsonValue &value,
		int depth = 0,
		bool defer = true);
	QVariant resolvedValue(const QString &key, bool *found = nullptr, bool warnOnFailure = true) const;
	QColor resolvedColor(const QString &value) const;

	QHash<QString, QQmlPropertyMap *> m_subTrees;
	ScreenSize m_screenSize = FiveInch;
	ColorScheme m_colorScheme = Dark;
	std::deque<std::pair<QString, QJsonValue>> m_deferred;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_THEME_H
