/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	icon.source: "qrc:/images/switches.svg"
	//% "Switches"
	title.text: qsTrId("controlcard_switches")

	ListView {
		anchors{
			top: parent.top
			topMargin: 52
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		model: SwitchesModel
		delegate: Item {
			width: parent.width
			height: 56
			Label {
				anchors {
					left: parent.left
					leftMargin: 16
					verticalCenter: parent.verticalCenter
				}
				text: qsTrId(model.text)
			}
			Switch {
				anchors {
					right: parent.right
					rightMargin: 16
					verticalCenter: parent.verticalCenter
				}
				checked: model.on ? true : false
				onToggled: SwitchesModel.setProperty(index, "on", checked)
			}
			SeparatorBar {
				anchors {
					left: parent.left
					leftMargin: 8
					right: parent.right
					rightMargin: 8
					bottom: parent.bottom
				}
			}
		}
	}
}
