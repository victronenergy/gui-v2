/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "branding.h"

using namespace Victron;

QString BrandingData::colorPropertyName(Color color)
{
	switch (color) {
	case Brand: return QStringLiteral("color_brand");
	case Success: return QStringLiteral("color_success");
	case Warning: return QStringLiteral("color_warning");
	case Critical: return QStringLiteral("color_critical");
	case BackgroundPrimary: return QStringLiteral("color_background_primary");
	case BackgroundSecondary: return QStringLiteral("color_background_secondary");
	case BackgroundPage: return QStringLiteral("color_background_page");
	case FontPrimary: return QStringLiteral("color_font_primary");
	case FontSecondary: return QStringLiteral("color_font_secondary");
	case ColorCount: break;
	}
	return QString();
}

Branding::Branding(QObject *parent)
	: QObject(parent)
{
}

BrandingData Branding::snapshot() const
{
	return m_data;
}
