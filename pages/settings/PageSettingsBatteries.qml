/*
** Copyright (C) 2022 Victron Energy B.V.
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

	DataPoint {
		id: availableBatteries
		source: "com.victronenergy.system/AvailableBatteries"
		onValueChanged: {
			let jsonObject
			try {
				jsonObject = JSON.parse(value)
			} catch (e) {
				console.warn("Unable to parse data from", source)
				return
			}
			_batteries = jsonObject
			batteryListView.model = Object.keys(jsonObject)
		}
	}

	DataPoint {
		id: activeBatteryService
		source: "com.victronenergy.system/ActiveBatteryService"
	}

	SettingsListView {
		id: batteryListView

		header: SettingsLabel {
			//% "Use this menu to define which battery measurements to see on the VRM Portal and the MFD HTML5 App."
			text: qsTrId("settings_batteries_intro")
		}

		delegate: SettingsListNavigationItem {
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
			secondaryText: batteryEnabled.value !== undefined
				? (batteryEnabled.value === 1 || activeBattery ? root._visibleText : root._hiddenText)
				: "--"

			onClicked: Global.pageManager.pushPage(batterySettingsComponent, {"title": text})

			DataPoint {
				id: batteryEnabled
				source: "com.victronenergy.settings/Settings/SystemSetup/Batteries/Configuration/" + batteryMenuItem.configId + "/Enabled"
			}

			Component {
				id: batterySettingsComponent

				Page {
					SettingsListView {
						model: ObjectModel {
							SettingsListTextItem {
								text: root._visibleText
								//% "Active battery monitor"
								secondaryText: qsTrId("settings_batteries_active_battery_monitor")
								visible: batteryMenuItem.activeBattery
							}

							SettingsListSwitch {
								text: root._visibleText
								visible: !batteryMenuItem.activeBattery
								source: batteryEnabled.source
							}

							SettingsListTextField {
								//% "Name"
								text: qsTrId("settings_batteries_name")
								//% "Enter name"
								placeholderText: qsTrId("settings_batteries_enter_name")
								source: "com.victronenergy.settings/Settings/SystemSetup/Batteries/Configuration/" + batteryMenuItem.configId + "/Name"
								visible: dataPoint.value !== undefined
								textField.maximumLength: 32 // TODO can the max be fetched from dbus?
							}
						}
					}
				}
			}
		}
	}
}
