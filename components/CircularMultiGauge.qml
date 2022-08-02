/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Gauges.js" as Gauges

Item {
	id: gauges

	property alias model: arcRepeater.model
	readonly property real strokeWidth: Theme.geometry.circularMultiGauge.strokeWidth
	property bool animationEnabled: true
	property real labelMargin
	property alias labelOpacity: textCol.opacity

	// Step change in the size of the bounding boxes of successive gauges
	readonly property real _stepSize: 2 * (strokeWidth + Theme.geometry.circularMultiGauge.spacing)

	Item {
		anchors.fill: parent

		// Antialiasing
		layer.enabled: true
		layer.samples: 4

		Repeater {
			id: arcRepeater
			width: parent.width
			delegate: ProgressArc {
				property int status: Gauges.getValueStatus(model.value, model.valueType)
				width: parent.width - (index*_stepSize)
				height: width
				anchors.centerIn: parent
				radius: width/2
				startAngle: 0
				endAngle: 270
				value: model.value
				progressColor: Theme.statusColorValue(status)
				remainderColor: Theme.statusColorValue(status, true)
				strokeWidth: gauges.strokeWidth
				visible: model.index < Theme.geometry.briefPage.centerGauge.maximumGaugeCount
				animationEnabled: gauges.animationEnabled
				shineAnimationEnabled: model.tankType === VenusOS.Tank_Type_Battery && Global.battery.mode === VenusOS.Battery_Mode_Charging
			}
		}
	}

	Item {
		id: textCol

		anchors.top: parent.top
		anchors.topMargin: strokeWidth/2
		anchors.bottom: parent.verticalCenter
		anchors.left: parent.left
		anchors.right: parent.horizontalCenter
		anchors.rightMargin: Theme.geometry.circularMultiGauge.labels.rightMargin + gauges.labelMargin

		Repeater {
			model: gauges.model
			delegate: Row {
				anchors.verticalCenter: textCol.top
				anchors.verticalCenterOffset: index * _stepSize/2
				anchors.right: parent.right
				anchors.rightMargin: Math.max(0, Theme.geometry.circularMultiGauge.icons.maxWidth - iconImage.width)
				spacing: Theme.geometry.circularMultiGauge.row.spacing
				visible: model.index < Theme.geometry.briefPage.centerGauge.maximumGaugeCount

				Label {
					horizontalAlignment: Text.AlignRight
					font.pixelSize: Theme.font.size.body2
					color: Theme.color.font.primary
					text: model.name
				}
				Label {
					anchors.verticalCenter: parent.verticalCenter
					horizontalAlignment: Text.AlignRight
					font.pixelSize: Theme.font.size.body2
					color: Theme.color.font.primary
					visible: Global.systemSettings.briefView.showPercentages
					//% "%1%"
					text: qsTrId("%1%").arg(Math.round(model.value))
				}
				CP.ColorImage {
					id: iconImage
					anchors.verticalCenter: parent.verticalCenter
					height: Theme.geometry.briefPage.centerGauge.icon.height
					source: model.icon
					color: Theme.color.font.primary
					fillMode: Image.PreserveAspectFit
					smooth: true
				}
			}
		}
	}
}
