import QtQuick
import Victron.GuiPlugins

// The plugin settings page, under Settings -> Integrations -> UI Plugins. Each subpage shows one
// group of the Victron.GuiPlugins types.
PluginPage {
	id: root

	title: "Full API example"

	// A value that no list item shows directly: the Settings list item below uses it for its secondaryText.
	PluginDataItem {
		id: enabledSetting

		serviceType: "settings"
		path: "/Settings/FullApiExample/Enabled"
	}

	PluginGradientListView {
		PluginPrimaryListLabel {
			text: "This plugin uses every type in Victron.GuiPlugins. Each subpage shows one group of types."
		}

		PluginSettingsListHeader {
			text: "Subpages"
		}

		PluginListNavigation {
			text: "Readings"
			caption: "Text, quantities and temperatures"
			pageUrl: Qt.resolvedUrl("FullApiExample_Readings.qml")
		}

		PluginListNavigation {
			text: "Settings"
			caption: "Switches, text fields, numbers, options and buttons"
			// PluginWords are common words, already translated into the user's language.
			secondaryText: !enabledSetting.valid ? ""
				: enabledSetting.value === 1 ? PluginWords.enabled
				: PluginWords.disabled
			pageUrl: Qt.resolvedUrl("FullApiExample_Settings.qml")
		}

		PluginListNavigation {
			text: "Custom items"
			caption: "Items with content of your own, in the theme colors"
			pageUrl: Qt.resolvedUrl("FullApiExample_CustomItems.qml")
			// Sets a title other than the list item's text, and a property that the subpage declares.
			pageProperties: ({ title: "Items of your own", levelCount: 5 })
		}

		PluginListNavigation {
			text: "Access levels"
			caption: "Items shown or changed only from an access level"
			pageUrl: Qt.resolvedUrl("FullApiExample_AccessLevels.qml")
		}

		PluginListNavigation {
			text: "Words and icons"
			caption: "Common words, already translated, and icons in the GUI's colors"
			pageUrl: Qt.resolvedUrl("FullApiExample_WordsAndIcons.qml")
		}

		PluginListNavigation {
			text: "Card"
			caption: "An icon, a title and a status, and content of your own"
			pageUrl: Qt.resolvedUrl("FullApiExample_Card.qml")
		}

		PluginListNavigation {
			text: "Not clickable"
			caption: "A navigation item with interactive set to false has no arrow, and opens nothing."
			interactive: false
		}
	}
}
