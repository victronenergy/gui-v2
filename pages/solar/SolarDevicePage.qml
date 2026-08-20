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
		header: ListItem {
			id: tableListItem

			topPadding: 0
			bottomPadding: bottomInset
			leftPadding: leftInset
			rightPadding: rightInset
			contentItem: HorizontalFlickable {
				implicitHeight: trackerTable.y + trackerTable.height
				contentWidth: Math.max(Theme.geometry_quantityTable_maximumWidth_large, tableListItem.availableWidth)

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
							text: root.singleTracker ? CommonWords.pv_power : CommonWords.total_power,
							unit: VenusOS.Units_Watt
						}
					]

					bodyHeaderText: solarDevice.serviceType === "inverter"
							? VenusOS.inverter_stateToText(stateItem.value)
							: VenusOS.solarCharger_stateToText(stateItem.value)
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
		}

		model: DelegateComponentModel {
			DelegateComponent {
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
			}

			DelegateComponent {
				ListRelayState {
					dataItem.uid: solarDevice.serviceUid + "/Relay/0/State"
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.error
					dataItem.uid: solarDevice.serviceUid + "/ErrorCode"
					secondaryText: ChargerError.description(dataItem.value)
				}
			}

			DelegateComponent {
				id: daysAvailableDC
				dataItem: VeQuickItem { uid: solarDevice.serviceUid + "/History/Overall/DaysAvailable" }
				preferredVisible: daysAvailableDC.dataItem.valid && daysAvailableDC.dataItem.value > 0
				ListNavigation {
					text: CommonWords.history
					onClicked: {
						Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
								{ "serviceUid": solarDevice.serviceUid })
					}

					VeQuickItem {
						id: daysAvailable
						uid: solarDevice.serviceUid + "/History/Overall/DaysAvailable"
					}
				}
			}

			DelegateComponent {
				id: productPageLinkDC
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
				preferredVisible: productPageLinkDC.pageUrl.length > 0
				ListNavigation {
					text: CommonWords.product_page
					onClicked: {
						Global.pageManager.pushPage(productPageLinkDC.pageUrl, { title: text, bindPrefix: solarDevice.serviceUid })
					}
				}
			}
		}
	}
}
