/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	title: device.name

	Device {
		id: device
		serviceUid: root.bindPrefix
	}

	GradientListView {
		model: ObjectModel {
			ListSwitch {
				text: CommonWords.switch_mode
				dataItem.uid: root.bindPrefix + "/Mode"
				valueTrue: 1
				valueFalse: 4
				allowed: defaultAllowed && dataItem.isValid
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListText {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}

			ListSpinBox {
				text: CommonWords.input_current_limit
				writeAccessLevel: VenusOS.User_AccessType_User
				allowed: defaultAllowed && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/Ac/In/CurrentLimit"
				suffix: Units.defaultUnitString(VenusOS.Units_Amp)
				stepSize: 0.1
				decimals: 1
			}

			Column {
				width: parent ? parent.width : 0

				VeQuickItem {
					id: nrOfOutputs
					uid: root.bindPrefix + "/NrOfOutputs"
				}

				Repeater {
					model: nrOfOutputs.value || 1
					delegate: ListQuantityGroup {
						//: %1 = battery number
						//% "Battery %1"
						text: qsTrId("settings_accharger_battery").arg(model.index + 1)
						textModel: [
							{ value: dcVoltage.value, unit: VenusOS.Units_Volt_DC },
							{ value: dcCurrent.value, unit: VenusOS.Units_Amp },
						]

						VeQuickItem {
							id: dcVoltage
							uid: root.bindPrefix + "/Dc/%1/Voltage".arg(model.index)
						}

						VeQuickItem {
							id: dcCurrent
							uid: root.bindPrefix + "/Dc/%1/Current".arg(model.index)
						}
					}
				}
			}

			ListTemperature {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListQuantity {
				//% "AC current"
				text: qsTrId("settings_accharger_current")
				unit: VenusOS.Units_Amp
				dataItem.uid: root.bindPrefix + "/Ac/In/L1/I"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Low battery voltage alarm"
				text: qsTrId("settings_accharger_low_battery_voltage_alarm")
				dataItem.uid: root.bindPrefix + "/Alarms/LowVoltage"
				allowed: dataItem.isValid
			}

			ListAlarm {
				id: highBatteryAlarm

				//% "High battery voltage alarm"
				text: qsTrId("settings_accharger_high_battery_voltage_alarm")
				dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
				allowed: dataItem.isValid
			}

			ListText {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				secondaryText: dataItem.isValid ? ChargerError.description(dataItem.value) : dataItem.invalidText
			}

			// This is the master´s relay state
			ListRelayState {
				dataItem.uid: root.bindPrefix + "/Relay/0/State"
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
