/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Rectangle {
	id: tankGroupData

	property bool showTankGroupData: false
	property alias model: groupedSubgaugesRepeater.model

	parent: dialogManager
	anchors.fill: parent
	color: Theme.color.levelsPage.tankGroupData.background.color
	opacity: 0

	OpacityAnimator on opacity {
		from: 0;
		to: 1;
		running: showTankGroupData
		duration: Theme.animation.levelsPage.animation.duration
	}
	SequentialAnimation {
		id: hideTankGroupDataAnimation

		running: false
		NumberAnimation {
			target: tankGroupData
			property: "opacity"
			to: 0
			duration: Theme.animation.levelsPage.animation.duration
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: showTankGroupData = false
		}
	}
	MouseArea {
		anchors.fill: parent
		onClicked: hideTankGroupDataAnimation.running = true
	}
	Rectangle {
		color: Theme.color.levelsPage.gauge.backgroundColor
		radius: Theme.geometry.levelsPage.gauge.radius
		border.width: Theme.geometry.levelsPage.gauge.border.width
		border.color: parent.model && parent.model.get(0) ? _tankProperties[parent.model.get(0).type].borderColor : "transparent"
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
						horizontalCenterOffset: Theme.geometry.levelsPage.gauge.icon.horizontalCenterOffset
					}
					source: _tankProperties[type].icon
					color: Theme.color.levelsPage.tankIcon
				}
				Label {
					id: label
					height: Theme.geometry.levelsPage.gauge.label.height
					anchors {
						top: img.bottom
						topMargin: Theme.geometry.levelsPage.gauge.label.topMargin
						horizontalCenter: parent.horizontalCenter
					}
					font.pixelSize: Theme.font.size.s
					text: name
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
					percentage: model.percentage
				}
				Row {
					id: percentageText
					anchors {
						horizontalCenter: parent.horizontalCenter
						bottom: valueText.top
					}
					spacing: Theme.geometry.levelsPage.gauge.percentageText.spacing

					Label {
						font.pixelSize: Theme.levelsPage.percentageText.font.size
						text: (100 * percentage).toFixed(0)
					}
					Label {
						font.pixelSize: Theme.levelsPage.percentageText.font.size
						opacity: Theme.geometry.levelsPage.gauge.percentage.opacity
						text: '%'
					}
				}
				Label {
					id: valueText
					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry.levelsPage.gauge.valueText.bottomMargin
						horizontalCenter: parent.horizontalCenter
					}
					font.pixelSize: Theme.font.size.xs
					opacity: Theme.geometry.levelsPage.gauge.percentage.opacity
					text: ("%1/%2ℓ").arg((percentage * 1000).toFixed(0)).arg(1000) // TODO - connect to real capacity
				}
			}
		}
	}
}
