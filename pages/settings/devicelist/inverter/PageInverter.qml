/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	readonly property bool isInverterCharger: isInverterChargerItem.value === 1

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.bindPrefix + "/IsInverterCharger"
	}

	GradientListView {
		model: VisibleItemModel {
			ListItem {
				id: modeListButton

				text: CommonWords.mode
				writeAccessLevel: VenusOS.User_AccessType_User
				content.children: [
					InverterChargerModeButton {
						width: Math.min(implicitWidth, modeListButton.maximumContentWidth)
						serviceUid: root.bindPrefix
					}
				]
			}

			ListText {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}

			InverterAcOutSettings {
				bindPrefix: root.bindPrefix
			}

			ListQuantityGroup {
				text: CommonWords.dc
				textModel: [
					{ value: dcVoltage.value, unit: VenusOS.Units_Volt_DC },
					{ value: dcCurrent.value, unit: VenusOS.Units_Amp },
				]

				VeQuickItem {
					id: dcVoltage
					uid: root.bindPrefix + "/Dc/0/Voltage"
				}

				VeQuickItem {
					id: dcCurrent
					uid: root.bindPrefix + "/Dc/0/Current"
				}
			}

			ListQuantityGroup {
				//% "PV"
				text: qsTrId("inverter_pv")
				preferredVisible: pvV.isValid || pvYield.isValid
				textModel: [
					{ value: pvV.value, unit: VenusOS.Units_Volt_DC },
					{ value: pvYield.value, unit: VenusOS.Units_Watt },
				]

				VeQuickItem {
					id: pvV
					uid: root.bindPrefix + "/Pv/V"
				}

				VeQuickItem {
					id: pvYield
					uid: root.bindPrefix + "/Yield/Power"
				}
			}

			ListQuantity {
				//% "Total yield"
				text: qsTrId("inverter_total_yield")
				preferredVisible: dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/User"
			}

			ListQuantity {
				//% "System yield"
				text: qsTrId("inverter_system_yield")
				preferredVisible: dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/System"
			}

			ListQuantity {
				text: CommonWords.state_of_charge
				preferredVisible: root.isInverterCharger
				unit: VenusOS.Units_Percentage
				dataItem.uid: root.bindPrefix + "/Soc"
			}

			ListTemperature {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
				preferredVisible: dataItem.isValid
			}

			ListText {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				preferredVisible: root.isInverterCharger
				secondaryText: ChargerError.description(dataItem.value)
			}

			ListRelayState {
				dataItem.uid: root.bindPrefix + "/Relay/0/State"
			}

			ListNavigation {
				property SolarHistory solarHistory

				text: CommonWords.daily_history
				preferredVisible: (numberOfTrackers.value || 0) > 0
				onClicked: {
					if (!solarHistory) {
						solarHistory = solarHistoryComponent.createObject(root)
					}
					Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
							{ "solarHistory": solarHistory })
				}

				VeQuickItem {
					id: numberOfTrackers
					uid: root.bindPrefix + "/NrOfTrackers"
				}

				Component {
					id: solarHistoryComponent

					SolarHistory {
						id: solarHistory

						bindPrefix: root.bindPrefix
						deviceName: solarDevice.name
						trackerCount: numberOfTrackers.value || 0

						readonly property Device solarDevice: Device {
							serviceUid: root.bindPrefix
						}
					}
				}
			}

			ListNavigation {
				text: CommonWords.overall_history
				preferredVisible: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigation {
				text: CommonWords.alarm_status
				preferredVisible: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarms.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigation {
				text: CommonWords.alarm_setup
				preferredVisible: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarmSettings.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
