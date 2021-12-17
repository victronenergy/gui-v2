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
		delegate: Item {
			width: parent.width
			height: Theme.geometry.controlCard.mediumItem.height
			Label {
				anchors {
					left: parent.left
					leftMargin: Theme.geometry.controlCard.contentMargins
					verticalCenter: parent.verticalCenter
				}
				text: qsTrId(model.text)
			}
			Switch {
				anchors {
					right: parent.right
					rightMargin: Theme.geometry.controlCard.contentMargins
					verticalCenter: parent.verticalCenter
				}
				checked: model.on ? true : false
				onToggled: SwitchesModel.setProperty(index, "on", checked)
			}
			SeparatorBar {
				anchors {
					left: parent.left
					leftMargin: Theme.geometry.controlCard.itemSeparator.margins
					right: parent.right
					rightMargin: Theme.geometry.controlCard.itemSeparator.margins
					bottom: parent.bottom
				}
			}
		}
	}
}
