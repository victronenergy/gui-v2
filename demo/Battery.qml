/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "../components/Utils.js" as Utils

Item {
	id: root

	property real stateOfCharge: 64.12
	property real power: 55.15
	property real current: 14.24
	property real temperature: 28.33
	property real timeToGo: 190 * 60
	property string icon: Utils.batteryIcon(root)
	readonly property bool idle: current === 0 || power === 0
}
