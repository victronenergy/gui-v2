/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property SolarDevice solarDevice
	readonly property SolarTracker singleTracker: trackerObjects.count === 1 ? trackerObjects.objectAt(0) : null

	title: solarDevice.name

	VeQuickItem {
		id: stateItem
		uid: root.solarDevice.serviceUid + "/State"
	}

	GradientListView {
		model: VisibleItemModel {
			BaseListItem {
				width: parent ? parent.width : 0
				height: trackerTable.y + trackerTable.height

				// When there is only one tracker, this table shows the overall voltage and current.
				// Otherwise, the voltage and current are shown per-tracker in the tracker table.
				QuantityTableSummary {
					id: trackerSummary

					model: [
						{
							title: CommonWords.state,
							text: VenusOS.solarCharger_stateToText(stateItem.value),
							unit: VenusOS.Units_None,
						},
						{
							title: CommonWords.yield_today,
							value: root.solarDevice.dailyHistory(0)?.yieldKwh ?? NaN,
							unit: VenusOS.Units_Energy_KiloWattHour
						},
						{
							title: root.singleTracker ? CommonWords.voltage : "",
							value: root.singleTracker?.voltage ?? NaN,
							unit: root.singleTracker ? VenusOS.Units_Volt_DC : VenusOS.Units_None,
						},
						{
							title: root.singleTracker ? CommonWords.current_amps : "",
							value: root.singleTracker?.current ?? NaN,
							unit: root.singleTracker ? VenusOS.Units_Amp : VenusOS.Units_None
						},
						{
							title: root.singleTracker
								   ? CommonWords.pv_power
									 //% "Total PV Power"
								   : qsTrId("charger_total_pv_power"),
							value: root.solarDevice.power,
							unit: VenusOS.Units_Watt
						},
					]
				}

				QuantityTable {
					id: trackerTable

					anchors.top: trackerSummary.bottom
					visible: root.solarDevice.trackerCount > 1

					rowCount: root.solarDevice.trackerCount
					units: [
						{ title: CommonWords.tracker, unit: VenusOS.Units_None },
						{ title: trackerSummary.model[1].title, unit: VenusOS.Units_Energy_KiloWattHour },
						{ title: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
						{ title: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ title: CommonWords.power_watts, unit: VenusOS.Units_Watt }
					]
					valueForModelIndex: function(trackerIndex, column) {
						const tracker = trackerObjects.objectAt(trackerIndex)
						if (column === 0) {
							return Global.solarDevices.formatTrackerName(tracker.name, trackerIndex, root.solarDevice.trackerCount, root.solarDevice.name, VenusOS.TrackerName_NoDevicePrefix)
						} else if (column === 1) {
							// Today's yield for this tracker
							const history = root.solarDevice.dailyTrackerHistory(0, trackerIndex)
							return history ? history.yieldKwh : NaN
						} else if (column === 2) {
							return tracker.voltage
						} else if (column === 3) {
							return tracker.current
						} else if (column === 4) {
							return tracker.power
						}
					}
					rowIsVisible: function(row) {
						const tracker = trackerObjects.objectAt(row)
						return tracker.enabled
					}

					Instantiator {
						id: trackerObjects

						model: root.solarDevice.trackerCount
						delegate: SolarTracker {
							required property int index

							device: root.solarDevice
							trackerIndex: index
						}
					}
				}
			}

			ListQuantityGroup {
				text: CommonWords.battery
				model: QuantityObjectModel {
					QuantityObject { object: batteryVoltage; unit: VenusOS.Units_Volt_DC }
					QuantityObject { object: batteryCurrent; unit: VenusOS.Units_Amp }
				}

				VeQuickItem {
					id: batteryVoltage
					uid: root.solarDevice.serviceUid + "/Dc/0/Voltage"
				}

				VeQuickItem {
					id: batteryCurrent
					uid: root.solarDevice.serviceUid + "/Dc/0/Current"
				}

			}

			ListRelayState {
				dataItem.uid: root.solarDevice.serviceUid + "/Relay/0/State"
			}

			ListText {
				text: CommonWords.error
				dataItem.uid: root.solarDevice.serviceUid + "/ErrorCode"
				secondaryText: ChargerError.description(dataItem.value)
			}

			ListNavigation {
				text: CommonWords.history
				preferredVisible: root.solarDevice.history.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
							{ "solarHistory": root.solarDevice.history })
				}
			}

			ListNavigation {
				id: productPageLink

				readonly property string pageUrl: {
					const serviceType = BackendConnection.serviceTypeFromUid(root.solarDevice.serviceUid)
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
					Global.pageManager.pushPage(pageUrl, { title: text, bindPrefix: root.solarDevice.serviceUid })
				}
			}

			ListNavigation {
				text: CommonWords.device_info_title
				preferredVisible: productPageLink.pageUrl.length === 0
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.solarDevice.serviceUid })
				}
			}
		}
	}
}
