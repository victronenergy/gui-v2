/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	id: root

	property ColorPresetModel model

	signal presetActivated(index : int)
	signal presetAdded(index : int)
	signal presetRemoved(index : int)

	function resetSelection() {
		selectionIndicator.reset()
	}

	implicitWidth: buttonGrid.width
	implicitHeight: buttonGrid.y + buttonGrid.height

	Label {
		anchors {
			left: buttonGrid.left
			leftMargin: Theme.geometry_colorWheelDialog_preset_button_spacing / 2
			verticalCenter: editButton.verticalCenter
		}
		//% "Preset"
		text: qsTrId("color_preset")
		font.pixelSize: Theme.font_size_body2
	}

	Button {
		id: editButton
		anchors {
			right: buttonGrid.right
			rightMargin: Theme.geometry_colorWheelDialog_preset_button_spacing / 2
		}
		width: Theme.geometry_colorWheelDialog_preset_edit_width
		height: Theme.geometry_colorWheelDialog_preset_edit_width
		icon.source: "qrc:/images/icon_edit_32.svg"
		flat: false
		onClicked: checked = !checked
	}

	SeparatorBar {
		id: separator
		anchors {
			top: editButton.bottom
			topMargin: Theme.geometry_colorWheelDialog_preset_edit_spacing
			horizontalCenter: buttonGrid.horizontalCenter
		}
		x: Theme.geometry_colorWheelDialog_preset_button_spacing / 2
		width: buttonGrid.width - (2 * x)
	}

	Image {
		id: selectionIndicator

		function moveTo(button) {
			parent = button
		}

		function reset() {
			parent = root
		}

		anchors.centerIn: parent
		source: "qrc:/images/selection_dot.svg"
		visible: parent != root && !editButton.checked
	}

	GridView {
		id: buttonGrid

		anchors.top: separator.bottom
		interactive: false
		width: cellWidth * 3
		height: cellHeight * 3
		cellWidth: Theme.geometry_colorWheelDialog_preset_button_width + Theme.geometry_colorWheelDialog_preset_button_spacing
		cellHeight: Theme.geometry_colorWheelDialog_preset_button_width + Theme.geometry_colorWheelDialog_preset_button_spacing
		currentIndex: -1
		model: root.model
		delegate: Item {
			id: presetDelegate

			required property int index
			required property color color
			readonly property bool canRemove: editButton.checked && color.valid

			width: buttonGrid.cellWidth
			height: buttonGrid.cellHeight
			enabled: color.valid || !editButton.checked  // empty presets cannot be clicked in edit mode

			Keys.onSpacePressed: colorButton.clicked(null)
			KeyNavigationHighlight.active: activeFocus

			ColorButton {
				id: colorButton

				anchors.centerIn: parent
				width: Theme.geometry_colorWheelDialog_preset_button_width
				height: Theme.geometry_colorWheelDialog_preset_button_width
				border {
					width: Theme.geometry_button_border_width
					color: presetDelegate.color.valid ? Theme.color_ok
							: enabled ? Theme.color_colorWheelDialog_preset_empty_button_border
							: Theme.color_colorWheelDialog_preset_empty_button_border_disabled
				}
				radius: Theme.geometry_colorWheelDialog_preset_button_radius
				centerColor: Qt.hsva(presetDelegate.color.hsvHue,
						presetDelegate.color.hsvSaturation,
						1.0, 1.0)
				color: presetDelegate.color.valid
					   ? "transparent"
					   : Theme.color_colorWheelDialog_preset_empty_button_background

				onClicked: {
					if (presetDelegate.canRemove) {
						// Clicked the "-" icon
						if (selectionIndicator.parent === colorButton) {
							selectionIndicator.reset()
						}
						root.presetRemoved(presetDelegate.index)
					} else if (presetDelegate.color.valid) {
						// Clicked a button with a color
						root.presetActivated(presetDelegate.index)
						selectionIndicator.moveTo(colorButton)
					} else {
						// Clicked the "+" icon
						root.presetAdded(presetDelegate.index)
					}
				}

				// If a color is set, show "-" icon in editing mode.
				// Otherwise, show "+" icon to indicate a color can be added.
				CP.ColorImage {
					anchors.centerIn: parent
					source: presetDelegate.canRemove
							? "qrc:/images/icon_minus.svg"
							: "qrc:/images/icon_plus.svg"
					visible: presetDelegate.canRemove || !presetDelegate.color.valid
					color: presetDelegate.canRemove
							  // Minus icon is shown, which is always white
							? Theme.color_white
							  // Plus icon is shown, which is the primary font color, or disabled color
							: (editButton.checked ? Theme.color_colorWheelDialog_preset_empty_button_icon_disabled : Theme.color_font_primary)
				}
			}
		}

		focus: true
		keyNavigationEnabled: true
		KeyNavigation.up: editButton
	}
}
