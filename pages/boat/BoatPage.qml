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
	title: qsTrId("nav_boat")
	iconSource: "qrc:/images/icon_boat_32.svg"
	url: "qrc:/qt/qml/Victron/Boat/BoatPage.qml"
	backgroundColor: Theme.color_boatPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	Loader {
		id: pageLoader
		anchors.fill: parent
		sourceComponent: Theme.screenSize === Theme.Portrait ? boatPagePortrait : boatPageLandscape

		Component {
			id: boatPageLandscape

			BoatPage_Landscape {
				animationEnabled: root.animationEnabled
			}
		}

		Component {
			id: boatPagePortrait

			BoatPage_Portrait {
				animationEnabled: root.animationEnabled
			}
		}
	}
}
