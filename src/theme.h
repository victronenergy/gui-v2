/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_THEME_H
#define VICTRON_VENUSOS_GUI_V2_THEME_H

#include <QGuiApplication>
#include <QScreen>
#include <QObject>
#include <QSizeF>
#include <QFont>
#include <QHash>
#include <qqmlintegration.h>

namespace Victron {
namespace VenusOS {

struct FontInfo
{
	QFont font;
	qreal numberWidth = 0;
	qreal alphaWidth = 0;
	qreal advanceWidth = 0;
	qreal dotDeltaWidth = 0;
	qreal minusDeltaWidth = 0;
	qreal oneHundredWidth = 0;
};

class Theme : public QObject
{
	Q_OBJECT
	QML_NAMED_ELEMENT(ThemeBase)
	Q_PROPERTY(ScreenSize screenSize READ screenSize WRITE setScreenSize NOTIFY screenSizeChanged)
	Q_PROPERTY(ColorScheme colorScheme READ colorScheme WRITE setColorScheme NOTIFY colorSchemeChanged)

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

	Theme(QObject *parent = nullptr) : QObject(parent)
	{
#if !defined(VENUS_WEBASSEMBLY_BUILD)
		const QSizeF physicalScreenSize = QGuiApplication::primaryScreen()->physicalSize();
		const int screenDiagonalMm = static_cast<int>(sqrt((physicalScreenSize.width() * physicalScreenSize.width())
			+ (physicalScreenSize.height() * physicalScreenSize.height())));
		setScreenSize((round(screenDiagonalMm / 10 / 2.5) == 7)
			? Victron::VenusOS::Theme::SevenInch
			: Victron::VenusOS::Theme::FiveInch);
#endif
	}

	Victron::VenusOS::Theme::ScreenSize screenSize() const { return m_screenSize; }
	void setScreenSize(Victron::VenusOS::Theme::ScreenSize size) {
		if (m_screenSize != size) {
			m_screenSize = size;
			Q_EMIT screenSizeChanged(size);
			Q_EMIT screenSizeChanged_parameterless(); // work around moc limitation.
		}
	}

	Victron::VenusOS::Theme::ColorScheme colorScheme() const { return m_colorScheme; }
	void setColorScheme(Victron::VenusOS::Theme::ColorScheme scheme) {
		if (m_colorScheme != scheme) {
			m_colorScheme = scheme;
			Q_EMIT colorSchemeChanged(scheme);
			Q_EMIT colorSchemeChanged_parameterless(); // work around moc limitation.
		}
	}

	Q_INVOKABLE qreal characterWidthNumber(const QFont &font) const;
	Q_INVOKABLE qreal characterWidthAlpha(const QFont &font) const;
	Q_INVOKABLE qreal characterAdvanceWidth(const QFont &font) const;
	Q_INVOKABLE qreal characterDotDeltaWidth(const QFont &font) const;
	Q_INVOKABLE qreal characterMinusDeltaWidth(const QFont &font) const;
	Q_INVOKABLE qreal charactersOneHundredWidth(const QFont &font) const;

	Q_INVOKABLE bool objectHasQObjectParent(QObject *obj) const { return obj && obj->parent(); }

Q_SIGNALS:
	void screenSizeChanged(Victron::VenusOS::Theme::ScreenSize screenSize);
	void screenSizeChanged_parameterless();
	void colorSchemeChanged(Victron::VenusOS::Theme::ColorScheme colorScheme);
	void colorSchemeChanged_parameterless();

protected:
	const FontInfo& fontInfo(const QFont &font) const;
	ScreenSize m_screenSize = SevenInch;
	ColorScheme m_colorScheme = Dark;
	mutable QVector<FontInfo> m_fontInfo;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_THEME_H
