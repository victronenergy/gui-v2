/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS
import QtQuick.Templates as CT

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
					if (activeFocus) {
						// Prevent key navigation to other grid delegates while in edit mode.
						return true
					}
					break
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
			from: dimmingMin.valid ? dimmingMin.value : 0
			to: dimmingMax.valid ? dimmingMax.value : 100
			stepSize: 1
			state: dimmingState.expectedValue

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

			VeQuickItem {
				id: dimmingMax
				uid: root.outputUid + "/Settings/DimmingMax"
			}
			VeQuickItem {
				id: dimmingMin
				uid: root.outputUid + "/Settings/DimmingMin"
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

		MomentaryButton {
			id: momentaryButton

			function handlePress(key) {
				if (key === Qt.Key_Space) {
					// Write state=1 (on) if no other write is in progress.
					if (!momentaryState.busy) {
						momentaryState.writeValue(1)
					}
					return true
				}
				return false
			}
			function handleRelease(key) {
				if (key === Qt.Key_Space) {
					// If writing state=0 (off), then allow it even if a previous state=1 (on) write
					// is in progress; the state=0 change will be queued on the backend.
					if (!momentaryState.busy || momentaryState.expectedValue !== 0) {
						momentaryState.writeValue(0)
					}
					return true
				}
				return false
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height

			// Disable if a write is in progress, unless expecting mouse/key release.
			enabled: !momentaryState.busy || momentaryState.expectedValue === 1

			// Show as checked, when pressing or backend indicates it is pressed
			checked: momentaryState.expectedValue === 1
				// Or when waiting for a release to be synced, else the button text flickers between
				// "On" and "Pressed" on Wasm when there is a delay between release and sync.
				|| momentaryState.busy

			// Do not give focus to the control when clicked/tabbed, as it has no edit mode.
			focusPolicy: Qt.NoFocus

			onPressed: momentaryState.writeValue(1)
			onReleased: momentaryState.writeValue(0)
			onCanceled: momentaryState.writeValue(0)

			SettingSync {
				id: momentaryState
				backendValue: output.state
				onUpdateToBackend: (value) => { output.setState(value) }
			}
		}
	}

	Component {
		id: toggleComponent

		ToggleButtonRow {
			id: toggleButtonRow

			function handlePress(key) {
				if (key === Qt.Key_Space && enabled) {
					toggleState.writeValue(toggleState.backendValue === 1 ? 0 : 1)
					return true
				}
				return false
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			on: toggleState.expectedValue === 1
			enabled: !toggleState.busy

			// Do not focus the internal buttons when clicked, as this control has no edit mode.
			focusPolicy: Qt.NoFocus

			onOnClicked: toggleState.writeValue(1)
			onOffClicked: toggleState.writeValue(0)

			SettingSync {
				id: toggleState
				backendValue: output.state
				onUpdateToBackend: (value) => { output.setState(value) }
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

		ComboBox {
			id: dropdown

			function handlePress(key) {
				// Enter edit mode (i.e. allow ComboBox to handle key events) when space is pressed.
				switch (key) {
				case Qt.Key_Space:
					focus = true
					return true
				default:
					return false
				}
			}

			width: root._buttonWidth
			enabled: !dropdownSync.busy
			onActivated: (index) => dropdownSync.writeValue(index)

			// Process key events in edit mode.
			Keys.onPressed: (event) => {
				switch (event.key) {
				case Qt.Key_Enter:
				case Qt.Key_Return:
					// Save highlighted index as the currentIndex, and exit edit mode.
					if (highlightedIndex >= 0 && highlightedIndex < count) {
						currentIndex = highlightedIndex
						activated(highlightedIndex)
					}
					focus = false
					event.accepted = true
					return
				case Qt.Key_Escape:
					// Exit edit mode. If the popup was open, it will be closed without changing the
					// current index.
					focus = false
					event.accepted = true
					return
				case Qt.Key_Left:
				case Qt.Key_Right:
					// When in edit mode, prevent left/right from moving focus to another item in
					// the grid view.
					event.accepted = true
					return
				default:
					break
				}
				event.accepted = false
			}

			SettingSync {
				id: dropdownSync
				backendValue: dropdownSelection.value
				onUpdateToBackend: (value) => { dropdownSelection.setValue(Math.floor(value)) }
				onBackendValueChanged: {
					if (backendValue >= 0 && backendValue < dropdown.count) {
						dropdown.currentIndex = Math.floor(backendValue)
					}
				}
			}

			VeQuickItem {
				uid: root.outputUid + "/Settings/Labels"
				onValueChanged: {
					if (value === undefined) {
						dropdown.model = []
					} else {
						let items = []
						for (const key in value) {
							items.push({ text: value[key] })
						}
						dropdown.model = items
						dropdown.currentIndex = Math.floor(dropdownSync.backendValue)
					}
				}
			}

			// The /DimmingValue holds the selected dropdwon index.
			VeQuickItem {
				id: dropdownSelection
				uid: root.outputUid + "/Dimming"
			}
		}
	}

	Component {
		id: basicSliderComponent

		PlaceholderDelegate {}
	}

	Component {
		id: unrangedSetpointComponent

		MiniSpinBox {
			id: spinBox

			function handlePress(key) {
				// Enter edit mode when space is pressed.
				switch (key) {
				case Qt.Key_Space:
					focus = true
					return true
				default:
					return false
				}
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_button_height
			enabled: !unrangedValueSync.busy
			editable: !Global.isGxDevice // no room for VKB in the switch pane
			suffix: unrangedUnit.value ?? ""
			from: decimalConverter.intFrom
			to: decimalConverter.intTo
			stepSize: decimalConverter.intStepSize
			value: decimalConverter.decimalToInt(unrangedValueSync.backendValue)
			textFromValue: (value, locale) => decimalConverter.textFromValue(value)
			valueFromText: (text, locale) => {
				const v = decimalConverter.valueFromText(text)
				return isNaN(v) ? decimalConverter.decimalToInt(unrangedValueSync.backendValue) : v
			}
			onValueModified: {
				// Update the /Dimming value to the user-entered value.
				unrangedValueSync.writeValue(decimalConverter.intToDecimal(value))
			}

			VeQuickItem {
				id: unrangedMin
				uid: root.outputUid + "/Settings/DimmingMin"
			}
			VeQuickItem {
				id: unrangedMax
				uid: root.outputUid + "/Settings/DimmingMax"
			}
			VeQuickItem {
				id: unrangedStepSize
				uid: root.outputUid + "/Settings/StepSize"
			}
			VeQuickItem {
				id: unrangedUnit
				uid: root.outputUid + "/Settings/Unit"
			}

			SpinBoxDecimalConverter {
				id: decimalConverter

				decimals: 2
				from: unrangedMin.valid ? unrangedMin.value : 0
				to: unrangedMax.valid ? unrangedMax.value : 100
				stepSize: unrangedStepSize.valid ? unrangedStepSize.value : 1
			}

			SettingSync {
				id: unrangedValueSync
				backendValue: output.dimming
				onUpdateToBackend: (value) => { output.setDimming(value) }
			}
		}
	}

	Component {
		id: threeStateSwitchComponent

		AutoToggleButton {
			id: autoToggleButton

			function handlePress(key) {
				switch (key) {
				case Qt.Key_Space:
					focus = true
					return true
				}
				return false
			}

			height: Theme.geometry_switchableoutput_button_height
			width: root._buttonWidth
			enabled: !toggleState.busy || !autoToggleState.busy
			onChecked: toggleState.backendValue === 1
			autoChecked: autoToggleState.backendValue
			onOnClicked: toggleState.writeValue(1)
			onOffClicked: toggleState.writeValue(0)
			onAutoClicked: autoToggleState.writeValue(autoToggleState.backendValue === 1 ? 0 : 1)

			SettingSync {
				id: autoToggleState
				backendValue: autoState.value
				onUpdateToBackend: (value) => { autoState.setValue(value) }
			}

			VeQuickItem {
				id: autoState
				uid: root.outputUid + "/Auto"
			}

			SettingSync {
				id: toggleState
				backendValue: output.state
				onUpdateToBackend: (value) => { output.setState(value) }
			}
		}
	}
}
