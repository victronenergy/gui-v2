/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property int accessLevel: VenusOS.User_AccessType_User

	property QtObject briefView: QtObject {
		property ListModel gauges: ListModel {
			ListElement { value: VenusOS.Tank_Type_Battery }
			ListElement { value: VenusOS.Tank_Type_Fuel }
			ListElement { value: VenusOS.Tank_Type_FreshWater }
			ListElement { value: VenusOS.Tank_Type_BlackWater }
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
