/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroupNavigation {
	id: root

	required property string uid
	required property string name

	text: name
	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: outputCurrent; unit: VenusOS.Units_Amp }
		QuantityObject { object: output; key: "dataText"; unit: output.dataNumberUnit }
		QuantityObject { object: output; key: output.secondaryDataText ? "secondaryDataText" : ""; unit: VenusOS.Units_None }
		QuantityObject { object: output; key: "typeText" }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/switchable-outputs/PageSwitchableOutput.qml", {
			outputUid: output.uid,
			title: Qt.binding(function() { return root.text })
		})
	}

	SwitchableOutput {
		id: output

		// The main information to show for this output. Generally, if Status=On, then some detail
		// is shown (e.g. the Dimming value) and otherwise, just show the status text (On, Off,
		// Fault, etc.)
		readonly property string dataText: {
			switch (output.type) {
			case VenusOS.SwitchableOutput_Type_Momentary:
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					return CommonWords.onOrOff(output.state)
				}
				break
			case VenusOS.SwitchableOutput_Type_Toggle:
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					return CommonWords.onOrOff(output.state)
				}
				break
			case VenusOS.SwitchableOutput_Type_Dimmable:
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					return output.dimming
				}
				break
			case VenusOS.SwitchableOutput_Type_TemperatureSetpoint:
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					const temp = Units.convert(output.dimming, VenusOS.Units_Temperature_Celsius, Global.systemSettings.temperatureUnit)
					return temp.toFixed(stepSizeItem.decimalCount)
				}
				break
			case VenusOS.SwitchableOutput_Type_SteppedSwitch:
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					return output.dimming
				}
				break
			case VenusOS.SwitchableOutput_Type_Slave:
				break
			case VenusOS.SwitchableOutput_Type_Dropdown:
				// Show the label for the current dropdown index.
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					return dropdownLabelsItem.selectedLabel
				}
				break
			case VenusOS.SwitchableOutput_Type_BasicSlider:
			case VenusOS.SwitchableOutput_Type_NumericInput:
				// For both of these types, show /Dimming with /Unit text.
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					return output.dimming.toFixed(stepSizeItem.decimalCount) + (unitItem.value || "")
				}
				break
			case VenusOS.SwitchableOutput_Type_ThreeStateSwitch:
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					const stateText = CommonWords.onOrOff(output.state)
					if (autoItem.value === 1) {
						//: %1 = 'On' or 'Off'
						//% "Auto (%1)"
						return qsTrId("switchableoutput_list_delegate_auto_status").arg(stateText)
					} else {
						return stateText
					}
				}
				break
			case VenusOS.SwitchableOutput_Type_BilgePump:
				break
			}
			return statusText
		}

		readonly property int dataNumberUnit: output.status !== VenusOS.SwitchableOutput_Status_On ? VenusOS.Units_None
				: type === VenusOS.SwitchableOutput_Type_TemperatureSetpoint ? Global.systemSettings.temperatureUnit
				: type === VenusOS.SwitchableOutput_Type_Dimmable ? VenusOS.Units_Percentage
				: VenusOS.Units_None

		readonly property string secondaryDataText: {
			if (output.type === VenusOS.SwitchableOutput_Type_BilgePump) {
				if (output.status === VenusOS.SwitchableOutput_Status_On
						|| output.status === VenusOS.SwitchableOutput_Status_Off) {
					return output.state === 1
						  //% "Forced"
						? qsTrId("switchableoutput_list_delegate_state_forced")
						: CommonWords.auto
				}
			}
			return ""
		}

		readonly property string statusText: VenusOS.switchableOutput_statusToText(status, type)
		readonly property string typeText: VenusOS.switchableOutput_typeToText(type, name)

		uid: root.uid
	}

	VeQuickItem {
		id: outputCurrent
		uid: root.uid + "/Current"
	}

	VeQuickItem {
		id: autoItem
		uid: output.type === VenusOS.SwitchableOutput_Type_ThreeStateSwitch ? output.uid + "/Auto" : ""
	}

	VeQuickItem {
		id: stepSizeItem

		readonly property int decimalCount: stepSizeItem.valid
				? stepSizeItem.value.toString().split(".")[1]?.length ?? 0
				: 0

		uid: output.type === VenusOS.SwitchableOutput_Type_TemperatureSetpoint
				|| output.type === VenusOS.SwitchableOutput_Type_BasicSlider
				|| output.type === VenusOS.SwitchableOutput_Type_NumericInput
			 ? root.uid + "/Settings/StepSize"
			 : ""
	}

	VeQuickItem {
		id: unitItem
		uid: output.type === VenusOS.SwitchableOutput_Type_BasicSlider
				|| output.type === VenusOS.SwitchableOutput_Type_NumericInput
			 ? root.uid + "/Settings/Unit"
			 : ""
	}

	VeQuickItem {
		id: dropdownLabelsItem
		readonly property string selectedLabel: uid.length === 0 || !valid || !value ? ""
				: (value[output.dimming] || "")
		uid: output.type === VenusOS.SwitchableOutput_Type_Dropdown ? root.uid + "/Settings/Labels" : ""
	}
}
