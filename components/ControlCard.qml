/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	property Page page: ListView.view ? ListView.view.parent : null
	property alias icon: icon
	property alias title: title
	property alias status: status

	width: 368 // TODO - handle 7" size if it is different
	height: 432 // TODO - handle 7" size if it is different
	color: Theme.controlCardBackgroundColor
	radius: 8

	MouseArea {
		anchors.fill: parent
		onClicked: if (page) page.controlsButton.clicked()
	}

	Row {
		anchors {
			left: parent.left
			leftMargin: 20
			top: parent.top
			topMargin: 12
		}
		spacing: 8
		Image {
			id: icon
		}
		Label {
			id: title

			font.pixelSize: Theme.fontSizeMedium
		}
	}

	Label {
		id: status

		anchors {
			top: parent.top
			topMargin: 37
			left: parent.left
			leftMargin: 16
		}
		font.pixelSize: Theme.fontSizeLarge
	}
}
