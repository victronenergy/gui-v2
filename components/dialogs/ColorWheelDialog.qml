/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ModalDialog {
	id: root

	required property ColorDimmerData colorDimmerData
	required property SwitchableOutput switchableOutput

	readonly property StateGroup stateGroup: StateGroup {
		states: [
			State {
				name: "rgb"
				when: root.switchableOutput.type === VenusOS.SwitchableOutput_Type_ColorDimmerRgb
				PropertyChanges {
					target: root
					secondaryTitle: CommonWords.color
				}
				PropertyChanges {
					target: presetGrid
					model: rgbPresetModel
				}
			},
			State {
				name: "rgbw"
				when: root.switchableOutput.type === VenusOS.SwitchableOutput_Type_ColorDimmerRgbW
				PropertyChanges {
					target: root
					secondaryTitle: CommonWords.color
				}
				PropertyChanges {
					target: presetGrid
					model: rgbWPresetModel
				}
			},
			State {
				name: "cct"
				when: root.switchableOutput.type === VenusOS.SwitchableOutput_Type_ColorDimmerCct
				PropertyChanges {
					target: root
					secondaryTitle: CommonWords.temperature
				}
				PropertyChanges {
					target: presetGrid
					model: cctPresetModel
				}
			}
		]
	}

	width: Theme.geometry_colorWheelDialog_width
	height: Theme.geometry_colorWheelDialog_height
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions

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

		CloseButton {
			anchors.right: parent.right
			anchors.rightMargin: Theme.geometry_closeButton_rightMargin
			onClicked: root.close()
		}
	}

	contentItem: ModalDialog.FocusableContentItem {
		// Button for switching between RGB(W) and CCT colour wheels. When clicked, the
		// SwitchableOutput/<x>/Type value is updated.
		ColorWheelModeButton {
			id: colorModeButton

			function changeOutputType(type) {
				if (root.switchableOutput.type === type) {
					return
				}
				root.switchableOutput.type = type
				if (type === VenusOS.SwitchableOutput_Type_ColorDimmerCct
						&& root.colorDimmerData.colorTemperature === 0) {
					// Reset the LightControls value to the default (warm temperature).
					root.colorDimmerData.colorTemperature = 2000
				}
				// Update the selector to show the correct colour in the centre.
				root.colorDimmerData.save()
				colorSelector.updateWheelAngle()
			}

			anchors {
				bottom: colorSelector.top
				bottomMargin: Theme.geometry_colorWheelDialog_mode_button_verticalMargin
				horizontalCenter: colorSelector.horizontalCenter
			}
			visible: {
				// Show the mode toggle button if multiple types of color wheels are supported.
				let supportsRgb = false
				let supportsCct = false
				if (root.switchableOutput.validTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerRgb)
						|| root.switchableOutput.validTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerRgbW)) {
					supportsRgb = true
				}
				if (root.switchableOutput.validTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerCct)) {
					supportsCct = true
				}
				return supportsRgb && supportsCct
			}
			outputType: root.switchableOutput.type

			onRgbClicked: {
				if (root.switchableOutput.validTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerRgbW)) {
					changeOutputType(VenusOS.SwitchableOutput_Type_ColorDimmerRgbW)
				} else if (root.switchableOutput.validTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerRgb)) {
					changeOutputType(VenusOS.SwitchableOutput_Type_ColorDimmerRgb)
				}
			}
			onCctClicked: {
				if (root.switchableOutput.validTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerCct)) {
					changeOutputType(VenusOS.SwitchableOutput_Type_ColorDimmerCct)
				}
			}
		}

		ColorSelector {
			id: colorSelector

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: colorModeButton.visible ? (colorModeButton.height / 2) : 0
				left: parent.left
				leftMargin: Theme.geometry_colorWheelDialog_horizontalMargin_left
			}
			colorDimmerData: root.colorDimmerData
		}

		ColorPresetGrid {
			id: presetGrid

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: -(colorModeButton.height / 2)
				right: parent.right
				rightMargin: Theme.geometry_colorWheelDialog_horizontalMargin_right
			}
			focus: true
			onPresetActivated: (index) => {
				// Take the color data from the selected preset, and load it into the color data
				// that is displayed by the color selector.
				root.colorDimmerData.loadFromPreset(model.get(index))
				colorSelector.updateWheelAngle()
			}
			onPresetAdded: (index) => {
				// Take the color data from the color selector, and adds it as a new preset.
				model.setPreset(index,
						root.colorDimmerData.color,
						root.colorDimmerData.white,
						root.colorDimmerData.colorTemperature)
			}
			onPresetRemoved: (index) => {
				// Remove the color data from the selected preset.
				model.clearPreset(index)
			}

			ColorPresetModel {
				id: rgbPresetModel
				settingUid: Global.systemSettings.serviceUid + "/Settings/Gui2/Switchpane/Preset/RGB"
			}
			ColorPresetModel {
				id: rgbWPresetModel
				settingUid: Global.systemSettings.serviceUid + "/Settings/Gui2/Switchpane/Preset/RGBW"
			}
			ColorPresetModel {
				id: cctPresetModel
				settingUid: Global.systemSettings.serviceUid + "/Settings/Gui2/Switchpane/Preset/CCT"
			}
		}

		// When the selected colour changes, clear the preset selection to indicate that the
		// selected preset is no longer in use.
		Connections {
			target: root.colorDimmerData
			function onColorChanged() {
				presetGrid.resetSelection()
			}
		}
	}
}
