import QtQuick
import Victron.GuiPlugins

/*
	Rows with content of your own, built with PluginListItem.

	Plugins cannot read the GUI's colors, which change with light and dark mode and with OEM
	branding. So the content here has no text of its own, as the rows draw their text, and uses
	colors that can be seen on both light and dark backgrounds.
*/
PluginPage {
	id: root

	// The number of squares in the Level row. The main page sets it with pageProperties.
	property int levelCount: 3

	readonly property PluginDataItem socItem: PluginDataItem {
		serviceType: "system"
		path: "/Dc/Battery/Soc"
	}

	// Created by Reset to defaults on the Settings page, in mock mode.
	readonly property PluginDataItem levelSetting: PluginDataItem {
		serviceType: "settings"
		path: "/Settings/FullApiExample/Level"
	}

	PluginGradientListView {
		PluginListItem {
			// Without text, the content fills the width of the row, and the caption is below it.
			caption: "Battery state of charge"

			Rectangle {
				width: parent.width
				height: 12
				radius: 6
				color: "#80969591"

				Rectangle {
					width: parent.width * Math.max(0, Math.min(100, root.socItem.value ?? 0)) / 100
					height: parent.height
					radius: parent.radius
					color: "#387DC5"
				}
			}
		}

		PluginListItem {
			id: levelRow

			text: "Level"
			caption: "Touch a square, or press Space when the row has the key navigation focus."
			interactive: root.levelSetting.valid
			writeAccessLevel: PluginAccessLevel.User

			// Key presses go to the row. Check the access level before changing the setting.
			Keys.onSpacePressed: {
				if (levelRow.interactive && levelRow.checkWriteAccessLevel()) {
					root.levelSetting.setValue(root.levelSetting.value % root.levelCount + 1)
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
						color: root.levelSetting.valid && square.index < root.levelSetting.value ? "#387DC5" : "#80969591"

						MouseArea {
							anchors.fill: parent
							// clickable is true when the row is interactive, and the user has writeAccessLevel.
							enabled: levelRow.clickable
							onClicked: root.levelSetting.setValue(square.index + 1)
						}
					}
				}
			}
		}
	}
}
