/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	title.icon.source: "qrc:/images/switches.svg"
	//% "Switches"
	title.text: qsTrId("controlcard_switches")

	ListView {
		anchors {
			top: parent.top
			topMargin: Theme.geometry.controlCard.mediumItem.height
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		model: SwitchesModel
		delegate: SwitchControlValue {
			label.text: qsTrId(model.text)
			button.checked: model.on ? true : false
			onClicked: SwitchesModel.setProperty(index, "on", button.checked)
		}
	}
}
