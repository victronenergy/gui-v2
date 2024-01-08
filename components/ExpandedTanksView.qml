/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Gauges
import Victron.Units

Rectangle {
	id: root

	property bool active
	property alias tankModel: groupedSubgaugesRepeater.model
	readonly property var _tankProperties: Gauges.tankProperties(tankModel.type)
	property bool animationEnabled

	parent: Global.dialogLayer
	anchors.fill: parent
	color: Theme.color_levelsPage_tankGroupData_background_color
	opacity: active ? 1 : 0

	Behavior on opacity {
		enabled: root.animationEnabled
		OpacityAnimator {
			duration: Theme.animation_levelsPage_tanks_expandedView_fade_duration
		}
	}

	MouseArea {
		anchors.fill: parent
		enabled: root.active
		onClicked: root.active = false
	}

	Rectangle {
		color: Theme.color_levelsPage_gauge_backgroundColor
		radius: Theme.geometry_levelsPage_gauge_radius
		border.width: Theme.geometry_levelsPage_gauge_border_width
		border.color: root._tankProperties.borderColor
		width: groupedSubgauges.width + Theme.geometry_levelsPage_tankGroupData_horizontalMargin
		height: groupedSubgauges.height
		anchors.centerIn: groupedSubgauges
	}

	Row {
		id: groupedSubgauges

		anchors.centerIn: parent
		spacing: groupedSubgaugesRepeater.count > 2 ? Theme.geometry_levelsPage_tankGroupData_spacing3 : Theme.geometry_levelsPage_tankGroupData_spacing2

		Repeater {
			id: groupedSubgaugesRepeater

			height: Theme.geometry_levelsPage_tankGroupData_height

			delegate: Item {
				width: Theme.geometry_levelsPage_groupedSubgauges_delegate_width
				height: Theme.geometry_levelsPage_groupedSubgauges_delegate_height
				CP.ColorImage  {
					id: img
					anchors {
						top: parent.top
						topMargin: Theme.geometry_levelsPage_gauge_icon_topMargin
						horizontalCenter: parent.horizontalCenter
					}
					source: root._tankProperties.icon
					color: Theme.color_levelsPage_tankIcon
				}
				Label {
					id: label
					anchors {
						top: img.bottom
						topMargin: Theme.geometry_levelsPage_gauge_label_topMargin
						horizontalCenter: parent.horizontalCenter
					}
					width: Theme.geometry_levelsPage_gaugeDelegate_contentWidth
					font.pixelSize: Theme.font_size_body1
					minimumPixelSize: Theme.font_size_caption
					fontSizeMode: Text.HorizontalFit
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignBottom
					elide: Text.ElideRight
					text: model.device.name || root._tankProperties.name
				}
				TankGauge {
					anchors {
						top: label.bottom
						topMargin: Theme.geometry_levelsPage_subgauges_topMargin
						bottom: percentageText.top
						bottomMargin: Theme.geometry_levelsPage_subgauges_bottomMargin
					}
					width: parent.width
					height: groupedSubgauges.height
					gaugeValueType: root._tankProperties.valueType
					animationEnabled: root.animationEnabled
					value: model.device.level / 100
				}
				QuantityLabel {
					id: percentageText

					anchors {
						horizontalCenter: parent.horizontalCenter
						bottom: valueText.top
						bottomMargin: Theme.geometry_levelsPage_gauge_valueText_topMargin
					}
					font.pixelSize: Theme.font_size_h1
					unit: VenusOS.Units_Percentage
					value: (isNaN(model.device.level) || model.device.level < 0) ? 0 : Math.round(model.device.level)
				}
				Label {
					id: valueText

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry_levelsPage_gauge_valueText_bottomMargin
						horizontalCenter: parent.horizontalCenter
					}
					width: Theme.geometry_levelsPage_gaugeDelegate_contentWidth
					horizontalAlignment: Text.AlignHCenter
					fontSizeMode: Text.HorizontalFit
					font.pixelSize: Theme.font_size_caption
					color: Theme.color_font_secondary
					text: Units.getCapacityDisplayText(Global.systemSettings.volumeUnit,
							model.device.capacity,
							model.device.remaining,
							Theme.geometry_quantityLabel_valueLength)
				}
			}
		}
	}
}
