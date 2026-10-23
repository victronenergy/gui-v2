/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_BRANDING_BRANDING_H
#define VICTRON_BRANDING_BRANDING_H

// Victron.Branding depends only on Qt. It must not include, import or link
// any other Victron module (see .github/architecture.md).

#include <QObject>
#include <QColor>
#include <QString>
#include <QStringList>
#include <QUrl>
#include <qqmlintegration.h>

#include <array>
#include <optional>

namespace Victron {

// The version of the Victron.Branding module, set in cmake/ModuleBranding.cmake.
// The loader checks each plugin's requiredBrandingVersion against it.
inline constexpr int BrandingModuleMajorVersion = VICTRON_BRANDING_VERSION_MAJOR;
inline constexpr int BrandingModuleMinorVersion = VICTRON_BRANDING_VERSION_MINOR;

/*
A plain-value copy of the properties that a Branding file set.

An unset property is std::nullopt: the file did not mention it, so lookups
skip it. No sentinel value means "unset".
*/
struct BrandingData
{
	// The colors that a Branding file can set. The other theme colors are computed from them.
	enum Color {
		Brand = 0,
		Success,
		Warning,
		Critical,
		BackgroundPrimary,
		BackgroundSecondary,
		BackgroundPage,
		FontPrimary,
		FontSecondary,
		ColorCount
	};

	static QString colorPropertyName(Color color);

	std::array<std::optional<QColor>, ColorCount> colors;
	// How far the computed Light mode backgrounds move from the Dark mode ones: HSL lightness L
	// becomes 0.5 + factor * (0.5 - L). The value as written: the loader validates and rounds it.
	std::optional<qreal> lightModeBackgroundFactor;
	std::optional<QStringList> fontFiles;
	std::optional<QString> fontFamily;
	std::optional<QString> quantityFontFamily;
	std::optional<QUrl> splashLogoIcon;
	std::optional<QUrl> splashLogoText;
	std::optional<bool> splashLogoIconPreserveColors;
	std::optional<bool> splashLogoTextPreserveColors;

	// Not a Branding property: the loader records which plugin supplied the data.
	QString pluginName;
};

/*
The Branding type that branding plugins instantiate in their Branding.qml.

Each plugin file is one instance. The host creates it, takes a snapshot(),
and destroys it, so no plugin object stays alive.

It has no default property, so it cannot hold child objects. Properties have
no change signals: the values are read once, by the host, after creation.
*/
class Branding : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	// The comment above each property is its entry in the property reference in
	// .github/branding-plugins.md: tools/brandingproperties.py copies it there. It says what the
	// property sets, then "If not set:" and what is used when no installed Branding file sets it.

