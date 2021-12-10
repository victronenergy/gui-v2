/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.Switch {
	id: root

	readonly property int _indicatorOverlap: 2

	background: Rectangle {
		implicitWidth: 44
		implicitHeight: 20
		x: _indicatorOverlap
		y: parent.height / 2 - height / 2
		radius: 12
		color: root.checked ? Theme.okColor : 'transparent'
		border.color: root.checked ? 'transparent' : Theme.secondaryFontColor
		border.width: 2
	}

	indicator: Item {
		implicitWidth: background.width + 2*_indicatorOverlap
		Rectangle {
			x: root.checked ? parent.width - width : 0
			y: root.height / 2 - height / 2

			width: 24
			height: 24
			radius: 12
			color: Theme.primaryFontColor

			Behavior on x {
				NumberAnimation {
					duration: 200
					easing.type: Easing.InOutQuad
				}
			}
		}
	}

	contentItem: Item {
		implicitWidth: root.text === "" ? 0 : label.implicitWidth + root.indicator.implicitWidth + root.spacing

		Label {
			id: label

			text: root.text
			color: Theme.primaryFontColor
			verticalAlignment: Text.AlignVCenter
		}
	}
}
