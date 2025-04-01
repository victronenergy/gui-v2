/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

ProgressArc {
	id: centerGauge

	// Always show GPS speed in the center, unless it is unavailable. Then, we show motordrive or system dc consumption
	required property VeQuickItemsQuotient dataSource
	readonly property real _angularRange: endAngle - startAngle

	anchors {
		top: parent.top
		topMargin: Theme.geometry_boatPage_centerGauge_topMargin
		horizontalCenter: parent.horizontalCenter
	}
	rotation: Theme.geometry_boatPage_centerGauge_rotation
	width: Theme.geometry_boatPage_centerGauge_width
	height: width
	radius: width/2
	startAngle: Theme.geometry_boatPage_centerGauge_startAngle
	endAngle: Theme.geometry_boatPage_centerGauge_endAngle
	value: dataSource.percentage
	strokeWidth: Theme.geometry_boatPage_centerGauge_strokeWidth
	animationEnabled: false
	objectName: "centerGauge"
	onDataSourceChanged: console.log(objectName, "dataSource:", dataSource ? dataSource.objectName : "null")

	Rectangle {
		id: needle
		anchors {
			bottom: parent.verticalCenter
			horizontalCenter: parent.horizontalCenter
		}

		width: centerGauge.strokeWidth
		height: Theme.geometry_boatPage_centerGauge_needleHeight
		radius: width / 2
		color: Theme.color_boatPage_background
		transformOrigin: Item.Bottom
		rotation: (centerGauge._angularRange * centerGauge.dataSource.normalizedValue)
		Rectangle {
			anchors {
				top: parent.top
				topMargin: radius
				horizontalCenter: parent.horizontalCenter
			}
			width: Theme.geometry_boatPage_centerGauge_innerNeedleWidth
			height: Theme.geometry_boatPage_centerGauge_innerNeedleHeight
			radius: width / 2
			gradient: Gradient {
				GradientStop {
					position: 0.0
					color: Theme.color_boatPage_needle
				}
				GradientStop {
					position: 0.4
					color: Theme.color_boatPage_needle
				}
				GradientStop {
					position: 0.6
					color: "transparent"
				}
				GradientStop {
					position: 1
					color: "transparent"
				}
			}
		}
	}
}

