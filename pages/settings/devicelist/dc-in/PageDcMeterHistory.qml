/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	readonly property bool showStarterVoltage: hasStarterVoltage.valid && hasStarterVoltage.value
	readonly property bool showTemperature: hasTemperature.valid && hasTemperature.value

	VeQuickItem {
		id: hasStarterVoltage
		uid: root.bindPrefix + "/Settings/HasStarterVoltage"
	}
	VeQuickItem {
		id: hasTemperature
		uid: root.bindPrefix + "/Settings/HasTemperature"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/History/MinimumVoltage" }
				preferredVisible: dataItem.valid
				ListQuantity {
					text: CommonWords.minimum_voltage
					dataItem.uid: root.bindPrefix + "/History/MinimumVoltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/History/MaximumVoltage" }
				preferredVisible: dataItem.valid
				ListQuantity {
					text: CommonWords.maximum_voltage
					dataItem.uid: root.bindPrefix + "/History/MaximumVoltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/History/LowVoltageAlarms" }
				preferredVisible: dataItem.valid
				ListText {
					text: CommonWords.low_voltage_alarms
					dataItem.uid: root.bindPrefix + "/History/LowVoltageAlarms"
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/History/HighVoltageAlarms" }
				preferredVisible: dataItem.valid
				ListText {
					text: CommonWords.high_voltage_alarms
					dataItem.uid: root.bindPrefix + "/History/HighVoltageAlarms"
				}
			}

			DelegateComponent {
				preferredVisible: root.showStarterVoltage
				ListText {
					//% "Low aux voltage alarms"
					text: qsTrId("dcmeter_history_low_aux_voltage_alarms")
					dataItem.uid: visible ? root.bindPrefix + "/History/LowStarterVoltageAlarms" : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.showStarterVoltage
				ListText {
					//% "High aux voltage alarms"
					text: qsTrId("dcmeter_history_high_aux_voltage_alarms")
					dataItem.uid: visible ? root.bindPrefix + "/History/HighStarterVoltageAlarms" : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.showStarterVoltage
				ListQuantity {
					//% "Minimum aux voltage"
					text: qsTrId("dcmeter_history_minimum_aux_voltage")
					dataItem.uid: visible ? root.bindPrefix + "/History/MinimumStarterVoltage" : ""
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: root.showStarterVoltage
				ListQuantity {
					//% "Maximum aux voltage"
					text: qsTrId("dcmeter_history_maximum_aux_voltage")
					dataItem.uid: visible ? root.bindPrefix + "/History/MaximumStarterVoltage" : ""
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: showTemperature
				ListTemperature {
					text: CommonWords.minimum_temperature
					dataItem.uid: root.bindPrefix + "/History/MinimumTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: showTemperature
				ListTemperature {
					text: CommonWords.maximum_temperature
					dataItem.uid: root.bindPrefix + "/History/MaximumTemperature"
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/History/EnergyOut" }
				preferredVisible: dataItem.valid
				ListQuantity {
					//% "Produced energy"
					text: qsTrId("dcmeter_history_produced_energy")
					dataItem.uid: root.bindPrefix + "/History/EnergyOut"
					unit: VenusOS.Units_Energy_KiloWattHour
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/History/EnergyIn" }
				preferredVisible: dataItem.valid
				ListQuantity {
					//% "Consumed energy"
					text: qsTrId("dcmeter_history_consumed_energy")
					dataItem.uid: root.bindPrefix + "/History/EnergyIn"
					unit: VenusOS.Units_Energy_KiloWattHour
				}
			}

			DelegateComponent {
				ListInfoLabel {
					text: CommonWords.reset_history_on_the_monitor_itself
					visible: !clearHistoryDC.clearHistoryVisible
				}
			}

			DelegateComponent {
				id: clearHistoryDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/History/CanBeCleared" }
				property VeQuickItem connectedItem: VeQuickItem { uid: root.bindPrefix + "/Connected" }
				property bool clearHistoryVisible: connectedItem.value === 1 && dataItem.value === 1
				ListClearHistoryButton {
					bindPrefix: root.bindPrefix
				}
			}
		}
	}
}
