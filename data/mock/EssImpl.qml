/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	Component.onCompleted: {
		Global.ess.minimumStateOfCharge = 10
	}

	property Connections essConn: Connections {
		target: Global.ess

		function onSetStateRequested(s) {
			Global.ess.state = s
		}

		function onSetMinimumStateOfChargeRequested(soc) {
			Global.ess.minimumStateOfCharge = soc
		}
	}
}
