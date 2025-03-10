/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property ManualRelayModel model

	icon.source: "qrc:/images/switches.svg"
	//% "Switches"
	title.text: qsTrId("controlcard_switches")

	SettingsColumn {
		id: switchesView

		anchors {
			top: root.title.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		Repeater {
			model: root.model
			delegate: ListSwitch {
				//: %1 = Relay number
				//% "Relay %1"
				text: qsTrId("controlcard_switches_relay_name").arg(model.relayNumber + 1)
				checked: model.relayState === VenusOS.Relays_State_Active
				flat: true
				onClicked: {
					const newState = model.relayState === VenusOS.Relays_State_Active
							? VenusOS.Relays_State_Inactive
							: VenusOS.Relays_State_Active
					root.model.setRelayState(model.relayNumber, newState)
				}
			}
		}
	}
}
