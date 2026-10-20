/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "theme.h"
#include "language.h"
#include "logging.h"

#include <QInputMethod>
#include <QFont>
#include <QFontDatabase>
#include <QLocale>
#include <QRawFont>

using namespace Victron::VenusOS;

// Global pointer to current theme instance
static Victron::VenusOS::Theme *g_themeInstance = nullptr;

namespace {

using Victron::BrandingData;

QFontDatabase::WritingSystem writingSystemForLanguage(QLocale::Language language)
{
	switch (QLocale(language).script()) {
	case QLocale::LatinScript: return QFontDatabase::Latin;
	case QLocale::CyrillicScript: return QFontDatabase::Cyrillic;
	case QLocale::GreekScript: return QFontDatabase::Greek;
	case QLocale::ArabicScript: return QFontDatabase::Arabic;
	case QLocale::HebrewScript: return QFontDatabase::Hebrew;
	case QLocale::ThaiScript: return QFontDatabase::Thai;
	case QLocale::SimplifiedHanScript: return QFontDatabase::SimplifiedChinese;
	case QLocale::TraditionalHanScript: return QFontDatabase::TraditionalChinese;
	case QLocale::JapaneseScript: return QFontDatabase::Japanese;
	case QLocale::KoreanScript: return QFontDatabase::Korean;
	default: return QFontDatabase::Any;
	}
}

// Fonts report "Latin" for basic Latin alone, so also sample the
// Latin-extended letters of the supported languages that need them.
QList<char32_t> sampleCharacters(QLocale::Language language)
{
	switch (language) {
	case QLocale::Czech:
		return { 0x011B, 0x0161, 0x010D, 0x0159, 0x017E, 0x016F, 0x011A, 0x0160, 0x010C, 0x0158, 0x017D, 0x016E };
	case QLocale::Polish:
		return { 0x0105, 0x0107, 0x0119, 0x0142, 0x0144, 0x015B, 0x017A, 0x017C, 0x0104, 0x0141, 0x015A, 0x017B };
	case QLocale::Romanian:
		return { 0x0103, 0x00E2, 0x00EE, 0x0219, 0x021B, 0x0102, 0x0218, 0x021A };
	case QLocale::Turkish:
		return { 0x011F, 0x0131, 0x015F, 0x00E7, 0x0130, 0x011E, 0x015E };
	default:
		return {};
	}
}

bool fontCoversLanguage(const QString &family, QLocale::Language language)
{
	const QFontDatabase::WritingSystem writingSystem = writingSystemForLanguage(language);
	if (writingSystem != QFontDatabase::Any
			&& !QFontDatabase::writingSystems(family).contains(writingSystem)) {
		return false;
	}
	const QList<char32_t> samples = sampleCharacters(language);
	if (!samples.isEmpty()) {
		const QRawFont rawFont = QRawFont::fromFont(QFont(family));
		for (char32_t c : samples) {
			if (!rawFont.supportsCharacter(c)) {
				return false;
			}
		}
	}
	return true;
}

const QUrl &builtInLanguageFontUrl()
{
	static const QUrl url(QStringLiteral("qrc:/fonts/Roboto-Regular.ttf"));
	return url;
}

}

#if defined(VENUS_WEBASSEMBLY_BUILD)
#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>

EM_JS(int, getScreenWidth, (), {
	return screen.width;
});

EM_JS(int, getScreenHeight, (), {
	return screen.height;
});

EM_JS(int, getWindowHeight, (), {
	return window.innerHeight;
});

EM_JS(int, getVisualViewportHeight, (), {
	return window.visualViewport ? window.visualViewport.height : window.innerHeight;
});

EM_JS(int, getVisualViewportOffsetTop, (), {
	return window.visualViewport ? window.visualViewport.offsetTop : 0;
});

#endif

