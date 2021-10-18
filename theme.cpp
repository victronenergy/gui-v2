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

int Theme::fontSizeMedium() const
{
	return otherValue(FontSizeMedium).toInt();
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
	}
}
