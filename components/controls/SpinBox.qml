/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.SpinBox {
	id: root

	property alias label: label
	property int buttonWidth: 64

	height: 72
	spacing: Theme.marginSmall

	contentItem: Label {
		id: label
		text: root.value
		font.pixelSize: Theme.fontSizeXXL
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter
	}

	up.indicator: Rectangle {
		x: parent.width - width
		height: parent.height
		implicitWidth: root.buttonWidth
		implicitHeight: 72
		radius: 6
		color: root.up.pressed ? Theme.okSecondaryColor : Theme.spinboxButtonColor // TODO need disabled rgba from Design

		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_plus.svg'
		}
	}

	down.indicator: Rectangle {
		height: parent.height
		implicitWidth: root.buttonWidth
		implicitHeight: 72
		radius: 6
		color: root.down.pressed ? Theme.okSecondaryColor : Theme.spinboxButtonColor // TODO need disabled rgba from Design
		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_minus.svg'
		}
	}

	background: Item {
		implicitWidth: root.width - root.buttonWidth*2 - root.spacing*2
	}
}
