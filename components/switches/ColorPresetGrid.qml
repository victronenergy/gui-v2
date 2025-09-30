/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property alias model: gridRepeater.model
	property bool editing
	property int currentIndex

	implicitWidth: buttonGrid.width
	implicitHeight: buttonGrid.y + buttonGrid.height

	Label {
		anchors {
			left: parent.left
			verticalCenter: editButton.verticalCenter
		}
		//% "Preset"
		text: qsTrId("color_preset")
	}

	CP.ColorImage {
		id: editButton
		anchors.right: parent.right
		source: "qrc:/images/icon_edit_32.svg"
		color: Theme.color_blue

		PressArea {
			anchors.fill: parent
			onClicked: root.editing = !root.editing
		}
	}

	Grid {
		id: buttonGrid

		anchors {
			top: editButton.bottom
			topMargin: Theme.color_colorWheelDialog_preset_edit_spacing
		}
		spacing: Theme.color_colorWheelDialog_preset_button_spacing
		columns: 3

		Repeater {
			id: gridRepeater
			delegate: Rectangle {
				width: Theme.color_colorWheelDialog_preset_button_width
				height: Theme.color_colorWheelDialog_preset_button_width
				radius: Theme.geometry_button_radius
				border.width: modelData === undefined || model.index === root.currentIndex ? Theme.geometry_button_border_width : 0
				border.color: modelData === undefined ? Theme.color_colorWheelDialog_button_border
						: model.index === root.currentIndex ? Theme.color_background_primary
						: "transparent"
				color: modelData === undefined ? Theme.color_button_off_background_disabled : modelData

				Rectangle {
					z: -1
					anchors.centerIn: parent
					width: parent.width + (2 * Theme.geometry_button_border_width)
					height: parent.width + (2 * Theme.geometry_button_border_width)
					radius: Theme.geometry_button_radius + Theme.geometry_button_border_width
					color: visible ? modelData : "transparent"
					visible: model.index === root.currentIndex
				}

				Image {
					anchors.centerIn: parent
					source: "qrc:/images/icon_plus.svg"
					visible: modelData === undefined
				}

				PressArea {
					anchors.fill: parent
					onClicked: root.currentIndex = model.index
				}
			}
		}
	}
}
