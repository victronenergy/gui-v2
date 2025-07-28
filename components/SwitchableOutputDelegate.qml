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
			enabled: output.status !== VenusOS.SwitchableOutput_Status_Disabled
			sourceComponent: {
				switch (output.type) {
				case VenusOS.SwitchableOutput_Type_Momentary:
					return momentaryComponent
				case VenusOS.SwitchableOutput_Type_Toggle:
					return toggleComponent
				case VenusOS.SwitchableOutput_Type_Dimmable:
					return dimmingComponent
				case VenusOS.SwitchableOutput_Type_TemperatureSetpoint:
					return temperatureSetpointComponent
				case VenusOS.SwitchableOutput_Type_SteppedSwitch:
					return steppedSwitchComponent
				case VenusOS.SwitchableOutput_Type_Dropdown:
					return dropdownComponent
				case VenusOS.SwitchableOutput_Type_BasicSlider:
					return basicSliderComponent
				case VenusOS.SwitchableOutput_Type_UnrangedSetpoint:
					return unrangedSetpointComponent
				case VenusOS.SwitchableOutput_Type_ThreeStateSwitch:
					return threeStateSwitchComponent
				default:
					return null
				}
			}

			// For simple controls without internal arrow key handling (e.g. momentary/latching
			// controls, which only respond to the space key), focus the overall control and just
			// call handlePress() and handleRelease() to trigger its features. This is consistent
			// with the Control Cards, which focus the overall delegates in each card, rather than
			// the controls within the delegates.
			//
			// For controls that require internaly arrow key handling (e.g. a slider with left/right
			// triggers to move the handle), they need to have an "edit" mode, where:
			//  - the space key enters edit mode by setting focus=true on the control; while in this
			//    mode, the control handles all key events.
			//  - the return key exits edit mode by setting focus=false, thus returning focus to
			//    the overall delegate, so that arrow keys can once again navigate to previous/next
			//    items in the switch pane grid.
			focus: true
			Keys.onPressed: (event) => { event.accepted = !event.isAutoRepeat && item.handlePress !== undefined && item.handlePress(event.key) }
			Keys.onReleased: (event) => { event.accepted = item.handleRelease !== undefined && item.handleRelease(event.key) }
			Keys.enabled: Global.keyNavigationEnabled

			// Hide the delegate highlight when the loader item is showing its own highlight (i.e. if
			// showing a DimmingSlider in edit mode).
			KeyNavigationHighlight.active: switchWidgetLoader.activeFocus && !switchWidgetLoader.item?.activeFocus
			KeyNavigationHighlight.fill: root
		}
	}

	Component {
		id: dimmingComponent

		DimmingSlider {
			id: slider

			property bool valueChangeKeyPressed
			readonly property bool dragging: pressed || valueChangeKeyPressed

			// When space key is pressed, enter an "edit" (i.e. focused) mode where the space key
			// toggles the on/off state and left/right keys move the slider.
			// When return key is pressed, exit the edit mode.
			function handlePress(key) {
				switch (key) {
				case Qt.Key_Space:
					if (activeFocus) {
						_toggleState()
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

			function _toggleState() {
				if (!dimmingState.busy) {
					dimmingState.writeValue(output.state === 0 ? 1 : 0)
				}
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			highlightColor: enabled
				? (dimmingState.expectedValue === 1 ? Theme.color_ok : Theme.color_button_down)
				: Theme.color_font_disabled
			from: 1
			to: 100
			stepSize: 1

			// On the MQTT backend, many consecutive changes can create a huge queue of backend
			// changes. Avoid this by preventing changes until the backend is in sync.
			enabled: !dimmingValue.busy || dragging

			onDraggingChanged: {
				if (!dragging) {
					dimmingValue.syncBackendValueToSlider()
				}
			}
			onClicked: {
				_toggleState()
			}
			onMoved: {
				value = Math.round(value)
				dimmingValue.writeValue(value)
			}

			Keys.onPressed: (event) => {
				if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
					valueChangeKeyPressed = true
				}
				event.accepted = false
			}
			Keys.onReleased: (event) => {
				if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
					valueChangeKeyPressed = false
				}
				event.accepted = false
			}
			KeyNavigationHighlight.active: slider.activeFocus

			Label {
				anchors.centerIn: parent
				text: CommonWords.onOrOff(dimmingState.expectedValue)
				font.pixelSize: Theme.font_size_body2
			}

			SettingSync {
				id: dimmingState
				backendValue: output.state
				onUpdateToBackend: (value) => { output.setState(value) }
			}

			SettingSync {
				id: dimmingValue

				// Update the slider value to the backend value.
				function syncBackendValueToSlider() {
					// If user has interacted with the slider to change the value, delay briefly
					// before syncing the slider to the backend value, else this may be done while
					// user changes are still being written.
					if (busy || slider.dragging || delayedSliderUpdate.running) {
						delayedSliderUpdate.restart()
					} else {
						slider.value = backendValue
					}
				}

				backendValue: output.dimming
				onUpdateToBackend: (value) => { output.setDimming(value) }
				onBackendValueChanged: syncBackendValueToSlider()
				onBusyChanged: if (!busy) syncBackendValueToSlider()
			}

			Timer {
				id: delayedSliderUpdate
				interval: 1000
				onTriggered: dimmingValue.syncBackendValueToSlider()
			}
		}
	}

	Component {
		id: momentaryComponent

		Button {
			id: momentaryButton

			property bool spaceKeyPressed

			function handlePress(key) { return _handleKey(key, 1) }
			function handleRelease(key) { return _handleKey(key, 0) }
			function _handleKey(key, newValue) {
				if (key === Qt.Key_Space) {
					spaceKeyPressed = newValue === 1
					if (enabled) {
						momentaryState.writeValue(newValue)
						return true
					}
				}
				return false
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			font.pixelSize: Theme.font_size_body2
			//% "Press"
			text: qsTrId("switchable_output_press")
			flat: false

			// Disable if a write is in progress, unless expecting mouse/key release.
			enabled: !momentaryState.busy || pressed || spaceKeyPressed

			onPressed: momentaryState.writeValue(1)
			onReleased: momentaryState.writeValue(0)
			onCanceled: momentaryState.writeValue(0)

			// When UI is idle, update the button to reflect the backend state.
			Binding {
				when: !momentaryState.busy && !momentaryButton.pressed && !momentaryButton.spaceKeyPressed
				momentaryButton.checked: momentaryState.backendValue === 1
			}

			SettingSync {
				id: momentaryState
				backendValue: output.state
				onUpdateToBackend: (value) => { output.setState(value) }
			}
		}
	}

	Component {
		id: toggleComponent

		SegmentedButtonRow {
			id: buttonRow

			function handlePress(key) {
				if (key === Qt.Key_Space && enabled) {
					// Toggle the currentIndex between 0 and 1.
					activateIndex(currentIndex === 0 ? 1 : 0)
					return true
				}
				return false
			}

			function activateIndex(index) {
				const newValue = index === 1 ? 1 : 0
				if (newValue !== toggleState.backendValue) {
					currentIndex = index
					toggleState.writeValue(newValue)
				}
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			fontPixelSize: Theme.font_size_body1
			model: [{ "value": CommonWords.off, "selectedBackgroundColor": Theme.color_button_off_background },
				{ "value": CommonWords.on, "selectedBackgroundColor": Theme.color_button_on_background }]
			enabled: !toggleState.busy
			onButtonClicked: (buttonIndex) => {
				activateIndex(buttonIndex)
			}

			SettingSync {
				id: toggleState
				backendValue: output.state
				onUpdateToBackend: (value) => { output.setState(value) }
				onBackendValueChanged: buttonRow.currentIndex = backendValue === 1 ? 1 : 0
				Component.onCompleted: buttonRow.currentIndex = backendValue === 1 ? 1 : 0
			}
		}
	}

	// TODO remove this type when all controls are implemented.
	component PlaceholderDelegate : Rectangle {
		width: root._buttonWidth
		height: Theme.geometry_switchableoutput_button_height
		color: Theme.color_button_off_background

		Label {
			anchors.centerIn: parent
			text: "Placeholder"
		}
	}

	Component {
		id: temperatureSetpointComponent

		PlaceholderDelegate {}
	}

	Component {
		id: steppedSwitchComponent

		PlaceholderDelegate {}
	}

	Component {
		id: dropdownComponent

		PlaceholderDelegate {}
	}

	Component {
		id: basicSliderComponent

		PlaceholderDelegate {}
	}

	Component {
		id: unrangedSetpointComponent

		PlaceholderDelegate {}
	}

	Component {
		id: threeStateSwitchComponent

		PlaceholderDelegate {}
	}
}
