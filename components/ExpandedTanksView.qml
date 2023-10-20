/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import "/components/Gauges.js" as Gauges
import "/components/Units.js" as Units

Rectangle {
	id: root

	property bool active
	property alias tankModel: groupedSubgaugesRepeater.model
	readonly property var _tankProperties: Gauges.tankProperties(tankModel.type)
	property bool animationEnabled

	parent: Global.dialogLayer
	anchors.fill: parent
	color: Theme.color.levelsPage.tankGroupData.background.color
	opacity: active ? 1 : 0

	Behavior on opacity {
		enabled: root.animationEnabled
		OpacityAnimator {
			duration: Theme.animation.levelsPage.tanks.expandedView.fade.duration
		}
	}

	MouseArea {
		anchors.fill: parent
		enabled: root.active
		onClicked: root.active = false
	}

	Rectangle {
		color: Theme.color.levelsPage.gauge.backgroundColor
		radius: Theme.geometry.levelsPage.gauge.radius
		border.width: Theme.geometry.levelsPage.gauge.border.width
		border.color: root._tankProperties.borderColor
		width: groupedSubgauges.width + Theme.geometry.levelsPage.tankGroupData.horizontalMargin
		height: groupedSubgauges.height
		anchors.centerIn: groupedSubgauges
	}

	Row {
		id: groupedSubgauges

		anchors.centerIn: parent
		spacing: groupedSubgaugesRepeater.count > 2 ? Theme.geometry.levelsPage.tankGroupData.spacing3 : Theme.geometry.levelsPage.tankGroupData.spacing2

		Repeater {
			id: groupedSubgaugesRepeater

			height: Theme.geometry.levelsPage.tankGroupData.height

			delegate: Item {
				width: Theme.geometry.levelsPage.groupedSubgauges.delegate.width
				height: Theme.geometry.levelsPage.groupedSubgauges.delegate.height
				CP.ColorImage  {
					id: img
					anchors {
						top: parent.top
						topMargin: Theme.geometry.levelsPage.gauge.icon.topMargin
						horizontalCenter: parent.horizontalCenter
					}
					source: root._tankProperties.icon
					color: Theme.color.levelsPage.tankIcon
				}
				Label {
					id: label
					anchors {
						top: img.bottom
						topMargin: Theme.geometry.levelsPage.gauge.label.topMargin
						horizontalCenter: parent.horizontalCenter
					}
					width: Theme.geometry.levelsPage.gaugeDelegate.contentWidth
					font.pixelSize: Theme.font.size.body1
					minimumPixelSize: Theme.font.size.caption
					fontSizeMode: Text.HorizontalFit
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignBottom
					elide: Text.ElideRight
					text: model.device.name || root._tankProperties.name
				}
				TankGauge {
					anchors {
						top: label.bottom
						topMargin: Theme.geometry.levelsPage.subgauges.topMargin
						bottom: percentageText.top
						bottomMargin: Theme.geometry.levelsPage.subgauges.bottomMargin
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
						bottomMargin: Theme.geometry.levelsPage.gauge.valueText.topMargin
					}
					font.pixelSize: Theme.font.size.h1
					unit: VenusOS.Units_Percentage
					value: (isNaN(model.device.level) || model.device.level < 0) ? 0 : Math.round(model.device.level)
				}
				Label {
					id: valueText

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry.levelsPage.gauge.valueText.bottomMargin
						horizontalCenter: parent.horizontalCenter
					}
					width: Theme.geometry.levelsPage.gaugeDelegate.contentWidth
					horizontalAlignment: Text.AlignHCenter
					fontSizeMode: Text.HorizontalFit
					font.pixelSize: Theme.font.size.caption
					color: Theme.color.font.secondary
					text: Units.getCapacityDisplayText(Global.systemSettings.volumeUnit.value,
							model.device.capacity,
							model.device.remaining,
							Theme.geometry.quantityLabel.valueLength)
				}
			}
		}
	}
}
