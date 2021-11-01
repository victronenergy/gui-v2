/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#include "theme.h"

using namespace Victron::VenusOS;

QColor Theme::colorValue(DisplayMode mode, ColorProperty role) const
{
	return m_colorValues[mode][role].value<QColor>();
}

QVariant Theme::otherValue(OtherProperty role) const
{
	return m_otherValues[role];
}

QColor Theme::statusColorValue(StatusLevel level, bool secondaryColor) const
{
	switch (level) {
	case Warning:
		return colorValue(m_displayMode, secondaryColor ? WarningSecondaryColor : WarningColor);
	case Critical:
		return colorValue(m_displayMode, secondaryColor ? CriticalSecondaryColor : CriticalColor);
	default:
		break;
	}
	return colorValue(m_displayMode, secondaryColor ? OkSecondaryColor : OkColor);
}

QColor Theme::backgroundColor() const
{
	return colorValue(m_displayMode, BackgroundColor);
}

QColor Theme::primaryFontColor() const
{
	return colorValue(m_displayMode, PrimaryFontColor);
}

QColor Theme::secondaryFontColor() const
{
	return colorValue(m_displayMode, SecondaryFontColor);
}

QColor Theme::highlightColor() const
{
	return colorValue(m_displayMode, HighlightColor);
}

QColor Theme::dimColor() const
{
	return colorValue(m_displayMode, DimColor);
}

QColor Theme::weatherColor() const
{
	return otherValue(WeatherColor).value<QColor>();
}

QColor Theme::okColor() const
{
	return colorValue(m_displayMode, OkColor);
}

QColor Theme::okSecondaryColor() const
{
	return colorValue(m_displayMode, OkSecondaryColor);
}

QColor Theme::warningColor() const
{
	return colorValue(m_displayMode, WarningColor);
}

QColor Theme::warningSecondaryColor() const
{
	return colorValue(m_displayMode, WarningSecondaryColor);
}

QColor Theme::criticalColor() const
{
	return colorValue(m_displayMode, CriticalColor);
}

QColor Theme::criticalSecondaryColor() const
{
	return colorValue(m_displayMode, CriticalSecondaryColor);
}

int Theme::fontSizeMedium() const
{
	return otherValue(FontSizeMedium).toInt();
}

int Theme::marginSmall() const
{
	return otherValue(MarginSmall).toInt();
}

int Theme::horizontalPageMargin() const
{
	return otherValue(HorizontalPageMargin).toInt();
}

int Theme::iconSizeMedium() const
{
	return otherValue(IconSizeMedium).toInt();
}

Theme::DisplayMode Theme::displayMode() const
{
	return m_displayMode;
}

void Theme::setDisplayMode(Theme::DisplayMode mode)
{
	if (m_displayMode != mode) {
		m_displayMode = mode;
		emit displayModeChanged();
		/* also emit change signals for all color values */
		emit backgroundColorChanged();
		emit primaryFontColorChanged();
		emit secondaryFontColorChanged();
		emit highlightColorChanged();
		emit dimColorChanged();
		emit okColorChanged();
		emit okSecondaryColorChanged();
		emit warningColorChanged();
		emit warningSecondaryColorChanged();
		emit criticalColorChanged();
		emit criticalSecondaryColorChanged();
	}
}

Theme::ScreenSize Theme::screenSize() const
{
	return m_screenSize;
}

void Theme::setScreenSize(ScreenSize screenSize)
{
	if (screenSize == m_screenSize)
	{
		return;
	}
	m_screenSize = screenSize;
	emit screenSizeChanged();
}