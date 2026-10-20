/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.Branding

TestCase {
	id: root

	name: "BrandingTest"

	readonly property var brandingColorThemeKeys: [
		"color_brand", "color_success", "color_warning", "color_critical",
		"color_background_primary", "color_background_secondary", "color_page_background",
		"color_font_primary", "color_font_secondary"
	]
	// Victron's branding colors (the built-in branding), and the Light scheme colors computed from them.
	readonly property var victronDark: ({
		color_brand: "#387dc5", color_success: "#72b84c", color_warning: "#f0962e", color_critical: "#f35c58",
		color_background_primary: "#000000", color_background_secondary: "#141414", color_page_background: "#000000",
		color_font_primary: "#ffffff", color_font_secondary: "#969591"
	})
	readonly property var victronLight: ({
		color_brand: "#387dc5", color_success: "#72b84c", color_warning: "#f0962e", color_critical: "#f35c58",
		color_background_primary: "#ffffff", color_background_secondary: "#f7f7f7", color_page_background: "#e5e5e5",
		color_font_primary: "#262626", color_font_secondary: "#807f7c"
	})
	property var builtInDark
	property var builtInLight
	// The checks only resolve URLs against this URL, so no file needs to exist there.
	readonly property string pluginBrandingFileUrl: "qrc:/TestPlugin/Branding.qml"

	function themeBrandingColors() {
		let result = {}
		for (const name of brandingColorThemeKeys) {
			result[name] = Theme[name].toString()
		}
		return result
	}

	function initTestCase() {
		BrandingTestHelper.setThemeBranding([])
		Theme.colorScheme = Theme.Light
		builtInLight = themeBrandingColors()
		Theme.colorScheme = Theme.Dark
		builtInDark = themeBrandingColors()
	}

	function init() {
		BrandingTestHelper.setThemeBranding([])
		Theme.colorScheme = Theme.Dark
		themeValuesSpy.clear()
	}

	function cleanupTestCase() {
		BrandingTestHelper.setThemeBranding([])
		Theme.colorScheme = Theme.Dark
	}

	SignalSpy {
		id: themeValuesSpy
		target: Theme
		signalName: "themeValuesChanged"
	}

	QtObject {
		id: boundToTheme
		property color brand: Theme.color_brand
		property color ok: Theme.color_ok
		property url splashLogoIcon: Theme.splash_logo_icon
	}

	function test_snapshotHasOnlySetProperties() {
		const branding = Qt.createQmlObject(
			'import Victron.Branding; Branding { color_brand: "#003366"; splash_logo_icon_preserve_colors: false }',
			root)
		const data = BrandingTestHelper.snapshot(branding)
		branding.destroy()
		compare(Object.keys(data).sort(), ["color_brand", "splash_logo_icon_preserve_colors"])
		compare(data.color_brand.toString(), "#003366")
		compare(data.splash_logo_icon_preserve_colors, false)
	}

	function test_brandingCannotHoldChildObjects() {
		let failed = false
		try {
			Qt.createQmlObject('import QtQml; import Victron.Branding; Branding { QtObject {} }', root)
		} catch (e) {
			failed = true
		}
		verify(failed)
	}

	function test_noBrandingUsesVictronColors() {
		compare(themeBrandingColors(), victronDark)
		compare(BrandingTestHelper.resolvedBrandingColors().lightModeBackgroundFactorThousandths, 1120)
		compare(Theme.font_family, "")
		compare(Theme.quantity_font_family, "")
		compare(Theme.splash_logo_icon.toString(), "qrc:/images/splash-logo-icon.svg")
		compare(Theme.splash_logo_text.toString(), "qrc:/images/splash-logo-text.svg")
		verify(!Theme.splash_logo_icon_preserve_colors)
		verify(!Theme.splash_logo_text_preserve_colors)
		Theme.colorScheme = Theme.Light
		compare(themeBrandingColors(), victronLight)
	}

	function test_lastWriterWins() {
		BrandingTestHelper.setThemeBranding([
			{ pluginName: "A", color_brand: "#111111", color_critical: "#222222", splash_logo_text: "file:///a/text.svg" },
			{ pluginName: "B", color_brand: "#333333", splash_logo_icon: "file:///b/icon.svg", splash_logo_icon_preserve_colors: true },
		])
		compare(themeValuesSpy.count, 1)
		compare(Theme.color_brand.toString(), "#333333")
		compare(Theme.color_critical.toString(), "#222222")
		compare(Theme.color_warning.toString(), builtInDark.color_warning)
		compare(Theme.splash_logo_icon.toString(), "file:///b/icon.svg")
		verify(Theme.splash_logo_icon_preserve_colors)
		compare(Theme.splash_logo_text.toString(), "file:///a/text.svg")
		verify(!Theme.splash_logo_text_preserve_colors)
		compare(boundToTheme.brand.toString(), "#333333")
		compare(boundToTheme.splashLogoIcon.toString(), "file:///b/icon.svg")

		BrandingTestHelper.setThemeBranding([])
		compare(themeValuesSpy.count, 2)
		compare(themeBrandingColors(), builtInDark)
		compare(boundToTheme.brand.toString(), builtInDark.color_brand)
		compare(Theme.splash_logo_icon.toString(), "qrc:/images/splash-logo-icon.svg")
	}

	// The background colors of the Branding whose color_background_primary is used, or of a later
	// one, and that Branding's light_mode_background_factor. Each list is background_primary,
	// background_secondary, page background, font_primary and font_secondary.
	function test_backgroundColors_data() {
		const victronDarkScheme = ["#000000", "#141414", "#000000", "#ffffff", "#969591"]
		const victronLightScheme = ["#ffffff", "#f7f7f7", "#e5e5e5", "#262626", "#807f7c"]
		const grayDarkScheme = ["#1a1a1a", "#2c2c2c", "#1a1a1a", "#ffffff", "#969591"]
		const grayLightScheme = ["#e5e5e5", "#d3d3d3", "#cecece", "#222222", "#737370"]
		return [
			{
				tag: "color_brand only",
				pluginBranding: [{ pluginName: "A", color_brand: "#f28c28" }],
				darkScheme: victronDarkScheme, lightScheme: victronLightScheme, factorThousandths: 1120
			},
			{
				// Matching Victron's background_primary does not restore Victron's secondary or factor.
				tag: "Victron black without a factor",
				pluginBranding: [{ pluginName: "A", color_background_primary: "#000000" }],
				darkScheme: victronDarkScheme,
				lightScheme: ["#ffffff", "#ebebeb", "#e5e5e5", "#262626", "#807f7c"],
				factorThousandths: 1000
			},
			{
				tag: "background_primary only",
				pluginBranding: [{ pluginName: "A", color_background_primary: "#1a1a1a" }],
				darkScheme: grayDarkScheme, lightScheme: grayLightScheme, factorThousandths: 1000
			},
			{
				tag: "later background_secondary",
				pluginBranding: [
					{ pluginName: "A", color_background_primary: "#1a1a1a" },
					{ pluginName: "B", color_background_secondary: "#333333" },
				],
				darkScheme: ["#1a1a1a", "#333333", "#1a1a1a", "#ffffff", "#969591"],
				lightScheme: ["#e5e5e5", "#cccccc", "#cecece", "#222222", "#6d6d6a"], factorThousandths: 1000
			},
			{
				tag: "earlier background_secondary and page",
				pluginBranding: [
					{ pluginName: "A", color_background_secondary: "#333333", color_background_page: "#101010" },
					{ pluginName: "B", color_background_primary: "#1a1a1a" },
				],
				darkScheme: grayDarkScheme, lightScheme: grayLightScheme, factorThousandths: 1000
			},
			{
				tag: "factor 0.45",
				pluginBranding: [
					{ pluginName: "A", color_background_primary: "#1a1a1a", light_mode_background_factor: 0.45 },
				],
				darkScheme: grayDarkScheme,
				lightScheme: ["#adadad", "#a5a5a5", "#9b9b9b", "#1a1a1a", "#4c4b4a"],
				factorThousandths: 450
			},
			{
				// The green channel of font_secondary is exactly 61.5: integer mixing rounds it up.
				tag: "factor 0.3",
				pluginBranding: [
					{ pluginName: "A", color_background_primary: "#1a1a1a", light_mode_background_factor: 0.3 },
				],
				darkScheme: grayDarkScheme,
				lightScheme: ["#9e9e9e", "#999999", "#8e8e8e", "#181818", "#3e3e3c"],
				factorThousandths: 300
			},
			{
				tag: "factor before the background_primary that is used",
				pluginBranding: [
					{ pluginName: "A", color_background_primary: "#1a1a1a", light_mode_background_factor: 0.45 },
					{ pluginName: "B", color_background_primary: "#1a1a1a" },
				],
				darkScheme: grayDarkScheme, lightScheme: grayLightScheme, factorThousandths: 1000
			},
			{
				tag: "factor without background_primary",
				pluginBranding: [
					{ pluginName: "A", color_background_primary: "#1a1a1a" },
					{ pluginName: "B", light_mode_background_factor: 0.45 },
				],
				darkScheme: grayDarkScheme, lightScheme: grayLightScheme, factorThousandths: 1000
			},
			{
				tag: "factor only",
				pluginBranding: [{ pluginName: "A", light_mode_background_factor: 0.45 }],
				darkScheme: victronDarkScheme, lightScheme: victronLightScheme, factorThousandths: 1120
			},
		]
	}

	function test_backgroundColors(data) {
		const names = [
			"color_background_primary", "color_background_secondary", "color_page_background",
			"color_font_primary", "color_font_secondary"
		]
		BrandingTestHelper.setThemeBranding(data.pluginBranding)
		compare(BrandingTestHelper.resolvedBrandingColors().lightModeBackgroundFactorThousandths,
			data.factorThousandths)
		compare(names.map(name => Theme[name].toString()), data.darkScheme)
		Theme.colorScheme = Theme.Light
		compare(names.map(name => Theme[name].toString()), data.lightScheme)
	}

	// The Branding colors are the Dark scheme's, however light they are: a light background_primary
	// gives a dark Light scheme.
	function test_lightBackgroundIsForDarkScheme() {
		ignoreWarning("Branding from plugin Pale: color_font_primary on color_background_primary has a contrast ratio of 1.32:1 in the Dark color scheme, below 4.5:1")
		ignoreWarning("Branding from plugin Pale: color_font_primary on color_background_primary has a contrast ratio of 1.24:1 in the Light color scheme, below 4.5:1")
		BrandingTestHelper.setThemeBranding([{ pluginName: "Pale", color_background_primary: "#e0e0e0" }])
		compare(Theme.color_background_primary.toString(), "#e0e0e0")
		Theme.colorScheme = Theme.Light
		compare(Theme.color_background_primary.toString(), "#1f1f1f")
	}

	// font_primary is inverted for Light. font_secondary is not: each scheme moves it toward its
	// font_primary, in 5% steps, until it is readable.
	function test_fontColors() {
		BrandingTestHelper.setThemeBranding([{ color_font_primary: "#eeeeee", color_font_secondary: "#222222" }])
		compare(Theme.color_font_primary.toString(), "#eeeeee")
		compare(Theme.color_font_secondary.toString(), "#696969")

		Theme.colorScheme = Theme.Light
		compare(Theme.color_font_primary.toString(), "#353535")
		compare(Theme.color_font_secondary.toString(), "#222222")
	}

	function test_secondaryTextIsReadable() {
		compare(Theme.color_font_secondary.toString(), "#969591")
		Theme.colorScheme = Theme.Light
		compare(Theme.color_font_secondary.toString(), "#807f7c")
		for (const background of [Theme.color_page_background, Theme.color_background_secondary]) {
			verify(BrandingTestHelper.contrastRatio(Theme.color_font_secondary.toString(), background.toString()) >= 3.0)
		}
	}

	// The dim and dark colors are the color blended onto background_primary, and are opaque.
	function test_dimAndDarkColors() {
		compare(BrandingTestHelper.blendOnto("#387dc5", 0x4d, "#000000"), "#11263b")
		compare(BrandingTestHelper.blendOnto("#387dc5", 0xb3, "#000000"), "#27588a")
		compare(Theme.color_darkBlue.toString(), "#11263b")
		compare(Theme.color_dimBlue.toString(), "#27588a")
		// Not the old hand-picked #592220: the formula gives a lighter red.
		compare(Theme.color_dimCritical.toString(), "#ab413e")
		compare(Theme.color_darkBlue.a, 1)
		compare(Theme.color_critical_background.a, 1)
		// The translucent exceptions.
		verify(Theme.color_dimWhite2.a < 1)
		verify(Theme.color_darkGray2.a < 1)

		Theme.colorScheme = Theme.Light
		compare(Theme.color_button_down.toString(), "#73a4d6")
		compare(Theme.color_darkBlue.a, 1)
	}

	// The dim and dark colors are recomputed on an OEM background, even with the Victron brand color.
	function test_dimAndDarkColorsFollowTheBackground() {
		BrandingTestHelper.setThemeBranding([{ pluginName: "A", color_background_primary: "#1a1a1a" }])
		compare(Theme.color_darkOk.toString(), "#23384e")
		Theme.colorScheme = Theme.Light
		compare(Theme.color_darkOk.toString(), "#b1c6db")
	}

	function test_brandColorChangesOnlyColorsThatUseIt() {
		const before = {
			success: Theme.color_success.toString(),
			warning: Theme.color_warning.toString(),
			critical: Theme.color_critical.toString(),
			blue: Theme.color_blue.toString(),
			page: Theme.color_page_background.toString(),
		}
		BrandingTestHelper.setThemeBranding([{ color_brand: "#003366" }])
		compare(Theme.color_button.toString(), "#003366")
		compare(Theme.color_ok.toString(), "#003366")
		compare(Theme.color_navigationBar_button_on.toString(), "#003366")
		compare(Theme.color_darkOk.toString(), "#000f1f")
		compare({
			success: Theme.color_success.toString(),
			warning: Theme.color_warning.toString(),
			critical: Theme.color_critical.toString(),
			blue: Theme.color_blue.toString(),
			page: Theme.color_page_background.toString(),
		}, before)
	}

	// Text on a colored fill is white if white reaches 3.0:1 on it, else the darker font_primary.
	function test_textColorOnFills() {
		compare(Theme.color_button_down_text.toString(), "#ffffff")
		compare(Theme.color_solarHistoryErrorView_primaryText.toString(), "#ffffff")
		Theme.colorScheme = Theme.Light
		// Only the brand color is checked, not the lighter background of the pressed button.
		compare(Theme.color_button_down_text.toString(), "#ffffff")
		compare(Theme.color_demoModeIndicator_foreground.toString(), "#262626")

		BrandingTestHelper.setThemeBranding([{ color_brand: "#72b84c" }])
		compare(Theme.color_button_down_text.toString(), "#262626")
		Theme.colorScheme = Theme.Dark
		compare(Theme.color_button_down_text.toString(), "#262626")
	}

	function test_lightModeBackgroundColor_data() {
		return [
			{ tag: "factor 1.12 #000000", color: "#000000", factor: 1120, expected: "#ffffff" },
			{ tag: "factor 1.12 #050505", color: "#050505", factor: 1120, expected: "#fefefe" },
			{ tag: "factor 1.12 #0a0a0a", color: "#0a0a0a", factor: 1120, expected: "#fdfdfd" },
			{ tag: "factor 1.12 #0f0f0f", color: "#0f0f0f", factor: 1120, expected: "#fafafa" },
			{ tag: "factor 1.12 #141414", color: "#141414", factor: 1120, expected: "#f7f7f7" },
			{ tag: "factor 1.12 #1e1e1e", color: "#1e1e1e", factor: 1120, expected: "#ededed" },
			{ tag: "factor 1 #141414", color: "#141414", factor: 1000, expected: "#ebebeb" },
			{ tag: "factor 1 #e0e0e0", color: "#e0e0e0", factor: 1000, expected: "#1f1f1f" },
			// Exactly 113.5 per channel: the double operations, in this order, give 113.
			{ tag: "factor 1.12 tie", color: "#8c8c8c", factor: 1120, expected: "#717171" },
		]
	}

	function test_lightModeBackgroundColor(data) {
		compare(BrandingTestHelper.lightModeBackgroundColor(data.color, data.factor), data.expected)
	}

	function test_lightModeBackgroundColorOfGrays() {
		const gray = value => "#" + value.toString(16).padStart(2, "0").repeat(3)
		// Up to a factor of 1, the result is exactly 0.5 + factor * (0.5 - lightness).
		for (const factorThousandths of [1, 300, 450, 999, 1000]) {
			const factor = factorThousandths / 1000
			for (let value = 0; value < 256; ++value) {
				const expected = Math.max(0, Math.min(255,
					Math.floor((0.5 + factor * (0.5 - value / 255)) * 255 + 0.5)))
				compare(BrandingTestHelper.lightModeBackgroundColor(gray(value), factorThousandths), gray(expected),
					"factor " + factor + " " + gray(value))
			}
		}
		// Above it, the softening near black and white keeps black white, and never reverses the order.
		for (const factorThousandths of [1001, 1120, 1500, 2000]) {
			compare(BrandingTestHelper.lightModeBackgroundColor("#000000", factorThousandths), "#ffffff")
			compare(BrandingTestHelper.lightModeBackgroundColor("#ffffff", factorThousandths), "#000000")
			let previous = 256
			for (let value = 0; value < 256; ++value) {
				const result = parseInt(
					BrandingTestHelper.lightModeBackgroundColor(gray(value), factorThousandths).substring(1, 3), 16)
				verify(result <= previous, "factor " + factorThousandths / 1000 + " " + gray(value))
				previous = result
			}
		}
	}

	// A color that aliases a branding color follows it, also through another alias. A palette color
	// (such as color_blue) does not.
	function test_aliasesFollowTheirBrandingColor() {
		const blue = Theme.color_blue.toString()
		BrandingTestHelper.setThemeBranding([{ color_brand: "#003366", color_success: "#00ff00", color_warning: "#ff00ff" }])
		compare(Theme.color_ok.toString(), "#003366")
		compare(Theme.color_settings_breadcrumb_background_top_page.toString(), "#003366")
		compare(boundToTheme.ok.toString(), "#003366")
		compare(Theme.color_blue.toString(), blue)
		compare(Theme.color_focus_highlight.toString(), "#00ff00")

		Theme.colorScheme = Theme.Light
		compare(Theme.color_ok.toString(), "#003366")
		compare(Theme.color_focus_highlight.toString(), "#ff00ff")
	}

	function test_fontFamilies() {
		verify(BrandingTestHelper.setBuiltInFontRegistered(true))
		BrandingTestHelper.setThemeBranding([{ font_family: "Roboto", quantity_font_family: "Roboto" }])
		compare(Theme.font_family, "Roboto")
		compare(Theme.quantity_font_family, "Roboto")
	}

	function test_fontFamilyThatDoesNotCoverTheLanguageIsNotUsed() {
		ignoreWarning(/Branding font family "NoSuchBrandingFamily" does not cover language/)
		BrandingTestHelper.setThemeBranding([{ font_family: "NoSuchBrandingFamily" }])
		compare(Theme.font_family, "")
	}

	function test_snapshotFromFile() {
		const result = BrandingTestHelper.loadBrandingFile("valid")
		verify(result.valid)
		compare(result.pluginName, "TestPlugin")
		compare(Object.keys(result.data).sort(), ["color_brand", "splash_logo_icon"])
		compare(result.data.color_brand.toString(), "#003366")
		compare(result.data.splash_logo_icon, "qrc:/branding-test/valid/images/icon.svg")
	}

	// The app loads branding plugins before any QML file has imported QtQuick, and the colors
	// in the Branding file must still be read then.
	function test_snapshotBeforeQtQuickImported() {
		const result = BrandingTestHelper.brandingLoadedBeforeQtQuick()
		verify(result.valid)
		compare(Object.keys(result.data).sort(), ["color_brand", "splash_logo_icon"])
		compare(result.data.color_brand.toString(), "#003366")
	}

	Image {
		id: exampleLogo
		sourceSize: Qt.size(285, 54)
	}

	// examples/BrandingExample loads without warnings, and gives the colors that its README describes.
	function test_brandingExample() {
		failOnWarning(/./)
		const result = BrandingTestHelper.loadBrandingFile("BrandingExample")
		verify(result.valid)
		BrandingTestHelper.setThemeBranding([Object.assign({ pluginName: result.pluginName }, result.data)])

		// Theme color: [Dark, Light]
		const expected = {
			color_background_primary: ["#1a1a1a", "#adadad"],
			color_background_secondary: ["#2c2c2c", "#a5a5a5"],
			color_page_background: ["#1a1a1a", "#9b9b9b"],
			color_font_primary: ["#ffffff", "#1a1a1a"],
			color_font_secondary: ["#969591", "#4c4b4a"],
			color_brand: ["#f28c28", "#f28c28"],
			color_button_off_background: ["#b26a24", "#dd9650"],  // dim(color_brand)
			color_darkOk: ["#5b3c1e", "#c2a385"],  // dark(color_brand)
			color_button_down_text: ["#1a1a1a", "#1a1a1a"],  // the label on a brand fill
			color_warning: ["#f2c200", "#f2c200"],
			color_success: ["#72b84c", "#72b84c"],
			color_critical: ["#f35c58", "#f35c58"],
		}
		const names = Object.keys(expected)
		compare(names.map(name => Theme[name].toString()), names.map(name => expected[name][0]))
		Theme.colorScheme = Theme.Light
		compare(names.map(name => Theme[name].toString()), names.map(name => expected[name][1]))
		// The label on a warning fill.
		compare(Theme.color_demoModeIndicator_foreground.toString(), "#1a1a1a")

		verify(Theme.splash_logo_icon_preserve_colors)
		verify(!Theme.splash_logo_text_preserve_colors)
		for (const logo of [Theme.splash_logo_icon, Theme.splash_logo_text]) {
			exampleLogo.source = logo
			tryCompare(exampleLogo, "status", Image.Ready)
		}
		compare(exampleLogo.source.toString(), "qrc:/branding-test/BrandingExample/wordmark.svg")
	}

	// examples/BrandingMinimalExample changes the brand color and nothing else.
	function test_brandingMinimalExample() {
		failOnWarning(/./)
		const result = BrandingTestHelper.loadBrandingFile("BrandingMinimalExample")
		verify(result.valid)
		compare(Object.keys(result.data), ["color_brand"])
		BrandingTestHelper.setThemeBranding([Object.assign({ pluginName: result.pluginName }, result.data)])
		compare(themeBrandingColors(), Object.assign({}, builtInDark, { color_brand: "#f28c28" }))
		Theme.colorScheme = Theme.Light
		compare(themeBrandingColors(), Object.assign({}, builtInLight, { color_brand: "#f28c28" }))
	}

	function test_disallowedImportWarns() {
		ignoreWarning(/imports Victron\.VenusOS - only Victron\.Branding, QtQml and QtQuick are supported/)
		const result = BrandingTestHelper.loadBrandingFile("import")
		verify(result.valid)
	}

	function test_invalidBrandingFile_data() {
		return [
			{ tag: "child object", warning: /Cannot load branding for plugin TestPlugin : / },
			{ tag: "not a Branding", warning: /does not declare a Branding object/ },
			{ tag: "syntax error", warning: /Cannot load branding for plugin TestPlugin : / },
		]
	}

	function test_invalidBrandingFile(data) {
		ignoreWarning(data.warning)
		const result = BrandingTestHelper.loadBrandingFile(data.tag.replace(/ /g, "_"))
		verify(!result.valid)
	}

	function test_requiredBrandingVersion_data() {
		const parts = BrandingTestHelper.brandingModuleVersion().split(".").map(Number)
		const major = parts[0]
		const minor = parts[1]
		return [
			{ tag: "missing", plugin: {}, problem: "" },
			{ tag: "this version", plugin: { requiredBrandingVersion: major + "." + minor }, problem: "" },
			{ tag: "first minor", plugin: { requiredBrandingVersion: major + ".0" }, problem: "" },
			{ tag: "newer minor", plugin: { requiredBrandingVersion: major + "." + (minor + 1) },
				problem: "it needs Victron.Branding " + major + "." + (minor + 1) + ", but this GUI only has " + major + "." + minor },
			{ tag: "newer major", plugin: { requiredBrandingVersion: (major + 1) + ".0" },
				problem: "it needs Victron.Branding " + (major + 1) + ".0, but this GUI has " + major + "." + minor },
			{ tag: "older major", plugin: { requiredBrandingVersion: (major - 1) + ".0" },
				problem: "it needs Victron.Branding " + (major - 1) + ".0, but this GUI has " + major + "." + minor },
			{ tag: "no minor", plugin: { requiredBrandingVersion: "" + major }, problem: "requiredBrandingVersion is not a \"major.minor\" string" },
			{ tag: "patch number", plugin: { requiredBrandingVersion: major + ".0.0" }, problem: "requiredBrandingVersion is not a \"major.minor\" string" },
			{ tag: "spaces", plugin: { requiredBrandingVersion: " " + major + ".0" }, problem: "requiredBrandingVersion is not a \"major.minor\" string" },
			{ tag: "number", plugin: { requiredBrandingVersion: major }, problem: "requiredBrandingVersion is not a \"major.minor\" string" },
			{ tag: "null", plugin: { requiredBrandingVersion: null }, problem: "requiredBrandingVersion is not a \"major.minor\" string" },
		]
	}

	function test_requiredBrandingVersion(data) {
		compare(BrandingTestHelper.checkRequiredBrandingVersion(JSON.stringify(data.plugin)), data.problem)
	}

	function test_unsupportedBrandingVersionDropsOnlyTheBrandingIntegration() {
		// GuiPluginLoader.PluginSettingsPage and GuiPluginLoader.Branding. The enum values are not
		// used directly, as that would create the GuiPluginLoader singleton.
		const settingsPageType = 1
		const brandingType = 6
		const major = Number(BrandingTestHelper.brandingModuleVersion().split(".")[0])
		const plugin = {
			integrations: [
				{ type: settingsPageType, url: "qrc:/TestPlugin/SettingsPage.qml" },
				{ type: brandingType, url: "qrc:/TestPlugin/Branding.qml" },
			]
		}
		compare(BrandingTestHelper.integrationTypes(JSON.stringify(plugin)), [settingsPageType, brandingType])

		plugin.requiredBrandingVersion = (major + 1) + ".0"
		ignoreWarning(/^Ignoring the branding integration in plugin TestPlugin - it needs Victron\.Branding /)
		compare(BrandingTestHelper.integrationTypes(JSON.stringify(plugin)), [settingsPageType])
	}

	function test_colorThatIsNotOpaqueIsIgnored() {
		ignoreWarning(/Ignoring branding color "color_success" in plugin "TestPlugin" : it must be opaque/)
		const result = BrandingTestHelper.checkAndResolveBrandingSnapshot(
			{ color_brand: "#003366", color_success: "#80ff0000" }, pluginBrandingFileUrl)
		compare(Object.keys(result.data), ["color_brand"])
	}

	function test_backgroundFactorRangeAndRounding_data() {
		return [
			{ tag: "rounded", value: 1.1204, expected: 1.12 },
			{ tag: "smallest", value: 0.0006, expected: 0.001 },
			{ tag: "largest", value: 2, expected: 2 },
			{ tag: "zero", value: 0 },
			{ tag: "rounds to zero", value: 0.0004 },
			{ tag: "negative", value: -1 },
			{ tag: "too large", value: 2.0001 },
		]
	}

	function test_backgroundFactorRangeAndRounding(data) {
		if (data.expected === undefined) {
			ignoreWarning(/Ignoring branding light_mode_background_factor .* in plugin "TestPlugin" : it must be more than 0 and at most 2/)
		}
		const result = BrandingTestHelper.checkAndResolveBrandingSnapshot(
			{ light_mode_background_factor: data.value }, pluginBrandingFileUrl)
		compare(result.data.light_mode_background_factor, data.expected)
	}

	function test_logoUrlsAreResolvedAgainstTheBrandingFile() {
		const result = BrandingTestHelper.checkAndResolveBrandingSnapshot(
			{ splash_logo_icon: "images/icon.svg", splash_logo_text: "qrc:/other/text.svg" }, pluginBrandingFileUrl)
		compare(result.data.splash_logo_icon, "qrc:/TestPlugin/images/icon.svg")
		compare(result.data.splash_logo_text, "qrc:/other/text.svg")
	}

	function test_fontFilesAreResolvedAndRegistered() {
		ignoreWarning(/Cannot register branding font QUrl\("qrc:\/fonts\/Missing\.ttf"\) in plugin "TestPlugin"/)
		// The built-in font is in the test executable's resources, next to this Branding file URL.
		const result = BrandingTestHelper.checkAndResolveBrandingSnapshot(
			{ font_files: ["Roboto-Regular.ttf", "Missing.ttf"] }, "qrc:/fonts/Branding.qml")
		compare(result.fontCount, 1)
		compare(result.data.font_files, ["qrc:/fonts/Roboto-Regular.ttf"])
	}

	function test_fontFamilyThatIsNotInstalledIsIgnored() {
		verify(BrandingTestHelper.setBrandFontRegistered(true))
		ignoreWarning(/Ignoring branding font family "NoSuchQuantityFamily" in plugin "TestPlugin" : no such font/)
		const result = BrandingTestHelper.checkAndResolveBrandingSnapshot(
			{ font_family: "BrandF", quantity_font_family: "NoSuchQuantityFamily" }, pluginBrandingFileUrl)
		verify(BrandingTestHelper.setBrandFontRegistered(false))
		compare(Object.keys(result.data), ["font_family"])
		compare(result.data.font_family, "BrandF")
	}

	// The loader takes the snapshot before Global.qml registers the built-in font, so the result
	// must not depend on whether it is registered.
	function test_builtInFontFamilyIsUnset_data() {
		return [
			{ tag: "registered", registered: true },
			{ tag: "not registered", registered: false },
		]
	}

	function test_builtInFontFamilyIsUnset(data) {
		verify(BrandingTestHelper.setBuiltInFontRegistered(data.registered))
		failOnWarning(/no such font/)
		const result = BrandingTestHelper.checkAndResolveBrandingSnapshot(
			{ font_family: "Roboto", quantity_font_family: "roboto" }, pluginBrandingFileUrl)
		compare(Object.keys(result.data), [])
	}

	// The focus ring art is #72b84c. Tinting it with its own color keeps its transparency, and
	// changes the color of anti-aliased edge pixels by at most 1, from rounding. The larger size is
	// the art at a device pixel ratio of 1.5.
	function test_tintedImageWithItsOwnColor_data() {
		return [
			{ tag: "1x", width: 144, height: 65 },
			{ tag: "1.5x", width: 216, height: 98 },
		]
	}

	function test_tintedImageWithItsOwnColor(data) {
		const result = BrandingTestHelper.compareTintedImage("#72b84c", "images/key_navigation_highlight.svg",
				data.width, data.height)
		verify(result.valid)
		verify(result.visiblePixels > 0)
		compare(result.alphaDifferences, 0)
		verify(result.maxDifferenceFromOriginal <= 1, "max difference: " + result.maxDifferenceFromOriginal)
	}

	// Tinting keeps each pixel's transparency, and paints it in the tint color.
	function test_tintedImageWithAnotherColorKeepsTransparency() {
		const result = BrandingTestHelper.compareTintedImage("#f0962e", "images/key_navigation_highlight.svg",
				144, 65)
		verify(result.valid)
		verify(result.visiblePixels > 0)
		compare(result.alphaDifferences, 0)
		verify(result.maxDifferenceFromTint <= 1, "max difference: " + result.maxDifferenceFromTint)
	}

	function test_tintedImageSize_data() {
		return [
			{ tag: "not set", width: 0, height: 0, expectedWidth: 144, expectedHeight: 65 },
			{ tag: "width and height", width: 100, height: 100, expectedWidth: 100, expectedHeight: 100 },
			{ tag: "width only", width: 288, height: 0, expectedWidth: 288, expectedHeight: 130 },
			{ tag: "height only", width: 0, height: 130, expectedWidth: 288, expectedHeight: 130 },
		]
	}

	function test_tintedImageSize(data) {
		const result = BrandingTestHelper.tintedImage("72b84c/images/key_navigation_highlight.svg",
				data.width, data.height)
		verify(result.valid)
		compare(result.width, data.expectedWidth)
		compare(result.height, data.expectedHeight)
		compare(result.originalWidth, 144)
		compare(result.originalHeight, 65)
	}

	function test_tintedImageWithBadUrl_data() {
		return [
			{ tag: "no color", id: "images/key_navigation_highlight.svg", warning: /Tinted image: expected/ },
			{ tag: "not a color", id: "zzzzzz/images/key_navigation_highlight.svg", warning: /Tinted image: expected/ },
			{ tag: "no path", id: "72b84c/", warning: /Tinted image: expected/ },
			{ tag: "missing file", id: "72b84c/images/no_such_image.svg", warning: /Tinted image: cannot read/ },
		]
	}

	function test_tintedImageWithBadUrl(data) {
		ignoreWarning(data.warning)
		verify(!BrandingTestHelper.tintedImage(data.id, 0, 0).valid)
	}
}
