import QtQuick
import Victron.GuiPlugins

/*
	List items with content of your own, built with PluginListSetting.

	Plugins cannot read the GUI's colors, which change with light and dark mode and with OEM
	branding. So the content here has no text of its own, as the list items draw their text, and uses
	colors that can be seen on both light and dark backgrounds.
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
		PluginPrimaryListLabel {
			text: "Battery state of charge"
		}

		PluginListSetting {
			// Without text, the content fills the width of the list item.

			Rectangle {
				width: parent.width
				height: 12
				radius: 6
				color: "#80969591"

				Rectangle {
					width: parent.width * Math.max(0, Math.min(100, socItem.value ?? 0)) / 100
					height: parent.height
					radius: parent.radius
					color: "#387DC5"
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
						color: levelSetting.valid && square.index < levelSetting.value ? "#387DC5" : "#80969591"

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
