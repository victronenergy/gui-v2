/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "branding.h"

/*
BEGIN property reference
The property reference in .github/branding-plugins.md. tools/brandingproperties.py copies
each entry below. An entry starts with the property name, then what it sets, then "If not set:".

color_brand
The brand color: buttons, switches, sliders, radio buttons, the selected navigation bar tab, and
the Overview widget borders. It is not used for informative notifications. The Light scheme uses
the same color.
If not set: Victron's color.

color_success
Good states, such as feed-in power, and the key navigation focus ring in the Dark scheme. The Light
scheme uses the same color.
If not set: Victron's color.

color_warning
Warnings, modified settings, the demo mode indicator, and the key navigation focus ring in the Light
scheme. The Light scheme uses the same color.
If not set: Victron's color.

color_critical
Errors and alarms. The Light scheme uses the same color.
If not set: Victron's color.

color_info
Informative notifications, and quantities that are not a success, a warning or an alarm, such as
load below the warning line and power being imported. It may be the brand color. Keep it distinct
from color_success, color_warning and color_critical. The Light scheme uses the same color.
If not set: Victron's color.

color_background_primary
The main background in the Dark scheme. The Light scheme's background is computed from it, using
light_mode_background_factor. The Branding file whose color_background_primary is used also supplies
the background factor, and limits where color_background_secondary and color_background_page are
read from, so set them in the same file.
If not set: Victron's color.

color_background_secondary
The background of cards and list items in the Dark scheme. The Light scheme's is computed from it.
Read only from the Branding file whose color_background_primary is used, or a later one.
If not set: computed from color_background_primary, mixed 8% toward color_font_primary. Victron's
color is used only when no Branding file sets color_background_primary.

color_background_page
The page background behind the cards, in the Dark scheme only: the Light scheme's page is always its
background mixed 12% toward its text color. Read only from the Branding file whose
color_background_primary is used, or a later one.
If not set: color_background_primary.

color_font_primary
The main text and icons in the Dark scheme. The Light scheme's text color is computed from it. The
loader warns when it has less than 4.5:1 contrast on color_background_primary in either scheme.
If not set: Victron's color.

color_font_secondary
Secondary text, such as list item values and the unselected navigation bar tabs, in the Dark scheme.
In each scheme, if it has less than 3:1 contrast on the page or on the card background, it is moved
toward the scheme's main text color until it has.
If not set: Victron's color.

light_mode_background_factor
How the Light scheme's backgrounds are computed from the Dark scheme's: 1.0 inverts their lightness,
a lower value moves them toward mid gray, and a higher value spreads them apart. More than 0 and at
most 2. Read only from the Branding file whose color_background_primary is used, so set the two
together.
If not set: 1.0. Victron's own backgrounds use 1.12, so a plugin that sets no
color_background_primary keeps that.

font_files
Font files (.ttf or .otf) to register, relative to Branding.qml. Name the font with font_family and
quantity_font_family.
If not set: no font files are registered.

font_family
The family name of the font for all text except quantities, from font_files or installed on the
device. It is used only for languages it has the letters for; the others, and languages that have
their own font (such as Chinese), use the built-in font.
If not set: the built-in font, Roboto, or the language's own font.

quantity_font_family
The family name of the font for quantities: numbers with their units. It needs digits of equal
width, or changing values jitter. It is used for every language.
If not set: Roboto.

splash_logo_icon
The icon on the start-up screen: an .svg or .png file, relative to Branding.qml. It is drawn over
splash_logo_text, both stretched to the same box, so draw it on a 285x54 canvas, at the left.
If not set: Victron's icon.

splash_logo_text
The wordmark on the start-up screen: an .svg or .png file, relative to Branding.qml. Draw it on a
285x54 canvas, to the right of the icon. Draw text as paths, not as SVG text.
If not set: Victron's wordmark.

splash_logo_icon_preserve_colors
true: draw splash_logo_icon in its own colors, which must then read on both the Dark and the Light
background. false: draw it in one color, the scheme's main text color.
If not set: false.

splash_logo_text_preserve_colors
true: draw splash_logo_text in its own colors, which must then read on both the Dark and the Light
background. false: draw it in one color, the scheme's main text color.
If not set: false.

splash_gauge_animation
The gauge animation on the start-up screen: a .gif file, relative to Branding.qml. It is drawn at
its own size on both the 5" and 7" screens, and played to its last frame. It is used in both
schemes, unless splash_gauge_animation_light is set.
If not set: Victron's animation. The Light scheme still uses splash_gauge_animation_light if that is set.

splash_gauge_animation_light
The gauge animation on the start-up screen in the Light scheme, instead of splash_gauge_animation:
a .gif file, relative to Branding.qml. It is drawn at its own size on both the 5" and 7" screens,
and played to its last frame.
If not set: splash_gauge_animation, or Victron's animation if that is not set either.

END property reference
*/

using namespace Victron;

QString BrandingData::colorPropertyName(Color color)
{
	switch (color) {
	case Brand: return QStringLiteral("color_brand");
	case Success: return QStringLiteral("color_success");
	case Warning: return QStringLiteral("color_warning");
	case Critical: return QStringLiteral("color_critical");
	case Info: return QStringLiteral("color_info");
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
