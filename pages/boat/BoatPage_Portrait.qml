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
}
