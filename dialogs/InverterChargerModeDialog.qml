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
	titleText: qsTrId("controlcard_inverter_charger_mode")

	contentChildren: [
		Column {
			anchors.centerIn: parent
			anchors.verticalCenterOffset: 2
			anchors.horizontalCenterOffset: -8
			Repeater {
				id: repeater

				model: ControlCardsModel.inverterModeStrings
				delegate: buttonStyling
			}
		}
	]
	Component {
		id: buttonStyling

		Item {
			width: 480
			height: 56

			RadioButton {
				id: button

				anchors {
					right: parent.right
				}
				checked: index === root.newModeIndex
				width: 470
				label.topPadding: -2
				text: qsTrId(modelData)
				onClicked: root.newModeIndex = index
			}
			SeparatorBar {
				anchors {
					top: button.bottom
					topMargin: 9
					left: parent.left
					leftMargin: 8
				}

				width: parent.width
			}
		}
	}

	onAccepted: root.setMode(newModeIndex)
}
