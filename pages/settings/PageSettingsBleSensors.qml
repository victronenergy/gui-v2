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

					// Each Bluetooth sensor is shown either as an enable switch or, for an
					// encrypted Instant Readout device that is not yet enabled, as an encryption
					// key entry field. A Loader swaps between two standard list items as the
					// device's state changes, so neither has to emulate the other.
					delegate: Loader {
						id: sensorDelegate

						// The device's dbus path prefix, e.g. ".../Devices/xxxxxx_xxxxxxx".
						readonly property string devicePrefix: model.item.itemParent().uid
						readonly property string deviceName: model.item.value
						// Encrypted Instant Readout devices expose a Devices/<id>/Key path; such a
						// device is enabled by entering a valid key rather than via a switch.
						readonly property bool keyRequired: keyItem.seen
						readonly property bool deviceEnabled: enabledItem.value === 1

						// True from when we enable the device with an entered key until the backend
						// either rejects it (Enabled returns to 0) or the window below elapses with
						// the device still enabled. Used to report a rejected key to the user.
						property bool awaitingValidation: false
						// Set while the user deliberately disables the device, so the resulting
						// Enabled -> 0 is not mistaken for a backend key rejection.
						property bool userDisabling: false

						// Width is set, height is left to follow the loaded list item's implicit height.
						width: parent ? parent.width : 0

						// Show the key field while an encrypted device is disabled; otherwise (a
						// non-encrypted device, or an enabled encrypted one) show the enable switch.
						sourceComponent: (keyRequired && !deviceEnabled) ? keyFieldComponent : switchComponent

						// Save the key, then enable the device. The backend validates the key and,
						// if it is wrong, disables the device again (see the enabledItem Connections).
						// Deferred via Qt.callLater so it is safe to call from the key field's own
						// signal handlers - enabling swaps the field out from under them.
						function enableWithKey(key) {
							keyItem.setValue(key)
							awaitingValidation = true
							validationTimer.restart()
							enabledItem.setValue(1)
						}

						function disable() {
							userDisabling = true
							awaitingValidation = false
							validationTimer.stop()
							enabledItem.setValue(0)
						}

						VeQuickItem {
							id: enabledItem
							uid: sensorDelegate.devicePrefix + "/Enabled"
						}
						VeQuickItem {
							id: keyItem
							uid: sensorDelegate.devicePrefix + "/Key"
						}

						// Detect the backend rejecting an entered key: Enabled dropping back to 0
						// while we were awaiting validation and the user did not disable the device.
						Connections {
							target: enabledItem
							function onValueChanged() {
								if (sensorDelegate.deviceEnabled) {
									return
								}
								if (sensorDelegate.userDisabling) {
									sensorDelegate.userDisabling = false
								} else if (sensorDelegate.awaitingValidation) {
									//% "The submitted encryption key is invalid."
									Global.showToastNotification(VenusOS.Notification_Warning,
											qsTrId("settings_ble_sensors_encryption_key_rejected"), 5000)
								}
								sensorDelegate.awaitingValidation = false
								validationTimer.stop()
							}
						}

						// If the device is still enabled when this elapses, assume the key was
						// accepted; a rejection is expected to disable the device before then.
						Timer {
							id: validationTimer
							interval: 20000
							onTriggered: sensorDelegate.awaitingValidation = false
						}

						Component {
							id: switchComponent

							ListSwitch {
								text: sensorDelegate.deviceName
								dataItem.uid: sensorDelegate.devicePrefix + "/Enabled"
								// A non-encrypted device toggles Enabled directly. An encrypted device
								// only shows the switch while enabled, so clicking it disables the
								// device (routed through disable() to keep the delegate's state in sync).
								updateDataOnClick: !sensorDelegate.keyRequired
								onClicked: {
									if (sensorDelegate.keyRequired) {
										sensorDelegate.disable()
									}
								}
							}
						}

						Component {
							id: keyFieldComponent

							ListTextField {
								id: keyField

								//% "Encryption key"
								readonly property string _keyCaption: qsTrId("settings_ble_sensors_encryption_key")
								//% "The encryption key must be 32 hexadecimal characters."
								readonly property string _keyInvalid: qsTrId("settings_ble_sensors_encryption_key_invalid")

								text: sensorDelegate.deviceName
								// The field is for entering a new key; the stored key is never shown,
								// so a disabled device always presents an empty field. A fresh instance
								// is loaded each time the device becomes disabled.
								secondaryText: ""
								dataItem.uid: sensorDelegate.devicePrefix + "/Key"
								// Limited to 32 hexadecimal characters; input is case insensitive.
								maximumLength: 32
								inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
								// The key is sensitive, so mask it while typing.
								echoMode: TextInput.Password
								validator: RegularExpressionValidator { regularExpression: /^[0-9A-Fa-f]{0,32}$/ }
								//% "Enter a 32-character key"
								placeholderText: qsTrId("settings_ble_sensors_encryption_key_placeholder")
								validateInput: function() {
									if (/^[0-9A-Fa-f]{32}$/.test(secondaryText)) {
										return Utils.validationResult(VenusOS.InputValidation_Result_OK)
									}
									return Utils.validationResult(VenusOS.InputValidation_Result_Error, _keyInvalid)
								}
								// Entering a complete, valid key enables the device. Fires for any
								// input method (typing, paste); enabling swaps this field out for the
								// switch, so defer the write until this handler has returned.
								onSecondaryTextChanged: {
									if (/^[0-9A-Fa-f]{32}$/.test(secondaryText)) {
										Qt.callLater(sensorDelegate.enableWithKey, secondaryText)
									}
								}
								// Also enable on an explicit submit (Enter / focus lost) as a fallback.
								saveInput: function() {
									if (/^[0-9A-Fa-f]{32}$/.test(secondaryText)) {
										Qt.callLater(sensorDelegate.enableWithKey, secondaryText)
									}
								}

								// Single row: device name on the left, then the "Encryption key" label
								// immediately before the entry box, instead of a caption on its own row.
								contentItem: RowLayout {
									function forceInputFocus() { keyTextField.forceInputFocus() }
									function runValidation(mode) { return keyTextField.runValidation(mode) }

									spacing: keyField.spacing

									Label {
										// ListTextField clears the root's vertical padding; add it back
										// here so the row keeps its normal height.
										topPadding: Theme.geometry_listItem_content_verticalMargin
										bottomPadding: Theme.geometry_listItem_content_verticalMargin
										text: keyField.text
										font: keyField.font
										textFormat: keyField.textFormat
										wrapMode: Text.Wrap

										Layout.fillWidth: true
										Layout.alignment: Qt.AlignVCenter
									}

									CaptionLabel {
										text: keyField._keyCaption

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
										validator: keyField.validator

										flickable: keyField.flickable
										validateInput: keyField.validateInput
										validateOnFocusLost: keyField.validateOnFocusLost

										onInputValidated: keyField.saveInput()
										onTextChanged: keyField.secondaryText = text

										Layout.alignment: Qt.AlignVCenter
										Layout.minimumWidth: Theme.geometry_listItem_textField_minimumWidth
										Layout.maximumWidth: Theme.geometry_listItem_textField_maximumWidth
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
