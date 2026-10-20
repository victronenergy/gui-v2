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
#include <QColor>
#include <QList>
#include <QUrl>
#include <qqmlintegration.h>

#include "enums.h"
#include "branding.h"
#include "colorderivation.h"

namespace Victron {
namespace VenusOS {

class Theme : public QObject
{
	Q_OBJECT
	QML_NAMED_ELEMENT(ThemeBase)
	Q_PROPERTY(ScreenSize screenSize READ screenSize WRITE setScreenSize NOTIFY screenSizeChanged)
	Q_PROPERTY(ColorScheme colorScheme READ colorScheme WRITE setColorScheme NOTIFY colorSchemeChanged)
	Q_PROPERTY(SystemColorScheme systemColorScheme READ systemColorScheme WRITE setSystemColorScheme NOTIFY systemColorSchemeChanged)
	Q_PROPERTY(ForcedColorScheme forcedColorScheme READ forcedColorScheme WRITE setForcedColorScheme NOTIFY forcedColorSchemeChanged)
	Q_PROPERTY(QString applicationVersion READ applicationVersion CONSTANT)
	Q_PROPERTY(int geometry_screen_width READ geometry_screen_width WRITE setGeometry_screen_width NOTIFY geometry_screen_widthChanged FINAL)
	Q_PROPERTY(int geometry_screen_height READ geometry_screen_height WRITE setGeometry_screen_height NOTIFY geometry_screen_heightChanged FINAL)
	Q_PROPERTY(bool adjustingGeometry READ adjustingGeometry NOTIFY adjustingGeometryChanged FINAL)
	Q_PROPERTY(int visualViewportBottom READ visualViewportBottom NOTIFY visualViewportBottomChanged FINAL)
	Q_PROPERTY(bool virtualKeyboardOpened READ virtualKeyboardOpened NOTIFY virtualKeyboardOpenedChanged FINAL)

	// Branding-dependent values. An empty font family means "use the built-in font".
	Q_PROPERTY(QString font_family READ font_family NOTIFY themeValuesChanged FINAL)
	Q_PROPERTY(QString quantity_font_family READ quantity_font_family NOTIFY themeValuesChanged FINAL)
	Q_PROPERTY(QUrl splash_logo_icon READ splash_logo_icon NOTIFY themeValuesChanged FINAL)
	Q_PROPERTY(QUrl splash_logo_text READ splash_logo_text NOTIFY themeValuesChanged FINAL)
	Q_PROPERTY(bool splash_logo_icon_preserve_colors READ splash_logo_icon_preserve_colors NOTIFY themeValuesChanged FINAL)
	Q_PROPERTY(bool splash_logo_text_preserve_colors READ splash_logo_text_preserve_colors NOTIFY themeValuesChanged FINAL)

public:
	enum ScreenSize {
		FiveInch = 0,
		SevenInch,
		Portrait
	};
	Q_ENUM(ScreenSize)

	enum ColorScheme {
		Dark = 0,
		Light
	};
	Q_ENUM(ColorScheme)

	enum SystemColorScheme {
		SystemColorSchemeDark = 0,
		SystemColorSchemeLight
	};
	Q_ENUM(SystemColorScheme)

	enum ForcedColorScheme {
		ForcedColorSchemeDark = 0,
		ForcedColorSchemeLight,
		ForcedColorSchemeAuto,
		ForcedColorSchemeDefault // uses the user choice, not the forced color scheme
	};
	Q_ENUM(ForcedColorScheme)

	enum StatusLevel {
		Ok = 0,
		Warning,
		Critical
	};
	Q_ENUM(StatusLevel)

	explicit Theme(QObject *parent = nullptr);

	Victron::VenusOS::Theme::ScreenSize screenSize() const;
	void setScreenSize(Victron::VenusOS::Theme::ScreenSize size);

	Victron::VenusOS::Theme::ColorScheme colorScheme() const;
	void setColorScheme(Victron::VenusOS::Theme::ColorScheme scheme);

	Victron::VenusOS::Theme::SystemColorScheme systemColorScheme() const;
	void setSystemColorScheme(Victron::VenusOS::Theme::SystemColorScheme systemScheme);

	static Theme *instance();

	Victron::VenusOS::Theme::ForcedColorScheme forcedColorScheme() const;
	void setForcedColorScheme(Victron::VenusOS::Theme::ForcedColorScheme forcedScheme);

	int geometry_screen_width() const;
	void setGeometry_screen_width(int width);
	int geometry_screen_height() const;
	void setGeometry_screen_height(int height);

