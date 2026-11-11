/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.Branding
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginPaletteTest"

	VictronBranding {
		id: victronBranding
	}

	function initTestCase() {
		Theme.addBranding(victronBranding)
	}

	function cleanupTestCase() {
		Theme.colorScheme = Theme.Dark
	}

	// A PluginPalette color uses the branding name. When that differs from the Theme name, add it
	// here, as "pluginPaletteName": "themeName".
	readonly property var renamedColors: ({
		"color_background_page": "color_page_background"
	})

	readonly property var colorNames: [
		"color_background_primary",
		"color_background_secondary",
		"color_background_page",
		"color_font_primary",
		"color_font_secondary",
		"color_font_disabled",
		"color_brand",
		"color_info",
		"color_success",
		"color_warning",
		"color_critical"
	]

	// Each PluginPalette font size is the size of some text that the GUI draws, as the docs promise.
	readonly property var fontSizes: ({
		"font_size_small": "font_listItem_caption_size",
		"font_size_medium": "font_listItem_primary_size",
		"font_size_large": "font_controlCard_status"
	})

	function promisedNames(singleton) {
		let names = []
		for (const name in singleton) {
			if (name !== "objectName" && typeof singleton[name] !== "function") {
				names.push(name)
			}
		}
		return names
	}

	function test_colorsMatchTheme() {
		const names = root.colorNames.concat(["font_family", "quantity_font_family", "orientation"],
				Object.keys(root.fontSizes))
		compare(promisedNames(PluginPalette).slice().sort().join(","), names.slice().sort().join(","))
		compare(PluginPalette.font_family, Theme.font_family)
		compare(PluginPalette.quantity_font_family, Theme.quantity_font_family)

		const previousScheme = Theme.colorScheme
		Theme.colorScheme = Theme.Dark
		const darkBackground = PluginPalette.color_background_primary.toString()
		const schemes = [Theme.Dark, Theme.Light]
		for (let s = 0; s < schemes.length; ++s) {
			Theme.colorScheme = schemes[s]
			for (let i = 0; i < root.colorNames.length; ++i) {
				const name = root.colorNames[i]
				const themeName = root.renamedColors[name] ?? name
				compare(PluginPalette[name].toString(), Theme[themeName].toString(), name)
			}
		}
		verify(PluginPalette.color_background_primary.toString() !== darkBackground)
		Theme.colorScheme = previousScheme
	}

	function test_fontSizesMatchTheme() {
		const previousScreenSize = Theme.screenSize
		const screenSizes = [Theme.FiveInch, Theme.SevenInch, Theme.Portrait]
		for (let s = 0; s < screenSizes.length; ++s) {
			Theme.screenSize = screenSizes[s]
			for (const name in root.fontSizes) {
				compare(PluginPalette[name], Theme[root.fontSizes[name]], name + " in screen size " + s)
			}
		}
		// The sizes change with the screen size: text is smaller in portrait layout.
		Theme.screenSize = Theme.FiveInch
		const landscapeSize = PluginPalette.font_size_medium
		Theme.screenSize = Theme.Portrait
		verify(PluginPalette.font_size_medium < landscapeSize)
		Theme.screenSize = previousScreenSize
	}

	function test_orientationFollowsScreenSize() {
		const previousScreenSize = Theme.screenSize
		Theme.screenSize = Theme.FiveInch
		compare(PluginPalette.orientation, Qt.LandscapeOrientation)
		Theme.screenSize = Theme.SevenInch
		compare(PluginPalette.orientation, Qt.LandscapeOrientation)
		Theme.screenSize = Theme.Portrait
		compare(PluginPalette.orientation, Qt.PortraitOrientation)
		Theme.screenSize = previousScreenSize
	}
}
