/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property QtObject solarCharger
	readonly property QtObject singleTracker: solarCharger.trackers.count === 1 ? solarCharger.trackers.get(0).solarTracker : null

	title: solarCharger.name

	GradientListView {
		model: ObjectModel {
			ListItemBackground {
				height: trackerTable.y + trackerTable.height

				QuantityTableSummary {
					id: trackerSummary

					x: Theme.geometry_listItem_content_horizontalMargin
					width: parent.width - Theme.geometry_listItem_content_horizontalMargin

					model: [
						{
							title: CommonWords.state,
							text: Global.solarChargers.chargerStateToText(root.solarCharger.state),
							unit: VenusOS.Units_None,
						},
						{
							title: CommonWords.yield_today,
							value: root.solarCharger.dailyHistory(0).yieldKwh || 0,
							unit: VenusOS.Units_Energy_KiloWattHour
						},
						{
							title: root.singleTracker ? CommonWords.voltage : "",
							value: root.singleTracker ? root.singleTracker.voltage : NaN,
							unit: root.singleTracker ? VenusOS.Units_Volt : VenusOS.Units_None
						},
						{
							title: root.singleTracker ? CommonWords.current_amps : "",
							value: root.singleTracker ? root.singleTracker.current : NaN,
							unit: root.singleTracker ? VenusOS.Units_Amp : VenusOS.Units_None
						},
						{
							title: root.singleTracker
								   ? CommonWords.pv_power
									 //% "Total PV Power"
								   : qsTrId("charger_total_pv_power"),
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
						{ title: CommonWords.tracker, unit: VenusOS.Units_None },
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
				height: Theme.geometry_gradientList_spacing
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

			/* Only available on 15A chargers */
			ListTextItem {
				//% "Load"
				text: qsTrId("charger_load")
				dataItem.uid: root.solarCharger.serviceUid + "/Load/State"
				visible: defaultVisible && dataItem.isValid

				/* If load is on and current present, show current.
				 * Otherwise show the state of the load output. */
				secondaryText: dataItem.isValid && dataItem.value && loadCurrent.isValid
						? loadCurrent.value
						: CommonWords.yesOrNo(dataItem.value)

				VeQuickItem {
					id: loadCurrent
					uid: root.solarCharger.serviceUid + "/Load/I"
				}
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
					: CommonWords.none_errors
				secondaryLabel.color: root.solarCharger.errorModel.count ? Theme.color_critical : Theme.color_font_secondary

				// Only enable if there is content on the alarms/errors page.
				// TODO update this binding to consider 'active alarms' section when it is
				// implemented for the page.
				enabled: lowBatteryAlarm.isValid || highBatteryAlarm.isValid
						 || root.solarCharger.errorModel.count

				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarChargerAlarmsAndErrorsPage.qml",
							{ "title": text, "solarCharger": root.solarCharger })
				}

				VeQuickItem {
					id: lowBatteryAlarm
					uid: root.solarCharger.serviceUid + "/Alarms/LowVoltage"
				}
				VeQuickItem {
					id: highBatteryAlarm
					uid: root.solarCharger.serviceUid + "/Alarms/HighVoltage"
				}
			}

			ListNavigationItem {
				text: CommonWords.history
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
