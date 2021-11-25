/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property var value
	property alias label: label
	property alias rectangle: rectangle
	property alias displayValue: displayValueText

	signal clicked()

	spacing: 16

	Item {
		width: parent.width
		height: 40
		anchors {
			left: parent.left
			leftMargin: 8
		}

		Label {
			id: label

			anchors {
				left: parent.left
				verticalCenter: parent.verticalCenter
			}
			width: parent.width - rectangle.width - rectangle.anchors.rightMargin
			elide: Text.ElideRight
			font.pixelSize: Theme.fontSizeMedium
			color: Theme.primaryFontColor
		}
		Rectangle {
			id: rectangle

			anchors {
				right: parent.right
				rightMargin: 16
				verticalCenter: parent.verticalCenter
			}
			border.color: Theme.okColor
			border.width: 2
			color: Theme.spinboxButtonSecondaryColor
			height: 40
			radius: 6
			MouseArea {
				anchors.fill: parent
				onClicked: root.clicked()
			}
		}
		Text {
			id: displayValueText

			anchors.fill: rectangle
			elide: Text.ElideRight
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			color: Theme.primaryFontColor
			font.pixelSize: 22
		}
	}
	SeparatorBar {
		width: 352
	}
}
