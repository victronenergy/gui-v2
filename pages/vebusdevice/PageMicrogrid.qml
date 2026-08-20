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
	readonly property bool _showApplyAllParameters: externalControl.valid && externalControl.value === VenusOS.MicrogridExternalControl_Standalone
			&& (p0ModifiedItem.value === 1
			|| f0ModifiedItem.value === 1
			|| fpDroopModifiedItem.value === 1
			|| q0ModifiedItem.value === 1
			|| u0ModifiedItem.value === 1
			|| uqDroopModifiedItem.value === 1
			|| p0RangeFromModifiedItem.value === 1
			|| p0RangeToModifiedItem.value === 1
			|| q0RangeFromModifiedItem.value === 1
			|| q0RangeToModifiedItem.value === 1)

	VeQuickItem {
		id: p0ValueItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Value"
	}
	VeQuickItem {
		id: f0ValueItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/F0/Value"
	}
	VeQuickItem {
		id: fpDroopValueItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/FPDroop/Value"
	}
	VeQuickItem {
		id: q0ValueItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Q0/Value"
	}
	VeQuickItem {
		id: u0ValueItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/U0/Value"
	}
	VeQuickItem {
		id: uqDroopValueItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/UQDroop/Value"
	}
	VeQuickItem {
		id: p0ModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Modified"
	}
	VeQuickItem {
		id: f0ModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/F0/Modified"
	}
	VeQuickItem {
		id: fpDroopModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/FPDroop/Modified"
	}
	VeQuickItem {
		id: q0ModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Q0/Modified"
	}
	VeQuickItem {
		id: u0ModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/U0/Modified"
	}
	VeQuickItem {
		id: uqDroopModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/UQDroop/Modified"
	}
	VeQuickItem {
		id: p0RangeFromItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmin/Value"
	}
	VeQuickItem {
		id: p0RangeToItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmax/Value"
	}
	VeQuickItem {
		id: q0RangeFromItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMin/Value"
	}
	VeQuickItem {
		id: q0RangeToItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMax/Value"
	}
	VeQuickItem {
		id: p0RangeFromModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmin/Modified"
	}
	VeQuickItem {
		id: p0RangeToModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmax/Modified"
	}
	VeQuickItem {
		id: q0RangeFromModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMin/Modified"
	}
	VeQuickItem {
		id: q0RangeToModifiedItem
		uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMax/Modified"
	}

	function _generatePreset(size, median, lowerBound, upperBound, stepSize, decimals) {
		// Creates a set of values, close to the median value, within two stepSize to use as SpinBox presets.
		// It defines the functions bounds, compensates for median values at boundary edges and uses these
		// values to generate the specified neighbourhood values and outputs the values with decimal places.
		const from = Math.min(Math.max(lowerBound, median - (stepSize * Math.floor(size/2))), upperBound - (stepSize * (size - 1)))
		const to = Math.max(Math.min(upperBound, median + (stepSize * Math.floor(size/2))), lowerBound + (stepSize * (size - 1)))
		const array = Array.from({ length: ((to - from) / stepSize) + 1 }, (_, i) => (from + i * stepSize) )
		return array.map(function(v) { return { value: v.toFixed(decimals) } } )
	}

	component MicrogridModeListText: ListText {
		//% "Active mode"
		text: qsTrId("page_microgrid_active_mode")
		secondaryText: VenusOS.microgridModeToText(mode.value, externalControl.value)
	}

	component MicrogridListSpinBox: ListSpinBox {
		property alias dataItemModified: parameterModified

		textFormat: Text.RichText // for super/sub support
		readOnly: !externalControl.valid || externalControl.value !== VenusOS.MicrogridExternalControl_Standalone

		decimals: 2
		stepSize: 0.01
		presets: Array.from({ length: 5 }, (_, i) => from + i * (to - from)/4).map(function(v) { return { value: v.toFixed(decimals) } })
		buttonBorderColor: parameterModified.value === 1 ? Theme.color_button_on_border_modified : FastUtils.invalidColor()

		VeQuickItem {
			id: parameterModified
		}
	}

	component MicrogridListQuantity: ListQuantity {
		textFormat: Text.RichText
		decimals: 2
		formatHints: Units.NoDecimalAdjustment
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
			decimals: 2
			formatHints: Units.NoDecimalAdjustment
		}

		QuantityInfo {
			id: toInfo

			unitType: parent && parent.unitType ? parent.unitType : VenusOS.Units_None
			value: dataItemTo.valid ? dataItemTo.value : NaN
			decimals: 2
			formatHints: Units.NoDecimalAdjustment
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

			DelegateComponentModel {
				DelegateComponent {
					MicrogridModeListText {}
				}

				DelegateComponent {
					/* Chart feature is hidden, pending review. See issue #3099.
					ListDroopGraph {
						// reference values
						p0Value: p0ValueItem.value
						p0LowerValue: p0RangeFromItem.value
						p0UpperValue: p0RangeToItem.value
						f0Value: f0ValueItem.value
						fpDroop: fpDroopValueItem.value

						q0Value: q0ValueItem.value
						q0LowerValue: q0RangeFromItem.value
						q0UpperValue: q0RangeToItem.value
						u0Value: u0ValueItem.value
						uqDroop: uqDroopValueItem.value

						// operational values
						frequency: activeFrequency.value
						voltage: activeVoltage.value

						VeQuickItem {
							id: activeFrequency
							uid: root.bindPrefix + "/Ac/ActiveIn/L1/F"
						}
						VeQuickItem {
							id: activeVoltage
							uid: root.bindPrefix + "/Ac/ActiveIn/L1/V"
						}
					}
				}
				DelegateComponent {
					*/

					SettingsListHeader {
						//% "Hybrid droop parameters"
						text: qsTrId("page_microgrid_hybrid_droop_parameters")
					}
				}

				DelegateComponent {
					MicrogridListSpinBox {
						id: p0
						//% "Reference active power (P<sub>0</sub>)"
						text: qsTrId("page_microgrid_reference_active_power_p0")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Value"
						dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Modified"

						from: p0RangeFromItem.valid ? p0RangeFromItem.value : dataItem.defaultMin
						to: p0RangeToItem.valid ? p0RangeToItem.value : dataItem.defaultMax

						suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
					}
				}

				DelegateComponent {
					MicrogridListSpinBox {
						id: f0
						//% "Reference frequency (f<sub>0</sub>)"
						text: qsTrId("page_microgrid_reference_frequency_f0")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/F0/Value"
						dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/F0/Modified"

						from: 45
						to: 65
						presets: root._generatePreset(5, value, from, to, stepSize * 10, decimals)

						suffix: Units.defaultUnitString(VenusOS.Units_Hertz)
					}
				}

				DelegateComponent {
					MicrogridListSpinBox {
						id: fpDroop
						//% "Frequency droop slope (droop<sub>fP</sub>)"
						text: qsTrId("page_microgrid_frequency_droop_slope")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/FPDroop/Value"
						dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/FPDroop/Modified"

						from: 1
						to: 20
						presets: root._generatePreset(5, value, from, to, stepSize * 50, decimals)

						suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
					}
				}

				DelegateComponent {
					MicrogridListSpinBox {
						id: q0
						//% "Reference reactive power (Q<sub>0</sub>)"
						text: qsTrId("page_microgrid_reference_reactive_power")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Q0/Value"
						dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Q0/Modified"

						from: q0RangeFromItem.valid ? q0RangeFromItem.value : dataItem.defaultMin
						to: q0RangeToItem.valid ? q0RangeToItem.value : dataItem.defaultMax

						suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
					}
				}

				DelegateComponent {
					MicrogridListSpinBox {
						id: u0
						//% "Reference Voltage (U<sub>0</sub>)"
						text: qsTrId("page_microgrid_reference_voltage")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/U0/Value"
						dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/U0/Modified"

						from: 220
						to: 270
						presets: root._generatePreset(5, value, from, to, stepSize * 500, decimals)

						suffix: Units.defaultUnitString(VenusOS.Units_Volt_AC)
					}
				}

				DelegateComponent {
					MicrogridListSpinBox {
						id: uqDroop
						//% "Voltage droop slope (droop<sub>UQ</sub>)"
						text: qsTrId("page_microgrid_voltage_droop_slope")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/UQDroop/Value"
						dataItemModified.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/UQDroop/Modified"

						from: 1
						to: 20
						presets: root._generatePreset(5, value, from, to, stepSize * 50, decimals)

						suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
					}
				}

				DelegateComponent {
					SettingsListHeader {
						//% "Minimum and maximum parameters"
						text: qsTrId("page_microgrid_minimum_and_maximum_parameters")
					}
				}

				DelegateComponent {
					ListSpinBoxRange {
						id: p0Range
						//% "Allowed active power range"
						text: qsTrId("page_microgrid_allowed_active_power_range")
						readOnly: !externalControl.valid || externalControl.value !== VenusOS.MicrogridExternalControl_Standalone

						dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmin/Value"
						dataItemModifiedFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmin/Modified"
						rangeModelFrom.minimumValue: -200
						rangeModelFrom.maximumValue: 200
						rangeModelFrom.stepSize: 0.01

						dataItemTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmax/Value"
						dataItemModifiedTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmax/Modified"
						rangeModelTo.minimumValue: -200
						rangeModelTo.maximumValue: 200
						rangeModelTo.stepSize: 0.01

						unit: VenusOS.Units_Percentage
						decimals: 2
					}
				}

				DelegateComponent {
					ListSpinBoxRange {
						id: q0Range
						//% "Allowed reactive power range"
						text: qsTrId("page_microgrid_allowed_reactive_power_range")
						readOnly: !externalControl.valid || externalControl.value !== VenusOS.MicrogridExternalControl_Standalone

						dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMin/Value"
						dataItemModifiedFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMin/Modified"
						rangeModelFrom.minimumValue: -70
						rangeModelFrom.maximumValue: 70
						rangeModelFrom.stepSize: 0.01

						dataItemTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMax/Value"
						dataItemModifiedTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMax/Modified"
						rangeModelTo.minimumValue: -70
						rangeModelTo.maximumValue: 70
						rangeModelTo.stepSize: 0.01

						unit: VenusOS.Units_Percentage
						decimals: 2
					}
				}

				DelegateComponent {
					preferredVisible: root._showApplyAllParameters
					SettingsListHeader {
						text: "" // Blank section padding
					}
				}

				DelegateComponent {
					preferredVisible: root._showApplyAllParameters
					ListButton {
						//% "Apply all parameters"
						text: qsTrId("page_microgrid_apply_all_parameters")
						//% "Apply"
						secondaryText: qsTrId("page_microgrid_apply")

						buttonBorderColor: Theme.color_button_on_border_modified
						buttonBackgroundColor: Theme.color_button_on_background_modified

						onClicked: applyAll.setValue(1)

						VeQuickItem {
							id: applyAll
							uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/ActivateAndStore"
						}
					}
				}
			}
		}

		Component {
			id: gridFollowingModel

			DelegateComponentModel {

				DelegateComponent {
					MicrogridModeListText {}
				}

				DelegateComponent {
					SettingsListHeader {
						//% "P-Q direct drive settings"
						text: qsTrId("page_microgrid_p_q_direct_drive_settings")
					}
				}

				DelegateComponent {
					MicrogridListQuantity {
						//% "Active power setpoint (P)"
						text: qsTrId("page_microgrid_active_power_setpoint_p")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/P"
						unit: VenusOS.Units_Percentage
					}
				}

				DelegateComponent {
					MicrogridListQuantity {
						//% "Reactive power setpoint (Q)"
						text: qsTrId("page_microgrid_reactive_power_setpoint_q")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Q"
						unit: VenusOS.Units_Percentage
					}
				}

				DelegateComponent {
					ListValueRange {
						//% "Allowed frequency range"
						text: qsTrId("page_microgrid_allowed_frequency_range")
						unitType: VenusOS.Units_Hertz
						dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Fmin"
						dataItemTo.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Fmax"
					}
				}

				DelegateComponent {
					ListValueRange {
						//% "Allowed voltage range"
						text: qsTrId("page_microgrid_allowed_voltage_range")
						unitType: VenusOS.Units_Volt_AC
						dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Umin"
						dataItemTo.uid: root.bindPrefix + "/MicroGrid/DirectDrivePQ/Umax"
					}
				}
			}
		}

		Component {
			id: gridFormingModel

			DelegateComponentModel {

				DelegateComponent {
					MicrogridModeListText {}
				}

				DelegateComponent {
					SettingsListHeader {
						//% "V-f direct drive settings"
						text: qsTrId("page_microgrid_v_f_direct_drive_settings")
					}
				}

				DelegateComponent {
					MicrogridListQuantity {
						//% "Voltage setpoint (U)"
						text: qsTrId("page_microgrid_voltage_setpoint")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDriveVf/U"
						unit: VenusOS.Units_Volt_AC
					}
				}

				DelegateComponent {
					MicrogridListQuantity {
						//% "Frequency setpoint (f)"
						text: qsTrId("page_microgrid_frequency_setpoint")
						dataItem.uid: root.bindPrefix + "/MicroGrid/DirectDriveVf/F"
						unit: VenusOS.Units_Hertz
					}
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

		VeQuickItem {
			id: microgridError

			uid: root.bindPrefix + "/MicroGrid/Error"
			onValueChanged: {
				if (valid && value !== 0) {
					Global.showToastNotification(VenusOS.Notification_Warning, VenusOS.microgrid_errorToText(value), 10000)
				}
			}
		}
	}
}
