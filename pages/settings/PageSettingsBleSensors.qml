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

			Column {
				width: parent ? parent.width : 0
				spacing: Theme.geometry_gradientList_spacing

				Repeater {
					model: VeQItemSortTableModel {
						model: VeQItemChildModel {
							model: sensors
							childId: "Name"
						}
						dynamicSortFilter: true
						filterFlags: VeQItemSortTableModel.FilterInvalid
					}

					delegate: ListSwitch {
						text: model.item.value
						dataItem.uid: model.item.itemParent().uid + "/Enabled"
					}
				}
			}
		}
	}
}
