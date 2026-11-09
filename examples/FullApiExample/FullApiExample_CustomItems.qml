import QtQuick
import Victron.GuiPlugins

/*
	List items with content of your own, built with PluginListSetting.

	Draw that content with PluginPalette colors, so it follows light and dark mode and custom
	branding. The list items still draw the text.
*/
PluginPage {
	id: root

	// The number of squares in the Level list item. The main page sets it with pageProperties.
	property int levelCount: 3

	PluginDataItem {
		id: socItem

		serviceType: "system"
		path: "/Dc/Battery/Soc"
	}

	// Created by Reset to defaults on the Settings page, in mock mode.
	PluginDataItem {
		id: levelSetting

		serviceType: "settings"
		path: "/Settings/FullApiExample/Level"
	}

	PluginGradientListView {
		PluginSettingsListHeader {
			text: "Theme colors"
		}

		PluginPrimaryListLabel {
			text: "These are the PluginPalette colors. They follow light and dark mode, and custom branding."
		}

		PluginListSetting {
			Flow {
				width: parent.width
				spacing: 8

				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_background_primary
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_background_secondary
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_background_page
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_font_primary
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_font_secondary
					border.width: 1
					border.color: PluginPalette.color_font_primary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_brand
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_info
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_success
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_warning
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
				Rectangle {
					width: 28
					height: 28
					radius: 4
					color: PluginPalette.color_critical
					border.width: 1
					border.color: PluginPalette.color_font_secondary
				}
			}
		}

		PluginPrimaryListLabel {
			text: "Battery state of charge"
		}

		PluginListSetting {
			// Without text, the content fills the width of the list item.

			Rectangle {
				width: parent.width
				height: 12
				radius: 6
				// A faint brand color: the brand color at 30%, laid over the background.
				color: Qt.tint(PluginPalette.color_background_primary, Qt.alpha(PluginPalette.color_brand, 0.3))

				Rectangle {
					width: parent.width * Math.max(0, Math.min(100, socItem.value ?? 0)) / 100
					height: parent.height
					radius: parent.radius
					color: PluginPalette.color_brand
				}
			}
		}

		PluginListSetting {
			id: levelRow

			text: "Level"
			interactive: levelSetting.valid
			writeAccessLevel: PluginAccessLevel.User

			// Key presses go to the list item. Check the access level before changing the setting.
			Keys.onSpacePressed: {
				if (levelRow.interactive && levelRow.checkWriteAccessLevel()) {
					levelSetting.setValue(levelSetting.value % root.levelCount + 1)
				}
			}

			Row {
				spacing: 8

				Repeater {
					model: root.levelCount

					delegate: Rectangle {
						id: square

						required property int index

						width: 32
						height: 32
						radius: 4
						color: levelSetting.valid && square.index < levelSetting.value
							? PluginPalette.color_brand
							: PluginPalette.color_font_secondary

						MouseArea {
							anchors.fill: parent
							// clickable is true when the list item is interactive, and the user has writeAccessLevel.
							enabled: levelRow.clickable
							onClicked: levelSetting.setValue(square.index + 1)
						}
					}
				}
			}
		}
	}
}
