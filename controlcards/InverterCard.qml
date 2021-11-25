/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property int inputCurrentLimit: 10700 // (mA) TODO - hook this up to the real value
	//% "On"
	property var mode: qsTrId("inverter_card_on") // TODO - hook this up to the real value

	icon.source: "qrc:/images/inverter.svg"
	//% "Inverter"
	title.text: qsTrId("controlcard_inverter")

	//% "Inverting"
	status.text: qsTrId("controlcard_inverting")

	Column {
		anchors {
			top: parent.top
			topMargin: 121
			left: parent.left
			leftMargin: 8
			right: parent.right
			rightMargin: 16
		}
		spacing: 16
		ControlValue {
			rectangle.width: 112
			value: root.inputCurrentLimit
			//% "Input current limit"
			label.text: qsTrId("controlcard_input_current_limit")

			//% "%1 A"
			displayValue.text: qsTrId("amps").arg(value / 1000)
			onClicked: {
				dialogManager.inputCurrentLimitDialog.newInputCurrentLimit = root.inputCurrentLimit
				dialogManager.activeDialog = dialogManager.inputCurrentLimitDialog
			}
		}
		ControlValue {
			rectangle.width: 180
			//% "Mode"
			label.text: qsTrId("controlcard_mode")
			displayValue.text: root.mode
		}
	}
	Connections {
		target: dialogManager.inputCurrentLimitDialog

		function onSetInputCurrentLimit(newValue) {
			root.inputCurrentLimit = newValue
		}
	}
}
