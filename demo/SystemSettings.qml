/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property int accessLevel: User.AccessUser

	property QtObject briefView: QtObject {
		property ListModel gauges: ListModel {
			ListElement { value: Gauges.Battery }
			ListElement { value: Gauges.Fuel }
			ListElement { value: Gauges.FreshWater }
			ListElement { value: Gauges.BlackWater }
		}
		property bool showPercentages

		function setGauge(index, value) {
			gauges.setProperty(index, "value", value)
		}

		function setShowPercentages(value) {
			showPercentages = value
		}
	}

	function setAccessLevel(value) {
		accessLevel = value
	}

	function setDisplayMode(value) {
		// no-op
	}
}
