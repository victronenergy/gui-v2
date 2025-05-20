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
			sourceComponent: output.type === VenusOS.SwitchableOutput_Type_Dimmable ? dimmingComponent
					: output.type === VenusOS.SwitchableOutput_Type_Momentary ? momentaryComponent
					: output.type === VenusOS.SwitchableOutput_Type_Latching ? latchingComponent
					: null

			// Instead of giving focus to the individual controls, handle the keys directly here.
			// This is consistent with the Control Cards, which focus the overall delegates in each
			// card, rather than the controls within the delegates.
			// (The DimmingSlider is a special case; it needs to be focused individually to provide
			// an "edit" mode, so that left/right keys will move the slider instead of navigating to
			// the previous/next item in the grid.)
			focus: true
			Keys.onPressed: (event) => { event.accepted = !event.isAutoRepeat && item.handlePress !== undefined && item.handlePress(event.key) }
			Keys.onReleased: (event) => { event.accepted = item.handleRelease !== undefined && item.handleRelease(event.key) }
			Keys.enabled: Global.keyNavigationEnabled
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

			Label {
				anchors.centerIn: parent
				text: CommonWords.onOrOff(dimmingState.expectedValue)
				font.pixelSize: Theme.font_size_body2
			}

			KeyNavigationHighlight {
				anchors.fill: parent
				active: parent.activeFocus
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
		id: latchingComponent

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
				if (newValue !== latchingState.backendValue) {
					currentIndex = index
					latchingState.writeValue(newValue)
				}
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			fontPixelSize: Theme.font_size_body2
			model: [{ "value": CommonWords.off }, { "value": CommonWords.on }]
			enabled: !latchingState.busy
			onButtonClicked: (buttonIndex) => {
				activateIndex(buttonIndex)
			}

			SettingSync {
				id: latchingState
				backendValue: output.state
				onUpdateToBackend: (value) => { output.setState(value) }
				onBackendValueChanged: buttonRow.currentIndex = backendValue === 1 ? 1 : 0
				Component.onCompleted: buttonRow.currentIndex = backendValue === 1 ? 1 : 0
			}
		}
	}
}
