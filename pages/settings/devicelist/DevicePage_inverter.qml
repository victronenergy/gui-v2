/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for an inverter device.
*/
DevicePage {
	id: root

	readonly property bool isInverterCharger: isInverterChargerItem.value === 1

	settingsModel: VisibleItemModel {
		ListInverterChargerModeButton {
			serviceUid: root.serviceUid
		}

		ListText {
			text: CommonWords.state
			secondaryText: VenusOS.system_stateToText(dataItem.value)
			dataItem.uid: root.serviceUid + "/State"
		}

		InverterAcOutSettings {
			bindPrefix: root.serviceUid
		}

		ListQuantityGroup {
			text: CommonWords.dc
			model: QuantityObjectModel {
				QuantityObject { object: dcVoltage; unit: VenusOS.Units_Volt_DC }
				QuantityObject { object: dcCurrent; unit: VenusOS.Units_Amp }
			}

			VeQuickItem {
				id: dcVoltage
				uid: root.serviceUid + "/Dc/0/Voltage"
			}

			VeQuickItem {
				id: dcCurrent
				uid: root.serviceUid + "/Dc/0/Current"
			}
		}

		ListQuantityGroup {
			//% "PV"
			text: qsTrId("inverter_pv")
			preferredVisible: pvV.valid || pvYieldPower.valid
			model: QuantityObjectModel {
				QuantityObject { object: pvV; unit: VenusOS.Units_Volt_DC }
				QuantityObject { object: pvYieldPower; unit: VenusOS.Units_Watt }
			}

			VeQuickItem {
				id: pvV
				uid: root.serviceUid + "/Pv/V"
			}

			VeQuickItem {
				id: pvYieldPower
				uid: root.serviceUid + "/Yield/Power"
			}
		}

		ListQuantity {
			//% "Total yield"
			text: qsTrId("inverter_total_yield")
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Energy_KiloWattHour
			dataItem.uid: root.serviceUid + "/Yield/User"
		}

		ListQuantity {
			//% "System yield"
			text: qsTrId("inverter_system_yield")
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Energy_KiloWattHour
			dataItem.uid: root.serviceUid + "/Yield/System"
		}

		ListQuantity {
			text: CommonWords.state_of_charge
			preferredVisible: root.isInverterCharger
			unit: VenusOS.Units_Percentage
			dataItem.uid: root.serviceUid + "/Soc"
		}

		ListTemperature {
			text: CommonWords.battery_temperature
			dataItem.uid: root.serviceUid + "/Dc/0/Temperature"
			preferredVisible: dataItem.valid
		}

		ListText {
			text: CommonWords.error
			dataItem.uid: root.serviceUid + "/ErrorCode"
			preferredVisible: root.isInverterCharger
			secondaryText: ChargerError.description(dataItem.value)
		}

		ListRelayState {
			dataItem.uid: root.serviceUid + "/Relay/0/State"
		}

		ListNavigation {
			text: CommonWords.daily_history
			preferredVisible: (numberOfTrackers.value || 0) > 0
			onClicked: {
				Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
						{ "serviceUid": root.serviceUid })
			}

			VeQuickItem {
				id: numberOfTrackers
				uid: root.serviceUid + "/NrOfTrackers"
			}
		}

		ListNavigation {
			text: CommonWords.overall_history
			preferredVisible: root.isInverterCharger
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}

		ListNavigation {
			text: CommonWords.alarm_status
			preferredVisible: root.isInverterCharger
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarms.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}

		ListNavigation {
			text: CommonWords.alarm_setup
			preferredVisible: root.isInverterCharger
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarmSettings.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}
	}

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.serviceUid + "/IsInverterCharger"
	}

}
