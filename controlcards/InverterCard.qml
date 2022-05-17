/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property int state
	property int mode: VenusOS.Inverters_Mode_Off
	property bool modeAdjustable
	property var ampOptions: []
	property alias currentLimits: currentLimitRepeater.model

	signal changeMode(newMode: int)
	signal changeCurrentLimit(index: int, newCurrentLimit: int)

	title.icon.source: "qrc:/images/inverter_charger.svg"
	//% "Inverter / Charger"
	title: qsTrId("controlcard_inverter_charger")

	status.text: {
		// TODO this duplicates the translations in OverviewWidget, should move the translations to a common component
		switch (root.state) {
		case VenusOS.System_State_Off:
			//: System state = 'Off'
			//% "Off"
			return qsTrId("overview_widget_state_off")
		case VenusOS.System_State_LowPower:
			//: System state = 'Low power'
			//% "Low power"
			return qsTrId("overview_widget_state_lowpower")
		case VenusOS.System_State_FaultCondition:
			//: System state = 'Fault condition'
			//% "Fault"
			return qsTrId("overview_widget_state_faultcondition")
		case VenusOS.System_State_BulkCharging:
			//: System state = 'Bulk charging'
			//% "Bulk"
			return qsTrId("overview_widget_state_bulkcharging")
		case VenusOS.System_State_AbsorptionCharging:
			//: System state = 'Absorption charging'
			//% "Absorption"
			return qsTrId("overview_widget_state_absorptioncharging")
		case VenusOS.System_State_FloatCharging:
			//: System state = 'Float charging'
			//% "Float"
			return qsTrId("overview_widget_state_floatcharging")
		case VenusOS.System_State_StorageMode:
			//: System state = 'Storage mode'
			//% "Storage"
			return qsTrId("overview_widget_state_storagemode")
		case VenusOS.System_State_EqualizationCharging:
			//: System state = 'Equalization charging'
			//% "Equalize"
			return qsTrId("overview_widget_state_equalisationcharging")
		case VenusOS.System_State_PassThrough:
			//: System state = 'Pass-thru'
			//% "Pass-through"
			return qsTrId("overview_widget_state_passthrough")
		case VenusOS.System_State_Inverting:
			//: System state = 'Inverting'
			//% "Inverting"
			return qsTrId("overview_widget_state_inverting")
		case VenusOS.System_State_Assisting:
			//: System state = 'Assisting'
			//% "Assisting"
			return qsTrId("overview_widget_state_assisting")
		case VenusOS.System_State_Discharging:
			//: System state = 'Discharging'
			//% "Discharging"
			return qsTrId("overview_widget_state_discharging")
		}
		return ""
	}

	Column {
		anchors {
			top: parent.status.bottom
			left: parent.left
			right: parent.right
		}
		Column {
			width: parent.width

			Repeater {
				id: currentLimitRepeater

				delegate: ButtonControlValue {
					visible: label.text !== ""
					value: modelData.currentLimit
					label.text: dialogManager.inputCurrentLimitDialog.currentLimitText(modelData.inputType)
					enabled: modelData.currentLimitAdjustable
					//% "%1 A"
					button.text: qsTrId("amps").arg(value / 1000)
					onClicked: {
						dialogManager.inputCurrentLimitDialog.inputIndex = model.index
						dialogManager.inputCurrentLimitDialog.inputType = modelData.inputType
						dialogManager.inputCurrentLimitDialog.currentLimit = modelData.currentLimit
						dialogManager.inputCurrentLimitDialog.ampOptions = root.ampOptions
						dialogManager.inputCurrentLimitDialog.open()
					}
				}
			}
		}
		ButtonControlValue {
			width: parent.width
			button.width: Math.max(button.implicitWidth, 180)
			//% "Mode"
			label.text: qsTrId("controlcard_mode")
			button.text: dialogManager.inverterChargerModeDialog.modeText(root.mode)
			enabled: root.modeAdjustable

			onClicked: {
				dialogManager.inverterChargerModeDialog.mode = root.mode
				dialogManager.inverterChargerModeDialog.open()
			}
		}
	}
	Connections {
		target: dialogManager.inputCurrentLimitDialog
		function onAccepted() {
			var inverter = currentLimitRepeater.itemAt(dialogManager.inputCurrentLimitDialog.inputIndex)
			if (inverter != null
					&& inverter.currentLimit !== dialogManager.inputCurrentLimitDialog.currentLimit) {
				root.changeCurrentLimit(dialogManager.inputCurrentLimitDialog.inputIndex,
						dialogManager.inputCurrentLimitDialog.currentLimit)
			}
		}
	}
	Connections {
		target: dialogManager.inverterChargerModeDialog
		function onAccepted() {
			if (root.mode !== dialogManager.inverterChargerModeDialog.mode) {
				root.changeMode(dialogManager.inverterChargerModeDialog.mode)
			}
		}
	}
}
