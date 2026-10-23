/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginWordsAndIconsTest"

	Component {
		id: imageComponent

		Image {}
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
	// as "pluginWordsName": "commonWordsName".
	readonly property var renamedWords: ({})

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
}