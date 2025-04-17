/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

Item {
	id: root

	required property string outputUid
	readonly property int _buttonWidth: Theme.geometry_controlCard_minimumWidth
			- (2 * Theme.geometry_controlCard_button_margins)

	SwitchableOutput {
		id: output
		uid: root.outputUid
	}

	Column {
		anchors.verticalCenter: parent.verticalCenter
		width: parent.width

		Row {
			anchors {
				left: switchWidgetLoader.left
				right: switchWidgetLoader.right
			}

			Label {
				id: nameLabel
				anchors.bottom: parent.bottom
				bottomPadding: Theme.geometry_switchableoutput_label_margin
				rightPadding: Theme.geometry_switchableoutput_label_margin
				text: output.formattedName
				width: parent.width - (statusRect.visible ? statusRect.width : 0)
				elide: Text.ElideMiddle // don't elide right, as it may obscure a trailing channel id
			}

			Rectangle {
				id: statusRect

				anchors {
					bottom: parent.bottom
					bottomMargin: Theme.geometry_switchableoutput_label_margin
				}
				width: Math.max(Theme.geometry_switchableoutput_status_minimum_width,
								Math.min(parent.width / 2, statusLabel.implicitWidth))
				height: statusLabel.height
				color: statusLabel.color === Theme.color_green ? Theme.color_darkGreen
						: statusLabel.color === Theme.color_orange ? Theme.color_darkOrange
						: statusLabel.color === Theme.color_red ? Theme.color_darkRed
						: Theme.color_background_disabled
				radius: Theme.geometry_switchableoutput_status_radius
				visible: !((output.status === VenusOS.SwitchableOutput_Status_Off)
					  || (output.status === VenusOS.SwitchableOutput_Status_On)
					  || (output.status === VenusOS.SwitchableOutput_Status_Powered)
					  || ((output.status === VenusOS.SwitchableOutput_Status_Output_Fault)
						  && (output.type === VenusOS.SwitchableOutput_Type_Dimmable)))

				Label {
					id: statusLabel

					text: VenusOS.switchableOutput_statusToText(output.status)
					width: parent.width
					topPadding: Theme.geometry_switchableoutput_status_verticalPadding
					bottomPadding: Theme.geometry_switchableoutput_status_verticalPadding
					leftPadding: Theme.geometry_switchableoutput_status_horizontalPadding
					rightPadding: Theme.geometry_switchableoutput_status_horizontalPadding
					horizontalAlignment: Text.AlignHCenter
					elide: Text.ElideRight
					font.pixelSize: Theme.font_size_caption
					color: {
						switch (output.status) {
						case VenusOS.SwitchableOutput_Status_Off:
							return Theme.color_font_secondary
						case VenusOS.SwitchableOutput_Status_Powered:
						case VenusOS.SwitchableOutput_Status_On:
							return Theme.color_green
						case VenusOS.SwitchableOutput_Status_Output_Fault:
							return Theme.color_orange
						case VenusOS.SwitchableOutput_Status_Disabled:
						case VenusOS.SwitchableOutput_Status_TripLowVoltage:
						case VenusOS.SwitchableOutput_Status_Over_Temperature:
						case VenusOS.SwitchableOutput_Status_Short_Fault:
						case VenusOS.SwitchableOutput_Status_Tripped:
							return Theme.color_red
						default:
							return Theme.color_red
						}
					}
				}
			}
		}

		Loader {
			id: switchWidgetLoader
			anchors.horizontalCenter: parent.horizontalCenter
			sourceComponent: output.type === VenusOS.SwitchableOutput_Type_Dimmable ? dimmingSlider
					: output.type === VenusOS.SwitchableOutput_Type_Momentary ? momentarySwitchButton
					: output.type === VenusOS.SwitchableOutput_Type_Latching ? latchingButton
					: null
		}
	}

	Component {
		id: dimmingSlider

		DimmingSlider {
			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			highlightColor: output.state === 1 ? Theme.color_ok : Theme.color_button_down
			from: 1
			to: 100
			value: output.hasDimming ? output.dimming : 0
			onPositionChanged:{
				value = Math.round(value) // break binding so that the delayed data update doesn't fight user input
				output.setDimming(value)
			}
			onClicked: {
				output.setState(output.state === 0 ? 1 : 0)
			}

			Label {
				anchors.centerIn: parent
				text: output.state === 1 ? CommonWords.on : CommonWords.off
				font.pixelSize: Theme.font_size_body2
			}
		}
	}

	Component {
		id: momentarySwitchButton

		Button {
			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			font.pixelSize: Theme.font_size_body2
			//% "Press"
			text: qsTrId("switchable_output_press")
			flat: false
			checked: output.state === 1
			onPressed: output.setState(1)
			onReleased: output.setState(0)
			onCanceled: output.setState(0)
		}
	}

	Component {
		id: latchingButton

		SegmentedButtonRow {
			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			fontPixelSize: Theme.font_size_body2
			currentIndex: output.state === 1 ? 1 : 0
			model: [{ "value": CommonWords.off }, { "value": CommonWords.on }]
			onCurrentIndexChanged: {
				output.setState(currentIndex === 1 ? 1 : 0)
			}
		}
	}
}
