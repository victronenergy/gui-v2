/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls
import Victron.VenusOS

Dialog {
	id: root

	property string titleText
	property alias content: content
	property bool active: false

	verticalPadding: 0
	horizontalPadding: 0
	contentHeight: parent.height
	contentWidth: parent.width

	enter: Transition {
		NumberAnimation { properties: "opacity"; from: 0.0; to: 1.0; duration: 300 }
	}
	exit: Transition {
		NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 300 }
	}

	background: Rectangle {
		anchors.fill: parent
		color: "black"
		opacity: 0.7
	}
	contentChildren: [
		Rectangle {
			id: content

			anchors.centerIn: parent
			width: 624
			height: 368
			radius: 8
			border.color: Theme.separatorBarColor
			color: Theme.controlCardBackgroundColor

			Text {
				id: title

				anchors {
					top: parent.top
					topMargin: 21
					horizontalCenter: parent.horizontalCenter
				}
				horizontalAlignment: Text.AlignHCenter
				color: Theme.primaryFontColor
				font.pixelSize: Theme.fontSizeLarge
				text: titleText
			}
			SeparatorBar {
				anchors {
					bottom: parent.bottom
					bottomMargin: 64
				}
				width: parent.width
			}
		},
		Row {
			anchors {
				bottom: parent.bottom
				bottomMargin: 56
				horizontalCenter: parent.horizontalCenter
			}
			width: 624
			height: 64
			Button {
				width: parent.width / 2
				height: parent.height
				font.pixelSize: Theme.fontSizeControlValue
				color: Theme.primaryFontColor
				spacing: 0
				//% "Close"
				text: qsTrId("controlcard_close")
				onClicked: root.reject()
			}
			SeparatorBar {
				anchors {
					bottom: parent.bottom
					bottomMargin: 8
				}
				height: 48
			}
			Button {
				width: parent.width / 2
				height: parent.height
				font.pixelSize: Theme.fontSizeControlValue
				color: Theme.primaryFontColor
				spacing: 0
				//% "Set"
				text: qsTrId("controlcard_set")
				onClicked: root.accept()
			}
		}
	]
}

