/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
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

					delegate: SettingsColumn {
						id: sensorDelegate

						// The device's dbus path prefix, e.g. ".../Devices/xxxxxx_xxxxxxx".
						readonly property string __devicePrefix: model.item.itemParent().uid
						// Encrypted Instant Readout devices expose a Devices/<id>/Key path. When that
						// path is present the device cannot be enabled until a valid key is entered.
						readonly property bool __keyRequired: keyField.dataItem.seen
						readonly property bool __keyValid: /^[0-9A-Fa-f]{32}$/.test(keyField.secondaryText)

						width: parent ? parent.width : 0

						ListSwitch {
							id: enabledSwitch
							text: model.item.value
							dataItem.uid: sensorDelegate.__devicePrefix + "/Enabled"
							// An encrypted device can only be enabled once a valid 32-character
							// hexadecimal key has been entered.
							interactive: defaultInteractive
									&& (!sensorDelegate.__keyRequired || sensorDelegate.__keyValid)
						}

						ListTextField {
							id: keyField

							//% "Encryption key"
							text: qsTrId("settings_ble_sensors_encryption_key")
							dataItem.uid: sensorDelegate.__devicePrefix + "/Key"
							preferredVisible: sensorDelegate.__keyRequired
							// Limited to 32 hexadecimal characters; input is case insensitive.
							maximumLength: 32
							inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
							validator: RegularExpressionValidator { regularExpression: /[0-9A-Fa-f]{0,32}/ }
							//% "Enter a 32-character key"
							placeholderText: qsTrId("settings_ble_sensors_encryption_key_placeholder")
							// Make the field read-only while the device is enabled.
							interactive: dataItem.valid && !enabledSwitch.checked
							validateInput: function() {
								if (sensorDelegate.__keyValid) {
									return Utils.validationResult(VenusOS.InputValidation_Result_OK)
								}
								//% "The encryption key must be 32 hexadecimal characters."
								return Utils.validationResult(VenusOS.InputValidation_Result_Error,
										qsTrId("settings_ble_sensors_encryption_key_invalid"))
							}
						}
					}
				}
			}
		}
	}
}
