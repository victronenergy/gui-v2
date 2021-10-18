/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Window {
	id: root

	width: 1024
	height: 768
	color: Theme.backgroundColor

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os-label-application_title")

	Text {
		anchors.bottom: gauge.top
		anchors.horizontalCenter: gauge.horizontalCenter

		//: Gauge title
		//% "Levels"
		text: qsTrId("venus_os-label-gauge_levels")
	}
	CircularMultiGauge {
		id: gauge
		anchors.centerIn: parent
		width: 100
		height: 100
	}
}
