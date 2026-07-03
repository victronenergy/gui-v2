/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SwipeViewPage {
	id: root

	//% "Overview"
	title: qsTrId("nav_overview")
	iconSource: "qrc:/images/overview.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/OverviewPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	fullScreenWhenIdle: true
	focusPolicy: pageLoader.item?.focusPolicy ?? Qt.NoFocus
	showTopGradient: pageLoader.sourceComponent === portraitComponent
			&& pageLoader.item && !pageLoader.item.atYBeginning
	showBottomGradient: pageLoader.sourceComponent === portraitComponent
			&& pageLoader.item && !pageLoader.item.atYEnd

	Loader {
		id: pageLoader
		anchors.fill: parent
		sourceComponent: Theme.screenSize === Theme.Portrait ? portraitComponent : landscapeComponent
		focus: true

		Component {
			id: landscapeComponent

			OverviewPage_Landscape {
				isCurrentPage: root.isCurrentPage
				animationEnabled: root.animationEnabled
			}
		}

		Component {
			id: portraitComponent

			Flickable {
				id: portraitFlickable

				contentHeight: portraitPage.implicitHeight
				boundsBehavior: Flickable.StopAtBounds
				flickableDirection: Flickable.VerticalFlick

				OverviewPage_Portrait {
					id: portraitPage

					width: portraitFlickable.width
					height: portraitFlickable.height
					animationEnabled: root.animationEnabled
				}
			}
		}
	}
}
