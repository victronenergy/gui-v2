/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix

	//% "Microgrid"
	title: qsTrId("microgrid")

	component MicrogridModeListText : ListText {
		//% "Active mode"
		text: qsTrId("page_microgrid_active_mode")
		secondaryText: VenusOS.microgridModeToText(mode.value)
	}

	component ListValueRange: ListText {
		property int unitType: VenusOS.Units_None
		property alias dataItemFrom: dataItemFrom
		property alias dataItemTo: dataItemTo
		property alias quantityInfoFrom: fromInfo
		property alias quantityInfoTo: toInfo

		//: Describes a range from one quantity to another, e.g. "30 W to 60 W".
		//: The first argument is the first quantity, the second argument is the units of the first quantity,
		//: the third argument is the second quantity, the fourth argument is the units of the second quantity.
		//% "%1 %2 to %3 %4"
		secondaryText: qsTrId("page_microgrid_from_p1_to_p2").arg(fromInfo.number).arg(Units.defaultUnitString(unitType)).arg(toInfo.number).arg(Units.defaultUnitString(unitType))

		QuantityInfo {
			id: fromInfo

			unitType: parent && parent.unitType ? parent.unitType : VenusOS.Units_None
			value: dataItemFrom.valid ? dataItemFrom.value : NaN
		}

		QuantityInfo {
			id: toInfo

			unitType: parent && parent.unitType ? parent.unitType : VenusOS.Units_None
			value: dataItemTo.valid ? dataItemTo.value : NaN
		}

		VeQuickItem {
			id: dataItemFrom
		}

		VeQuickItem {
			id: dataItemTo
		}
	}

	GradientListView {
		model: loader.item

		Loader {
			id: loader

			sourceComponent: {
				if (!mode.valid) {
					return null
				}

				switch (mode.value) {
				case VenusOS.MicrogridMode_GridForming:
					return gridFormingModel
				case VenusOS.MicrogridMode_GridFollowing:
					return gridFollowingModel
				case VenusOS.MicrogridMode_HybridDroop:
					return hybridDroopModel
				default:
					return null
				}
			}
		}

		Component {
			id: hybridDroopModel

			VisibleItemModel {

				MicrogridModeListText {}

				SettingsListHeader {
					//% "Hybrid droop parameters"
					text: qsTrId("page_microgrid_hybrid_droop_parameters")
				}

				ListQuantity {
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Value"
					textFormat: Text.RichText
					//% "Reference active power (P<sub>0</sub>)"
					text: qsTrId("page_microgrid_reference_active_power_p0")
					unit: VenusOS.Units_Percentage
					precision: 1
				}

				ListQuantity {
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/F0/Value"
					textFormat: Text.RichText
					//% "Reference frequency (f<sub>0</sub>)"
					text: qsTrId("page_microgrid_reference_frequency_f0")
					unit: VenusOS.Units_Hertz
					precision: 1
				}

				ListQuantity {
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/FPDroop/Value"
					textFormat: Text.RichText
					//% "Frequency droop slope (droop<sub>fP</sub>)"
					text: qsTrId("page_microgrid_frequency_droop_slope")
					unit: VenusOS.Units_Percentage
					precision: 1
				}

				ListQuantity {
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Q0/Value"
					textFormat: Text.RichText
					//% "Reference reactive power (Q<sub>0</sub>)"
					text: qsTrId("page_microgrid_reference_reactive_power")
					unit: VenusOS.Units_Percentage
					precision: 1
				}

				ListQuantity {
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/U0/Value"
					textFormat: Text.RichText
					//% "Reference Voltage (U<sub>0</sub>)"
					text: qsTrId("page_microgrid_reference_voltage")
					unit: VenusOS.Units_Volt_AC
					precision: 1
				}

				ListQuantity {
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/UQDroop/Value"
					textFormat: Text.RichText
					//% "Voltage droop slope (droop<sub>UQ</sub>)"
					text: qsTrId("page_microgrid_voltage_droop_slope")
					unit: VenusOS.Units_Percentage
					precision: 1
				}

				SettingsListHeader {
					//% "Minimum and maximum parameters"
					text: qsTrId("page_microgrid_minimum_and_maximum_parameters")
				}

				ListValueRange {
					//% "Allowed active power range"
					text: qsTrId("page_microgrid_allowed_active_power_range")
					unitType: VenusOS.Units_Watt
					dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmin/Value"
					dataItemTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmax/Value"
				}

				ListValueRange {
					//% "Allowed reactive power range"
					text: qsTrId("page_microgrid_allowed_reactive_power_range")
					unitType: VenusOS.Units_VoltAmpereReactive
					dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMin/Value"
					dataItemTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMax/Value"
				}
			}
		}

		Component {
			id: gridFollowingModel

			VisibleItemModel {

				MicrogridModeListText {}

				SettingsListHeader {
					//% "P-Q direct drive settings"
					text: qsTrId("page_microgrid_p_q_direct_drive_settings")
				}

				ListQuantity {
					//% "Active power setpoint (P)"
					text: qsTrId("page_microgrid_active_power_setpoint_p")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/P"
					unit: VenusOS.Units_Percentage
					precision: 0
				}

				ListQuantity {
					//% "Reactive power setpoint (Q)"
					text: qsTrId("page_microgrid_reactive_power_setpoint_q")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Q"
					unit: VenusOS.Units_Percentage
					precision: 0
				}

				ListValueRange {
					//% "Allowed frequency range"
					text: qsTrId("page_microgrid_allowed_frequency_range")
					unitType: VenusOS.Units_Hertz
					dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Fmin"
					dataItemTo.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Fmax"
				}

				ListValueRange {
					//% "Allowed voltage range"
					text: qsTrId("page_microgrid_allowed_voltage_range")
					unitType: VenusOS.Units_Volt_AC
					dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Umin"
					dataItemTo.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Umax"
				}
			}
		}

		Component {
			id: gridFormingModel

			VisibleItemModel {

				MicrogridModeListText {}

				SettingsListHeader {
					//% "V-f direct drive settings"
					text: qsTrId("page_microgrid_v_f_direct_drive_settings")
				}

				ListQuantity {
					//% "Voltage setpoint (U)"
					text: qsTrId("page_microgrid_voltage_setpoint")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDriveVf/U"
					unit: VenusOS.Units_Volt_AC
					precision: 1
				}

				ListQuantity {
					//% "Frequency setpoint (f)"
					text: qsTrId("page_microgrid_frequency_setpoint")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDriveVf/F"
					unit: VenusOS.Units_Hertz
					precision: 1
				}
			}
		}

		VeQuickItem {
			id: mode

			uid: root.bindPrefix + "/Mode"
		}
	}
}
