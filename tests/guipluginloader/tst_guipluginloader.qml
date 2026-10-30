/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest

TestCase {
	id: root

	name: "GuiPluginLoaderTest"

	// GuiPluginLoader.PluginSettingsPage and GuiPluginLoader.DeviceListSettingsPage. The enum
	// values are not used directly, as that would create the GuiPluginLoader singleton.
	readonly property int settingsPageType: 1
	readonly property int deviceListSettingsPageType: 2

	function pluginWithEachIntegrationType() {
		return {
			integrations: [
				{ type: root.settingsPageType, url: "qrc:/TestPlugin/SettingsPage.qml" },
				{ type: root.deviceListSettingsPageType, productId: "0xA389", title: "Test",
					url: "qrc:/TestPlugin/DevicePage.qml" },
			]
		}
	}

	function test_requiredGuiPluginsVersion_data() {
		const parts = GuiPluginLoaderTestHelper.guiPluginsModuleVersion().split(".").map(Number)
		const major = parts[0]
		const minor = parts[1]
		const notAVersion = "requiredGuiPluginsVersion is not a \"major.minor\" string"
		return [
			{ tag: "missing", plugin: {}, problem: "" },
			{ tag: "this version", plugin: { requiredGuiPluginsVersion: major + "." + minor }, problem: "" },
			{ tag: "first minor", plugin: { requiredGuiPluginsVersion: major + ".0" }, problem: "" },
			{ tag: "newer minor", plugin: { requiredGuiPluginsVersion: major + "." + (minor + 1) },
				problem: "it needs Victron.GuiPlugins " + major + "." + (minor + 1) + ", but this GUI only has " + major + "." + minor },
			{ tag: "newer major", plugin: { requiredGuiPluginsVersion: (major + 1) + ".0" },
				problem: "it needs Victron.GuiPlugins " + (major + 1) + ".0, but this GUI has " + major + "." + minor },
			{ tag: "older major", plugin: { requiredGuiPluginsVersion: (major - 1) + ".0" },
				problem: "it needs Victron.GuiPlugins " + (major - 1) + ".0, but this GUI has " + major + "." + minor },
			{ tag: "patch number", plugin: { requiredGuiPluginsVersion: major + ".0.0" }, problem: notAVersion },
			{ tag: "number", plugin: { requiredGuiPluginsVersion: major }, problem: notAVersion },
		]
	}

	function test_requiredGuiPluginsVersion(data) {
		compare(GuiPluginLoaderTestHelper.checkRequiredGuiPluginsVersion(JSON.stringify(data.plugin)), data.problem)
	}

	function test_supportedVersionKeepsEveryIntegration() {
		const plugin = pluginWithEachIntegrationType()
		const allTypes = [root.settingsPageType, root.deviceListSettingsPageType]
		compare(GuiPluginLoaderTestHelper.integrationTypes(JSON.stringify(plugin)), allTypes)

		plugin.requiredGuiPluginsVersion = GuiPluginLoaderTestHelper.guiPluginsModuleVersion()
		compare(GuiPluginLoaderTestHelper.integrationTypes(JSON.stringify(plugin)), allTypes)
	}

	function test_unsupportedVersionDropsEveryIntegration() {
		const plugin = pluginWithEachIntegrationType()
		const major = Number(GuiPluginLoaderTestHelper.guiPluginsModuleVersion().split(".")[0])
		plugin.requiredGuiPluginsVersion = (major + 1) + ".0"
		ignoreWarning(new RegExp("^Ignoring integration at index 0 in plugin TestPlugin - type: "
				+ root.settingsPageType + " - it needs Victron\\.GuiPlugins "))
		ignoreWarning(new RegExp("^Ignoring integration at index 1 in plugin TestPlugin - type: "
				+ root.deviceListSettingsPageType + " - it needs Victron\\.GuiPlugins "))
		compare(GuiPluginLoaderTestHelper.integrationTypes(JSON.stringify(plugin)), [])
	}
}