Theme::Theme(QObject *parent)
	: QObject(parent)
	, m_splashLogoIcon(builtInSplashLogoIcon())
	, m_splashLogoText(builtInSplashLogoText())
{
#if defined(VENUS_WEBASSEMBLY_BUILD)
	// 5"-6" Smartphones have 320 - 480 CSS independent pixel wide screens.
	if (getScreenHeight() > getScreenWidth()) {
		setScreenSize(Victron::VenusOS::Theme::Portrait);
	} else {
		setScreenSize(getScreenWidth() >= 480
			? Victron::VenusOS::Theme::SevenInch
			: Victron::VenusOS::Theme::FiveInch);
	}

	setWindowHeight(getWindowHeight());
	setVisualViewportHeight(getVisualViewportHeight());
	setVisualViewportOffsetTop(getVisualViewportOffsetTop());

	// Assign global instance for callbacks
	g_themeInstance = this;

	// Detect current color scheme and listen for changes
	emscripten::val mql = emscripten::val::global("window").call<emscripten::val>("matchMedia", std::string("(prefers-color-scheme: dark)"));
	bool isSystemSchemeDark = mql["matches"].as<bool>();

	setSystemColorScheme(isSystemSchemeDark ? Victron::VenusOS::Theme::SystemColorSchemeDark
								: Victron::VenusOS::Theme::SystemColorSchemeLight);

	// Sets the initial color to the same as the HTML loading screen until the right setting is available and applied
	// This prevents changing color scheme too often during startup
	setColorScheme(isSystemSchemeDark ? Victron::VenusOS::Theme::Dark
								: Victron::VenusOS::Theme::Light);

	// Register JavaScript listener for dynamic updates
	mql.call<void>("addEventListener", std::string("change"), emscripten::val::module_property("jsSystemColorSchemeChanged"));
#else
	QScreen *primaryScreen = QGuiApplication::primaryScreen();
	const QSize screenResolution = primaryScreen->size();

	// Physical diagonal size alone doesn't determine resolution: more than one
	// common panel resolution shares a ~7" diagonal (e.g. the official Raspberry
	// Pi touchscreen is 800x480, not the usual 1024x600). Prefer a direct match
	// against the actual native resolution so those panels get a 1:1 (unscaled)
	// layout instead of being scaled down from the wrong design resolution.
	if (screenResolution == QSize(800, 480)) {
		setScreenSize(Victron::VenusOS::Theme::FiveInch);
	} else if (screenResolution == QSize(1024, 600)) {
		setScreenSize(Victron::VenusOS::Theme::SevenInch);
	} else {
		const QSizeF physicalScreenSize = primaryScreen->physicalSize();
		const int screenDiagonalMm = static_cast<int>(sqrt((physicalScreenSize.width() * physicalScreenSize.width())
			+ (physicalScreenSize.height() * physicalScreenSize.height())));
		setScreenSize((round(screenDiagonalMm / 10 / 2.5) == 7)
			? Victron::VenusOS::Theme::SevenInch
			: Victron::VenusOS::Theme::FiveInch);
	}

	if (QInputMethod *inputMethod = QGuiApplication::inputMethod()) {
		connect(inputMethod, &QInputMethod::keyboardRectangleChanged, this, &Theme::updateViewportAndKeyboardProperties);
		connect(inputMethod, &QInputMethod::visibleChanged, this, &Theme::updateViewportAndKeyboardProperties);
	}
#endif
}

Theme *Theme::instance()
{
	return g_themeInstance;
}

Victron::VenusOS::Theme::ScreenSize Theme::screenSize() const
{
	return m_screenSize;
}

void Theme::setScreenSize(Victron::VenusOS::Theme::ScreenSize size)
{
	if (m_screenSize != size) {
		setAdjustingGeometry(true);
		m_screenSize = size;

		switch (size) {
		case FiveInch:
			setGeometry_screen_width(800);
			setGeometry_screen_height(480);
			break;
		case SevenInch:
			setGeometry_screen_width(1024);
			setGeometry_screen_height(600);
			break;
		case Portrait:
			setGeometry_screen_width(383);
			setGeometry_screen_height(793);
			break;
		}

		Q_EMIT screenSizeChanged(size);
		Q_EMIT screenSizeChanged_parameterless(); // work around moc limitation.
		setAdjustingGeometry(false);
	}
}

Victron::VenusOS::Theme::ColorScheme Theme::colorScheme() const
{
	return m_colorScheme;
}

void Theme::setColorScheme(Victron::VenusOS::Theme::ColorScheme scheme)
{
	if (m_colorScheme != scheme) {
		m_colorScheme = scheme;
		resolvePalette();
		Q_EMIT colorSchemeChanged(scheme);
		Q_EMIT colorSchemeChanged_parameterless(); // work around moc limitation.
		Q_EMIT themeValuesChanged();
	}
}

Victron::VenusOS::Theme::SystemColorScheme Theme::systemColorScheme() const
{
	return m_systemColorScheme;
}

void Theme::setSystemColorScheme(Victron::VenusOS::Theme::SystemColorScheme systemScheme)
{
	if (m_systemColorScheme != systemScheme) {
		m_systemColorScheme = systemScheme;
		Q_EMIT systemColorSchemeChanged(systemScheme);
		Q_EMIT systemColorSchemeChanged_parameterless(); // work around moc limitation.
	}
}

