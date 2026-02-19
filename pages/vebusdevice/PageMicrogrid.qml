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

	component MicrogridModeListText: ListText {
		//% "Active mode"
		text: qsTrId("page_microgrid_active_mode")
		secondaryText: VenusOS.microgridModeToText(mode.value, externalControl.value)
	}

	component MicrogridListSpinBox: ListSpinBox {

		property alias dataItemModified: parameterModified

		textFormat: Text.RichText
		readOnly: !externalControl.valid || externalControl.value !== VenusOS.MicrogridExternalControl_Standalone

		decimals: 2
		stepSize: 0.01
		presets: Array.from({ length: 5 }, (_, i) => from + i * (to - from)/4).map(function(v) { return { value: v } })

		Binding on button.borderColor {
			when: parameterModified.value === 1
			value: Theme.color_button_on_border_modified
		}
		VeQuickItem {
			id: parameterModified
		}
	}

	component MicrogridListQuantity: ListQuantity {
		textFormat: Text.RichText
		precision: 2
		precisionAdjustmentAllowed: false
	}

	component ListValueRange: ListText {
		property int unitType: VenusOS.Units_None
		property alias dataItemFrom: dataItemFrom
		property alias dataItemTo: dataItemTo
		property alias quantityInfoFrom: fromInfo
		property alias quantityInfoTo: toInfo

		//: Describes a range from one quantity to another, e.g. "30W to 60W".
		//: The first argument is the first quantity, the second argument is the units of the first quantity,
		//: the third argument is the second quantity, the fourth argument is the units of the second quantity.
		//% "%1%2 to %3%4"
		secondaryText: qsTrId("page_microgrid_from_p1_to_p2").arg(fromInfo.number).arg(Units.defaultUnitString(unitType)).arg(toInfo.number).arg(Units.defaultUnitString(unitType))

		QuantityInfo {
			id: fromInfo

			unitType: parent && parent.unitType ? parent.unitType : VenusOS.Units_None
			value: dataItemFrom.valid ? dataItemFrom.value : NaN
			precision: 2
			precisionAdjustmentAllowed: false
		}

		QuantityInfo {
			id: toInfo

			unitType: parent && parent.unitType ? parent.unitType : VenusOS.Units_None
			value: dataItemTo.valid ? dataItemTo.value : NaN
			precision: 2
			precisionAdjustmentAllowed: false
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

				readonly property bool _parametersModified: parameterP0SpinBox.dataItemModified.value === 1
									|| parameterF0SpinBox.dataItemModified.value === 1
									|| parameterFPSpinBox.dataItemModified.value === 1
									|| parameterQ0SpinBox.dataItemModified.value === 1
									|| parameterU0SpinBox.dataItemModified.value === 1
									|| parameterUQSpinBox.dataItemModified.value === 1
									|| parameterP0SpinBoxRange.dataItemModifiedFrom.value === 1
									|| parameterP0SpinBoxRange.dataItemModifiedTo.value === 1
									|| parameterQ0SpinBoxRange.dataItemModifiedFrom.value === 1
									|| parameterQ0SpinBoxRange.dataItemModifiedTo.value === 1

				MicrogridModeListText {}

				SettingsListHeader {
					//% "Hybrid droop parameters"
					text: qsTrId("page_microgrid_hybrid_droop_parameters")
				}

				MicrogridListSpinBox {
					id: parameterP0SpinBox

					//% "Reference active power (P<sub>0</sub>)"
					text: qsTrId("page_microgrid_reference_active_power_p0")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Value"
					dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Modified"

					from: parameterP0SpinBoxRange.dataItemFrom.value
					to: parameterP0SpinBoxRange.dataItemTo.value

					suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
				}

				MicrogridListSpinBox {
					id: parameterF0SpinBox

					//% "Reference frequency (f<sub>0</sub>)"
					text: qsTrId("page_microgrid_reference_frequency_f0")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/F0/Value"
					dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/F0/Modified"

					from: 40
					to: 70
					presets: [40, 45, 50, 55, 60, 65, 70].map(function(v) { return { value: v } })

					suffix: Units.defaultUnitString(VenusOS.Units_Hertz)
				}

				MicrogridListSpinBox {
					id: parameterFPSpinBox

					//% "Frequency droop slope (droop<sub>fP</sub>)"
					text: qsTrId("page_microgrid_frequency_droop_slope")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/FPDroop/Value"
					dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/FPDroop/Modified"

					from: 0
					to: 100
					presets: [0, 3, 4, 5, 7, 10].map(function(v) { return { value: v } })

					suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
				}

				MicrogridListSpinBox {
					id: parameterQ0SpinBox

					//% "Reference reactive power (Q<sub>0</sub>)"
					text: qsTrId("page_microgrid_reference_reactive_power")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Q0/Value"
					dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Q0/Modified"

					from: parameterQ0SpinBoxRange.dataItemFrom.value
					to: parameterQ0SpinBoxRange.dataItemTo.value

					suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
				}

				MicrogridListSpinBox {
					id: parameterU0SpinBox

					//% "Reference Voltage (U<sub>0</sub>)"
					text: qsTrId("page_microgrid_reference_voltage")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/U0/Value"
					dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/U0/Modified"

					from: 220
					to: 270
					presets: [230, 235, 240, 245, 250, 255, 260].map(function(v) { return { value: v } })

					suffix: Units.defaultUnitString(VenusOS.Units_Volt_AC)
				}

				MicrogridListSpinBox {
					id: parameterUQSpinBox

					//% "Voltage droop slope (droop<sub>UQ</sub>)"
					text: qsTrId("page_microgrid_voltage_droop_slope")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/UQDroop/Value"
					dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/UQDroop/Modified"

					from: 0
					to: 100
					presets: [0, 2, 4, 6, 8, 10].map(function(v) { return { value: v } })

					suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
				}

				SettingsListHeader {
					//% "Minimum and maximum parameters"
					text: qsTrId("page_microgrid_minimum_and_maximum_parameters")
				}

				ListSpinBoxRange {
					id: parameterP0SpinBoxRange
					//% "Allowed active power range"
					text: qsTrId("page_microgrid_allowed_active_power_range")
					readOnly: !externalControl.valid || externalControl.value !== VenusOS.MicrogridExternalControl_Standalone

					dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/PMin/Value"
					dataItemModifiedFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/PMin/Modified"
					rangeModelFrom.minimumValue: -100
					rangeModelFrom.maximumValue: 100
					rangeModelFrom.stepSize: 0.01

					dataItemTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/PMax/Value"
					dataItemModifiedTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/PMax/Modified"
					rangeModelTo.minimumValue: -100
					rangeModelTo.maximumValue: 100
					rangeModelTo.stepSize: 0.01

					unit: VenusOS.Units_Percentage
					decimals: 2
				}

				ListSpinBoxRange {
					id: parameterQ0SpinBoxRange
					//% "Allowed reactive power range"
					text: qsTrId("page_microgrid_allowed_reactive_power_range")
					readOnly: !externalControl.valid || externalControl.value !== VenusOS.MicrogridExternalControl_Standalone

					dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Qmin/Value"
					dataItemModifiedFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Qmin/Modified"
					rangeModelFrom.minimumValue: -100
					rangeModelFrom.maximumValue: 100
					rangeModelFrom.stepSize: 0.01

					dataItemTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Qmax/Value"
					dataItemModifiedTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Qmax/Modified"
					rangeModelTo.minimumValue: -100
					rangeModelTo.maximumValue: 100
					rangeModelTo.stepSize: 0.01

					unit: VenusOS.Units_Percentage
					decimals: 2
				}

				SettingsListHeader {
					text: "" // Blank section padding
					preferredVisible: externalControl.valid && externalControl.value === VenusOS.MicrogridExternalControl_Standalone
				}

				ListButton {
					//% "Apply all parameters"
					text: qsTrId("page_microgrid_apply_all_parameters")
					//% "Apply"
					secondaryText: qsTrId("page_microgrid_apply")
					preferredVisible: externalControl.valid && externalControl.value === VenusOS.MicrogridExternalControl_Standalone
							&& _parametersModified

					button.borderColor: Theme.color_button_on_border_modified
					button.backgroundColor: Theme.color_button_on_background_modified

					onClicked: applyAll.setValue(1)

					VeQuickItem {
						id: applyAll
						uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/ActivateAndStore"
					}
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

				MicrogridListQuantity {
					//% "Active power setpoint (P)"
					text: qsTrId("page_microgrid_active_power_setpoint_p")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/P"
					unit: VenusOS.Units_Percentage
				}

				MicrogridListQuantity {
					//% "Reactive power setpoint (Q)"
					text: qsTrId("page_microgrid_reactive_power_setpoint_q")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Q"
					unit: VenusOS.Units_Percentage
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

				MicrogridListQuantity {
					//% "Voltage setpoint (U)"
					text: qsTrId("page_microgrid_voltage_setpoint")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDriveVf/U"
					unit: VenusOS.Units_Volt_AC
				}

				MicrogridListQuantity {
					//% "Frequency setpoint (f)"
					text: qsTrId("page_microgrid_frequency_setpoint")
					dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDriveVf/F"
					unit: VenusOS.Units_Hertz
				}
			}
		}

		VeQuickItem {
			id: mode

			uid: root.bindPrefix + "/MicroGrid/Mode"
		}

		VeQuickItem {
			id: externalControl

			uid: root.bindPrefix + "/MicroGrid/ExternalControl"
		}
	}
}
