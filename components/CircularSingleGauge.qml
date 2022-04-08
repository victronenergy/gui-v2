/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: gauges

	property QtObject model // must be QtObject instead of var, else cannot update its values via Binding objects
	readonly property real strokeWidth: Theme.geometry.circularSingularGauge.strokeWidth
	property alias caption: captionLabel.text

	Item {
		id: arcGauge
		readonly property int antialiasingFactor: 2
		width: parent.width*antialiasingFactor
		height: parent.height*antialiasingFactor
		visible: false

		ProgressArc {
			property int status: Gauges.getValueStatus(model.value, model.valueType)
			
			width: parent.width - strokeWidth
			height: width
			anchors.centerIn: parent
			radius: width/2
			startAngle: 0
			endAngle: 360
			value: model.value
			progressColor: Theme.statusColorValue(status)
			remainderColor: Theme.statusColorValue(status, true)
			strokeWidth: gauges.strokeWidth * arcGauge.antialiasingFactor
		}
	}
	ShaderEffectSource {
		id: antialiasedArcGauge
		anchors.fill: parent
		sourceItem: arcGauge
		smooth: true
	}

	Column {
		anchors.centerIn: parent
		
		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			CP.ColorImage {
				id: icon
				source: model.icon
				color: Theme.color.font.primary
				fillMode: Image.PreserveAspectFit
				smooth: true
			}
			Label {
				anchors.verticalCenter: icon.verticalCenter
				font.pixelSize: Theme.font.size.m
				color: Theme.color.font.primary
				text: model.name
			}
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			Label {
				font.pixelSize: Theme.font.size.xxxl
				color: Theme.color.font.primary
				text: model.value
			}
			Label {
				font.pixelSize: Theme.font.size.xxxl
				color: Theme.color.font.secondary
				text: '%'
			}
		}

		Label {
			id: captionLabel

			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Theme.font.size.s
			color: Theme.color.font.secondary
		}
	}
}