Victron::VenusOS::Theme::ForcedColorScheme Theme::forcedColorScheme() const
{
	return m_forcedColorScheme;
}

void Theme::setForcedColorScheme(Victron::VenusOS::Theme::ForcedColorScheme forcedScheme)
{
	if (m_forcedColorScheme != forcedScheme) {
		m_forcedColorScheme = forcedScheme;
		Q_EMIT forcedColorSchemeChanged(forcedScheme);

		if (forcedScheme == Victron::VenusOS::Theme::ForcedColorSchemeDark) {
			setColorScheme(Victron::VenusOS::Theme::Dark);
		} else if (forcedScheme == Victron::VenusOS::Theme::ForcedColorSchemeLight) {
			setColorScheme(Victron::VenusOS::Theme::Light);
		} else if (forcedScheme == Victron::VenusOS::Theme::ForcedColorSchemeAuto) {
			// Auto mode: use system color scheme
			setColorScheme(m_systemColorScheme == Victron::VenusOS::Theme::SystemColorSchemeDark
				? Victron::VenusOS::Theme::Dark
				: Victron::VenusOS::Theme::Light);
		}
	}
}

int Theme::geometry_screen_width() const
{
	return m_screenWidth;
}

void Theme::setGeometry_screen_width(int width)
{
	if (m_screenWidth != width) {
		const bool wasAdjusting = adjustingGeometry();
		setAdjustingGeometry(true);
		m_screenWidth = width;
		Q_EMIT geometry_screen_widthChanged();
		setAdjustingGeometry(wasAdjusting);
	}
}

int Theme::geometry_screen_height() const
{
	return m_screenHeight;
}

void Theme::setGeometry_screen_height(int height)
{
	if (m_screenHeight != height) {
		const bool wasAdjusting = adjustingGeometry();
		setAdjustingGeometry(true);
		m_screenHeight = height;
		Q_EMIT geometry_screen_heightChanged();
		setAdjustingGeometry(wasAdjusting);
	}
}

bool Theme::adjustingGeometry() const
{
	return m_adjustingGeometry;
}

void Theme::setAdjustingGeometry(bool adjusting)
{
	if (m_adjustingGeometry != adjusting) {
		m_adjustingGeometry = adjusting;
		Q_EMIT adjustingGeometryChanged();
	}
}

Victron::VenusOS::Theme::StatusLevel Theme::getValueStatus(qreal value, Victron::VenusOS::Enums::Gauges_ValueType valueType) const
{
	if (valueType == Victron::VenusOS::Enums::Gauges_ValueType_RisingPercentage) {
		return value >= 90 ? Critical
			: value >= 80 ? Warning
			: Ok;
	} else if (valueType == Victron::VenusOS::Enums::Gauges_ValueType_FallingPercentage) {
		return value <= 10 ? Critical
			: value <= 20 ? Warning
			: Ok;
	} else {
		return Ok;
	}
}

bool Theme::objectHasQObjectParent(QObject *obj) const
{
	return obj && obj->parent();
}

QString Theme::applicationVersion() const
{
	return QStringLiteral("v%1.%2.%3").arg(PROJECT_VERSION_MAJOR).arg(PROJECT_VERSION_MINOR).arg(PROJECT_VERSION_PATCH);
}

bool Theme::virtualKeyboardOpened() const
{
	return m_virtualKeyboardOpened;
}

int Theme::visualViewportBottom() const
{
	return m_visualViewportBottom;
}

void Theme::updateViewportAndKeyboardProperties()
{
	const int prevViewportBottom = m_visualViewportBottom;
	const bool prevVirtualKeyboardOpened = m_virtualKeyboardOpened;

#if defined(VENUS_WEBASSEMBLY_BUILD)
	// Update the y pos of the bottom of the viewport.
	m_visualViewportBottom = m_visualViewportOffsetTop + m_visualViewportHeight;

	// If the visual viewport is at least 150px shorter than the layout viewport, assume the
	// keyboard is open.
	static const int keyboardMinHeight = 150;
	m_virtualKeyboardOpened = (m_windowHeight - m_visualViewportHeight) > keyboardMinHeight;

#else
	if (QInputMethod *inputMethod = QGuiApplication::inputMethod()) {
		m_virtualKeyboardOpened = inputMethod->isVisible();
		m_visualViewportBottom = inputMethod->keyboardRectangle().y();
	}
#endif

	if (prevViewportBottom != m_visualViewportBottom) {
		Q_EMIT visualViewportBottomChanged();
	}
	if (prevVirtualKeyboardOpened != m_virtualKeyboardOpened) {
		Q_EMIT virtualKeyboardOpenedChanged();
	}
}

