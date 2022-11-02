/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

PageGenerator {
	id: root

	DataPoint {
		id: relayFunction
		source: "com.victronenergy.settings/Settings/Relay/Function"
	}

	model: !relayFunction.valid || relayFunction.value === 1 ? startStopModel : disabledModel

	ObjectModel {
		id: disabledModel

		SettingsListItem {
			primaryLabel.horizontalAlignment: Text.AlignHCenter
			//% "Generator start/stop function is not enabled, go to relay settings and set function to \"Generator start/stop\""
			text: qsTrId("settings_generator_function_not_enabled" )
		}
	}
}
