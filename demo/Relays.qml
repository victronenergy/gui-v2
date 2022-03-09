/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils
import "../data" as DBusData

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
			property int state: model.index % 2 == 0 ? DBusData.Relays.Inactive : DBusData.Relays.Active

			function setState(s) {
				state = s
			}
		}
	}
}
