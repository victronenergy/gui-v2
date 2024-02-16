/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Item {
	id: gauges

	property alias model: arcRepeater.model
	readonly property real strokeWidth: Theme.geometry_circularMultiGauge_strokeWidth
	property bool animationEnabled
	property real labelMargin
	property alias labelOpacity: textCol.opacity

	// Step change in the size of the bounding boxes of successive gauges
	readonly property real _stepSize: 2 * (strokeWidth + Theme.geometry_circularMultiGauge_spacing)

	Item {
		id: antialiased
		anchors.fill: parent

		// Antialiasing without requiring multisample framebuffers.
		layer.enabled: true
		layer.smooth: true
		layer.textureSize: Qt.size(antialiased.width*2, antialiased.height*2)

		Repeater {
			id: arcRepeater
			width: parent.width
			delegate: Loader {
				id: loader
				property int gaugeStatus: Gauges.getValueStatus(model.value, model.valueType)
				property real value: model.value
				width: parent.width - (index*_stepSize)
				height: width
				anchors.centerIn: parent
				visible: model.index < Theme.geometry_briefPage_centerGauge_maximumGaugeCount
				sourceComponent: model.tankType === VenusOS.Tank_Type_Battery ? shinyProgressArc : progressArc
				onStatusChanged: if (status === Loader.Error) console.warn("Unable to load circular multi gauge progress arc:", errorString())

				Component {
					id: shinyProgressArc
					ShinyProgressArc {
						radius: width/2
						startAngle: 0
						endAngle: 270
						value: loader.value
						progressColor: Theme.statusColorValue(loader.gaugeStatus)
						remainderColor: Theme.statusColorValue(loader.gaugeStatus, true)
						strokeWidth: gauges.strokeWidth
						animationEnabled: gauges.animationEnabled
						shineAnimationEnabled: Global.batteries.system.mode === VenusOS.Battery_Mode_Charging
					}
				}

				Component {
					id: progressArc
					ProgressArc {
						radius: width/2
						startAngle: 0
						endAngle: 270
						value: loader.value
						progressColor: Theme.statusColorValue(loader.gaugeStatus)
						remainderColor: Theme.statusColorValue(loader.gaugeStatus, true)
						strokeWidth: gauges.strokeWidth
						animationEnabled: gauges.animationEnabled
					}
				}
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
		anchors.rightMargin: Theme.geometry_circularMultiGauge_labels_rightMargin + gauges.labelMargin

		Repeater {
			model: gauges.model
			delegate: Row {
				anchors.verticalCenter: textCol.top
				anchors.verticalCenterOffset: index * _stepSize/2
				anchors.right: parent.right
				anchors.rightMargin: Math.max(0, Theme.geometry_circularMultiGauge_icons_maxWidth - iconImage.width)
				spacing: Theme.geometry_circularMultiGauge_row_spacing
				visible: model.index < Theme.geometry_briefPage_centerGauge_maximumGaugeCount

				Label {
					horizontalAlignment: Text.AlignRight
					font.pixelSize: Theme.font_size_body2
					color: Theme.color_font_primary
					text: model.name
				}
				Label {
					anchors.verticalCenter: parent.verticalCenter
					horizontalAlignment: Text.AlignRight
					font.pixelSize: Theme.font_size_body2
					color: Theme.color_font_primary
					visible: Global.systemSettings.briefView.showPercentages.value === 1
					//% "%1%"
					text: qsTrId("%1%").arg(isNaN(model.value) ? 0 : Math.round(model.value))
				}
				CP.ColorImage {
					id: iconImage
					source: model.icon
					color: Theme.color_font_primary
				}
			}
		}
	}
}
