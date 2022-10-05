/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	property string source

	// The DemoMode value is special because it is read on start-up before any other values are
	// loaded, so this check avoids a binding loop on Global.demoManager.
	property var value: source !== "com.victronenergy.settings/Settings/Gui/DemoMode" && Global.demoManager
			? Global.demoManager.mockDataValues[source]
			: undefined

	property real min: 0
	property real max: 100

	function setValue(v) {
		value = v
	}
}
