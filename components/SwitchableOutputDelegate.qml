/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import QtQuick.Layouts
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

		RowLayout {
			anchors {
				left: switchWidgetLoader.left
				right: switchWidgetLoader.right
			}

			Label {
				id: nameLabel
				Layout.fillWidth: true
				bottomPadding: Theme.geometry_switchableoutput_label_margin
				rightPadding: Theme.geometry_switchableoutput_label_margin
				text: output.formattedName
				elide: Text.ElideMiddle // don't elide right, as it may obscure a trailing channel id
			}

			Label {
				id: secondaryTitleLabel
				bottomPadding: Theme.geometry_switchableoutput_label_margin
				text: switchWidgetLoader.item?.secondaryTitle ?? ""
			}

			Rectangle {
				id: statusRect

				Layout.bottomMargin: Theme.geometry_switchableoutput_label_margin
				Layout.maximumWidth: parent.width / 2
				Layout.minimumWidth: statusLabel.implicitWidth
				Layout.alignment: Qt.AlignRight
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

					anchors.centerIn: parent
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

				TextMetrics {
					id: nameTextMetrics
					font: nameLabel.font
					text: nameLabel.text
				}
				TextMetrics {
					id: secondaryTitleTextMetrics
					font: secondaryTitleLabel.font
					text: secondaryTitleLabel.text
				}
				TextMetrics {
					id: statusTextMetrics
					font: statusLabel.font
					text: statusLabel.text
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
				case VenusOS.SwitchableOutput_Type_NumericInput:
					return numericInputComponent
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

		// This container is used to separate the slider control from the on/off button, so that
		// their enabled states can be controlled independently.
		FocusScope {
			id: dimmingSliderContainer

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
				}
				return false
			}

			function _toggleState() {
				dimmingState.writeValue(output.state === 0 ? 1 : 0)
			}

			width: root._buttonWidth
			height: dimmingSlider.height

			// Continue to show the key navigation highlight when the slider is disabled (due to the
			// slider being in the off state).
			KeyNavigationHighlight.fill: dimmingSliderContainer
			KeyNavigationHighlight.active: dimmingSliderContainer.activeFocus && !dimmingSlider.activeFocus

			Keys.onPressed: (event) => {
				switch (event.key) {
				case Qt.Key_Return:
				case Qt.Key_Enter:
				case Qt.Key_Escape:
					focus = false
					event.accepted = true
					return
				case Qt.Key_Up:
				case Qt.Key_Down:
				case Qt.Key_Left:
				case Qt.Key_Right:
					// When button is 'off', the dimmingSlider is disabled and does not receive
					// events, so accept them here to prevent navigation to other grid delegates.
					event.accepted = true
					return
				}
				event.accepted = false
			}

			SwitchableOutputSlider {
				id: dimmingSlider

				// True when the On/Off button and the slider are both controllable.
				readonly property bool controlIsEnabled: dimmingSliderContainer.enabled

				// True when the On/Off button text is "On", i.e. the slider should be controllable.
				readonly property bool sliderIsEnabled: dimmingState.expectedValue === 1 || dragging

				width: parent.width
				switchableOutput: output
				leftPadding: dimmingToggleButton.width
				enabled: sliderIsEnabled
				highlightColor: controlIsEnabled
					? (sliderIsEnabled ? Theme.color_ok : Theme.color_button_off_background)
					: (sliderIsEnabled ? Theme.color_button_on_background_disabled : Theme.color_button_off_background_disabled)
				backgroundColor: controlIsEnabled ? Theme.color_darkOk : Theme.color_background_disabled
				borderColor: controlIsEnabled ? Theme.color_ok : Theme.color_font_disabled
				focus: true
				KeyNavigationHighlight.fill: dimmingSliderContainer
			}

			MiniToggleButton {
				id: dimmingToggleButton

				checked: dimmingState.expectedValue === 1
				onClicked: dimmingSliderContainer._toggleState()

				Rectangle {
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.geometry_miniSlider_separator_width
					height: parent.height - (Theme.geometry_miniSlider_decorator_vertical_padding * 2)
					radius: Theme.geometry_miniSlider_separator_width / 2
					color: enabled ? Theme.color_slider_separator : Theme.color_font_disabled
				}

				SettingSync {
					id: dimmingState
					backendValue: output.state
					onUpdateToBackend: (value) => { output.setState(value) }
				}
			}
		}
	}

	Component {
		id: momentaryComponent

		MomentaryButton {
			id: momentaryButton

			function handlePress(key) {
				if (key === Qt.Key_Space) {
					momentaryState.writeValue(1)
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
			height: Theme.geometry_switchableoutput_control_height

			// Show as checked, when pressing or backend indicates it is pressed
			checked: momentaryState.expectedValue === 1
				// Or when waiting for a release to be synced, else the button text flickers between
				// "On" and "Pressed" on Wasm when there is a delay between release and sync.
				|| momentaryState.busy

			// Only show the press effect when the backend has written the state succesfully.
			pressEffectRunning: momentaryState.backendValue === 1

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
			height: Theme.geometry_switchableoutput_control_height
			on: toggleState.expectedValue === 1

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
		height: Theme.geometry_switchableoutput_control_height
		color: Theme.color_button_off_background

		Label {
			anchors.centerIn: parent
			text: "Placeholder"
		}
	}

	Component {
		id: temperatureSetpointComponent

		TemperatureSlider {
			id: temperatureSlider

			readonly property string secondaryTitle: value.toFixed(stepSizeDecimalCount) + Global.systemSettings.temperatureUnitSuffix

			function handlePress(key) {
				switch (key) {
				case Qt.Key_Space:
					focus = true
					return true
				default:
					return false
				}
			}

			width: root._buttonWidth
			switchableOutput: output

			Keys.onPressed: (event) => {
				switch (event.key) {
				case Qt.Key_Return:
				case Qt.Key_Enter:
				case Qt.Key_Escape:
					focus = false
					event.accepted = true
					return
				}
				event.accepted = false
			}
		}
	}

	Component {
		id: steppedSwitchComponent

		MultiStepButton {
			id: multiStep

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

			function generateModel() {
				if (multiStepMax.value === undefined) {
					multiStep.model = []
				} else {
					let items = []
					// limit maximum number of options
					let totalOptions = Math.min(7, multiStepMax.value)
					for (let i = 0; i < totalOptions; i++) {
						items.push({ 'text': i + 1 })   // options are 1-based
					}
					multiStep.model = items
				}
			}

			width: root._buttonWidth
			height: Theme.geometry_switchableoutput_control_height
			checked: multiStepState.backendValue
			onOnClicked: multiStepState.writeValue(1)
			onOffClicked: multiStepState.writeValue(0)

			// Get/set the current index. Note Dimming and DimmingMax are 1-based. E.g. if Dimming=1
			// and DimmingMax=5, the options are 1-5 inclusive, and the first option is selected.
			currentIndex: output.hasDimming ? output.dimming - 1 : -1
			onIndexClicked: (index) => { output.setDimming(index + 1) }

			Connections {
				target: output
				function onDimmingChanged() {
					multiStep.currentIndex = output.hasDimming ? output.dimming - 1 : -1
				}
			}

			// The /DimmingMax holds the maximum value.
			VeQuickItem {
				id: multiStepMax
				uid: root.outputUid + "/Settings/DimmingMax"
				onValueChanged: multiStep.generateModel()
			}

			SettingSync {
				id: multiStepState
				backendValue: output.state
				onUpdateToBackend: (value) => { output.setState(value) }
			}
		}
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

				function syncValueToDropdown() {
					if (backendValue >= 0 && backendValue < dropdown.count) {
						dropdown.currentIndex = Math.floor(backendValue)
					}
				}

				backendValue: dropdownSelection.value
				onUpdateToBackend: (value) => { dropdownSelection.setValue(Math.floor(value)) }
				onBackendValueChanged: syncValueToDropdown()
				onTimeout: syncValueToDropdown()
			}

			VeQuickItem {
				uid: root.outputUid + "/Settings/Labels"
				onValueChanged: {
					if (value === undefined) {
						dropdown.model = []
					} else {
						const labelsJson = JSON.parse(value)
						let items = []
						if (labelsJson) {
							for (const key in labelsJson) {
								items.push({ text: labelsJson[key] })
							}
						} else {
							console.warn("Unable to parse dropdown labels at:", uid, "from value:", value)
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

		SwitchableOutputSlider {
			id: basicSlider

			readonly property string secondaryTitle: value.toFixed(stepSizeDecimalCount) + (basicSliderUnitItem.value || "")

			function handlePress(key) {
				switch (key) {
				case Qt.Key_Space:
					if (!activeFocus) {
						focus = true
						return true
					}
					break
				}
				return false
			}

			width: root._buttonWidth
			switchableOutput: output

			Keys.onPressed: (event) => {
				switch (event.key) {
				case Qt.Key_Return:
				case Qt.Key_Enter:
				case Qt.Key_Escape:
					focus = false
					event.accepted = true
					return
				}
				event.accepted = false
			}

			VeQuickItem {
				id: basicSliderUnitItem
				uid: root.outputUid + "/Settings/Unit"
			}
		}
	}

	Component {
		id: numericInputComponent

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
			height: Theme.geometry_switchableoutput_control_height
			editable: !Global.isGxDevice // no room for VKB in the switch pane
			suffix: numericInputUnit.value ?? ""
			from: decimalConverter.intFrom
			to: decimalConverter.intTo
			stepSize: decimalConverter.intStepSize
			value: decimalConverter.decimalToInt(numericInputValueSync.backendValue)
			textFromValue: (value, locale) => decimalConverter.textFromValue(value)
			valueFromText: (text, locale) => {
				const v = decimalConverter.valueFromText(text)
				return isNaN(v) ? decimalConverter.decimalToInt(numericInputValueSync.backendValue) : v
			}
			onValueModified: {
				// Update the /Dimming value to the user-entered value.
				numericInputValueSync.writeValue(decimalConverter.intToDecimal(value))
			}

			VeQuickItem {
				id: numericInputMin
				uid: root.outputUid + "/Settings/DimmingMin"
			}
			VeQuickItem {
				id: numericInputMax
				uid: root.outputUid + "/Settings/DimmingMax"
			}
			VeQuickItem {
				id: numericInputStepSize
				readonly property int decimalCount: valid ? value.toString().split(".")[1]?.length ?? 0 : 0
				uid: root.outputUid + "/Settings/StepSize"
			}
			VeQuickItem {
				id: numericInputUnit
				uid: root.outputUid + "/Settings/Unit"
			}

			SpinBoxDecimalConverter {
				id: decimalConverter

				decimals: numericInputStepSize.decimalCount
				from: numericInputMin.valid ? numericInputMin.value : 0
				to: numericInputMax.valid ? numericInputMax.value : 100
				stepSize: numericInputStepSize.valid ? numericInputStepSize.value : 1
			}

			SettingSync {
				id: numericInputValueSync
				backendValue: output.dimming
				onUpdateToBackend: (value) => { output.setDimming(value) }
				onTimeout: spinBox.value = decimalConverter.decimalToInt(backendValue)
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

			height: Theme.geometry_switchableoutput_control_height
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
