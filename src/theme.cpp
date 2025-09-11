/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "theme.h"

using namespace Victron::VenusOS;

// Global pointer to current theme instance
static Victron::VenusOS::Theme *g_themeInstance = nullptr;

#if defined(VENUS_WEBASSEMBLY_BUILD)
#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>

EM_JS(int, getScreenWidth, (), {
	return Math.min(screen.width, screen.height);
});

#endif

Theme::Theme(QObject *parent) : QObject(parent)
{
#if defined(VENUS_WEBASSEMBLY_BUILD)
	// 5"-6" Smartphones have 320 - 480 CSS independent pixel wide screens.
	setScreenSize(getScreenWidth() >= 480
		? Victron::VenusOS::Theme::SevenInch
		: Victron::VenusOS::Theme::FiveInch);

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
	const QSizeF physicalScreenSize = QGuiApplication::primaryScreen()->physicalSize();
	const int screenDiagonalMm = static_cast<int>(sqrt((physicalScreenSize.width() * physicalScreenSize.width())
		+ (physicalScreenSize.height() * physicalScreenSize.height())));
	setScreenSize((round(screenDiagonalMm / 10 / 2.5) == 7)
		? Victron::VenusOS::Theme::SevenInch
		: Victron::VenusOS::Theme::FiveInch);
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
		m_screenSize = size;
		Q_EMIT screenSizeChanged(size);
		Q_EMIT screenSizeChanged_parameterless(); // work around moc limitation.
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
		Q_EMIT colorSchemeChanged(scheme);
		Q_EMIT colorSchemeChanged_parameterless(); // work around moc limitation.
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

qreal Theme::requiredRotation() const
{
	return m_requiredRotation;
}

void Theme::setRequiredRotation(qreal rotation)
{
	if (!qFuzzyCompare(m_requiredRotation, rotation)) {
		m_requiredRotation = rotation;
		emit requiredRotationChanged();
	}
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

// Bind C++ function to JS
EMSCRIPTEN_BINDINGS(theme_bindings) {
	function("jsSystemColorSchemeChanged", &jsSystemColorSchemeChanged);
}
#endif
