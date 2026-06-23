/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A single Bluetooth sensor in the Bluetooth Sensors settings list.

	An ordinary sensor is shown as an enable switch. An encrypted Instant Readout device (one that
	exposes a Devices/<id>/Key path) cannot be enabled until its encryption key is known, so while
	such a device is disabled an encryption key field is shown instead of the switch. Entering a
	valid key writes the key and enables the device; if the key is wrong, the backend disables the
	device again.

	The key field and the enable switch are never shown at the same time: the field is the only
	control while an encrypted device is disabled, and accepting a complete key (Enter, or moving
	focus away) enables the device and replaces the field with the switch. Switching the device off
	again brings the field back, focused and holding the stored key, so that it can be switched back
	on with a single Enter.

	A device whose stored key is already complete is enabled as soon as this delegate learns its
	state, so that it comes up switched on rather than showing a key field for a key that is already
	known. Note that this applies every time the delegate is created, not only at application
	startup: a device switched off here is switched on again by the next visit to this page.

	A loader swaps between the two standard list items as the device's state changes, so neither
	has to emulate the other. It must be a ListItemLoader rather than a plain Loader: a plain
	Loader leaves focusPolicy at Qt.NoFocus, so Utils.acceptsKeyNavigation() rejects it and the
	row would be skipped by key navigation.
