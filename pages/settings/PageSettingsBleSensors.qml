/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Page {
	id: root

	VeQItemSortTableModel {
		id: sensors

		// TODO fix this model for MQTT
		model: VeQItemTableModel {
			uids: ["dbus/com.victronenergy.ble/Devices"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
	}

	VeQItemSortTableModel {
		id: interfaces
		model: VeQItemTableModel {
			uids: ["dbus/com.victronenergy.ble/Interfaces"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
	}

	SettingsListView {
		model: ObjectModel {
			SettingsListSwitch {
				id: enable
				//% "Enable"
				text: qsTrId("settings_bluetooth_enable")
				source: "com.victronenergy.settings/Settings/Services/BleSensors"
			}

			SettingsListSwitch {
				id: contScan
				//% "Continuous scanning"
				text: qsTrId("settings_continuous_scan")
				source: "com.victronenergy.ble/ContinuousScan"
				visible: enable.checked
			}

			SettingsLabel {
				//% "Continuous scanning may interfere with Wi-Fi operation"
				text: qsTrId("settings_continuous_scan_may_interfere")
				visible: contScan.checked
			}

			SettingsListNavigationItem {
				//% "Bluetooth adapters"
				text: qsTrId("settings_io_bluetooth_adapters")
				visible: enable.checked
				onClicked: {
					Global.pageManager.pushPage(bluetoothAdaptersComponent, {"title": text})
				}

				Component {
					id: bluetoothAdaptersComponent

					Page {
						SettingsListView {
							model: VeQItemSortTableModel {
								model: VeQItemChildModel {
									model: interfaces
									childId: "Address"
								}
								dynamicSortFilter: true
								filterFlags: VeQItemSortTableModel.FilterInvalid
							}
							delegate: SettingsListTextItem {
								text: model.item.itemParent().id
								source: Utils.normalizedSource(model.item.uid)
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

					delegate: SettingsListSwitch {
						text: model.item.value
						source: Utils.normalizedSource(model.item.itemParent().uid) + "/Enabled"
					}
				}
			}
		}
	}
}
