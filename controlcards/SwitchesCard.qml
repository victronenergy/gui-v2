/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	property alias model: switchesView.model

	title.icon.source: "qrc:/images/switches.svg"
	//% "Switches"
	title.text: qsTrId("controlcard_switches")

	ListView {
		id: switchesView

		anchors {
			top: parent.top
			topMargin: Theme.geometry.controlCard.mediumItem.height
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		delegate: SwitchControlValue {
			//: Relay number
			//% "Relay %1"
			label.text: qsTrId("controlcard_relay_name").arg(model.index + 1)
			button.checked: model.relay.state === Relays.State.Active
			onClicked: {
				var newState = model.relay.state === Relays.State.Active
						? Relays.State.Inactive
						: Relays.State.Active
				model.relay.setState(newState)
			}
		}
	}
}
