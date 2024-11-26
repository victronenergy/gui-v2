/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property bool locked: lock.isValid && lock.value

	VeQuickItem {
		id: lock
		uid: root.bindPrefix + "/Settings/Battery/Locked"
	}

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				//% "Nominal Voltage"
				text: qsTrId("batterysettingsbattery_nominal_voltage")
				dataItem.uid: root.bindPrefix + "/Settings/Battery/NominalVoltage"
				optionModel: [
					//% "12 Volt"
					{ display: qsTrId("batterysettingsbattery_12_volt"), value: 12 },
					//% "24 Volt"
					{ display: qsTrId("batterysettingsbattery_24_volt"), value: 24 },
					//% "48 Volt"
					{ display: qsTrId("batterysettingsbattery_48_volt"), value: 48 },
				]
				allowed: defaultAllowed && dataItem.isValid
			}

			ListSpinBox {
				//% "Capacity"
				text: qsTrId("batterysettingsbattery_capacity")
				allowed: defaultAllowed && dataItem.isValid
				enabled: !root.locked
				dataItem.uid: root.bindPrefix + "/Settings/Battery/Capacity"
				suffix: "Ah"
			}

			ListSpinBox {
				//% "Charged voltage"
				text: qsTrId("batterysettingsbattery_charged_voltage")
				allowed: defaultAllowed && dataItem.isValid
				enabled: !root.locked
				dataItem.uid: root.bindPrefix + "/Settings/Battery/ChargedVoltage"
				suffix: "V"
				decimals: 1
				stepSize: 0.1
			}

			ListSpinBox {
				//% "Tail current"
				text: qsTrId("batterysettingsbattery_tail_current")
				enabled: !root.locked
				allowed: defaultAllowed && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/Settings/Battery/TailCurrent"
				suffix: "%"
				decimals: 1
				stepSize: 0.1
			}

			ListSpinBox {
				//% "Charged detection time"
				text: qsTrId("batterysettingsbattery_charged_detection_time")
				enabled: !root.locked
				allowed: defaultAllowed && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/Settings/Battery/ChargedDetectionTime"
				suffix: "min"
			}

			ListSpinBox {
				//% "Peukert exponent"
				text: qsTrId("batterysettingsbattery_peukert_exponent")
				enabled: !root.locked
				allowed: defaultAllowed && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/Settings/Battery/PeukertExponent"
				decimals: 2
				stepSize: 0.01
			}

			ListSpinBox {
				//% "Charge efficiency factor"
				text: qsTrId("batterysettingsbattery_charge_efficiency_factor")
				enabled: !root.locked
				allowed: defaultAllowed && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/Settings/Battery/ChargeEfficiency"
				suffix: "%"
			}

			ListSpinBox {
				//% "Current threshold"
				text: qsTrId("batterysettingsbattery_current_threshold")
				enabled: !root.locked
				allowed: defaultAllowed && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/Settings/Battery/CurrentThreshold"
				suffix: Units.defaultUnitString(VenusOS.Units_Amp)
				decimals: 2
				stepSize: 0.01
			}

			ListSpinBox {
				//% "Time-to-go averaging period"
				text: qsTrId("batterysettingsbattery_time_to_go_averaging_period")
				enabled: !root.locked
				allowed: defaultAllowed && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/Settings/Battery/TTGAveragingPeriod"
				suffix: "min"
			}

			PrimaryListLabel {
				//% "Note that changing the Time-to-go discharge floor setting also changes the Low state-of-charge setting in the relay menu."
				text: qsTrId("batterysettingsbattery_time_to_go_discharge_note")
				allowed: dischargeFloorLinkedToRelay.isValid && dischargeFloorLinkedToRelay.value !== 0

				VeQuickItem {
					id: dischargeFloorLinkedToRelay
					uid: root.bindPrefix + "/Settings/DischargeFloorLinkedToRelay"
				}
			}

			ListSpinBox {
				//% "Time-to-go discharge floor"
				text: qsTrId("batterysettingsbattery_time_to_go_discharge_floor")
				enabled: !root.locked
				allowed: defaultAllowed && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/Settings/Battery/DischargeFloor"
				suffix: "%"
			}

			ListText {
				//% "Current offset"
				text: qsTrId("batterysettingsbattery_current_offset")
				dataItem.uid: root.bindPrefix + "/Settings/Battery/CurrentOffset"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListButton {
				//% "Synchronise state-of-charge to 100%"
				text: qsTrId("batterysettingsbattery_synchronise_state_of_charge_to_100%")
				//% "Press to sync"
				secondaryText: qsTrId("batterysettingsbattery_press_to_sync")
				enabled: !root.locked
				onClicked: sync.setValue(1)
				allowed: sync.isValid

				VeQuickItem {
					id: sync
					uid: root.bindPrefix + "/Settings/Battery/Synchronize"
				}
			}

			ListButton {
				//% "Calibrate zero current"
				text: qsTrId("batterysettingsbattery_calibrate_zero_current")
				//% "Press to set to 0"
				secondaryText: qsTrId("batterysettingsbattery_press_to_set_to_0")
				onClicked: zero.setValue(1)
				allowed: zero.isValid

				VeQuickItem {
					id: zero
					uid: root.bindPrefix + "/Settings/Battery/ZeroCurrent"
				}
			}
		}
	}
}
