/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: {
			append({ name: "L1", power: -446 })
			append({ name: "L2", power: 325 })
			append({ name: "L3", power: NaN })

			for (let i = 0; i < count; ++i) {
				root.power += get(i).power || 0
			}
		}
	}

	property real power
}