	// The brand color: buttons, switches, sliders, radio buttons, the selected navigation bar tab,
	// the Overview widget borders, and informative notifications. The Light scheme uses the same color.
	// If not set: Victron's color.
	Q_PROPERTY(QColor color_brand READ color_brand WRITE setColor_brand FINAL)
	// Good states, such as feed-in power, and the key navigation focus ring in the Dark scheme.
	// The Light scheme uses the same color.
	// If not set: Victron's color.
	Q_PROPERTY(QColor color_success READ color_success WRITE setColor_success FINAL)
	// Warnings, modified settings, the demo mode indicator, and the key navigation focus ring in the
	// Light scheme. The Light scheme uses the same color.
	// If not set: Victron's color.
	Q_PROPERTY(QColor color_warning READ color_warning WRITE setColor_warning FINAL)
	// Errors and alarms. The Light scheme uses the same color.
	// If not set: Victron's color.
	Q_PROPERTY(QColor color_critical READ color_critical WRITE setColor_critical FINAL)
	// The main background in the Dark scheme. The Light scheme's background is computed from it, using
	// light_mode_background_factor. The Branding file whose color_background_primary is used also
	// supplies the background factor, and limits where color_background_secondary and
	// color_background_page are read from, so set them in the same file.
	// If not set: Victron's color.
	Q_PROPERTY(QColor color_background_primary READ color_background_primary WRITE setColor_background_primary FINAL)
	// The background of cards and list items in the Dark scheme. The Light scheme's is computed from
	// it. Read only from the Branding file whose color_background_primary is used, or a later one.
	// If not set: computed from color_background_primary, mixed 8% toward color_font_primary. Victron's
	// color is used only when no Branding file sets color_background_primary.
	Q_PROPERTY(QColor color_background_secondary READ color_background_secondary WRITE setColor_background_secondary FINAL)
	// The page background behind the cards, in the Dark scheme only: the Light scheme's page is always
	// its background mixed 12% toward its text color. Read only from the Branding file whose
	// color_background_primary is used, or a later one.
	// If not set: color_background_primary.
	Q_PROPERTY(QColor color_background_page READ color_background_page WRITE setColor_background_page FINAL)
	// The main text and icons in the Dark scheme. The Light scheme's text color is computed from it.
	// The loader warns when it has less than 4.5:1 contrast on color_background_primary in either scheme.
	// If not set: Victron's color.
	Q_PROPERTY(QColor color_font_primary READ color_font_primary WRITE setColor_font_primary FINAL)
	// Secondary text, such as list item values and the unselected navigation bar tabs, in the Dark
	// scheme. In each scheme, if it has less than 3:1 contrast on the page or on the card background,
	// it is moved toward the scheme's main text color until it has.
	// If not set: Victron's color.
	Q_PROPERTY(QColor color_font_secondary READ color_font_secondary WRITE setColor_font_secondary FINAL)
	// How the Light scheme's backgrounds are computed from the Dark scheme's: 1.0 inverts their
	// lightness, a lower value moves them toward mid gray, and a higher value spreads them apart.
	// More than 0 and at most 2. Read only from the Branding file whose color_background_primary is
	// used, so set the two together.
	// If not set: 1.0. Victron's own backgrounds use 1.12, so a plugin that sets no
	// color_background_primary keeps that.
	Q_PROPERTY(qreal light_mode_background_factor READ light_mode_background_factor WRITE setLight_mode_background_factor FINAL)
	// Font files (.ttf or .otf) to register, relative to Branding.qml. Name the font with font_family
	// and quantity_font_family.
	// If not set: no font files are registered.
	Q_PROPERTY(QStringList font_files READ font_files WRITE setFont_files FINAL)
	// The family name of the font for all text except quantities, from font_files or installed on the
	// device. It is used only for languages it has the letters for; the others, and languages that
	// have their own font (such as Chinese), use the built-in font.
	// If not set: the built-in font, Roboto, or the language's own font.
	Q_PROPERTY(QString font_family READ font_family WRITE setFont_family FINAL)
	// The family name of the font for quantities: numbers with their units. It needs digits of equal
	// width, or changing values jitter. It is used for every language.
	// If not set: Roboto.
	Q_PROPERTY(QString quantity_font_family READ quantity_font_family WRITE setQuantity_font_family FINAL)
	// The icon on the start-up screen: an .svg or .png file, relative to Branding.qml. It is drawn over
	// splash_logo_text, both stretched to the same box, so draw it on a 285x54 canvas, at the left.
	// If not set: Victron's icon.
	Q_PROPERTY(QUrl splash_logo_icon READ splash_logo_icon WRITE setSplash_logo_icon FINAL)
	// The wordmark on the start-up screen: an .svg or .png file, relative to Branding.qml. Draw it on a
	// 285x54 canvas, to the right of the icon. Draw text as paths, not as SVG text.
	// If not set: Victron's wordmark.
	Q_PROPERTY(QUrl splash_logo_text READ splash_logo_text WRITE setSplash_logo_text FINAL)
	// true: draw splash_logo_icon in its own colors, which must then read on both the Dark and the
	// Light background. false: draw it in one color, the scheme's main text color.
	// If not set: false.
	Q_PROPERTY(bool splash_logo_icon_preserve_colors READ splash_logo_icon_preserve_colors WRITE setSplash_logo_icon_preserve_colors FINAL)
	// true: draw splash_logo_text in its own colors, which must then read on both the Dark and the
	// Light background. false: draw it in one color, the scheme's main text color.
	// If not set: false.
	Q_PROPERTY(bool splash_logo_text_preserve_colors READ splash_logo_text_preserve_colors WRITE setSplash_logo_text_preserve_colors FINAL)

public:
	explicit Branding(QObject *parent = nullptr);

