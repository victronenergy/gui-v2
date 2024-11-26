/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property SolarCharger solarCharger
	readonly property QtObject singleTracker: solarCharger.trackers.count === 1 ? solarCharger.trackers.get(0).solarTracker : null

	title: solarCharger.name

	GradientListView {
		model: ObjectModel {
			ListItemBackground {
				height: trackerTable.y + trackerTable.height

				QuantityTableSummary {
					id: trackerSummary

					model: [
						{
							title: CommonWords.state,
							text: Global.solarChargers.chargerStateToText(root.solarCharger.state),
							unit: VenusOS.Units_None,
						},
						{
							title: CommonWords.yield_today,
							value: solarCharger.dailyHistory(0)?.yieldKwh ?? NaN,
							unit: VenusOS.Units_Energy_KiloWattHour
						},
						{
							title: root.singleTracker ? CommonWords.voltage : "",
							value: root.singleTracker ? root.singleTracker.voltage : NaN,
							unit: root.singleTracker ? VenusOS.Units_Volt_DC : VenusOS.Units_None,
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
						{ title: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
						{ title: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ title: CommonWords.power_watts, unit: VenusOS.Units_Watt }
					]
					valueForModelIndex: function(trackerIndex, column) {
						const tracker = root.solarCharger.trackers.get(trackerIndex).solarTracker
						if (column === 0) {
							return Global.solarChargers.formatTrackerName(tracker.name, trackerIndex, root.solarCharger.trackers.count, root.solarCharger.name, VenusOS.TrackerName_NoDevicePrefix)
						} else if (column === 1) {
							// Today's yield for this tracker
							const history = root.solarCharger.dailyTrackerHistory(0, trackerIndex)
							return history ? history.yieldKwh : NaN
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
						unit: VenusOS.Units_Volt_DC,
					},
					{
						value: root.solarCharger.batteryCurrent,
						unit: VenusOS.Units_Amp
					},
				]
			}

			/* Only available on 15A chargers */
			/* If load is on and current present, show current.
			 * Otherwise show the state of the load output. */
			ListQuantity {
				id: loadQuantityItem

				//% "Load"
				text: qsTrId("charger_load")
				dataItem.uid: root.solarCharger.serviceUid + "/Load/I"
				unit: VenusOS.Units_Amp
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				text: loadQuantityItem.text
				dataItem.uid: root.solarCharger.serviceUid + "/Load/State"
				allowed: defaultAllowed && dataItem.isValid && !loadQuantityItem.visible
				secondaryText: CommonWords.yesOrNo(dataItem.value)
			}

			ListSwitch {
				text: CommonWords.relay
				checked: root.solarCharger.relayOn
				secondaryText: CommonWords.onOrOff(root.solarCharger.relayOn)
				allowed: root.solarCharger.relayValid
				enabled: false
			}

			ListNavigation {
				// This is the number of active alarms, plus the active error (if present).
				readonly property int itemCount: (lowBatteryAlarm.isValid && lowBatteryAlarm.value !== 0 ? 1 : 0)
						+ (highBatteryAlarm.isValid && highBatteryAlarm.value !== 0 ? 1 : 0)
						+ (highTemperatureAlarm.isValid && highTemperatureAlarm.value !== 0 ? 1 : 0)
						+ (shortCircuitAlarm.isValid && shortCircuitAlarm.value !== 0 ? 1 : 0)
						+ (root.solarCharger.errorCode > 0 ? 1 : 0)

				//% "Alarms & Errors"
				text: qsTrId("charger_alarms_alarms_and_errors")
				secondaryText: enabled
					? (itemCount > 0
						  //: Shows number of items found. %1 = number of items
						  //% "%1 found"
						? qsTrId("charger_history_found_with_count").arg(itemCount)
						: "")
					: CommonWords.none_errors
				secondaryLabel.color: itemCount ? Theme.color_critical : Theme.color_font_secondary

				// Only enable if there is content on the alarms/errors page.
				enabled: itemCount > 0 || root.solarCharger.errorModel.count

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
				VeQuickItem {
					id: highTemperatureAlarm
					uid: root.solarCharger.serviceUid + "/Alarms/HighTemperature"
				}
				VeQuickItem {
					id: shortCircuitAlarm
					uid: root.solarCharger.serviceUid + "/Alarms/ShortCircuit"
				}
			}

			ListNavigation {
				text: CommonWords.history
				allowed: root.solarCharger.history.valid
				onClicked: {
					//: Solar charger historic data information. %1 = charger name
					//% "%1 History"
					const title = qsTrId("charger_history_name").arg(root.solarCharger.name)
					Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
							{ "title": title, "solarHistory": root.solarCharger.history })
				}
			}

			ListNavigation {
				//% "Networked operation"
				text: qsTrId("charger_networked_operation")
				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarChargerNetworkedOperationPage.qml",
							{ "title": text, "solarCharger": root.solarCharger })
				}
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.solarCharger.serviceUid })
				}
			}
		}
	}
}
