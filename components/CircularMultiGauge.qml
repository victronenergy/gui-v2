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
	property int leftGaugeCount

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
						progressColor: Theme.color_darkOk,Theme.statusColorValue(loader.gaugeStatus)
						remainderColor: Theme.color_darkOk,Theme.statusColorValue(loader.gaugeStatus, true)
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
						progressColor: Theme.color_darkOk,Theme.statusColorValue(loader.gaugeStatus)
						remainderColor: Theme.color_darkOk,Theme.statusColorValue(loader.gaugeStatus, true)
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
		anchors.leftMargin: Theme.geometry_circularMultiGauge_label_leftMargin
		anchors.right: parent.horizontalCenter
		anchors.rightMargin: Theme.geometry_circularMultiGauge_icon_rightMargin + gauges.labelMargin

		Repeater {
			model: gauges.model
			delegate: Row {
				anchors.verticalCenter: textCol.top
				anchors.verticalCenterOffset: index * _stepSize/2
				anchors.right: parent.right
				anchors.rightMargin: Math.max(0, Theme.geometry_circularMultiGauge_icons_maxWidth - iconImage.width)
				visible: model.index < Theme.geometry_briefPage_centerGauge_maximumGaugeCount
				height: iconImage.height

				Label {
					anchors.verticalCenter: parent.verticalCenter
					rightPadding: Theme.geometry_circularMultiGauge_label_rightMargin
					horizontalAlignment: Text.AlignRight
					font.pixelSize: valueLabel.visible ? Theme.font_size_body1 : Theme.font_size_body2
					color: Theme.color_font_primary
					text: model.name

					// With three gauges on the left there is a risk that the last labels on
					// on the multi-gauge overlap with the labels on the top-left gauge.
					//
					// Increase the space for the two top-most labels or if there are less left gauges.
					width: textCol.width - valueLabel.width - iconImage.width
						+ (model.index < 2 || gauges.leftGaugeCount < 3 ? Theme.geometry_circularMultiGauge_label_extraWidth : 0)
					elide: Text.ElideRight
				}

				Label {
					id: valueLabel
					anchors.verticalCenter: parent.verticalCenter
					rightPadding: Theme.geometry_circularMultiGauge_value_rightMargin
					horizontalAlignment: Text.AlignRight
					font.pixelSize: Theme.font_size_body1
					color: Theme.color_font_primary
					visible: false

					property int unit
					property quantityInfo quantity

					states: State {
						when: Global.systemSettings.briefView.unit.value !== VenusOS.BriefView_Unit_None
						PropertyChanges {
							target: valueLabel

							visible: true
							text: quantity.number + quantity.unit
							quantity: Units.getDisplayText(unit, value)
							unit: {
								if (Global.systemSettings.briefView.unit.value === VenusOS.BriefView_Unit_Percentage) {
									return VenusOS.Units_Percentage
								} else if (model.tankType === VenusOS.Tank_Type_Battery) {
									return VenusOS.Units_Percentage
								} else {
									return Global.systemSettings.volumeUnit
								}
							}
						}
					}
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
