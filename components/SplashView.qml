/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Rectangle {
	id: root
	color: Theme.color.background.primary

	signal hideSplash()

	Image {
		id: logo
		anchors.centerIn: parent
		anchors.verticalCenterOffset: Theme.geometry.splashView.verticalCenterOffset
		source: Theme.screenSize === Theme.FiveInch ? "qrc:/images/splash-logo-5inch.svg"
			: "qrc:/images/splash-logo-7inch.svg"
		MouseArea {
			anchors.fill: parent
			onClicked: root.hideSplash()
		}
	}

	ProgressBar {
		anchors {
			top: logo.bottom
			topMargin: Theme.geometry.splashView.spacing
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry.splashView.progressBar.width
		indeterminate: root.visible
	}

	Timer {
		id: loadFinishedTimer
		interval: 3600
		running: root.visible
		onTriggered: root.hideSplash()
	}
}