	// Returns the properties that were set, and only those.
	BrandingData snapshot() const;

	QColor color_brand() const { return brandingColor(BrandingData::Brand); }
	void setColor_brand(const QColor &c) { setBrandingColor(BrandingData::Brand, c); }
	QColor color_success() const { return brandingColor(BrandingData::Success); }
	void setColor_success(const QColor &c) { setBrandingColor(BrandingData::Success, c); }
	QColor color_warning() const { return brandingColor(BrandingData::Warning); }
	void setColor_warning(const QColor &c) { setBrandingColor(BrandingData::Warning, c); }
	QColor color_critical() const { return brandingColor(BrandingData::Critical); }
	void setColor_critical(const QColor &c) { setBrandingColor(BrandingData::Critical, c); }
	QColor color_background_primary() const { return brandingColor(BrandingData::BackgroundPrimary); }
	void setColor_background_primary(const QColor &c) { setBrandingColor(BrandingData::BackgroundPrimary, c); }
	QColor color_background_secondary() const { return brandingColor(BrandingData::BackgroundSecondary); }
	void setColor_background_secondary(const QColor &c) { setBrandingColor(BrandingData::BackgroundSecondary, c); }
	QColor color_background_page() const { return brandingColor(BrandingData::BackgroundPage); }
	void setColor_background_page(const QColor &c) { setBrandingColor(BrandingData::BackgroundPage, c); }
	QColor color_font_primary() const { return brandingColor(BrandingData::FontPrimary); }
	void setColor_font_primary(const QColor &c) { setBrandingColor(BrandingData::FontPrimary, c); }
	QColor color_font_secondary() const { return brandingColor(BrandingData::FontSecondary); }
	void setColor_font_secondary(const QColor &c) { setBrandingColor(BrandingData::FontSecondary, c); }

	qreal light_mode_background_factor() const { return m_data.lightModeBackgroundFactor.value_or(1.0); }
	void setLight_mode_background_factor(qreal factor) { m_data.lightModeBackgroundFactor = factor; }

	QStringList font_files() const { return m_data.fontFiles.value_or(QStringList()); }
	void setFont_files(const QStringList &files) { m_data.fontFiles = files; }
	QString font_family() const { return m_data.fontFamily.value_or(QString()); }
	void setFont_family(const QString &family) { m_data.fontFamily = family; }
	QString quantity_font_family() const { return m_data.quantityFontFamily.value_or(QString()); }
	void setQuantity_font_family(const QString &family) { m_data.quantityFontFamily = family; }

	QUrl splash_logo_icon() const { return m_data.splashLogoIcon.value_or(QUrl()); }
	void setSplash_logo_icon(const QUrl &url) { m_data.splashLogoIcon = url; }
	QUrl splash_logo_text() const { return m_data.splashLogoText.value_or(QUrl()); }
	void setSplash_logo_text(const QUrl &url) { m_data.splashLogoText = url; }
	bool splash_logo_icon_preserve_colors() const { return m_data.splashLogoIconPreserveColors.value_or(false); }
	void setSplash_logo_icon_preserve_colors(bool preserve) { m_data.splashLogoIconPreserveColors = preserve; }
	bool splash_logo_text_preserve_colors() const { return m_data.splashLogoTextPreserveColors.value_or(false); }
	void setSplash_logo_text_preserve_colors(bool preserve) { m_data.splashLogoTextPreserveColors = preserve; }

private:
	QColor brandingColor(BrandingData::Color color) const { return m_data.colors[color].value_or(QColor()); }
	void setBrandingColor(BrandingData::Color color, const QColor &value) { m_data.colors[color] = value; }

	BrandingData m_data;
};

} // namespace Victron

#endif // VICTRON_BRANDING_BRANDING_H
