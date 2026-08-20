/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string bleServiceUid: BackendConnection.serviceUidForType("ble")

	VeQuickItem {
		id: bindAddressItem
		uid: root.bleServiceUid + "/Socket/BindAddress"
	}

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
		id: namedSensors

		model: VeQItemChildModel {
			model: sensors
			childId: "Name"
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterInvalid
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
		model: DelegateComponentModel {
			DelegateComponent {
				id: enableDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/Services/BleSensors" }
				property bool checked: dataItem.value === 1
				ListSwitch {
					id: enable
					text: CommonWords.enable
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/BleSensors"
				}
			}

			DelegateComponent {
				id: contScanDC
				dataItem: VeQuickItem { uid: root.bleServiceUid + "/ContinuousScan" }
				property bool checked: dataItem.value === 1
				preferredVisible: enableDC.checked
				ListSwitch {
					id: contScan
					//% "Continuous scanning"
					text: qsTrId("settings_continuous_scan")
					dataItem.uid: root.bleServiceUid + "/ContinuousScan"
				}
			}

			DelegateComponent {
				preferredVisible: contScanDC.checked
				PrimaryListLabel {
					//% "Continuous scanning may interfere with Wi-Fi operation."
					text: qsTrId("settings_continuous_scan_may_interfere")
				}
			}

			DelegateComponent {
				preferredVisible: enableDC.checked
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
			}

			DelegateComponent {
				preferredVisible: enableDC.checked && bindAddressItem.valid
				ListRadioButtonGroup {
					id: gatewayAccess
					//% "BLE gateway access"
					text: qsTrId("settings_ble_gateway_access")
					dataItem.uid: root.bleServiceUid + "/Socket/BindAddress"
					optionModel: [
						{ display: CommonWords.disabled, value: "" },
						//% "Proxy"
						{ display: qsTrId("settings_ble_gateway_access_proxy"), value: "127.0.0.1" },
						//% "Proxy and direct"
						{ display: qsTrId("settings_ble_gateway_access_proxy_and_direct"), value: "0.0.0.0" },
					]
				}
			}

			DelegateComponent {
				preferredVisible: namedSensors.rowCount > 0
				SettingsColumn {
					width: parent ? parent.width : 0

					Repeater {
						id: sensorRepeater
						model: namedSensors

						delegate: BleSensorDelegate {
							required property VeQItem item

							devicePrefix: item.itemParent().uid
							deviceName: item.value || ""
						}
					}
				}
			}
		}
	}
}
