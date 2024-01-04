/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

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
		model: ObjectModel {
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
				visible: enable.checked
			}

			ListLabel {
				//% "Continuous scanning may interfere with Wi-Fi operation"
				text: qsTrId("settings_continuous_scan_may_interfere")
				visible: contScan.checked
			}

			ListNavigationItem {
				//% "Bluetooth adapters"
				text: qsTrId("settings_io_bluetooth_adapters")
				visible: enable.checked
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
							delegate: ListTextItem {
								text: model.item.itemParent().id
								dataItem.uid: Utils.normalizedSource(model.item.uid)
							}
						}
					}
				}
			}

			Column {
				width: parent ? parent.width : 0

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
						dataItem.uid: Utils.normalizedSource(model.item.itemParent().uid) + "/Enabled"
					}
				}
			}
		}
	}
}
