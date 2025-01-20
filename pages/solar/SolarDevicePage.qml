/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix
	readonly property SolarCharger solarCharger: Global.solarChargers.model.deviceAt(Global.solarChargers.model.indexOf(bindPrefix))
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
							text: VenusOS.solarCharger_stateToText(root.solarCharger.state),
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

			ListSwitch {
				text: CommonWords.relay
				checked: root.solarCharger.relayOn
				secondaryText: CommonWords.onOrOff(root.solarCharger.relayOn)
				preferredVisible: root.solarCharger.relayValid
				enabled: false
			}

			ListText {
				text: CommonWords.error
				dataItem.uid: root.solarCharger.serviceUid + "/ErrorCode"
				secondaryText: ChargerError.description(dataItem.value)
			}

			ListNavigation {
				text: CommonWords.history
				preferredVisible: root.solarCharger.history.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
							{ "solarHistory": root.solarCharger.history })
				}
			}

			ListNavigation {
				id: productPageLink

				readonly property string pageUrl: {
					const serviceType = BackendConnection.serviceTypeFromUid(root.solarCharger.serviceUid)
					if (serviceType === "solarcharger") {
						return "/pages/solar/PageSolarCharger.qml"
					} else if (serviceType === "multi") {
						return "/pages/settings/devicelist/rs/PageMultiRs.qml"
					} else if (serviceType === "inverter") {
						return "/pages/settings/devicelist/inverter/PageInverter.qml"
					} else {
						return ""
					}
				}

				text: CommonWords.product_page
				preferredVisible: pageUrl.length > 0
				onClicked: {
					Global.pageManager.pushPage(pageUrl, { title: text, bindPrefix: root.solarCharger.serviceUid })
				}
			}

			ListNavigation {
				text: CommonWords.device_info_title
				preferredVisible: productPageLink.pageUrl.length === 0
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.solarCharger.serviceUid })
				}
			}
		}
	}
}
