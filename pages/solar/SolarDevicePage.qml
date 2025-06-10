/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property SolarDevice solarDevice
	readonly property SolarTracker singleTracker: solarDevice.trackerCount === 1 ? firstTracker : null

	title: solarDevice.name

	SolarTracker {
		id: firstTracker
		device: root.solarDevice
		trackerIndex: 0
	}

	VeQuickItem {
		id: stateItem
		uid: root.solarDevice.serviceUid + "/State"
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
						id: summaryModel
						readonly property real todaysYield: root.solarDevice.dailyHistory(0)?.yieldKwh ?? NaN

						QuantityObject { object: summaryModel; key: "todaysYield"; unit: VenusOS.Units_Energy_KiloWattHour }
						QuantityObject { object: root.singleTracker; key: "voltage"; unit: VenusOS.Units_Volt_DC; hidden: !root.singleTracker }
						QuantityObject { object: root.singleTracker; key: "current"; unit: VenusOS.Units_Amp; hidden: !root.singleTracker }
						QuantityObject { object: root.solarDevice; key: "power"; unit: VenusOS.Units_Watt }
					}
				}

				QuantityTable {
					id: trackerTable

					anchors.top: trackerSummary.bottom
					width: parent.width
					rightPadding: trackerSummary.rightPadding
					columnSpacing: trackerSummary.columnSpacing
					metricsFontSize: trackerSummary.metricsFontSize
					visible: root.solarDevice.trackerCount > 1

					model: root.solarDevice.trackerCount > 1 ? root.solarDevice.trackerCount : 0
					header: QuantityTable.TableHeader {
						headerText: CommonWords.tracker
						model: [
							{ text: CommonWords.yield_today, unit: VenusOS.Units_Energy_KiloWattHour },
							{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
							{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
							{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt }
						]
					}
					delegate: QuantityTable.TableRow {
						id: tableRow

						required property int index

						// Today's yield for this tracker
						readonly property real todaysYield: root.solarDevice.dailyTrackerHistory(0, index)?.yieldKwh ?? NaN

						preferredVisible: tracker.enabled
						headerText: Global.solarInputs.formatTrackerName(
								  tracker.name, index, root.trackerCount, root.solarDevice.name,
								  VenusOS.TrackerName_NoDevicePrefix)
						model: QuantityObjectModel {
							QuantityObject { object: tableRow; key: "todaysYield"; unit: VenusOS.Units_Energy_KiloWattHour }
							QuantityObject { object: tracker; key: "voltage"; unit: VenusOS.Units_Volt_DC }
							QuantityObject { object: tracker; key: "current"; unit: VenusOS.Units_Amp }
							QuantityObject { object: tracker; key: "power"; unit: VenusOS.Units_Watt }
						}

						SolarTracker {
							id: tracker
							device: root.solarDevice
							trackerIndex: tableRow.index
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
