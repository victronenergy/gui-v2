/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property var _batteries: ({})

	//% "Visible"
	readonly property string _visibleText: qsTrId("settings_batteries_battery_visible")
	//% "Hidden"
	readonly property string _hiddenText: qsTrId("settings_batteries_battery_hidden")

	VeQuickItem {
		id: availableBatteries
		uid: Global.system.serviceUid + "/AvailableBatteries"
		onValueChanged: {
			console.log("*****************", uid, value)
			let jsonObject
			try {
				jsonObject = JSON.parse(value)
			} catch (e) {
				console.warn("Unable to parse data from", uid)
				return
			}
			_batteries = jsonObject
			batteryListView.model = Object.keys(jsonObject)
		}
		property var batteryMap: ({})
		function addBattery() {
			batteryMap["blah123"] = {
				name: "name123",
				channel: null,
				type: "battery"
			}

			setValue(JSON.stringify(batteryMap))
		}
	}
	property var _batteries2:
		'{
			"com.victronenergy.dcsource/289":{"name":"blah Wind charger ","channel":null,"type":"dcsource"},
			"com.victronenergy.battery/289/1":{"name":"blah Service battery","channel":1,"type":"battery"},
			"com.victronenergy.battery/289":{"name":"blah Service battery","channel":null,"type":"battery"},
			"com.victronenergy.battery/512":{"name":"blah Pylontech Force L2","channel":null,"type":"battery"},
			"com.victronenergy.battery/0":{"name":"blah Virtual battery","channel":null,"type":"battery"},
			"com.victronenergy.battery/1":{"name":"blah Lynx Smart BMS NG","channel":null,"type":"battery"}
		}'

	Timer {
		running: true
		interval: 1000
		onTriggered: {
			console.log("****************** onTriggered")
			availableBatteries.addBattery()
		}
	}

	VeQuickItem {
		id: activeBatteryService
		uid: Global.system.serviceUid + "/ActiveBatteryService"
	}

	GradientListView {
		id: batteryListView

		header: PrimaryListLabel {
			//% "Use this menu to define the battery data shown when clicking the Battery icon on the Overview page. The same selection is also visible on the VRM Portal."
			text: qsTrId("settings_batteries_intro")
		}

		delegate: ListNavigation {
			id: batteryMenuItem

			readonly property string configId: modelData.replace(/\./g, "_")
			readonly property bool activeBattery: activeBatteryService.value === modelData

			text: {
				const battery = root._batteries[modelData]
				if (!battery || !battery.name) {
					return ""
				}
				if (battery.channel != null) {
					return battery.type === "battery"
						  //% "%1 (Auxiliary measurement)"
						? qsTrId("settings_batteries_battery_auxiliary_measurement").arg(battery.name)
						  //% "%1 (Output %2)"
						: qsTrId("settings_batteries_battery_output").arg(battery.name).arg(battery.channel + 1);
				}
				return battery.name
			}
			secondaryText: batteryEnabled.valid
				? (batteryEnabled.value === 1 || activeBattery ? root._visibleText : root._hiddenText)
				: "--"

			onClicked: Global.pageManager.pushPage(batterySettingsComponent, {"title": text})

			VeQuickItem {
				id: batteryEnabled
				uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/Batteries/Configuration/" + batteryMenuItem.configId + "/Enabled"
			}

			Component {
				id: batterySettingsComponent

				Page {
					GradientListView {
						model: VisibleItemModel {
							ListText {
								text: root._visibleText
								//% "Active battery monitor"
								secondaryText: qsTrId("settings_batteries_active_battery_monitor")
								preferredVisible: batteryMenuItem.activeBattery
							}

							ListSwitch {
								text: root._visibleText
								preferredVisible: !batteryMenuItem.activeBattery
								dataItem.uid: batteryEnabled.uid
								writeAccessLevel: VenusOS.User_AccessType_User
							}

							ListTextField {
								//% "Name"
								text: qsTrId("settings_batteries_name")
								//% "Enter name"
								placeholderText: qsTrId("settings_batteries_enter_name")
								dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/Batteries/Configuration/" + batteryMenuItem.configId + "/Name"
								preferredVisible: dataItem.valid
								textField.maximumLength: 32
							}
						}
					}
				}
			}
		}
	}
}
