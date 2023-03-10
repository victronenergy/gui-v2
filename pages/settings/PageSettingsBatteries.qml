/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
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

	listView: GradientListView {
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
			secondaryText: batteryEnabled.valid
				? (batteryEnabled.value === 1 || activeBattery ? root._visibleText : root._hiddenText)
				: "--"

			listPage: root
			listIndex: model.index
			onClicked: listPage.navigateTo(batterySettingsComponent, {"title": text}, listIndex)

			DataPoint {
				id: batteryEnabled
				source: "com.victronenergy.settings/Settings/SystemSetup/Batteries/Configuration/" + batteryMenuItem.configId + "/Enabled"
			}

			Component {
				id: batterySettingsComponent

				ListPage {
					listView: GradientListView {
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
								dataSource: batteryEnabled.source
							}

							ListTextField {
								//% "Name"
								text: qsTrId("settings_batteries_name")
								//% "Enter name"
								placeholderText: qsTrId("settings_batteries_enter_name")
								dataSource: "com.victronenergy.settings/Settings/SystemSetup/Batteries/Configuration/" + batteryMenuItem.configId + "/Name"
								visible: dataValid
								textField.maximumLength: 32 // TODO can the max be fetched from dbus?
							}
						}
					}
				}
			}
		}
	}
}
