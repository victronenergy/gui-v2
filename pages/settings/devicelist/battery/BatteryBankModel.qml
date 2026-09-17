/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DelegateComponentModel {
	id: root

	required property string bindPrefix
	readonly property bool locked: lock.valid && lock.value

	readonly property VeQuickItem lock: VeQuickItem {
		uid: root.bindPrefix + "/Settings/Battery/Locked"
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/NominalVoltage" }
		preferredVisible: dataItem.valid
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
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/Capacity" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Capacity"
			text: qsTrId("batterysettingsbattery_capacity")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/Capacity"
			suffix: "Ah"
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/ChargedVoltage" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Charged voltage"
			text: qsTrId("batterysettingsbattery_charged_voltage")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/ChargedVoltage"
			suffix: "V"
			decimals: 1
			stepSize: 0.1
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/TailCurrent" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Tail current"
			text: qsTrId("batterysettingsbattery_tail_current")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/TailCurrent"
			suffix: "%"
			decimals: 1
			stepSize: 0.1
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/ChargedDetectionTime" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Charged detection time"
			text: qsTrId("batterysettingsbattery_charged_detection_time")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/ChargedDetectionTime"
			suffix: "min"
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/PeukertExponent" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Peukert exponent"
			text: qsTrId("batterysettingsbattery_peukert_exponent")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/PeukertExponent"
			decimals: 2
			stepSize: 0.01
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/ChargeEfficiency" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Charge efficiency factor"
			text: qsTrId("batterysettingsbattery_charge_efficiency_factor")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/ChargeEfficiency"
			suffix: "%"
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/CurrentThreshold" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Current threshold"
			text: qsTrId("batterysettingsbattery_current_threshold")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/CurrentThreshold"
			suffix: Units.defaultUnitString(VenusOS.Units_Amp)
			decimals: 2
			stepSize: 0.01
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/TTGAveragingPeriod" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Time-to-go averaging period"
			text: qsTrId("batterysettingsbattery_time_to_go_averaging_period")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/TTGAveragingPeriod"
			suffix: "min"
		}
	}

	DelegateComponent {
		id: dischargeFloorLinkedToRelayDC
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/DischargeFloorLinkedToRelay" }
		preferredVisible: dischargeFloorLinkedToRelayDC.dataItem.valid && dischargeFloorLinkedToRelayDC.dataItem.value !== 0
		PrimaryListLabel {
			//% "Note that changing the Time-to-go discharge floor setting also changes the Low state-of-charge setting in the relay menu."
			text: qsTrId("batterysettingsbattery_time_to_go_discharge_note")

			VeQuickItem {
				id: dischargeFloorLinkedToRelay
				uid: root.bindPrefix + "/Settings/DischargeFloorLinkedToRelay"
			}
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/DischargeFloor" }
		preferredVisible: dataItem.valid
		ListSpinBox {
			//% "Time-to-go discharge floor"
			text: qsTrId("batterysettingsbattery_time_to_go_discharge_floor")
			interactive: dataItem.valid && !root.locked
			dataItem.uid: root.bindPrefix + "/Settings/Battery/DischargeFloor"
			suffix: "%"
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/CurrentOffset" }
		preferredVisible: dataItem.valid
		ListText {
			//% "Current offset"
			text: qsTrId("batterysettingsbattery_current_offset")
			dataItem.uid: root.bindPrefix + "/Settings/Battery/CurrentOffset"
		}
	}

	DelegateComponent {
		id: syncDC
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/Synchronize" }
		preferredVisible: syncDC.dataItem.valid
		ListButton {
			//% "Synchronise state-of-charge to 100%"
			text: qsTrId("batterysettingsbattery_synchronise_state_of_charge_to_100%")
			//: Trigger a synchronisation of the battery SOC
			//% "Sync"
			secondaryText: qsTrId("batterysettingsbattery_sync")
			interactive: !root.locked
			onClicked: sync.setValue(1)

			VeQuickItem {
				id: sync
				uid: root.bindPrefix + "/Settings/Battery/Synchronize"
			}
		}
	}

	DelegateComponent {
		id: zeroDC
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Battery/ZeroCurrent" }
		preferredVisible: zeroDC.dataItem.valid
		ListButton {
			//% "Calibrate zero current"
			text: qsTrId("batterysettingsbattery_calibrate_zero_current")
			//% "Set to 0"
			secondaryText: qsTrId("batterysettingsbattery_set_to_0")
			onClicked: zero.setValue(1)

			VeQuickItem {
				id: zero
				uid: root.bindPrefix + "/Settings/Battery/ZeroCurrent"
			}
		}
	}
}
