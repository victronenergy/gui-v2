/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function airQualityToText(iaqs) {
		if (isNaN(iaqs)) {
			return ""
		}
		if (iaqs >= 90) {
			//% "Excellent"
			return qsTrId("temperature_air_quality_excellent")
		} else if (iaqs >= 80) {
			//% "Good"
			return qsTrId("temperature_air_quality_good")
		} else if (iaqs >= 50) {
			//% "Fair"
			return qsTrId("temperature_air_quality_fair")
		} else if (iaqs >= 10) {
			//% "Poor"
			return qsTrId("temperature_air_quality_poor")
		} else {
			//% "Very poor"
			return qsTrId("temperature_air_quality_very_poor")
		}
	}

	function airQualityToColor(iaqs, defaultColor) {
		if (isNaN(iaqs)) {
			return defaultColor
		}
		if (iaqs >= 80) {
			return Theme.color_success
		} else if (iaqs >= 50) {
			return Theme.color_warning
		} else {
			return Theme.color_critical
		}
	}

	readonly property FilteredDeviceModel model: FilteredDeviceModel {
		serviceTypes: ["temperature"]
	}
}
