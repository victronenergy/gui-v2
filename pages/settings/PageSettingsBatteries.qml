/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

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
	}

	VeQuickItem {
		id: activeBatteryService
		uid: Global.system.serviceUid + "/ActiveBatteryService"
	}

	GradientListView {
		id: batteryListView

		header: ListLabel {
			//% "Use this menu to define which battery measurements to see on the VRM Portal and the MFD HTML5 App."
			text: qsTrId("settings_batteries_intro")
		}

		delegate: ListNavigationItem {
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
			secondaryText: batteryEnabled.isValid
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
						model: ObjectModel {
							ListTextItem {
								text: root._visibleText
								//% "Active battery monitor"
								secondaryText: qsTrId("settings_batteries_active_battery_monitor")
								visible: batteryMenuItem.activeBattery
							}

							ListSwitch {
								text: root._visibleText
								visible: !batteryMenuItem.activeBattery
								dataItem.uid: batteryEnabled.uid
							}

							ListTextField {
								//% "Name"
								text: qsTrId("settings_batteries_name")
								//% "Enter name"
								placeholderText: qsTrId("settings_batteries_enter_name")
								dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/Batteries/Configuration/" + batteryMenuItem.configId + "/Name"
								visible: dataItem.isValid
								textField.maximumLength: 32 // TODO can the max be fetched from dbus?
							}
						}
					}
				}
			}
		}
	}
}
