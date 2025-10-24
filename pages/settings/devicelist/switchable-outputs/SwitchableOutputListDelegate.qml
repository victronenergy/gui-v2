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

		// Generally, if Status=On, then show some output-specific detail (e.g. the Dimming value)
		// and otherwise, just show the status text (On, Off, Fault, etc.)
		QuantityObject {
			object: output
			key: !isNaN(output.dataNumber) ? "dataNumber" : "dataText"
			unit: output.dataNumberUnit
			precision: output.decimals
		}
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

		// The number and unit to show for this output, if applicable for the output type, and if
		// the output state=On.
		readonly property real dataNumber: output.status !== VenusOS.SwitchableOutput_Status_On
			|| (output.type !== VenusOS.SwitchableOutput_Type_Dimmable
				&& output.type !== VenusOS.SwitchableOutput_Type_TemperatureSetpoint
				&& output.type !== VenusOS.SwitchableOutput_Type_BasicSlider
				&& output.type !== VenusOS.SwitchableOutput_Type_NumericInput)
			? NaN
			: dimmingItem.value // use the dimming value with unit conversion, not the unconverted output.dimming
		readonly property int dataNumberUnit: isNaN(dataNumber) ? VenusOS.Units_None
			: output.type === VenusOS.SwitchableOutput_Type_Dimmable ? VenusOS.Units_Percentage
			: output.type === VenusOS.SwitchableOutput_Type_TemperatureSetpoint ? Global.systemSettings.temperatureUnit
			: output.type === VenusOS.SwitchableOutput_Type_BasicSlider ? Global.systemSettings.toPreferredUnit(output.unitType)
			: output.type === VenusOS.SwitchableOutput_Type_NumericInput ? Global.systemSettings.toPreferredUnit(output.unitType)
			: VenusOS.Units_None

		// The text data to show for this output, if dataNumber is not applicable.
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
			case VenusOS.SwitchableOutput_Type_Dropdown:
				// Show the label for the current dropdown index.
				if (output.status === VenusOS.SwitchableOutput_Status_On) {
					return dropdownLabelsItem.selectedLabel
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
			}
			return statusText
		}

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
		id: dimmingItem
		uid: output.uid + "/Dimming"
		sourceUnit: Units.unitToVeUnit(output.unitType)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.toPreferredUnit(output.unitType))
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
		id: dropdownLabelsItem
		readonly property string selectedLabel: uid.length === 0 || !valid || !value ? ""
				: (value[output.dimming] || "")
		uid: output.type === VenusOS.SwitchableOutput_Type_Dropdown ? root.uid + "/Settings/Labels" : ""
	}
}
