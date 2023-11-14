/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias dataSource: dataPoint.source
	property alias color: centreCircle.color
	property bool _pulse

	width: Theme.geometry.radioButton.indicator.width
	height: Theme.geometry.radioButton.indicator.width

	Rectangle {
		anchors.fill: parent
		radius: Theme.geometry.radioButton.indicator.width / 2
		border.color: Theme.color.radioButton.indicator.off
		color: "transparent"

		Rectangle {
			id: centreCircle

			anchors.fill: parent
			radius: Theme.geometry.radioButton.indicator.width / 2

			states: [
				State {
					name: "off"
					when: dataPoint.value === 0
					PropertyChanges { target: centreCircle; opacity : 0 }
				},
				State {
					name: "on"
					when: dataPoint.value === 1
					PropertyChanges { target: centreCircle; opacity : 1 }
				},
				State {
					name: "blink"
					when: dataPoint.value === 2
					PropertyChanges { target: centreCircle; opacity: _pulse ? 1 : 0 }
				},
				State {
					name: "blinkInverted"
					when: dataPoint.value === 3
					PropertyChanges { target: centreCircle; opacity: _pulse ? 0 : 1 }
				}
			]

			Timer {
				interval: 500
				running: dataPoint.value > 0
				repeat: true
				onTriggered: root._pulse = !root._pulse
			}
		}
	}

	DataPoint {
		id: dataPoint
	}
}
