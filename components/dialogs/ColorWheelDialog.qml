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
	required property int supportedOutputTypes

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
			onClicked: root.close()
		}
	}

	contentItem: ModalDialog.FocusableContentItem {
		// Button for switching between RGB(W) and CCT colour wheels. When clicked, the
		// SwitchableOutput/<x>/Type value is updated.
		ColorWheelModeButton {
			id: colorModeButton

			function changeOutputType(type) {
				root.switchableOutput.type = type
				root.colorDimmerData.save()
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
				if (root.supportedOutputTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerRgb)
						|| root.supportedOutputTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerRgbW)) {
					supportsRgb = true
				}
				if (root.supportedOutputTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerCct)) {
					supportsCct = true
				}
				return supportsRgb && supportsCct
			}
			outputType: root.switchableOutput.type

			onRgbClicked: {
				if (root.supportedOutputTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerRgbW)) {
					changeOutputType(VenusOS.SwitchableOutput_Type_ColorDimmerRgbW)
				} else if (root.supportedOutputTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerRgb)) {
					changeOutputType(VenusOS.SwitchableOutput_Type_ColorDimmerRgb)
				}
			}
			onCctClicked: {
				if (root.supportedOutputTypes & (1 << VenusOS.SwitchableOutput_Type_ColorDimmerCct)) {
					changeOutputType(VenusOS.SwitchableOutput_Type_ColorDimmerCct)
				}
			}
		}

		ColorSelector {
			id: colorSelector

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: colorModeButton.visible ? (colorModeButton.height / 2) : 0
				horizontalCenter: parent.horizontalCenter
				horizontalCenterOffset: -(presetGrid.width / 2) - (Theme.geometry_colorWheelDialog_content_spacing / 2)
			}
			colorDimmerData: root.colorDimmerData
			outputType: root.switchableOutput.type
		}

		ColorPresetGrid {
			id: presetGrid

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: -(colorModeButton.height / 2)
				left: colorSelector.right
				leftMargin: Theme.geometry_colorWheelDialog_content_spacing
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
				presetGrid.resetCurrentIndex()
			}
		}
	}
}
