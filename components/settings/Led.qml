/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Item {
	id: root

	readonly property alias dataItem: dataItem
	property alias color: centreCircle.color
	property bool _pulse

	width: Theme.geometry_radioButton_indicator_width
	height: Theme.geometry_radioButton_indicator_width

	Rectangle {
		anchors.fill: parent
		radius: Theme.geometry_radioButton_indicator_width / 2
		border.color: Theme.color_radioButton_indicator_off
		color: "transparent"

		Rectangle {
			id: centreCircle

			anchors.fill: parent
			radius: Theme.geometry_radioButton_indicator_width / 2

			states: [
				State {
					name: "off"
					when: dataItem.value === 0
					PropertyChanges { target: centreCircle; opacity : 0 }
				},
				State {
					name: "on"
					when: dataItem.value === 1
					PropertyChanges { target: centreCircle; opacity : 1 }
				},
				State {
					name: "blink"
					when: dataItem.value === 2
					PropertyChanges { target: centreCircle; opacity: _pulse ? 1 : 0 }
				},
				State {
					name: "blinkInverted"
					when: dataItem.value === 3
					PropertyChanges { target: centreCircle; opacity: _pulse ? 0 : 1 }
				}
			]

			Timer {
				interval: 500
				running: dataItem.value > 0
				repeat: true
				onTriggered: root._pulse = !root._pulse
			}
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
