/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ModalDialog {
	id: root

	property var rgbPresetModel: []
	property var temperaturePresetModel: []

	readonly property StateGroup stateGroup: StateGroup {
		function toggleState() {
			state = state === "rgb" ? "temperature" : "rgb"
		}

		state: "rgb"
		states: [
			State {
				name: "rgb"
				PropertyChanges {
					target: root
					//% "Color"
					secondaryTitle: qsTrId("colorselectordialog_color")
				}
				PropertyChanges {
					target: presetGrid
					model: root.rgbPresetModel
				}
			},
			State {
				name: "temperature"
				PropertyChanges {
					target: root
					secondaryTitle: CommonWords.temperature
				}
				PropertyChanges {
					target: presetGrid
					model: root.temperaturePresetModel
				}
			}
		]
	}

	width: Theme.color_colorWheelDialog_width
	height: Theme.color_colorWheelDialog_height

	header: Item {
		height: Theme.geometry_modalDialog_header_height

		Label {
			id: headerLabel
			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: -(secondaryLabel.height / 2)
				left: parent.left
				leftMargin: Theme.geometry_page_content_horizontalMargin
			}
			text: root.title
			elide: Text.ElideRight
		}

		Label {
			id: secondaryLabel
			anchors {
				top: headerLabel.bottom
				left: parent.left
				leftMargin: Theme.geometry_page_content_horizontalMargin
			}
			font.pixelSize: Theme.font_size_body2
			text: root.secondaryTitle
			elide: Text.ElideRight
		}

		ColorWheelModeButton {
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: Theme.geometry_page_content_horizontalMargin
			}
			onClicked: root.stateGroup.toggleState()
		}
	}

	contentItem: ModalDialog.FocusableContentItem {
		// TODO replace this with ColorSelector.
		Rectangle {
			id: colorSelector

			function load(rgbColor) {
				color = rgbColor
			}

			anchors {
				top: parent.top
				topMargin: Theme.color_colorWheelDialog_content_topPadding
				horizontalCenter: parent.horizontalCenter
				horizontalCenterOffset: -(presetGrid.width/2) - (Theme.color_colorWheelDialog_content_spacing/2)
			}
			width: 316
			height: 224
			border.width: 1            
			color: presetGrid.model[presetGrid.currentIndex] || "transparent"

			// When the color selector changes color, update the button in the preset grid.
			onColorChanged: {
				presetGrid.model[presetGrid.currentIndex] = color
			}

			PressArea {
				anchors.fill: parent
				onClicked: {
					parent.color = Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
				}
			}
		}

		ColorPresetGrid {
			id: presetGrid

			anchors {
				top: parent.top
				topMargin: Theme.color_colorWheelDialog_content_topPadding
				left: colorSelector.right
				leftMargin: Theme.color_colorWheelDialog_content_spacing
			}
			onCurrentIndexChanged: {
				if (model[currentIndex] === undefined) {
					model[currentIndex] = Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
				}
				colorSelector.load(model[currentIndex])
			}
		}
	}
}
