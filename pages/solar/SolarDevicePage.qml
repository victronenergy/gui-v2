/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string serviceUid
	readonly property SolarTracker singleTracker: solarDevice.trackerCount === 1 ? firstTracker : null

	title: solarDevice.name

	SolarDevice {
		id: solarDevice
		serviceUid: root.serviceUid
	}

	SolarTracker {
		id: firstTracker
		serviceUid: root.serviceUid
		trackerIndex: 0
		trackerCount: solarDevice.trackerCount
	}

	VeQuickItem {
		id: overallYieldToday
		uid: root.serviceUid + "/History/Daily/0/Yield"
	}

	VeQuickItem {
		id: stateItem
		uid: solarDevice.serviceUid + "/State"
	}

	GradientListView {
		model: VisibleItemModel {
			BaseListItem {
				width: parent?.width ?? 0
				height: trackerTable.y + trackerTable.height

				// When there is only one tracker, this table shows the overall voltage and current.
				// Otherwise, the voltage and current are shown per-tracker in the tracker table.
				QuantityTableSummary {
					id: trackerSummary

					width: parent.width
					columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_small
					summaryHeaderText: CommonWords.state
					summaryModel: [
						{ text: CommonWords.yield_today, unit: VenusOS.Units_Energy_KiloWattHour },
						{ text: root.singleTracker ? CommonWords.voltage : "", unit: VenusOS.Units_Volt_DC },
						{ text: root.singleTracker ? CommonWords.current_amps : "", unit: VenusOS.Units_Amp },
						{
							text: root.singleTracker
								   ? CommonWords.pv_power
									 //% "Total PV Power"
								   : qsTrId("charger_total_pv_power"),
							unit: VenusOS.Units_Watt
						}
					]

					bodyHeaderText: VenusOS.solarCharger_stateToText(stateItem.value)
					bodyModel: QuantityObjectModel {
						QuantityObject { object: overallYieldToday; unit: VenusOS.Units_Energy_KiloWattHour }
						QuantityObject { object: root.singleTracker; key: "voltage"; unit: VenusOS.Units_Volt_DC; hidden: !root.singleTracker }
						QuantityObject { object: root.singleTracker; key: "current"; unit: VenusOS.Units_Amp; hidden: !root.singleTracker }
						QuantityObject { object: solarDevice; key: "power"; unit: VenusOS.Units_Watt }
					}
				}

				QuantityTable {
					id: trackerTable

					anchors.top: trackerSummary.bottom
					width: parent.width
					rightPadding: trackerSummary.rightPadding
					columnSpacing: trackerSummary.columnSpacing
					metricsFontSize: trackerSummary.metricsFontSize
					model: solarDevice.trackerCount > 1 ? solarDevice.trackerCount : 0
					header: count > 0 ? tableHeaderComponent : null

					delegate: QuantityTable.TableRow {
						id: tableRow

						preferredVisible: tracker.enabled
						headerText: tracker.name
						model: QuantityObjectModel {
							QuantityObject { object: tracker; key: "todaysYield"; unit: VenusOS.Units_Energy_KiloWattHour }
							QuantityObject { object: tracker; key: "voltage"; unit: VenusOS.Units_Volt_DC }
							QuantityObject { object: tracker; key: "current"; unit: VenusOS.Units_Amp }
							QuantityObject { object: tracker; key: "power"; unit: VenusOS.Units_Watt }
						}

						SolarTracker {
							id: tracker
							serviceUid: root.serviceUid
							trackerIndex: tableRow.index
							trackerCount: solarDevice.trackerCount
						}
					}

					Component {
						id: tableHeaderComponent

						QuantityTable.TableHeader {
							headerText: CommonWords.tracker
							model: [
								{ text: CommonWords.yield_today, unit: VenusOS.Units_Energy_KiloWattHour },
								{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
								{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
								{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt }
							]
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
					uid: solarDevice.serviceUid + "/Dc/0/Voltage"
				}

				VeQuickItem {
					id: batteryCurrent
					uid: solarDevice.serviceUid + "/Dc/0/Current"
				}

			}

			ListRelayState {
				dataItem.uid: solarDevice.serviceUid + "/Relay/0/State"
			}

			ListText {
				text: CommonWords.error
				dataItem.uid: solarDevice.serviceUid + "/ErrorCode"
				secondaryText: ChargerError.description(dataItem.value)
			}

			ListNavigation {
				text: CommonWords.history
				preferredVisible: daysAvailable.valid && daysAvailable.value > 0
				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
							{ "serviceUid": solarDevice.serviceUid })
				}

				VeQuickItem {
					id: daysAvailable
					uid: solarDevice.serviceUid + "/History/Overall/DaysAvailable"
				}
			}

			ListNavigation {
				id: productPageLink

				readonly property string pageUrl: {
					const serviceType = BackendConnection.serviceTypeFromUid(solarDevice.serviceUid)
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
					Global.pageManager.pushPage(pageUrl, { title: text, bindPrefix: solarDevice.serviceUid })
				}
			}
		}
	}
}
