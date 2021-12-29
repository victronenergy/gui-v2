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

		Item {
			width: parent.width
			height: Theme.geometry.controlCard.mediumItem.height

			RadioButton {
				id: button

				anchors {
					left: parent.left
					leftMargin: 16
					right: parent.right
					rightMargin: 16
					verticalCenter: parent.verticalCenter
				}
				checked: index === root.newModeIndex
				label.topPadding: -2
				text: qsTrId(modelData)
				onClicked: root.newModeIndex = index
			}
			SeparatorBar {
				anchors {
					bottom: parent.bottom
					left: parent.left
					leftMargin: 8
					right: parent.right
					rightMargin: 8
				}
				height: 1
			}
		}
	}

	onAccepted: root.setMode(newModeIndex)
}
