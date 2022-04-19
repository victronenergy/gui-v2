/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: {
			for (let i = 0; i < instantiator.count; ++i) {
				append({ relay: instantiator.objectAt(i) })
			}
		}
	}

	Instantiator {
		id: instantiator

		model: 3

		delegate: QtObject {
			property int state: model.index % 2 == 0 ? Enums.Relays_State_Inactive : Enums.Relays_State_Active

			function setState(s) {
				state = s
			}
		}
	}
}
