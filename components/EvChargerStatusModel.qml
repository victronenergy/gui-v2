/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	readonly property var monitoredStatuses: [ Enums.Evcs_Status_Charging, Enums.Evcs_Status_Charged, Enums.Evcs_Status_Disconnected ]

	property var _statusConnections: Instantiator {
		model: Global.evChargers.model
		asynchronous: true
		delegate: Connections {
			target: model.device
			function onStatusChanged() { Qt.callLater(root._reloadCounts) }
			Component.onCompleted: Qt.callLater(root._reloadCounts)
		}
	}

	function _reloadCounts() {
		let totals = monitoredStatuses.map(function(status) { return 0 })
		let i
		for (i = 0; i < Global.evChargers.model.count; ++i) {
			const charger = Global.evChargers.model.deviceAt(i)
			const statusIndex = monitoredStatuses.indexOf(charger.status)
			if (statusIndex >= 0) {
				totals[statusIndex] += 1
			}
		}
		for (i = 0; i < totals.length; ++i) {
			setProperty(i, "statusCount", totals[i])
		}
	}

	Component.onCompleted: {
		for (let i = 0; i < monitoredStatuses.length; ++i) {
			append({ "status": monitoredStatuses[i], "statusCount": 0 })
		}
	}
}
