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

	Q_PROPERTY(QColor color_brand READ color_brand WRITE setColor_brand FINAL)
	Q_PROPERTY(QColor color_success READ color_success WRITE setColor_success FINAL)
	Q_PROPERTY(QColor color_warning READ color_warning WRITE setColor_warning FINAL)
	Q_PROPERTY(QColor color_critical READ color_critical WRITE setColor_critical FINAL)
	Q_PROPERTY(QColor color_background_primary READ color_background_primary WRITE setColor_background_primary FINAL)
	Q_PROPERTY(QColor color_background_secondary READ color_background_secondary WRITE setColor_background_secondary FINAL)
	Q_PROPERTY(QColor color_background_page READ color_background_page WRITE setColor_background_page FINAL)
	Q_PROPERTY(QColor color_font_primary READ color_font_primary WRITE setColor_font_primary FINAL)
	Q_PROPERTY(QColor color_font_secondary READ color_font_secondary WRITE setColor_font_secondary FINAL)
	Q_PROPERTY(qreal light_mode_background_factor READ light_mode_background_factor WRITE setLight_mode_background_factor FINAL)
	Q_PROPERTY(QStringList font_files READ font_files WRITE setFont_files FINAL)
	Q_PROPERTY(QString font_family READ font_family WRITE setFont_family FINAL)
	Q_PROPERTY(QString quantity_font_family READ quantity_font_family WRITE setQuantity_font_family FINAL)
	Q_PROPERTY(QUrl splash_logo_icon READ splash_logo_icon WRITE setSplash_logo_icon FINAL)
	Q_PROPERTY(QUrl splash_logo_text READ splash_logo_text WRITE setSplash_logo_text FINAL)
	Q_PROPERTY(bool splash_logo_icon_preserve_colors READ splash_logo_icon_preserve_colors WRITE setSplash_logo_icon_preserve_colors FINAL)
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
