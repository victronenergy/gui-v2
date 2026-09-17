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

	property string bindPrefix

	readonly property bool isInverterCharger: isInverterChargerItem.value === 1

	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Dc/0/Temperature"
	}
	VeQuickItem {
		id: systemItem
		uid: root.bindPrefix + "/Yield/System"
	}
	VeQuickItem {
		id: userItem
		uid: root.bindPrefix + "/Yield/User"
	}
	VeQuickItem {
		id: pvVItem
		uid: root.bindPrefix + "/Pv/V"
	}
	VeQuickItem {
		id: pvYieldPowerItem
		uid: root.bindPrefix + "/Yield/Power"
	}
	VeQuickItem {
		id: isInverterChargerItem
		uid: root.bindPrefix + "/IsInverterCharger"
	}

	serviceUid: bindPrefix
	settingsModel: DelegateComponentModel {
		DelegateComponent {
			ListInverterChargerModeButton {
				serviceUid: root.bindPrefix
			}
		}

		DelegateComponent {
			ListText {
				text: CommonWords.state
				secondaryText: VenusOS.system_stateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}
		}

		DelegateComponent {
			InverterAcOutSettings {
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			ListQuantityGroup {
				text: CommonWords.dc
				model: QuantityObjectModel {
					QuantityObject { object: dcVoltage; unit: VenusOS.Units_Volt_DC }
					QuantityObject { object: dcCurrent; unit: VenusOS.Units_Amp }
				}

				VeQuickItem {
					id: dcVoltage
					uid: root.bindPrefix + "/Dc/0/Voltage"
				}

				VeQuickItem {
					id: dcCurrent
					uid: root.bindPrefix + "/Dc/0/Current"
				}
			}
		}

		DelegateComponent {
			preferredVisible: pvVItem.valid || pvYieldPowerItem.valid
			ListQuantityGroup {
				//% "PV"
				text: qsTrId("inverter_pv")
				model: QuantityObjectModel {
					QuantityObject { object: pvV; unit: VenusOS.Units_Volt_DC }
					QuantityObject { object: pvYieldPower; unit: VenusOS.Units_Watt }
				}

				VeQuickItem {
					id: pvV
					uid: root.bindPrefix + "/Pv/V"
				}

				VeQuickItem {
					id: pvYieldPower
					uid: root.bindPrefix + "/Yield/Power"
				}
			}
		}

		DelegateComponent {
			preferredVisible: userItem.valid
			ListQuantity {
				//% "Total yield"
				text: qsTrId("inverter_total_yield")
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/User"
			}
		}

		DelegateComponent {
			preferredVisible: systemItem.valid
			ListQuantity {
				//% "System yield"
				text: qsTrId("inverter_system_yield")
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/System"
			}
		}

		DelegateComponent {
			preferredVisible: root.isInverterCharger
			ListQuantity {
				text: CommonWords.state_of_charge
				unit: VenusOS.Units_Percentage
				dataItem.uid: root.bindPrefix + "/Soc"
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem.valid
			ListTemperature {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
			}
		}

		DelegateComponent {
			preferredVisible: root.isInverterCharger
			ListText {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				secondaryText: ChargerError.description(dataItem.value)
			}
		}

		DelegateComponent {
			ListRelayState {
				dataItem.uid: root.bindPrefix + "/Relay/0/State"
			}
		}

		DelegateComponent {
			id: numberOfTrackersDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/NrOfTrackers" }
			preferredVisible: (numberOfTrackersDC.dataItem.value || 0) > 0
			ListNavigation {
				text: CommonWords.daily_history
				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
							{ "serviceUid": root.bindPrefix })
				}

				VeQuickItem {
					id: numberOfTrackers
					uid: root.bindPrefix + "/NrOfTrackers"
				}
			}
		}

		DelegateComponent {
			preferredVisible: root.isInverterCharger
			ListNavigation {
				text: CommonWords.overall_history
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}

		DelegateComponent {
			preferredVisible: root.isInverterCharger
			ListNavigation {
				text: CommonWords.alarm_status
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarms.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}

		DelegateComponent {
			preferredVisible: root.isInverterCharger
			ListNavigation {
				text: CommonWords.alarm_setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarmSettings.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}