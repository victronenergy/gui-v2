/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

// This file must be built without floating-point contraction (-ffp-contract=off on GCC and
// Clang, see cmake/ModuleVenus.cmake): a fused multiply-add rounds once instead of twice, so a
// result on a .5 tie could round differently on a GX device than on the desktop that ran the
// tests of the exact expected colors.

#include "colorderivation.h"

#include <QtMath>

#include <algorithm>
#include <cmath>

using Victron::BrandingData;

namespace Victron {
namespace VenusOS {
namespace ColorDerivation {

namespace {

// The WCAG linearisation of each 8-bit sRGB channel value: c / 12.92 if c <= 0.04045, else
// ((c + 0.055) / 1.055)^2.4, for c = value / 255. A fixed table, written out with Python's
// repr(), because pow() is not correctly rounded and its last bit can differ between C libraries.
constexpr std::array<double, 256> LinearisedChannelValue = {
	0.0, 0.0003035269835488375, 0.000607053967097675, 0.0009105809506465125,
	0.00121410793419535, 0.0015176349177441874, 0.001821161901293025, 0.0021246888848418626,
	0.0024282158683907, 0.0027317428519395373, 0.003035269835488375, 0.003346535763899161,
	0.003676507324047436, 0.004024717018496307, 0.004391442037410293, 0.004776953480693729,
	0.005181516702338386, 0.005605391624202723, 0.006048833022857054, 0.006512090792594475,
	0.006995410187265387, 0.007499032043226175, 0.008023192985384994, 0.008568125618069307,
	0.009134058702220787, 0.00972121732023785, 0.010329823029626936, 0.010960094006488246,
	0.011612245179743885, 0.012286488356915872, 0.012983032342173012, 0.013702083047289686,
	0.014443843596092545, 0.01520851442291271, 0.01599629336550963, 0.016807375752887384,
	0.017641954488384078, 0.018500220128379697, 0.019382360956935723, 0.0202885630566524,
	0.021219010376003555, 0.02217388479338738, 0.02315336617811041, 0.024157632448504756,
	0.02518685962736163, 0.026241221894849898, 0.027320891639074894, 0.028426039504420793,
	0.0295568344378088, 0.030713443732993635, 0.03189603307301153, 0.033104766570885055,
	0.03433980680868217, 0.03560131487502034, 0.03688945040110004, 0.0382043715953465,
	0.03954623527673284, 0.04091519690685319, 0.042311410620809675, 0.043735029256973465,
	0.04518620438567554, 0.046665086336880095, 0.04817182422688942, 0.04970656598412723,
	0.05126945837404324, 0.052860647023180246, 0.05448027644244237, 0.05612849004960009,
	0.05780543019106723, 0.0595112381629812, 0.06124605423161761, 0.06301001765316767,
	0.06480326669290577, 0.06662593864377289, 0.06847816984440017, 0.07036009569659588,
	0.07227185068231748, 0.07421356838014963, 0.07618538148130785, 0.07818742180518633,
	0.08021982031446832, 0.0822827071298148, 0.08437621154414882, 0.08650046203654976,
	0.08865558628577294, 0.09084171118340768, 0.09305896284668745, 0.0953074666309647,
	0.09758734714186246, 0.09989872824711389, 0.10224173308810132, 0.10461648409110419,
	0.10702310297826761, 0.10946171077829933, 0.1119324278369056, 0.11443537382697373,
	0.11697066775851084, 0.11953842798834562, 0.12213877222960187, 0.12477181756095049,
	0.12743768043564743, 0.1301364766903643, 0.13286832155381798, 0.13563332965520566,
	0.13843161503245183, 0.14126329114027164, 0.14412847085805777, 0.14702726649759498,
	0.14995978981060856, 0.15292615199615017, 0.1559264637078274, 0.1589608350608804,
	0.162029375639111, 0.1651321945016676, 0.16826940018969075, 0.1714411007328226,
	0.17464740365558504, 0.17788841598362912, 0.18116424424986022, 0.184474994500441,
	0.18782077230067787, 0.19120168274079138, 0.1946178304415758, 0.19806931955994886,
	0.20155625379439707, 0.20507873639031693, 0.20863687014525575, 0.21223075741405523,
	0.21586050011389926, 0.2195261997292692, 0.2232279573168085, 0.22696587351009836,
	0.23074004852434915, 0.23455058216100522, 0.238397573812271, 0.24228112246555486,
	0.24620132670783548, 0.25015828472995344, 0.25415209433082675, 0.2581828529215958,
	0.26225065752969623, 0.26635560480286247, 0.2704977910130658, 0.27467731206038465,
	0.2788942634768104, 0.2831487404299921, 0.2874408377269175, 0.29177064981753587,
	0.2961382707983211, 0.3005437944157765, 0.3049873140698863, 0.30946892281750854,
	0.31398871337571754, 0.31854677812509186, 0.32314320911295075, 0.3277780980565422,
	0.33245153634617935, 0.33716361504833037, 0.3419144249086609, 0.3467040563550296,
	0.35153259950043936, 0.3564001441459435, 0.3613067797835095, 0.3662525955988395,
	0.3712376804741491, 0.3762621229909065, 0.38132601143253014, 0.386429433787049,
	0.39157247774972326, 0.39675523072562685, 0.4019777798321958, 0.4072402119017367,
	0.41254261348390375, 0.4178850708481375, 0.4232676699860717, 0.4286904966139066,
	0.43415363617474895, 0.4396571738409188, 0.44520119451622786, 0.45078578283822346,
	0.45641102318040466, 0.4620769996544071, 0.467783796112159, 0.47353149614800955,
	0.4793201831008268, 0.4851499400560704, 0.4910208498478356, 0.4969329950608704,
	0.5028864580325687, 0.5088813208549338, 0.5149176653765214, 0.5209955732043543,
	0.5271151257058131, 0.5332764040105052, 0.5394794890121072, 0.5457244613701866,
	0.5520114015120001, 0.5583403896342679, 0.5647115057049292, 0.5711248294648731,
	0.5775804404296506, 0.5840784178911641, 0.5906188409193369, 0.5972017883637634,
	0.6038273388553378, 0.6104955708078648, 0.6172065624196511, 0.6239603916750761,
	0.6307571363461468, 0.6375968739940326, 0.6444796819705821, 0.6514056374198242,
	0.6583748172794485, 0.665387298282272, 0.6724431569576875, 0.6795424696330938,
	0.6866853124353135, 0.6938717612919899, 0.7011018919329731, 0.7083757798916868,
	0.7156935005064807, 0.7230551289219693, 0.7304607400903537, 0.7379104087727308,
	0.7454042095403874, 0.7529422167760779, 0.7605245046752924, 0.768151147247507,
	0.7758222183174236, 0.7835377915261935, 0.7912979403326302, 0.799102738014409,
	0.8069522576692516, 0.8148465722161012, 0.8227857543962835, 0.8307698767746546,
	0.83879901174074, 0.846873231509858, 0.8549926081242338, 0.8631572134541023,
	0.8713671191987972, 0.8796223968878317, 0.8879231178819663, 0.8962693533742664,
	0.9046611743911496, 0.9130986517934192, 0.9215818562772946, 0.9301108583754237,
	0.938685728457888, 0.9473065367331999, 0.9559733532492861, 0.9646862478944651,
	0.9734452903984125, 0.9822505503331171, 0.9911020971138298, 1.0,
};

// A fraction from 0 to 1 as an 8-bit channel value, rounded half up.
int channelFromFraction(double fraction)
{
	return std::clamp(static_cast<int>(std::floor(fraction * 255 + 0.5)), 0, 255);
}

// 0.5 + factor * (0.5 - lightness): the lightness reflected about the middle, with its distance
// from the middle multiplied by the factor. When the factor is more than 1, the results beyond 0
// and 1 would all be clamped to 0 or 1, so near the ends the result is softened instead, keeping
// different lightnesses different. Above softeningStart = 2 - largest, where largest =
// 0.5 + factor / 2 is the largest unsoftened result, the result is
// unsoftened - curvature * (unsoftened - softeningStart)^2, with the curvature chosen so that the
// largest result becomes exactly 1. Below 1 - softeningStart, the mirror image of that. The
// result always increases as the lightness decreases, for factors up to 2.
double invertedScaledLightness(double lightness, double factor)
{
	const double unsoftened = 0.5 + factor * (0.5 - lightness);
	if (factor <= 1) {
		return unsoftened;
	}
	const double largest = 0.5 + factor / 2;
	const double softeningStart = 2 - largest;
	const double curvature = (largest - 1) / ((largest - softeningStart) * (largest - softeningStart));
	if (unsoftened > softeningStart) {
		const double distance = unsoftened - softeningStart;
		return unsoftened - curvature * distance * distance;
	}
	if (unsoftened < 1 - softeningStart) {
		const double mirrored = 1 - unsoftened;
		const double distance = mirrored - softeningStart;
		return 1 - (mirrored - curvature * distance * distance);
	}
	return unsoftened;
}

// Converts to HSL, replaces the lightness with invertedScaledLightness(), and converts back, with
// the usual RGB and HSL conversion formulas.
QColor invertAndScaleLightness(const QColor &color, double factor)
{
	const double r = color.red() / 255.0;
	const double g = color.green() / 255.0;
	const double b = color.blue() / 255.0;
	const double maximum = std::max({ r, g, b });
	const double minimum = std::min({ r, g, b });
	const double lightness = (maximum + minimum) / 2;
	double hue = 0;
	double saturation = 0;
	if (maximum != minimum) {
		const double chroma = maximum - minimum;
		saturation = lightness > 0.5 ? chroma / (2 - maximum - minimum) : chroma / (maximum + minimum);
		if (maximum == r) {
			hue = std::fmod((g - b) / chroma, 6.0);
			if (hue < 0) {
				hue += 6.0;
			}
		} else if (maximum == g) {
			hue = (b - r) / chroma + 2;
		} else {
			hue = (r - g) / chroma + 4;
		}
		hue /= 6;
	}

	const double newLightness = invertedScaledLightness(lightness, factor);
	if (saturation == 0) {
		const int gray = channelFromFraction(newLightness);
		return QColor(gray, gray, gray);
	}
	const double q = newLightness < 0.5 ? newLightness * (1 + saturation)
			: newLightness + saturation - newLightness * saturation;
	const double p = 2 * newLightness - q;
	const auto channelForHue = [p, q](double t) {
		if (t < 0) {
			t += 1.0;
		} else if (t >= 1) {
			t -= 1.0;
		}
		if (t < 1.0 / 6) {
			return p + (q - p) * 6 * t;
		}
		if (t < 0.5) {
			return q;
		}
		if (t < 2.0 / 3) {
			return p + (q - p) * (2.0 / 3 - t) * 6;
		}
		return p;
	};
	return QColor(channelFromFraction(channelForHue(hue + 1.0 / 3)), channelFromFraction(channelForHue(hue)),
			channelFromFraction(channelForHue(hue - 1.0 / 3)));
}

// font_secondary in one scheme: the requested color if it has enough contrast on that scheme's
// page and background_secondary, else the first 5% step toward the scheme's font_primary that has.
QColor readableSecondaryText(const QColor &requested, const BrandingColors &scheme)
{
	const QColor &fontPrimary = scheme[BrandingData::FontPrimary];
	for (int step = 0; step < 20; ++step) {
		const QColor color = mix(requested, fontPrimary, step, 20);
		if (std::min(contrastRatio(color, scheme[BrandingData::BackgroundPage]),
				contrastRatio(color, scheme[BrandingData::BackgroundSecondary])) >= MinimumSecondaryTextContrast) {
			return color;
		}
	}
	return mix(requested, fontPrimary, 20, 20);
}

}

QColor mix(const QColor &from, const QColor &to, int numerator, int denominator)
{
	// Exact: (a(D - n) + bn) / D, rounded half up, without floating point.
	const auto mixChannel = [numerator, denominator](int a, int b) {
		return (a * (denominator - numerator) * 2 + b * numerator * 2 + denominator) / (2 * denominator);
	};
	return QColor(mixChannel(from.red(), to.red()), mixChannel(from.green(), to.green()),
			mixChannel(from.blue(), to.blue()));
}

QColor blendOnto(const QColor &color, int alpha, const QColor &background)
{
	return mix(background, color, alpha, 255);
}

QColor withAlpha(const QColor &color, int alpha)
{
	return QColor(color.red(), color.green(), color.blue(), alpha);
}

QColor lightModeBackgroundColor(const QColor &darkModeBackground, int factorThousandths)
{
	return invertAndScaleLightness(darkModeBackground, factorThousandths / 1000.0);
}

QColor lightnessInverted(const QColor &color)
{
	return invertAndScaleLightness(color, 1.0);
}

double relativeLuminance(const QColor &color)
{
	return 0.2126 * LinearisedChannelValue[color.red()] + 0.7152 * LinearisedChannelValue[color.green()]
			+ 0.0722 * LinearisedChannelValue[color.blue()];
}

double contrastRatio(const QColor &a, const QColor &b)
{
	const double la = relativeLuminance(a);
	const double lb = relativeLuminance(b);
	return (std::max(la, lb) + 0.05) / (std::min(la, lb) + 0.05);
}

QColor textColorOn(std::initializer_list<QColor> fills, const QColor &darkerFontPrimary)
{
	static const QColor white(255, 255, 255);
	const auto readable = [&fills](const QColor &text) {
		return std::all_of(fills.begin(), fills.end(), [&text](const QColor &fill) {
			return contrastRatio(text, fill) >= MinimumWhiteTextContrast;
		});
	};
	if (readable(white)) {
		return white;
	}
	// A mid-gray fill can be too light for white and too close to darkerFontPrimary for that dark
	// color. Darken it toward black until it can be read on every fill. Step 0 is the fallback
	// itself, so a fallback that already passes is returned unchanged.
	const QColor black(0, 0, 0);
	const QColor from(darkerFontPrimary.red(), darkerFontPrimary.green(), darkerFontPrimary.blue());
	for (int step = 0; step <= 255; ++step) {
		const QColor candidate = mix(from, black, step, 255);
		if (readable(candidate)) {
			return candidate;
		}
	}
	return black;
}

QColor fillForText(const QColor &preferred, const QColor &textColor)
{
	if (contrastRatio(textColor, preferred) >= MinimumWhiteTextContrast) {
		return preferred;
	}
	const QColor black(0, 0, 0);
	const QColor white(255, 255, 255);
	const QColor &toward = contrastRatio(textColor, black) >= contrastRatio(textColor, white) ? black : white;
	for (int step = 1; step <= 255; ++step) {
		const QColor candidate = mix(preferred, toward, step, 255);
		if (contrastRatio(textColor, candidate) >= MinimumWhiteTextContrast) {
			return candidate;
		}
	}
	return toward;
}

namespace {

QColor drawnOnFill(const QColor &text, const QColor &fill)
{
	if (text.alpha() == 255) {
		return QColor(text.red(), text.green(), text.blue());
	}
	return blendOnto(text, text.alpha(), fill);
}

bool readableOnFills(const QColor &text, std::initializer_list<QColor> fills)
{
	return std::all_of(fills.begin(), fills.end(), [&text](const QColor &fill) {
		return contrastRatio(drawnOnFill(text, fill), fill) >= MinimumWhiteTextContrast;
	});
}

}

QColor readableTextOn(const QColor &preferred, std::initializer_list<QColor> fills, const QColor &darkerFontPrimary)
{
	if (readableOnFills(preferred, fills)) {
		return preferred;
	}
	if (preferred.alpha() < 255) {
		for (int alpha = preferred.alpha() + 1; alpha <= 255; ++alpha) {
			const QColor candidate = withAlpha(preferred, alpha);
			if (readableOnFills(candidate, fills)) {
				return candidate;
			}
		}
	}
	const QColor target = textColorOn(fills, darkerFontPrimary);
	const QColor from(preferred.red(), preferred.green(), preferred.blue());
	for (int step = 1; step <= 255; ++step) {
		const QColor candidate = mix(from, target, step, 255);
		if (readableOnFills(candidate, fills)) {
			return candidate;
		}
	}
	return target;
}

bool isValidLightModeBackgroundFactor(qreal value)
{
	// Rounded to thousandths, it must be more than 0 and at most 2.
	return std::isfinite(value) && value > 0 && value <= MaximumLightModeBackgroundFactorThousandths / 1000.0
			&& qRound(value * 1000) >= 1;
}

int toLightModeBackgroundFactorThousandths(qreal value)
{
	return isValidLightModeBackgroundFactor(value) ? qRound(value * 1000)
			: DefaultLightModeBackgroundFactorThousandths;
}

ResolvedBrandingColors resolveBrandingColors(const QList<BrandingData> &brandingList)
{
	ResolvedBrandingColors result;
	BrandingColors &darkScheme = result.darkScheme;

	// When more than one entry sets a color, the last one is used.
	std::array<qsizetype, BrandingData::ColorCount> sourceIndex;
	sourceIndex.fill(-1);
	for (qsizetype i = 0; i < brandingList.size(); ++i) {
		const BrandingData &data = brandingList.at(i);
		for (int color = 0; color < BrandingData::ColorCount; ++color) {
			if (data.colors[color].has_value()) {
				darkScheme[color] = *data.colors[color];
				sourceIndex[color] = i;
			}
		}
	}

	// light_mode_background_factor, background_secondary and background_page are chosen to suit a
	// particular background_primary, so they are used only if they come from the entry whose
	// background_primary is used (or, for the two colors, from a later one).
	const qsizetype backgroundPrimarySource = sourceIndex[BrandingData::BackgroundPrimary];
	result.backgroundPrimarySourceIndex = backgroundPrimarySource;
	result.fontPrimarySourceIndex = sourceIndex[BrandingData::FontPrimary];
	if (backgroundPrimarySource >= 0) {
		const std::optional<qreal> &factor = brandingList.at(backgroundPrimarySource).lightModeBackgroundFactor;
		if (factor.has_value()) {
			result.lightModeBackgroundFactorThousandths = toLightModeBackgroundFactorThousandths(*factor);
		}
	}
	const int factorThousandths = result.lightModeBackgroundFactorThousandths;
	if (sourceIndex[BrandingData::BackgroundSecondary] < 0
			|| sourceIndex[BrandingData::BackgroundSecondary] < backgroundPrimarySource) {
		// The same difference as Victron's: #141414 is 2/25 of the way from black toward white.
		darkScheme[BrandingData::BackgroundSecondary] = mix(darkScheme[BrandingData::BackgroundPrimary],
				darkScheme[BrandingData::FontPrimary], 2, 25);
	}
	if (sourceIndex[BrandingData::BackgroundPage] < 0
			|| sourceIndex[BrandingData::BackgroundPage] < backgroundPrimarySource) {
		darkScheme[BrandingData::BackgroundPage] = darkScheme[BrandingData::BackgroundPrimary];
	}

	// The Light scheme: brand, success, warning and critical are the same as in Dark. The
	// backgrounds are converted with lightModeBackgroundColor(). font_primary is inverted, then
	// mixed 15% toward the background, so that text is not pure black on white. The page is always
	// computed: 12% of the way from background_primary toward font_primary.
	BrandingColors &lightScheme = result.lightScheme;
	lightScheme = darkScheme;
	lightScheme[BrandingData::BackgroundPrimary] = lightModeBackgroundColor(
			darkScheme[BrandingData::BackgroundPrimary], factorThousandths);
	lightScheme[BrandingData::BackgroundSecondary] = lightModeBackgroundColor(
			darkScheme[BrandingData::BackgroundSecondary], factorThousandths);
	lightScheme[BrandingData::FontPrimary] = mix(lightnessInverted(darkScheme[BrandingData::FontPrimary]),
			lightScheme[BrandingData::BackgroundPrimary], 3, 20);
	lightScheme[BrandingData::BackgroundPage] = mix(lightScheme[BrandingData::BackgroundPrimary],
			lightScheme[BrandingData::FontPrimary], 3, 25);

	const QColor requestedSecondaryText = darkScheme[BrandingData::FontSecondary];
	darkScheme[BrandingData::FontSecondary] = readableSecondaryText(requestedSecondaryText, darkScheme);
	lightScheme[BrandingData::FontSecondary] = readableSecondaryText(requestedSecondaryText, lightScheme);

	const QColor &darkSchemeFontPrimary = darkScheme[BrandingData::FontPrimary];
	const QColor &lightSchemeFontPrimary = lightScheme[BrandingData::FontPrimary];
	result.darkerFontPrimary = relativeLuminance(darkSchemeFontPrimary) <= relativeLuminance(lightSchemeFontPrimary)
			? darkSchemeFontPrimary : lightSchemeFontPrimary;
	return result;
}

} // namespace ColorDerivation
} // namespace VenusOS
} // namespace Victron
