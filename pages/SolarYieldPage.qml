/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Page {
	id: root

	controlsButton.visible: false

	Button {
		id: backButton

		anchors {
			left: parent.left
			leftMargin: 26
			top: parent.top
			topMargin: 10
		}

		height: 32
		width: height
		display: C.AbstractButton.IconOnly
		color: Theme.okColor
		icon.source: "qrc:/images/back.svg"
		icon.width: 14
		icon.height: 26
		onClicked: PageManager.popPage()
	}

	Label {
		id: titleLabel

		anchors {
			topMargin: 2*Theme.marginSmall // TODO: Theme constant for vertical margins
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}

		//% "Solar yield"
		//: The title of the page which shows solar yield details
		text: qsTrId("solar_yield_page_title")
		font.pixelSize: Theme.fontSizeLarge
	}

	SegmentedButtonRow {
		id: selectorButton
		anchors {
			topMargin: 2*Theme.marginSmall
			top: titleLabel.bottom
			horizontalCenter: parent.horizontalCenter
		}
		width: 368
		height: 40
		fontPixelSize: Theme.fontSizeMedium
		model: ["Devices", "History"]
		currentIndex: 0
	}

	Loader {
		id: loader
		anchors {
			topMargin: 2*Theme.marginSmall
			top: selectorButton.bottom
			bottom: root.bottom
			left: root.left
			right: root.right
		}
		sourceComponent: selectorButton.currentIndex === 0 ? detailsComponent : historyComponent
	}

	Component {
		id: detailsComponent
		Rectangle {
			color: "red"
			opacity: 0.3
		}
	}

	Component {
		id: historyComponent
		SolarYieldHistory { }
	}
}
