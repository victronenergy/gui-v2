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

	name: "PluginWordsAndIconsTest"

	VictronBranding {
		id: victronBranding
	}

	Component {
		id: imageComponent

		Image {}
	}

	Component {
		id: iconImageComponent

		PluginIconImage {}
	}

	function initTestCase() {
		Theme.addBranding(victronBranding)
	}

	// Returns the names of the promised properties of a PluginWords or PluginIcons singleton.
	function promisedNames(singleton) {
		let names = []
		for (const name in singleton) {
			if (name !== "objectName" && typeof singleton[name] !== "function") {
				names.push(name)
			}
		}
		return names
	}

	// A PluginWords word keeps its name when its CommonWords word is renamed. Add such words here,
	// as "pluginWordsName": "commonWordsName". PluginWords.unknown is CommonWords.unknown_status.
	readonly property var renamedWords: ({
		unknown: "unknown_status"
	})

	function test_wordsMatchCommonWords() {
		const names = promisedNames(PluginWords)
		verify(names.length > 0)
		for (const name of names) {
			verify(PluginWords[name].length > 0, name)
			compare(PluginWords[name], CommonWords[root.renamedWords[name] ?? name], name)
		}
	}

	function test_iconsLoad() {
		const names = promisedNames(PluginIcons)
		verify(names.length > 0)
		for (const name of names) {
			const image = createTemporaryObject(imageComponent, root, { source: PluginIcons[name] })
			tryCompare(image, "status", Image.Ready, 5000, name)
		}
	}

	// Each tint draws the icon in the PluginPalette color for its purpose. A disabled icon uses the
	// disabled color, whatever its tint.
	function test_iconTints_data() {
		return [
			{ tag: "Text", tint: PluginIconImage.Text, enabled: true, colorName: "color_font_primary" },
			{ tag: "SecondaryText", tint: PluginIconImage.SecondaryText, enabled: true, colorName: "color_font_secondary" },
			{ tag: "Warning", tint: PluginIconImage.Warning, enabled: true, colorName: "color_warning" },
			{ tag: "Critical", tint: PluginIconImage.Critical, enabled: true, colorName: "color_critical" },
			{ tag: "Success", tint: PluginIconImage.Success, enabled: true, colorName: "color_success" },
			{ tag: "Brand", tint: PluginIconImage.Brand, enabled: true, colorName: "color_brand" },
			{ tag: "Disabled", tint: PluginIconImage.Disabled, enabled: true, colorName: "color_font_disabled" },
			{ tag: "disabled icon", tint: PluginIconImage.Warning, enabled: false, colorName: "color_font_disabled" },
		]
	}

	function test_iconTints(data) {
		const icon = createTemporaryObject(iconImageComponent, root, { tint: data.tint, enabled: data.enabled })
		verify(icon !== null)
		compare(icon.children[0].color.toString(), PluginPalette[data.colorName].toString())
	}
}