void Theme::setVisualViewportOffsetTop(int offsetTop)
{
	if (m_visualViewportOffsetTop != offsetTop) {
		m_visualViewportOffsetTop = offsetTop;
		updateViewportAndKeyboardProperties();
	}
}

void Theme::setVisualViewportHeight(int height)
{
	if (m_visualViewportHeight != height) {
		m_visualViewportHeight = height;
		updateViewportAndKeyboardProperties();
	}
}

void Theme::setWindowHeight(int height)
{
	if (m_windowHeight != height) {
		m_windowHeight = height;
		updateViewportAndKeyboardProperties();
	}
}

QUrl Theme::builtInSplashLogoIcon()
{
	return QUrl(QStringLiteral("qrc:/images/splash-logo-icon.svg"));
}

QUrl Theme::builtInSplashLogoText()
{
	return QUrl(QStringLiteral("qrc:/images/splash-logo-text.svg"));
}

QString Theme::builtInFontFamily()
{
	// Read from the file: Global.qml registers the built-in font only after the branding has loaded.
	static const QString family = QRawFont(QLatin1Char(':') + builtInLanguageFontUrl().path(), 12).familyName();
	return family;
}

QColor Theme::victronBrandingColor(Victron::BrandingData::Color) const
{
	return QColor();
}

void Theme::resolvePalette()
{
}

void Theme::resolveBrandingColors(bool warnAboutContrast)
{
	// The built-in (Victron) branding is the first entry.
	BrandingData victron;
	for (int i = 0; i < BrandingData::ColorCount; ++i) {
		const QColor color = victronBrandingColor(static_cast<BrandingData::Color>(i));
		if (color.isValid()) {
			victron.colors[i] = color;
		}
	}
	victron.lightModeBackgroundFactor = VictronLightModeBackgroundFactorThousandths / 1000.0;
	QList<BrandingData> brandingList { victron };
	brandingList.append(m_pluginBranding);
	m_brandingColors = ColorDerivation::resolveBrandingColors(brandingList);

	if (!warnAboutContrast) {
		return;
	}
	// The built-in branding is not checked: only an OEM's choice of text and background.
	QStringList plugins;
	for (qsizetype index : { m_brandingColors.backgroundPrimarySourceIndex, m_brandingColors.fontPrimarySourceIndex }) {
		if (index > 0 && !plugins.contains(brandingList.at(index).pluginName)) {
			plugins.append(brandingList.at(index).pluginName);
		}
	}
	if (plugins.isEmpty()) {
		return;
	}
	const auto warn = [&plugins](const QString &schemeName, const ColorDerivation::BrandingColors &scheme) {
		const double ratio = ColorDerivation::contrastRatio(scheme[BrandingData::FontPrimary],
				scheme[BrandingData::BackgroundPrimary]);
		if (ratio < ColorDerivation::MinimumPrimaryTextContrast) {
			qCWarning(venusGui).noquote() << QStringLiteral(
					"Branding from plugin %1: color_font_primary on color_background_primary has a contrast ratio "
					"of %2:1 in the %3 color scheme, below %4:1")
					.arg(plugins.join(QStringLiteral(", ")), QString::number(ratio, 'f', 2), schemeName,
						QString::number(ColorDerivation::MinimumPrimaryTextContrast));
		}
	};
	warn(QStringLiteral("Dark"), m_brandingColors.darkScheme);
	warn(QStringLiteral("Light"), m_brandingColors.lightScheme);
}

QList<Victron::BrandingData> Theme::pluginBranding() const
{
	return m_pluginBranding;
}

void Theme::setPluginBranding(const QList<Victron::BrandingData> &pluginBranding)
{
	m_pluginBranding = pluginBranding;
	if (!m_pluginBranding.isEmpty() && !m_languageConnected) {
		m_languageConnected = true;
		connect(Language::create(), &Language::fontFileUrlChanged, this, [this]() {
			const QString family = resolveFontFamily();
			if (family != m_fontFamily) {
				m_fontFamily = family;
				Q_EMIT themeValuesChanged();
			}
		});
	}
	resolveBranding();
	resolveBrandingColors(true);
	resolvePalette();
	Q_EMIT themeValuesChanged();
}

