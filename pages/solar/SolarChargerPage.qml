/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property var solarCharger

	title: solarCharger.name

	GradientListView {
		model: ObjectModel {
			ListItemBackground {
				height: trackerTable.y + trackerTable.height

				QuantityTableSummary {
					id: trackerSummary

					x: Theme.geometry.listItem.content.horizontalMargin
					width: parent.width - Theme.geometry.listItem.content.horizontalMargin

					model: [
						{
							title: CommonWords.state,
							text: Global.solarChargers.chargerStateToText(root.solarCharger.state),
							unit: -1,
						},
						{
							title: CommonWords.yield_today,
							value: root.solarCharger.dailyHistory(0).yieldKwh || 0,
							unit: VenusOS.Units_Energy_KiloWattHour
						},
						{
							title: CommonWords.voltage,
							value: root.solarCharger.voltage,
							unit: VenusOS.Units_Volt
						},
						{
							title: CommonWords.current_amps,
							value: root.solarCharger.current,
							unit: VenusOS.Units_Amp
						},
						{
							title: CommonWords.pv_power,
							value: root.solarCharger.power,
							unit: VenusOS.Units_Watt
						},
					]
				}

				QuantityTable {
					id: trackerTable

					anchors.top: trackerSummary.bottom
					visible: root.solarCharger.trackers.count > 1

					rowCount: root.solarCharger.trackers.count
					units: [
						{ title: CommonWords.tracker, unit: -1 },
						{ title: trackerSummary.model[1].title, unit: VenusOS.Units_Energy_KiloWattHour },
						{ title: CommonWords.voltage, unit: VenusOS.Units_Volt },
						{ title: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ title: CommonWords.power_watts, unit: VenusOS.Units_Watt }
					]
					valueForModelIndex: function(trackerIndex, column) {
						const tracker = root.solarCharger.trackers.get(trackerIndex).solarTracker
						if (column === 0) {
							return tracker.name
						} else if (column === 1) {
							// Today's yield for this tracker
							return root.solarCharger.dailyHistory(0, trackerIndex).yieldKwh
						} else if (column === 2) {
							return tracker.voltage
						} else if (column === 3) {
							return tracker.current
						} else if (column === 4) {
							return tracker.power
						}
					}
				}
			}

			Item {
				width: 1
				height: Theme.geometry.gradientList.spacing
			}

			ListQuantityGroup {
				text: CommonWords.battery
				textModel: [
					{
						value: root.solarCharger.batteryVoltage,
						unit: VenusOS.Units_Volt
					},
					{
						value: root.solarCharger.batteryCurrent,
						unit: VenusOS.Units_Amp
					},
				]
			}

			ListSwitch {
				text: CommonWords.relay
				checked: root.solarCharger.relayOn
				secondaryText: CommonWords.onOrOff(root.solarCharger.relayOn)
				visible: root.solarCharger.relayValid
				enabled: false
			}

			ListNavigationItem {
				//% "Alarms and Errors"
				text: qsTrId("charger_alarms_alarms_and_errors")
				secondaryText: enabled
					? (root.solarCharger.errorModel.count > 0
						  //: Shows number of items found. %1 = number of items
						  //% "%1 found"
						? qsTrId("charger_history_found_with_count").arg(root.solarCharger.errorModel.count)
						: "")
					  //: Indicates there are no alarms/errors present
					  //% "None"
					: qsTrId("charger_alarms_none")
				secondaryLabel.color: root.solarCharger.errorModel.count ? Theme.color.critical : Theme.color.font.secondary

				// Only enable if there is content on the alarms/errors page.
				// TODO update this binding to consider 'active alarms' section when it is
				// implemented for the page.
				enabled: lowBatteryAlarm.valid || highBatteryAlarm.valid
						 || root.solarCharger.errorModel.count

				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarChargerAlarmsAndErrorsPage.qml",
							{ "title": text, "solarCharger": root.solarCharger })
				}

				DataPoint {
					id: lowBatteryAlarm
					source: root.solarCharger.serviceUid + "/Alarms/LowVoltage"
				}
				DataPoint {
					id: highBatteryAlarm
					source: root.solarCharger.serviceUid + "/Alarms/HighVoltage"
				}
			}

			ListNavigationItem {
				//: View solar charger yield history
				//% "History"
				text: qsTrId("charger_history")
				onClicked: {
					//: Solar charger historic data information. %1 = charger name
					//% "%1 History"
					const title = qsTrId("charger_history_name").arg(root.solarCharger.name)
					Global.pageManager.pushPage("/pages/solar/SolarChargerHistoryPage.qml",
							{ "title": title, "solarCharger": root.solarCharger })
				}
			}

			ListNavigationItem {
				//% "Networked operation"
				text: qsTrId("charger_networked_operation")
				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarChargerNetworkedOperationPage.qml",
							{ "title": text, "solarCharger": root.solarCharger })
				}
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.solarCharger.serviceUid })
				}
			}
		}
	}
}
