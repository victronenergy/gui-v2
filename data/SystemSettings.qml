/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property var accessLevel
	property var demoMode
	property var colorScheme
	property var energyUnit
	property var temperatureUnit
	property var volumeUnit
	property QtObject briefView: QtObject {
		// Default settings
		property ListModel gauges: ListModel {
			ListElement { value: VenusOS.Tank_Type_Battery }
			ListElement { value: VenusOS.Tank_Type_Fuel }
			ListElement { value: VenusOS.Tank_Type_FreshWater }
			ListElement { value: VenusOS.Tank_Type_BlackWater }
		}

		property var showPercentages
		signal setGaugeRequested(index: int, value: var)

		function setGauge(index, value) {
			gauges.setProperty(index, "value", value)
		}
	}

	function reset() {
		// no-op
	}

	function canAccess(level) {
		return !!accessLevel ? accessLevel.value >= level : false
	}

	function setDataSource(source) {
		root.accessLevel = source.accessLevel
		root.demoMode = source.demoMode
		root.colorScheme = source.colorScheme
		root.energyUnit = source.energyUnit
		root.temperatureUnit = source.temperatureUnit
		root.volumeUnit = source.volumeUnit
		root.briefView.showPercentages = source.showPercentages
	}

	Component.onCompleted: Global.systemSettings = root
}
