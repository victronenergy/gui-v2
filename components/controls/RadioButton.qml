/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.RadioButton {
	id: root

	indicator: Rectangle {
		x: root.width - width
		y: parent.height / 2 - height / 2
		implicitWidth: 24
		implicitHeight: 24
		radius: 12
		border.width: 2
		border.color: root.down || root.checked ? Theme.okColor : Theme.secondaryFontColor
		color: 'transparent'

		Rectangle {
			anchors.centerIn: parent
			width: 16
			height: 16
			radius: 8
			color: Theme.okColor
			visible: root.down || root.checked
		}
	}

	contentItem: Item {
		implicitWidth: label.implicitWidth + root.indicator.implicitWidth + root.spacing

		Label {
			id: label

			text: root.text
			color: Theme.primaryFontColor
			verticalAlignment: Text.AlignVCenter
		}
	}
}
