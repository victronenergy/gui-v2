/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Page {
	id: root

	readonly property string bleServiceUid: BackendConnection.serviceUidForType("ble")

	VeQItemSortTableModel {
		id: sensors

		model: VeQItemTableModel {
			uids: [ root.bleServiceUid + "/Devices" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
	}

	VeQItemSortTableModel {
		id: interfaces
		model: VeQItemTableModel {
			uids: [ root.bleServiceUid + "/Interfaces" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
	}

	GradientListView {
		model: VisibleItemModel {
			ListSwitch {
				id: enable
				text: CommonWords.enable
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/BleSensors"
			}

			ListSwitch {
				id: contScan
				//% "Continuous scanning"
				text: qsTrId("settings_continuous_scan")
				dataItem.uid: root.bleServiceUid + "/ContinuousScan"
				preferredVisible: enable.checked
			}

			PrimaryListLabel {
				//% "Continuous scanning may interfere with Wi-Fi operation."
				text: qsTrId("settings_continuous_scan_may_interfere")
				preferredVisible: contScan.checked
			}

			ListNavigation {
				//% "Bluetooth adapters"
				text: qsTrId("settings_io_bluetooth_adapters")
				preferredVisible: enable.checked
				onClicked: Global.pageManager.pushPage(bluetoothAdaptersComponent, {"title": text})

				Component {
					id: bluetoothAdaptersComponent

					Page {
						GradientListView {
							model: VeQItemSortTableModel {
								model: VeQItemChildModel {
									model: interfaces
									childId: "Address"
								}
								dynamicSortFilter: true
								filterFlags: VeQItemSortTableModel.FilterInvalid
							}
							delegate: ListText {
								text: model.item.itemParent().id
								dataItem.uid: model.item.uid
							}
						}
					}
				}
			}

			ListRadioButtonGroup {
				id: gatewayAccess
				//% "BLE gateway access"
				text: qsTrId("settings_ble_gateway_access")
				dataItem.uid: root.bleServiceUid + "/Socket/BindAddress"
				preferredVisible: enable.checked && dataItem.valid
				optionModel: [
					{ display: CommonWords.disabled, value: "" },
					//% "Proxy"
					{ display: qsTrId("settings_ble_gateway_access_proxy"), value: "127.0.0.1" },
					//% "Proxy and direct"
					{ display: qsTrId("settings_ble_gateway_access_proxy_and_direct"), value: "0.0.0.0" },
				]
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: sensorRepeater.count > 0

				Repeater {
					id: sensorRepeater
					model: VeQItemSortTableModel {
						model: VeQItemChildModel {
							model: sensors
							childId: "Name"
						}
						dynamicSortFilter: true
						filterFlags: VeQItemSortTableModel.FilterInvalid
					}

					// A single list item combining the device's enable switch with the encryption
					// key entry field. Based on ListTextField (which owns the /Key data item,
					// validation and virtual-keyboard handling); the enable switch is added into
					// a custom contentItem and wired to a separate /Enabled data item.
					delegate: ListTextField {
						id: sensorDelegate

						// The device's dbus path prefix, e.g. ".../Devices/xxxxxx_xxxxxxx".
						readonly property string __devicePrefix: model.item.itemParent().uid
						// Encrypted Instant Readout devices expose a Devices/<id>/Key path. When
						// that path is present the device cannot be enabled until a valid key is
						// entered.
						readonly property bool __keyRequired: dataItem.seen
						// Validity of the value currently in the text field (the live edit buffer).
						// A key is valid if it is empty (clearing the key) or exactly 32 hex chars.
						// Used to decide whether the edited input can be saved.
						readonly property bool __keyValid: /^([0-9A-Fa-f]{32})?$/.test(secondaryText)
						// True when the field currently holds a complete 32-character key. The switch
						// gates on this (the live field), matching the requirement that the slider is
						// disabled until the field contains a valid key. Enabling then saves the key
						// first (see __toggleEnabled), so the device is never enabled against an
						// unsaved key even though the switch reflects the live buffer.
						readonly property bool __liveKeyValid: /^[0-9A-Fa-f]{32}$/.test(secondaryText)
						// Validity of the key already committed to the backend (dataItem.value). The
						// read-only gating keys off this (not the live buffer) so the field does not
						// become read-only / disappear mid-edit the instant the 32nd char is typed.
						readonly property bool __savedKeyValid: dataItem.valid
								&& /^[0-9A-Fa-f]{32}$/.test(dataItem.value)
						readonly property bool __enabled: enabledDataItem.value === 1
						// An encrypted device can only be enabled once the field holds a valid
						// 32-character hexadecimal key. An already-enabled device can always be
						// disabled, so the user is never trapped if the backend presents an enabled
						// device with an invalid key.
						readonly property bool __switchClickable: userHasWriteAccess
								&& enabledDataItem.valid
								&& (__enabled || !__keyRequired || __liveKeyValid)

						// When enabling an encrypted device we save the key, then defer writing
						// /Enabled=1 until the backend confirms that exact key (dataItem.value),
						// so the device is never enabled against an unsaved or rejected key.
						property bool __enablePending: false
						property string __pendingKey

						function __toggleEnabled() {
							if (!checkWriteAccessLevel()) {
								return
							}
							if (__enabled) {
								// Disabling is always allowed and needs no key.
								enabledDataItem.setValue(0)
								return
							}
							if (!__keyRequired) {
								enabledDataItem.setValue(1)
								return
							}
							// Encrypted device: save the entered key first (the Qt.NoFocus switch does
							// not trigger a focus-loss save). Abort if it does not validate.
							if (runValidation(VenusOS.InputValidation_ValidateAndSave)
									=== VenusOS.InputValidation_Result_Error) {
								return
							}
							__pendingKey = secondaryText
							__enablePending = true
							__applyPendingEnable()
						}

						// Write /Enabled=1 once the saved key has round-tripped back from the
						// backend. Requires the live field to still equal the pending key, so an
						// edit made before the key is confirmed cancels the enable rather than
						// enabling against a superseded key.
						function __applyPendingEnable() {
							if (__enablePending
									&& secondaryText === __pendingKey
									&& dataItem.valid
									&& String(dataItem.value) === __pendingKey) {
								__enablePending = false
								enabledDataItem.setValue(1)
							}
						}

						// Complete a deferred enable when the key write is confirmed.
						Connections {
							target: sensorDelegate.dataItem
							function onValueChanged() { sensorDelegate.__applyPendingEnable() }
						}

						// Editing the field abandons any deferred enable.
						onSecondaryTextChanged: {
							if (__enablePending && secondaryText !== __pendingKey) {
								__enablePending = false
							}
						}

						// When the device becomes enabled (and the field turns read-only), discard
						// any uncommitted edit by re-binding the field to the committed key, so the
						// read-only field can never display a value that differs from the backend.
						Connections {
							target: enabledDataItem
							function onValueChanged() {
								if (sensorDelegate.__enabled) {
									sensorDelegate.secondaryText = Qt.binding(function() {
										return sensorDelegate.dataItem.valid ? sensorDelegate.dataItem.value : ""
									})
								}
							}
						}

						width: parent ? parent.width : 0

						// Primary label is the device name; the caption labels the key field.
						text: model.item.value
						//% "Encryption key"
						caption: qsTrId("settings_ble_sensors_encryption_key")

						// The text field edits the encryption key (/Key).
						dataItem.uid: __devicePrefix + "/Key"
						// Limited to 32 hexadecimal characters; input is case insensitive.
						maximumLength: 32
						inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
						// The key is sensitive, so mask it both while typing and in the
						// read-only display shown once the device is enabled.
						echoMode: TextInput.Password
						validator: RegularExpressionValidator { regularExpression: /^[0-9A-Fa-f]{0,32}$/ }
						//% "Enter a 32-character key"
						placeholderText: qsTrId("settings_ble_sensors_encryption_key_placeholder")
						// Make the field read-only once the device is enabled with a saved valid
						// key, but keep it editable if the saved key is invalid so the user can
						// correct it. Keying off the saved (not live) value means the field stays
						// editable while typing a correction, until the new key is actually saved.
						// Editable when either not yet enabled or the saved key is invalid (so an
						// enabled device with a bad key can still be corrected). Once enabled with a
						// valid saved key the field is read-only; any uncommitted edit made during
						// the enable round-trip is discarded when the device reports enabled.
						interactive: dataItem.valid && (!__enabled || !__savedKeyValid)
						validateInput: function() {
							if (sensorDelegate.__keyValid) {
								return Utils.validationResult(VenusOS.InputValidation_Result_OK)
							}
							//% "The encryption key must be 32 hexadecimal characters."
							return Utils.validationResult(VenusOS.InputValidation_Result_Error,
									qsTrId("settings_ble_sensors_encryption_key_invalid"))
						}

						// This delegate replaces a ListSwitch, so keep Space toggling the enable
						// switch like a ListSwitch would (ListTextField's default Space handler,
						// which focuses the text field, is overridden here). When the switch is
						// locked - e.g. an encrypted device whose key is not yet valid - fall back
						// to focusing the key field so the key can still be entered via the keyboard.
						Keys.onSpacePressed: {
							if (__switchClickable) {
								__toggleEnabled()
							} else if (clickable && contentItem && contentItem.forceInputFocus) {
								contentItem.forceInputFocus()
							}
						}

						// Two rows, each laid out as a RowLayout so that the control on the right is
						// vertically centered with its label on the left. The key caption/field row
						// is only shown for encrypted devices that require a key.
						// | Device name | Enable switch |
						// | Key caption | Key field     |
						contentItem: Column {
							// Called by ListTextField.runValidation() and Keys.onSpacePressed.
							function runValidation(mode) {
								return keyField.runValidation(mode)
							}
							function forceInputFocus() {
								keyField.forceInputFocus()
							}

							// Since the root top/bottomPadding is 0, add the content margins back
							// here. The inter-row spacing matches the top/bottom padding so that the
							// gap above the switch (to the top of the delegate) equals the gap below
							// it (to the text entry box); the switch is centered within its row, so
							// its centering offset applies equally on both sides.
							topPadding: Theme.geometry_listItem_content_verticalMargin
							bottomPadding: Theme.geometry_listItem_content_verticalMargin
							spacing: Theme.geometry_listItem_content_verticalMargin

							RowLayout {
								width: parent.width
								spacing: sensorDelegate.spacing

								Label {
									text: sensorDelegate.text
									textFormat: sensorDelegate.textFormat
									font: sensorDelegate.font
									wrapMode: Text.Wrap

									Layout.fillWidth: true
									Layout.alignment: Qt.AlignVCenter
								}

								Switch {
									id: enabledSwitch

									checked: sensorDelegate.__enabled
									// Keep 'checked' bound to the backend state: a Switch is checkable
									// by default, so clicking would otherwise assign 'checked' and break
									// the binding above. With checkable: false the click still emits
									// onClicked (driving __toggleEnabled), but the visual state only ever
									// follows __enabled - so a rejected/failed toggle can't desync the UI.
									checkable: false
									focusPolicy: Qt.NoFocus
									enabled: sensorDelegate.__switchClickable
									onClicked: sensorDelegate.__toggleEnabled()

									Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
								}
							}

							RowLayout {
								width: parent.width
								spacing: sensorDelegate.spacing
								visible: sensorDelegate.__keyRequired

								CaptionLabel {
									text: sensorDelegate.caption

									Layout.fillWidth: true
									Layout.alignment: Qt.AlignVCenter
								}

								TextValidationField {
									id: keyField

									horizontalAlignment: Text.AlignHCenter
									text: sensorDelegate.secondaryText
									// Editable only while clickable; otherwise the field stays visible
									// but disabled, showing the masked key (echoMode is Password) so an
									// enabled/read-only device still indicates a key is set instead of
									// showing a bare caption. The enclosing row is already hidden for
									// non-encrypted devices via its visible: __keyRequired binding.
									enabled: sensorDelegate.clickable
									echoMode: sensorDelegate.echoMode
									inputMethodHints: sensorDelegate.inputMethodHints
									placeholderText: sensorDelegate.placeholderText
									maximumLength: sensorDelegate.maximumLength
									validator: sensorDelegate.validator

									flickable: sensorDelegate.flickable
									validateInput: sensorDelegate.validateInput
									validateOnFocusLost: sensorDelegate.validateOnFocusLost

									onInputValidated: sensorDelegate.saveInput()
									onTextChanged: sensorDelegate.secondaryText = text

									Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
									Layout.minimumWidth: Theme.geometry_listItem_textField_minimumWidth
									Layout.maximumWidth: Theme.geometry_listItem_textField_maximumWidth
								}
							}
						}

						// The device's enabled state (/Enabled) lives on a separate data item
						// from the key field's /Key data item.
						VeQuickItem {
							id: enabledDataItem
							uid: sensorDelegate.__devicePrefix + "/Enabled"
						}
					}
				}
			}
		}
	}
}
