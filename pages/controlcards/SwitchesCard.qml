/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	property alias model: switchesView.model

	icon.source: "qrc:/images/switches.svg"
	//% "Switches"
	title.text: qsTrId("controlcard_switches")

	ListView {
		id: switchesView

		anchors {
			top: parent.top
			topMargin: Theme.geometry_controlCard_mediumItem_height
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		delegate: SwitchControlValue {
			label.text: model.device.name
			button.checked: model.device.state === VenusOS.Relays_State_Active
			onClicked: {
				var newState = model.device.state === VenusOS.Relays_State_Active
						? VenusOS.Relays_State_Inactive
						: VenusOS.Relays_State_Active
				model.device.setState(newState)
			}
		}
	}
}
