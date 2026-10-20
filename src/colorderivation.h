/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_COLORDERIVATION_H
#define VICTRON_VENUSOS_GUI_V2_COLORDERIVATION_H

#include <QColor>
#include <QList>

#include <array>
#include <initializer_list>

#include "branding.h"

namespace Victron {
namespace VenusOS {

/*
Computes the theme colors from the colors that the Branding objects set (BrandingData::Color).

Every function gives the same result on every platform, so that the tests can compare exact
expected colors:
- Mixes work per 8-bit sRGB channel, in integer arithmetic, and round half up.
- The HSL operations use doubles, in a fixed order of operations. colorderivation.cpp is
  built without floating-point contraction (fused multiply-add), which would change the
  rounding on some targets.
- Contrast ratios use a fixed table of linearised channel values instead of pow().

tools/themeparser.py generates the calls to these functions from the formulas in
themes/color/Dark.json and Light.json.
*/
namespace ColorDerivation {

// One color for each BrandingData::Color, in one color scheme.
using BrandingColors = std::array<QColor, Victron::BrandingData::ColorCount>;

// The alpha values of the dim, darkish and dark colors (for example color_dimRed,
// color_button_down and color_darkOk): a color at this alpha, blended onto background_primary.
constexpr int DimAlpha = 179;      // 0xB3, 70%
constexpr int DarkishAlpha = 121;  // 47.5%: the background of a pressed button
constexpr int DarkAlpha = 77;      // 0x4D, 30%

// light_mode_background_factor, in thousandths: the default, and the largest allowed value.
constexpr int DefaultLightModeBackgroundFactorThousandths = 1000;
constexpr int MaximumLightModeBackgroundFactorThousandths = 2000;

// The smallest contrast ratios (WCAG 2) that the computed colors keep.
constexpr double MinimumWhiteTextContrast = 3.0;     // white text on a colored button or banner
constexpr double MinimumSecondaryTextContrast = 3.0; // font_secondary on the page and background_secondary
constexpr double MinimumPrimaryTextContrast = 4.5;   // font_primary on background_primary (warning only)

// Moves "from" toward "to" by numerator / denominator, per channel. The result is opaque.
QColor mix(const QColor &from, const QColor &to, int numerator, int denominator);

// The opaque color that "color" at the given alpha (0 to 255) gives when drawn over background.
// Many of the gray theme colors (font_over_background(n) in the color scheme files) are
// font_primary blended onto background_primary. This produces colors which are cooler than the
// original design. In future, it may be necessary to modify this procedure to prefer warmer
// colors for the Victron branding, if required.
QColor blendOnto(const QColor &color, int alpha, const QColor &background);

QColor withAlpha(const QColor &color, int alpha);

// The Light mode color of a Dark mode background: HSL lightness L becomes
// 0.5 + factor * (0.5 - L), softened near black and white when the factor is more than 1 (so
// that different nearly-black colors stay different instead of all becoming white, and
// nearly-white ones instead of all becoming black). Hue and saturation are kept.
QColor lightModeBackgroundColor(const QColor &darkModeBackground, int factorThousandths);

// HSL lightness inverted (L becomes 1 - L): lightModeBackgroundColor() with a factor of 1.
QColor lightnessInverted(const QColor &color);

double relativeLuminance(const QColor &color);
double contrastRatio(const QColor &a, const QColor &b);

// The text color to use on top of the given fill colors: white if white has enough contrast on
// every one of them, else darkerFontPrimary.
QColor textColorOn(std::initializer_list<QColor> fills, const QColor &darkerFontPrimary);

// Returns a Branding light_mode_background_factor in thousandths, or the default if the value is
// out of range.
int toLightModeBackgroundFactorThousandths(qreal value);
bool isValidLightModeBackgroundFactor(qreal value);

struct ResolvedBrandingColors
{
	BrandingColors darkScheme;
	BrandingColors lightScheme;
	// The darker of the two schemes' font_primary colors: the text on fills that are too light
	// for white text.
	QColor darkerFontPrimary;
	int lightModeBackgroundFactorThousandths = DefaultLightModeBackgroundFactorThousandths;
	// The index, in the list given to resolveBrandingColors(), of the BrandingData whose
	// background_primary (or font_primary) is used. -1 if none sets it.
	qsizetype backgroundPrimarySourceIndex = -1;
	qsizetype fontPrimarySourceIndex = -1;
};

// Computes the branding colors of both color schemes from a list of BrandingData. The first
// entry is the built-in (Victron) branding, and must set every color except BackgroundPage.
// When more than one entry sets a value, the last one is used, with one exception:
// light_mode_background_factor, background_secondary and background_page are chosen to suit a
// particular background_primary, so they are used only if they come from the entry whose
// background_primary is used, or (for the two colors) from a later one. Otherwise they are
// computed. The Branding colors are the Dark scheme's colors; the Light scheme's colors are
// computed from them.
ResolvedBrandingColors resolveBrandingColors(const QList<Victron::BrandingData> &brandingList);

} // namespace ColorDerivation

} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_VENUSOS_GUI_V2_COLORDERIVATION_H