	Q_INVOKABLE Victron::VenusOS::Theme::StatusLevel getValueStatus(qreal value, Victron::VenusOS::Enums::Gauges_ValueType valueType) const;
	Q_INVOKABLE bool objectHasQObjectParent(QObject *obj) const;

	bool adjustingGeometry() const;
	bool virtualKeyboardOpened() const;
	QString applicationVersion() const;

	// The y pos of the bottom of the visual viewport.
	// - On GX, this is the top of the VKB.
	// - On Wasm, this is window.visualViewport.offsetTop + window.visualViewport.height, which
	//   should also be equivalent to the top of the VKB when it is visible.
	int visualViewportBottom() const;

	// Internal functions: used by JS Emscripten bridge.
	void setWindowHeight(int height);
	void setVisualViewportHeight(int height);
	void setVisualViewportOffsetTop(int offsetTop);

	// Branding: the values that each loaded branding plugin set, in plugin-name order.
	// When more than one plugin sets a property, the last one is used, except that
	// light_mode_background_factor, background_secondary and background_page are used only with
	// their own background_primary (see ColorDerivation::resolveBrandingColors()).
	// Emits themeValuesChanged() once.
	void setPluginBranding(const QList<Victron::BrandingData> &pluginBranding);
	QList<Victron::BrandingData> pluginBranding() const;

	QString font_family() const;
	QString quantity_font_family() const;
	QUrl splash_logo_icon() const;
	QUrl splash_logo_text() const;
	bool splash_logo_icon_preserve_colors() const;
	bool splash_logo_text_preserve_colors() const;

	static QUrl builtInSplashLogoIcon();
	static QUrl builtInSplashLogoText();
	static QString builtInFontFamily();

	// The light_mode_background_factor of the built-in (Victron) branding, in thousandths.
	static constexpr int VictronLightModeBackgroundFactorThousandths = 1120;

	// The branding colors of both color schemes, after the plugin branding is applied.
	const ColorDerivation::ResolvedBrandingColors &resolvedBrandingColors() const { return m_brandingColors; }

Q_SIGNALS:
	void screenSizeChanged(Victron::VenusOS::Theme::ScreenSize screenSize);
	void screenSizeChanged_parameterless();
	void colorSchemeChanged(Victron::VenusOS::Theme::ColorScheme colorScheme);
	void colorSchemeChanged_parameterless();
	void systemColorSchemeChanged(Victron::VenusOS::Theme::SystemColorScheme systemColorScheme);
	void systemColorSchemeChanged_parameterless();
	void forcedColorSchemeChanged(Victron::VenusOS::Theme::ForcedColorScheme forcedColorScheme);
	void geometry_screen_widthChanged();
	void geometry_screen_heightChanged();
	void adjustingGeometryChanged();
	void visualViewportBottomChanged();
	void virtualKeyboardOpenedChanged();

	// Emitted when a branding-dependent or color-scheme-dependent value may have changed.
	void themeValuesChanged();

protected:
	void setAdjustingGeometry(bool adjusting);
	void updateViewportAndKeyboardProperties();

	// The generated ThemeSingleton returns Victron's value of a branding color: its value in Dark.json.
	virtual QColor victronBrandingColor(Victron::BrandingData::Color color) const;

	// The generated ThemeSingleton computes the colors of the current scheme from m_brandingColors.
	virtual void resolvePalette();

	// Resolves m_brandingColors from Victron's branding colors and the plugin branding.
	void resolveBrandingColors(bool warnAboutContrast = false);
	void resolveBranding();
	QString resolveFontFamily();

	ScreenSize m_screenSize = SevenInch;
	ColorScheme m_colorScheme = Dark;
	SystemColorScheme m_systemColorScheme = SystemColorSchemeDark;
	ForcedColorScheme m_forcedColorScheme = ForcedColorSchemeDefault;
	int m_screenWidth = 1024;
	int m_screenHeight = 600;
	int m_visualViewportBottom = 0;
	int m_windowHeight = 0;
	int m_visualViewportHeight = 0;
	int m_visualViewportOffsetTop = 0;
	bool m_adjustingGeometry = false;
	bool m_virtualKeyboardOpened = false;

	QList<Victron::BrandingData> m_pluginBranding;
	ColorDerivation::ResolvedBrandingColors m_brandingColors;
	QUrl m_splashLogoIcon;
	QUrl m_splashLogoText;
	bool m_splashLogoIconPreserveColors = false;
	bool m_splashLogoTextPreserveColors = false;
	QString m_fontFamily;
	QString m_quantityFontFamily;
	QString m_lastFontCoverageWarning;
	bool m_languageConnected = false;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_THEME_H
