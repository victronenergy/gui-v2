/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
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
				when: colorModeButton.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerRgb
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
				when: colorModeButton.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerRgbW
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
				when: colorModeButton.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct
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

	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions

	header: Item {
		implicitHeight: headerLabel.height + secondaryLabel.height + (2 * Theme.geometry_modalDialog_header_verticalPadding)

		Label {
			id: headerLabel
			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: -(secondaryLabel.height / 2)
				left: parent.left
				leftMargin: Theme.geometry_page_content_horizontalMargin
			}
			font.pixelSize: Theme.font_dialog_header_smallSize
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
			font.pixelSize: Theme.font_dialog_header_largeSize
			text: root.secondaryTitle
			elide: Text.ElideRight
		}

		CloseButton {
			anchors {
				top: parent.top
				topMargin: Theme.geometry_closeButton_rightMargin
				right: parent.right
				rightMargin: Theme.geometry_closeButton_rightMargin
			}
			onClicked: root.close()
		}
	}

	topPadding: topInset + Theme.geometry_colorWheelDialog_topPadding
	bottomPadding: bottomInset + Theme.geometry_colorWheelDialog_bottomPadding
	leftPadding: leftInset + Theme.geometry_colorWheelDialog_leftPadding
	rightPadding: leftInset + Theme.geometry_colorWheelDialog_rightPadding

	contentItem: ModalDialog.FocusableContentItem {
		implicitWidth: contentLayout.implicitWidth
		implicitHeight: contentLayout.implicitHeight

		Flickable { // used in portrait layout
			anchors.fill: parent
			contentHeight: contentLayout.height
			boundsBehavior: Flickable.StopAtBounds

			GridLayout {
				id: contentLayout

				width: parent.width
				flow: GridLayout.TopToBottom
				rows: Theme.screenSize === Theme.Portrait ? 3 : 2
				rowSpacing: 0
				columnSpacing: Theme.geometry_colorWheelDialog_spacing

				// Button for switching between RGB(W) and CCT colour wheels. When clicked, the
				// SwitchableOutput/<x>/Type value is updated.
				ColorWheelModeButton {
					id: colorModeButton

					function changeOutputType(type) {
						if (outputType === type) {
							return
						}

						// Instead of changing SwitchableOutput::type, write the value with SettingsSync so
						// the UI shows the type change immediately, even if the value is not yet written
						// to the backend.
						outputTypeSync.writeValue(type)

						if (type === VenusOS.SwitchableOutput_Type_ColorDimmerCct
								&& root.colorDimmerData.colorTemperature === 0) {
							// Reset the LightControls value to the default (warm temperature).
							root.colorDimmerData.colorTemperature = 2000
						}
						// Update the selector to show the correct colour in the centre.
						root.colorDimmerData.save()
						colorSelector.updateWheelAngle()
					}

					enabled: {
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
					opacity: enabled ? 1 : 0
					outputType: outputTypeSync.expectedValue
					visible: enabled || Theme.screenSize !== Theme.Portrait // in portrait, collapse space when not enabled

					Layout.alignment: Qt.AlignHCenter
					Layout.bottomMargin: Theme.geometry_colorWheelDialog_mode_button_verticalMargin

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

					colorDimmerData: root.colorDimmerData
					outputType: colorModeButton.outputType

					Layout.alignment: Qt.AlignHCenter
					Layout.bottomMargin: Theme.screenSize === Theme.Portrait ? Theme.geometry_colorWheelDialog_spacing : 0
				}

				ColorPresetGrid {
					id: presetGrid

					focus: true

					Layout.rowSpan: Theme.screenSize === Theme.Portrait ? 1 : 2
					Layout.alignment: Qt.AlignHCenter

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
		}

		SettingSync {
			id: outputTypeSync
			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/Settings/Type"
			}
		}
	}
}
