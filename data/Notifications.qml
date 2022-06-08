/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property var activeModel: ActiveNotificationsModel
	property var historicalModel: HistoricalNotificationsModel
	property bool audibleAlarmActive: false
	property bool snoozeAudibleAlarmActive: false

	function reset() {
		activeModel.reset()
		historicalModel.reset()
	}

	Component.onCompleted: {
		Global.notifications = root
	}
}
