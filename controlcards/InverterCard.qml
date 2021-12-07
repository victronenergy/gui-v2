/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property int inputCurrentLimit: 10700 // (mA) TODO - hook this up to the real value

	property int modeIndex: 0 // TODO - hook this up to the real value

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
				dialogManager.inputCurrentLimitDialog.open()
			}
		}
		ControlValue {
			rectangle.width: 180
			//% "Mode"
			label.text: qsTrId("controlcard_mode")
			displayValue.text: qsTrId(ControlCardsModel.inverterModeStrings[modeIndex])
			onClicked: {
				dialogManager.inverterChargerModeDialog.newModeIndex = modeIndex
				dialogManager.inverterChargerModeDialog.open()
			}
		}
	}
	Connections {
		target: dialogManager.inputCurrentLimitDialog
		function onSetInputCurrentLimit(newValue) {
			root.inputCurrentLimit = newValue
		}
	}
	Connections {
		target: dialogManager.inverterChargerModeDialog
		function onSetMode(newIndex) {
			modeIndex = newIndex
		}
	}
}
