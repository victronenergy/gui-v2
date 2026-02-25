/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Boat as Boat
import Victron.VenusOS

SwipeViewPage {
	id: root

	//% "Boat"
	navButtonText: qsTrId("nav_boat")
	navButtonIcon: "qrc:/images/icon_boat_32.svg"
	url: "qrc:/qt/qml/Victron/Boat/BoatPage.qml"
	backgroundColor: Theme.color_boatPage_background
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	Boat.MotorDrives {
		id: motorDrives
	}

	Boat.Gps {
		id: gps
	}

	Boat.TimeToGo {
		id: ttg

		anchors {
			top: centerGauge.top
			topMargin: Theme.geometry_boatPage_timeToGo_topMargin
			horizontalCenter: centerGauge.horizontalCenter
		}
	}

	Boat.LargeCenterGauge {
		id: centerGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry_page_content_verticalMargin
			horizontalCenter: parent.horizontalCenter
		}

		width: Math.min(3 * root.width / 4, root.height/2 - 2*Theme.geometry_page_content_verticalMargin)
		height: centerGauge.width

		gps: gps // primary data source
		motorDrives: motorDrives // secondary data source
		animationEnabled: root.animationEnabled
	}
}
