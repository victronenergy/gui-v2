/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property int modeIndex: 0 // TODO - hook this up to the real value

	title.icon.source: "qrc:/images/inverter.svg"
	//% "Inverter"
	title.text: qsTrId("controlcard_inverter")

	//% "Inverting"
	status.text: qsTrId("controlcard_inverting")

	Column {
		anchors {
			top: parent.top
			topMargin: Theme.geometry.inverterCard.topMargin
			left: parent.left
			right: parent.right
		}
		ButtonControlValue {
			value: ControlCardsModel.inputCurrentLimit
			//% "Input current limit"
			label.text: qsTrId("controlcard_input_current_limit")
			//% "%1 A"
			button.text: qsTrId("amps").arg(value / 1000)
			onClicked: {
				dialogManager.inputCurrentLimitDialog.newInputCurrentLimit = ControlCardsModel.inputCurrentLimit
				dialogManager.inputCurrentLimitDialog.open()
			}
		}
		ButtonControlValue {
			width: parent.width
			button.width: Math.max(button.implicitWidth, 180)
			//% "Mode"
			label.text: qsTrId("controlcard_mode")
			button.text: qsTrId(ControlCardsModel.inverterModeStrings[modeIndex])
			onClicked: {
				dialogManager.inverterChargerModeDialog.newModeIndex = modeIndex
				dialogManager.inverterChargerModeDialog.open()
			}
		}
	}
	Connections {
		target: dialogManager.inputCurrentLimitDialog
		function onSetInputCurrentLimit(newValue) {
			ControlCardsModel.inputCurrentLimit = newValue
		}
	}
	Connections {
		target: dialogManager.inverterChargerModeDialog
		function onSetMode(newIndex) {
			modeIndex = newIndex
		}
	}
}
