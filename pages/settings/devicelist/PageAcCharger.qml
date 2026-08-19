/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a charger device.
*/
DevicePage {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: nrOfOutputs
		uid: root.bindPrefix + "/NrOfOutputs"
	}
	VeQuickItem {
		id: highVoltageItem
		uid: root.bindPrefix + "/Alarms/HighVoltage"
	}
	VeQuickItem {
		id: lowVoltageItem
		uid: root.bindPrefix + "/Alarms/LowVoltage"
	}
	VeQuickItem {
		id: iItem
		uid: root.bindPrefix + "/Ac/In/L1/I"
	}
	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Dc/0/Temperature"
	}
	VeQuickItem {
		id: currentLimitItem
		uid: root.bindPrefix + "/Ac/In/CurrentLimit"
	}
	VeQuickItem {
		id: modeItem
		uid: root.bindPrefix + "/Mode"
	}

	serviceUid: bindPrefix

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			preferredVisible: modeItem.valid
			ListSwitch {
				text: CommonWords.switch_mode
				dataItem.uid: root.bindPrefix + "/Mode"
				valueTrue: 1
				valueFalse: 4
				writeAccessLevel: VenusOS.User_AccessType_User
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
			preferredVisible: currentLimitItem.valid
			ListSpinBox {
				text: CommonWords.input_current_limit
				writeAccessLevel: VenusOS.User_AccessType_User
				dataItem.uid: root.bindPrefix + "/Ac/In/CurrentLimit"
				suffix: Units.defaultUnitString(VenusOS.Units_Amp)
				stepSize: 0.1
				decimals: 1
			}
		}

		DelegateComponent {
			preferredVisible: nrOfOutputs.valid
			SettingsColumn {
				width: parent ? parent.width : 0

				Repeater {
					id: outputRepeater
					model: nrOfOutputs.value || 1
					delegate: ListQuantityGroup {
						id: phaseDelegate

						required property int index
						readonly property string bindPrefix: `${root.bindPrefix}/Dc/${index}`

						//: %1 = battery number
						//% "Battery %1"
						text: qsTrId("settings_accharger_battery").arg(index + 1)
						model: QuantityObjectModel {
							QuantityObject { object: dcVoltage; unit: VenusOS.Units_Volt_DC }
							QuantityObject { object: dcCurrent; unit: VenusOS.Units_Amp }
						}

						VeQuickItem {
							id: dcVoltage
							uid: phaseDelegate.bindPrefix + "/Voltage"
						}

						VeQuickItem {
							id: dcCurrent
							uid: phaseDelegate.bindPrefix + "/Current"
						}
					}
				}
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
			preferredVisible: iItem.valid
			ListQuantity {
				//% "AC current"
				text: qsTrId("settings_accharger_current")
				unit: VenusOS.Units_Amp
				dataItem.uid: root.bindPrefix + "/Ac/In/L1/I"
			}
		}

		DelegateComponent {
			preferredVisible: lowVoltageItem.valid
			ListAlarm {
				//% "Low battery voltage alarm"
				text: qsTrId("settings_accharger_low_battery_voltage_alarm")
				dataItem.uid: root.bindPrefix + "/Alarms/LowVoltage"
			}
		}

		DelegateComponent {
			preferredVisible: highVoltageItem.valid
			ListAlarm {
				id: highBatteryAlarm

				//% "High battery voltage alarm"
				text: qsTrId("settings_accharger_high_battery_voltage_alarm")
				dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
			}
		}

		DelegateComponent {
			ListText {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
			}
		}

		DelegateComponent {
			// This is the master´s relay state
			ListRelayState {
				dataItem.uid: root.bindPrefix + "/Relay/0/State"
			}
		}
	}
}