*/
ListItemLoader {
	id: root

	// The device's dbus/mqtt path prefix, e.g. ".../Devices/xxxxxx_xxxxxxx".
	required property string devicePrefix
	required property string deviceName

	// Encrypted Instant Readout devices expose a Devices/<id>/Key path; such a device is enabled
	// by entering a valid key rather than via a switch.
	readonly property bool keyRequired: keyItem.seen
	readonly property bool deviceEnabled: enabledItem.value === 1

	// The key currently stored for the device, if any. Shown in the key field so that a key which
	// was rejected (or is simply out of date) can be corrected rather than retyped in full.
	readonly property string storedKey: keyItem.valid ? keyItem.value : ""

	// An enable attempt for an encrypted device runs in two stages, each tracked by its timer.
	// First the /Enabled=1 write has to be acknowledged by the backend - on dbus/mqtt the write is
	// asynchronous, so this is not immediate (enableAckTimer). Only once it has been acknowledged
	// does Enabled returning to 0 mean that the backend rejected the key (validationTimer);
	// before that, a 0 is simply the state we have not overwritten yet.
	readonly property bool enableAttemptInFlight: enableAckTimer.running || validationTimer.running

	// Set when the user switches an encrypted device off, so that the key field which replaces the
	// switch takes the focus as it loads: switching the device off is a step towards changing or
	// re-submitting its key, so the field is where the user is going next. Consumed by the field,
	// so that the focus is only taken on the load that this disable caused.
	property bool focusKeyFieldOnLoad: false

	function takeFocusRequest() {
		const requested = focusKeyFieldOnLoad
		focusKeyFieldOnLoad = false
		return requested
	}

	// Whether the initial state has been dealt with. Set as soon as the device's state is known,
	// whether or not it led to the device being enabled, so that this remains a one-shot: without
	// it, switching a device off would immediately re-enable it, as its stored key is still
	// complete.
	property bool initialStateApplied: false

	// A stored key that is already complete is all that gates an encrypted device, so enable the
	// device rather than presenting a key field for a key the user has no reason to re-enter.
	// The stored key and the enabled state arrive asynchronously (and on dbus/mqtt not at all
	// promptly), so this cannot simply run when the delegate is created; it is driven by the state
	// changing instead, and runs on the first update in which the state is known.
	function applyInitialState() {
		if (initialStateApplied || !enabledItem.valid) {
			// Already done, or the enabled state is not known yet.
			return
		}
		if (!keyRequired || !keyItem.valid) {
			// Either the key path has not been seen yet - the device may still turn out to be an
			// encrypted one - or it has, but its stored key has not arrived. Note that an ordinary
			// device therefore never settles here, which is harmless: it has no key to act on.
			return
		}
		initialStateApplied = true
		if (!deviceEnabled && keyIsComplete(storedKey)) {
			enableWithKey(storedKey)
		}
	}

	function keyIsComplete(key) {
		return /^[0-9a-fA-F]{32}$/.test(key)
	}

	// Save the key, then enable the device. The backend validates the key and, if it is wrong,
	// disables the device again (see the enabledItem Connections). Deferred via Qt.callLater so it
	// is safe to call from the key field's own signal handlers - enabling swaps the field out from
	// under them.
	function enableWithKey(key) {
		if (enableAttemptInFlight || deviceEnabled) {
			// An attempt is already in flight. On dbus/mqtt the writes are asynchronous, so the key
			// field is still shown while we wait and could otherwise submit a second, interleaved
			// attempt.
			return
		}
		enableAckTimer.restart()
		keyItem.setValue(key)
		enabledItem.setValue(1)
	}

	function disable() {
		// Stop tracking first, so that the resulting Enabled -> 0 is not mistaken for the backend
		// rejecting a key.
		abandonEnableAttempt()
		// Only an encrypted device swaps in a key field to focus; an ordinary device keeps its
		// switch, and moving the focus off it would be wrong.
		focusKeyFieldOnLoad = keyRequired
		// The user has made an explicit choice, which the initial-state handling must not undo if
		// it has not run by now (it normally has, since the device was enabled to be switched off).
		initialStateApplied = true
		enabledItem.setValue(0)
	}

	function abandonEnableAttempt() {
		enableAckTimer.stop()
		validationTimer.stop()
	}

	// Width is set, height is left to follow the loaded list item's implicit height.
	width: parent ? parent.width : 0

	// Show the key field while an encrypted device is disabled; otherwise (an ordinary device, or
	// an enabled encrypted one) show the enable switch.
	sourceComponent: (keyRequired && !deviceEnabled) ? keyFieldComponent : switchComponent

	Component.onCompleted: applyInitialState()
	onStoredKeyChanged: applyInitialState()
	onKeyRequiredChanged: applyInitialState()
	onDeviceEnabledChanged: applyInitialState()

	VeQuickItem {
		id: enabledItem
		uid: root.devicePrefix + "/Enabled"
	}
	VeQuickItem {
		id: keyItem
		uid: root.devicePrefix + "/Key"
	}

	// Track the enable attempt, and detect the backend rejecting an entered key: Enabled dropping
	// back to 0 after it acknowledged our Enabled=1, without the user having disabled the device.
	Connections {
		target: enabledItem
		// A device that arrives already disabled leaves deviceEnabled at false, so its arrival is
		// only visible as the item becoming valid.
		function onValidChanged() {
			root.applyInitialState()
		}
		function onValueChanged() {
			if (enabledItem.value === 1) {
				if (enableAckTimer.running) {
					// The write landed. From here on, a return to 0 means the backend rejected the key.
					enableAckTimer.stop()
					validationTimer.restart()
				}
				return
			}
			// Enabled is now 0, or the item became invalid because the service dropped out. Only
			// the former, and only while awaiting a validation result, means a rejected key: an
			// invalid item cannot be tracked, and the Enabled=0 that the service republishes when
			// it comes back must not be reported as a bad key either.
			if (enabledItem.value === 0 && validationTimer.running) {
				//% "The submitted encryption key is invalid."
				Global.showToastNotification(VenusOS.Notification_Warning,
						qsTrId("settings_ble_sensors_encryption_key_rejected"), 5000)
			}
			root.abandonEnableAttempt()
		}
	}

	// The Enabled=1 write is asynchronous on dbus/mqtt. If the backend never echoes it back,
	// abandon the attempt rather than waiting for a validation result that can no longer arrive.
	Timer {
		id: enableAckTimer
		interval: 10000
		onTriggered: root.abandonEnableAttempt()
	}

	// Started only once the backend has acknowledged Enabled=1, so that a slow round-trip cannot
	// eat into the window. If the device is still enabled when this elapses, assume the key was
	// accepted; a rejection is expected to disable the device before then (observed to take ~15
	// seconds).
	Timer {
		id: validationTimer
		interval: 30000
	}

	Component {
		id: switchComponent

		ListSwitch {
			text: root.deviceName
			dataItem.uid: root.devicePrefix + "/Enabled"
			// An ordinary device toggles Enabled directly. An encrypted device only shows the
			// switch while enabled, so clicking it disables the device (routed through disable()
			// to keep the delegate's state in sync).
			updateDataOnClick: !root.keyRequired
			onClicked: {
				if (root.keyRequired) {
					root.disable()
				}
			}
		}
	}

	Component {
		id: keyFieldComponent

		ListTextField {
			id: keyField

			readonly property bool portrait: Theme.screenSize === Theme.Portrait

			function focusKeyField() { contentItem.forceInputFocus() }

			// Take the focus when this field replaces the switch of a device the user just
			// switched off. Deferred, because at this point the loader has not yet given the item
			// a window to take focus in.
			Component.onCompleted: {
				if (root.takeFocusRequest()) {
					Qt.callLater(focusKeyField)
				}
			}

			text: root.deviceName
			// Start from the key that is currently stored for the device, so that a key which the
			// backend rejected can be corrected instead of retyped; empty if none is stored yet.
			// The binding is broken by the first edit, as in ListTextField itself, so a
			// late-arriving /Key value cannot overwrite what the user is typing.
			secondaryText: root.storedKey
			// Note the absence of a dataItem.uid here: the key is written via the delegate's
			// keyItem. Pointing dataItem at /Key would make the default 'interactive' binding
			// (which requires dataItem.valid) disable the field whenever the path has been seen
			// but holds no valid value yet - i.e. exactly when a key still has to be entered.
			// Instead, lock the field while an enable attempt is in flight, so a slow dbus/mqtt
			// round-trip cannot queue a second attempt, and so the field cannot appear
			// editable-but-inert if the device drops back to disabled while we are still awaiting
			// a validation result.
			interactive: !root.enableAttemptInFlight
			maximumLength: 32
			inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
			//% "Enter a 32-character key"
			placeholderText: qsTrId("settings_ble_sensors_encryption_key_placeholder")
			validateInput: function() {
				if (secondaryText.length === 0 || root.keyIsComplete(secondaryText)) {
					return Utils.validationResult(VenusOS.InputValidation_Result_OK)
				}
				//% "The encryption key must be 32 hexadecimal characters."
				return Utils.validationResult(VenusOS.InputValidation_Result_Error,
						qsTrId("settings_ble_sensors_encryption_key_invalid"))
			}
			// A valid key is submitted when the input is accepted (Enter) or focus is lost.
			// Enabling swaps this field out for the switch, so defer the write until this handler
			// has returned.
			saveInput: function() {
				if (root.keyIsComplete(secondaryText)) {
					Qt.callLater(root.enableWithKey, secondaryText)
				}
			}

			// Landscape: device name, then the "Encryption key" label immediately before the entry
			// box, instead of a caption on its own row. In portrait the row is too long for that,
			// so the name keeps the first row and the caption and entry box drop to a second one.
			// Grid positions are therefore assigned explicitly: the two orientations need the
			// items in a different order.
			contentItem: GridLayout {
				// Called by ListTextField's Keys.onSpacePressed, to focus the entry box.
				function forceInputFocus() { keyTextField.forceInputFocus() }

				columns: keyField.portrait ? 2 : 3
				columnSpacing: keyField.spacing
				rowSpacing: 0

				Label {
					// ListTextField clears the root's vertical padding; add it back here so the
					// row keeps its normal height.
					topPadding: Theme.geometry_listItem_content_verticalMargin
					bottomPadding: Theme.geometry_listItem_content_verticalMargin
					text: keyField.text
					font: keyField.font
					textFormat: keyField.textFormat
					wrapMode: Text.Wrap

					Layout.row: 0
					Layout.column: 0
					Layout.fillWidth: true
					// In portrait the name has the first row to itself.
					Layout.columnSpan: keyField.portrait ? 2 : 1
					Layout.alignment: Qt.AlignVCenter
				}

				CaptionLabel {
					//% "Encryption key"
					text: qsTrId("settings_ble_sensors_encryption_key")

					Layout.row: keyField.portrait ? 1 : 0
					Layout.column: keyField.portrait ? 0 : 1
					Layout.alignment: Qt.AlignVCenter
				}

				TextValidationField {
					id: keyTextField

					horizontalAlignment: Text.AlignHCenter
					text: keyField.secondaryText
					enabled: keyField.clickable
					echoMode: keyField.echoMode
					inputMethodHints: keyField.inputMethodHints
					placeholderText: keyField.placeholderText
					maximumLength: keyField.maximumLength

					flickable: keyField.flickable
					validateInput: keyField.validateInput
					validateOnFocusLost: keyField.validateOnFocusLost

					// A key that came from the backend is generally too long for the field, and
					// setting the text leaves the cursor - and with it the visible part of the text
					// - at its end, hiding the first characters. Show the start of the key instead,
					// so that it reads as a key. Deferred, because the text arrives before the
					// layout has given the field its width, and the scroll position follows the
					// cursor only once there is a width to scroll within. Skipped while the user is
					// editing, so it cannot fight the cursor as they type.
					function showStartOfKey() {
						if (!activeFocus) {
							cursorPosition = 0
						}
					}

					// TextValidationField submits on Enter and on focus loss, but only if the text
					// has been edited since it was focused. Here an unedited key has to be
					// submitted too: after a device is switched off, its field is refocused still
					// holding the stored key, and re-submitting that key is how it gets switched
					// back on. Marking the field as having something to save on focus, when it
					// already holds a complete key, arms both of its submit paths at once.
					// A Connections rather than an onActiveFocusChanged handler, which would
					// override the one this type relies on for the submit itself.
					Connections {
						target: keyTextField
						function onActiveFocusChanged() {
							if (keyTextField.activeFocus && root.keyIsComplete(keyTextField.text)) {
								keyTextField._validateBeforeSaving = true
							}
						}
					}

					onInputValidated: keyField.saveInput()
					// onTextEdited, not onTextChanged, so that only a user edit writes back to
					// secondaryText: assigning it from a text change caused by the binding itself
					// would break that binding, and a key the backend later clears or replaces
					// would no longer reach the field. As in ListTextField itself.
					onTextEdited: keyField.secondaryText = text
					onTextChanged: {
						if (!activeFocus) {
							Qt.callLater(showStartOfKey)
						}
					}

					Layout.row: keyField.portrait ? 1 : 0
					Layout.column: keyField.portrait ? 1 : 2
					Layout.alignment: Qt.AlignVCenter
					Layout.minimumWidth: Theme.geometry_listItem_textField_minimumWidth
					// On its own row there is space for the whole key, so let the field use it.
					Layout.fillWidth: keyField.portrait
					Layout.maximumWidth: keyField.portrait ? Number.POSITIVE_INFINITY
							: Theme.geometry_listItem_textField_maximumWidth
					Layout.bottomMargin: keyField.portrait ? Theme.geometry_listItem_content_verticalMargin : 0
				}
			}
		}
	}
}
