/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

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
