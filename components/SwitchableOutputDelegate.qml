/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

BaseListItem {
	id: root

	required property string outputUid
	readonly property int _buttonWidth: Theme.geometry_controlCard_minimumWidth
			- (2 * Theme.geometry_controlCard_button_margins)

	// Hide the delegate highlight when the loader item is showing its own highlight (i.e. if
	// showing a DimmingSlider in edit mode).
	navigationHighlight.active: activeFocus && !switchWidgetLoader.item?.activeFocus

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

			// Instead of giving focus to the individual controls, handle the keys directly here.
			// This is consistent with the Control Cards, which focus the overall delegates in each
			// card, rather than the controls within the delegates.
			// (The DimmingSlider is a special case; it needs to be focused individually to provide
			// an "edit" mode, so that left/right keys will move the slider instead of navigating to
			// the previous/next item in the grid.)
			focus: true
			Keys.onPressed: (event) => { event.accepted = item.handlePress !== undefined && item.handlePress(event.key) }
			Keys.onReleased: (event) => { event.accepted = item.handleRelease !== undefined && item.handleRelease(event.key) }
			Keys.enabled: Global.keyNavigationEnabled
		}
	}

	Component {
		id: dimmingSlider

		DimmingSlider {
			id: slider

			property real movedValue: NaN

			// When space key is pressed, enter an "edit" (i.e. focused) mode where the space key
			// toggles the on/off state and left/right keys move the slider.
			// When return key is pressed, exit the edit mode.
			function handlePress(key) {
				switch (key) {
				case Qt.Key_Space:
					if (activeFocus) {
						_toggle()
					} else {
						focus = true
					}
					return true
				case Qt.Key_Return:
					focus = false
					return true
				case Qt.Key_Up:
				case Qt.Key_Down:
					// Remove focus and reject event to allow key navigation to delegates above/below.
					focus = false
					return false
				}
				return false
			}

			function _toggle() {
				output.setState(output.state === 0 ? 1 : 0)
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			highlightColor: output.state === 1 ? Theme.color_ok : Theme.color_button_down
			from: 1
			to: 100
			stepSize: 1

			onClicked: {
				output.setState(output.state === 0 ? 1 : 0)
			}
			onMoved: {
				value = Math.round(value)
				output.setDimming(value)
				movedValue = value
			}

			Connections {
				target: output
				Component.onCompleted: slider.value = output.dimming

				// Update the slider value from the backend. If the backend value is changing in
				// response to slider user input, the backend change may lag behind the user change,
				// so do not update the slider value until the slider and backend values are in
				// sync, else the two values will fight each other.
				function onDimmingChanged() {
					if (isNaN(slider.movedValue)) {
						// The slider was not moved, so the value change must have come from
						// the backend independently, and the slider value can updated directly.
						slider.value = output.dimming
					} else if (slider.movedValue === Math.round(output.dimming)) {
						// The user moved the slider and the backend is now up-to-date with the
						// user-moved value, so clear the flag.
						slider.movedValue = NaN
					} else {
						// The slider was moved, and the backend value changed in response, but
						// the backend still has an older moved value from the UI, so ignore
						// this as the backend is not yet up-to-date with the UI value.
					}
				}
			}

			Label {
				anchors.centerIn: parent
				text: output.state === 1 ? CommonWords.on : CommonWords.off
				font.pixelSize: Theme.font_size_body2
			}

			KeyNavigationHighlight {
				anchors.fill: parent
				active: parent.activeFocus
			}
		}
	}

	Component {
		id: momentarySwitchButton

		Button {
			function handlePress(key) { return _handleKey(key, 1) }
			function handleRelease(key) { return _handleKey(key, 0) }
			function _handleKey(key, newValue) {
				if (key === Qt.Key_Space) {
					output.setState(newValue)
					return true
				}
				return false
			}

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
			id: buttonRow

			function handlePress(key) {
				if (key === Qt.Key_Space) {
					currentIndex = currentIndex === 0 ? 1 : 0
					return true
				}
				return false
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			fontPixelSize: Theme.font_size_body2
			currentIndex: output.state === 1 ? 1 : 0
			model: [{ "value": CommonWords.off }, { "value": CommonWords.on }]
			onCurrentIndexChanged: {
				output.setState(currentIndex === 1 ? 1 : 0)
			}

			// currentIndex binding is broken when user clicks the button, so ensure value is
			// updated if backend value changes.
			Connections {
				target: output
				function onStateChanged() {
					buttonRow.currentIndex = output.state === 1 ? 1 : 0
				}
			}
		}
	}
}
