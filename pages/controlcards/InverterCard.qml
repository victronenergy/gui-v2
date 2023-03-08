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

	property var _currentLimitDialog

	signal changeMode(newMode: int)
	signal changeCurrentLimit(index: int, newCurrentLimit: real)

	title.icon.source: "qrc:/images/inverter_charger.svg"
	//% "Inverter / Charger"
	title.text: qsTrId("controlcard_inverter_charger")

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

	Component {
		id: currentLimitDialogComponent

		InputCurrentLimitDialog {
			property int inputIndex

			ampOptions: root.ampOptions

			onAccepted: {
				const inverter = currentLimitRepeater.itemAt(inputIndex)
				if (inverter != null && inverter.currentLimit !== currentLimit) {
					root.changeCurrentLimit(inputIndex, currentLimit)
				}
			}
		}
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
					label.text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
					enabled: modelData.currentLimitAdjustable
					//% "%1 A"
					button.text: qsTrId("amps").arg(value)   // TODO use UnitConverter.convertToString() or unitToString() instead
					onClicked: {
						if (!root._currentLimitDialog) {
							root._currentLimitDialog = currentLimitDialogComponent.createObject(Global.dialogLayer)
						}
						root._currentLimitDialog.inputIndex = model.index
						root._currentLimitDialog.inputType = modelData.inputType
						root._currentLimitDialog.currentLimit = modelData.currentLimit
						root._currentLimitDialog.open()
					}
				}
			}
		}
		ButtonControlValue {
			property var _modeDialog

			width: parent.width
			button.width: Math.max(button.implicitWidth, 180)
			//% "Mode"
			label.text: qsTrId("controlcard_mode")
			button.text: Global.inverters.inverterModeToText(root.mode)
			enabled: root.modeAdjustable

			onClicked: {
				if (!_modeDialog) {
					_modeDialog = modeDialogComponent.createObject(Global.dialogLayer)
				}
				_modeDialog.mode = root.mode
				_modeDialog.open()
			}

			Component {
				id: modeDialogComponent

				InverterChargerModeDialog {
					onAccepted: {
						if (root.mode !== mode) {
							root.changeMode(mode)
						}
					}
				}
			}
		}
	}
}
