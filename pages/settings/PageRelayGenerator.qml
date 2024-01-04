/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

PageGenerator {
	id: root

	VeQuickItem {
		id: relayFunction
		uid: Global.systemSettings.serviceUid + "/Settings/Relay/Function"
	}

	model: !relayFunction.isValid || relayFunction.value === 1 ? startStopModel : disabledModel

	ObjectModel {
		id: disabledModel

		ListItem {
			primaryLabel.horizontalAlignment: Text.AlignHCenter
			//% "Generator start/stop function is not enabled, go to relay settings and set function to \"Generator start/stop\""
			text: qsTrId("settings_generator_function_not_enabled" )
		}
	}
}
