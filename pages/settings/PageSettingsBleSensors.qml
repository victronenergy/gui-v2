/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string bleServiceUid: BackendConnection.serviceUidForType("ble")
	property int encryptionKeySensorCount: 0

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

			ListNavigation {
				//% "Advanced"
				text: qsTrId("settings_ble_advanced")
				preferredVisible: enable.checked
				onClicked: Global.pageManager.pushPage(advancedPageComponent, {"title": text})
			}

			SectionHeader {
				//% "Sensors"
				text: qsTrId("settings_ble_sensors")
				preferredVisible: enable.checked && sensorRepeater.count > 0
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: enable.checked && sensorRepeater.count > 0

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

					delegate: BleSensorDelegate {
						required property VeQItem item

						devicePrefix: item.itemParent().uid
						deviceName: item.value || ""

						onKeyRequiredChanged: root.encryptionKeySensorCount++
						Component.onCompleted: {
							if (keyRequired) {
								root.encryptionKeySensorCount++
							}
						}
						Component.onDestruction: {
							if (keyRequired) {
								root.encryptionKeySensorCount--
							}
						}
					}
				}
			}

			PrimaryListLabel {
				//% "Use VictronConnect over Bluetooth to add encryption keys automatically."
				text: qsTrId("settings_ble_sensors_add_encryption_keys_via_victronconnect")
				preferredVisible: enable.checked && root.encryptionKeySensorCount > 0
			}
		}
	}

	Component {
		id: advancedPageComponent

		Page {
			VeQuickItem {
				id: bleTokenUsers
				uid: Global.venusPlatform.serviceUid + "/BleTokens/Users"
				onValueChanged: {
					if (!valid) {
						bleTokensView.model = []
						return
					}
					let model = []
					try {
						model = JSON.parse(value)
					} catch (e) {
						console.warn(uid, ": unable to parse JSON:", value, "exception:", e)
						model = []
					}
					bleTokensView.model = model
				}
			}

			GradientListView {
				id: bleTokensView

				header: SettingsColumn {
					width: parent?.width ?? 0

					ListNavigation {
						//% "Bluetooth adapters"
						text: qsTrId("settings_io_bluetooth_adapters")
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

					ListSwitch {
						id: contScan
						//% "Continuous scanning"
						text: qsTrId("settings_continuous_scan")
						dataItem.uid: root.bleServiceUid + "/ContinuousScan"
					}

					PrimaryListLabel {
						//% "Continuous scanning may interfere with Wi-Fi operation."
						text: qsTrId("settings_continuous_scan_may_interfere")
						preferredVisible: contScan.checked
					}

					ListRadioButtonGroup {
						id: gatewayAccess
						topInset: Theme.geometry_listItem_itemSeparator_height
						//% "BLE bridge access"
						text: qsTrId("settings_ble_bridge_access")
						dataItem.uid: root.bleServiceUid + "/Socket/BindAddress"
						preferredVisible: dataItem.valid

						readonly property bool _isCustom: dataItem.valid && dataItem.value !== "" && dataItem.value !== "127.0.0.1"

						optionModel: [
							{ display: CommonWords.disabled, value: "" },
							//% "Paired devices only"
							{ display: qsTrId("settings_ble_bridge_access_paired_only"), value: "127.0.0.1" },
						].concat(_isCustom ? [
							//% "Custom"
							{ display: qsTrId("settings_ble_bridge_access_custom"), value: dataItem.value, readOnly: _isCustom },
						] : [])
					}

					ListPairingModeButton {
						countDownUid: Global.venusPlatform.serviceUid + "/Tokens/Pairing/CountDown"
						preferredVisible: blePairingEnable.valid && !!gatewayAccess.currentValue
						onClicked: blePairingEnable.setValue("")

						VeQuickItem {
							id: blePairingEnable
							uid: Global.venusPlatform.serviceUid + "/Tokens/Pairing/Enable"
						}
					}

					SectionHeader {
						//% "Paired BLE bridges"
						text: qsTrId("pairing_ble_paired_bridges")
						visible: bleTokensView.count > 0
					}
				}

				delegate: ListUnpairButton {
					required property var modelData
					readonly property string tokenName: modelData["token_name"] ?? ""
					readonly property var tokenNameParts: tokenName.split("/")

					text: tokenNameParts[tokenNameParts.length - 1] ?? ""
					onClicked: {
						Global.dialogLayer.open(bleUnpairDialogComponent, { tokenName: tokenName })
					}
				}
			}

			Component {
				id: bleUnpairDialogComponent

				UnpairDialog {
					required property string tokenName

					name: tokenName.split("/").pop() ?? ""
					onAccepted: {
						bleTokenRemove.setValue(tokenName)
					}

					VeQuickItem {
						id: bleTokenRemove
						uid: Global.venusPlatform.serviceUid + "/BleTokens/Remove"
					}
				}
			}
		}
	}
}