void Theme::resolveBranding()
{
	// When more than one plugin sets a property, the last one is used. (The colors are resolved by
	// resolveBrandingColors().)
	std::optional<QUrl> splashLogoIcon;
	std::optional<QUrl> splashLogoText;
	std::optional<bool> splashLogoIconPreserveColors;
	std::optional<bool> splashLogoTextPreserveColors;
	std::optional<QString> quantityFontFamily;
	for (const BrandingData &data : std::as_const(m_pluginBranding)) {
		if (data.splashLogoIcon.has_value()) {
			splashLogoIcon = data.splashLogoIcon;
		}
		if (data.splashLogoText.has_value()) {
			splashLogoText = data.splashLogoText;
		}
		if (data.splashLogoIconPreserveColors.has_value()) {
			splashLogoIconPreserveColors = data.splashLogoIconPreserveColors;
		}
		if (data.splashLogoTextPreserveColors.has_value()) {
			splashLogoTextPreserveColors = data.splashLogoTextPreserveColors;
		}
		if (data.quantityFontFamily.has_value()) {
			quantityFontFamily = data.quantityFontFamily;
		}
	}

	m_splashLogoIcon = splashLogoIcon.value_or(builtInSplashLogoIcon());
	m_splashLogoText = splashLogoText.value_or(builtInSplashLogoText());
	m_splashLogoIconPreserveColors = splashLogoIconPreserveColors.value_or(false);
	m_splashLogoTextPreserveColors = splashLogoTextPreserveColors.value_or(false);
	m_quantityFontFamily = quantityFontFamily.value_or(QString());
	m_fontFamily = resolveFontFamily();
}

QString Theme::resolveFontFamily()
{
	QString family;
	for (const Victron::BrandingData &data : std::as_const(m_pluginBranding)) {
		if (data.fontFamily.has_value()) {
			family = *data.fontFamily;
		}
	}
	if (family.isEmpty()) {
		return QString();
	}

	// A language that has its own font (e.g. Arabic, Chinese, Japanese, Thai on GX) keeps it.
	const Language *language = Language::create();
	const QUrl languageFontUrl = language->fontFileUrl();
	if (!languageFontUrl.isEmpty() && languageFontUrl != builtInLanguageFontUrl()) {
		return QString();
	}

	const QLocale::Language currentLanguage = language->getCurrentLanguage();
	if (!fontCoversLanguage(family, currentLanguage)) {
		const QString warningKey = family + QLatin1Char('|') + QLocale::languageToCode(currentLanguage);
		if (warningKey != m_lastFontCoverageWarning) {
			m_lastFontCoverageWarning = warningKey;
			qCWarning(venusGui) << "Branding font family" << family << "does not cover language"
					<< QLocale::languageToCode(currentLanguage) << "- using the built-in font";
		}
		return QString();
	}
	return family;
}

QString Theme::font_family() const
{
	return m_fontFamily;
}

QString Theme::quantity_font_family() const
{
	return m_quantityFontFamily;
}

QUrl Theme::splash_logo_icon() const
{
	return m_splashLogoIcon;
}

QUrl Theme::splash_logo_text() const
{
	return m_splashLogoText;
}

bool Theme::splash_logo_icon_preserve_colors() const
{
	return m_splashLogoIconPreserveColors;
}

bool Theme::splash_logo_text_preserve_colors() const
{
	return m_splashLogoTextPreserveColors;
}

#if defined(VENUS_WEBASSEMBLY_BUILD)

// Called from JavaScript when theme changes
void jsSystemColorSchemeChanged(emscripten::val event)
{
	if (!g_themeInstance)
		return;

	const bool systemSchemeDark = event["matches"].as<bool>();
	g_themeInstance->setSystemColorScheme(systemSchemeDark ? Victron::VenusOS::Theme::SystemColorSchemeDark : Victron::VenusOS::Theme::SystemColorSchemeLight);
}

void jsSetWindowInnerHeight(int height)
{
	if (g_themeInstance)
		g_themeInstance->setWindowHeight(height);
}

void jsSetVisualViewportHeight(int height)
{
	if (g_themeInstance)
		g_themeInstance->setVisualViewportHeight(height);
}

void jsSetVisualViewportOffsetTop(int offsetTop)
{
	if (g_themeInstance)
		g_themeInstance->setVisualViewportOffsetTop(offsetTop);
}

// Bind C++ functions to JS — callable as Module.jsSetKeyboardHeight(h) etc.
EMSCRIPTEN_BINDINGS(theme_bindings) {
	using namespace emscripten;
	function("jsSystemColorSchemeChanged", &jsSystemColorSchemeChanged);
	function("jsSetWindowInnerHeight", &jsSetWindowInnerHeight);
	function("jsSetVisualViewportHeight", &jsSetVisualViewportHeight);
	function("jsSetVisualViewportOffsetTop", &jsSetVisualViewportOffsetTop);
}
#endif
