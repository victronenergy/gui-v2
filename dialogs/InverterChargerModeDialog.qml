/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int newModeIndex: 0

	signal setMode(var newValue)

	//% "Inverter / Charger mode"
	title: qsTrId("controlcard_inverter_charger_mode")

	contentItem: Column {
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: 64
		}

		Repeater {
			id: repeater
			width: parent.width
			model: ControlCardsModel.inverterModeStrings
			delegate: buttonStyling
		}
	}

	Component {
		id: buttonStyling

		RadioButtonControlValue {
			button.checked: index === root.newModeIndex
			label.text: qsTrId(modelData)
			onClicked: root.newModeIndex = index
		}
	}

	onAccepted: root.setMode(newModeIndex)
}
