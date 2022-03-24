/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Rectangle {
	id: root

	property bool interactive: true
	property int totalCapacity: 0
	property real percentage: 0
	property int gaugeIndex: 0

	readonly property var gaugeDelegateWidths: [
		Theme.geometry.levelsPage.gaugeDelegate.tanks1.width,
		Theme.geometry.levelsPage.gaugeDelegate.tanks2.width,
		Theme.geometry.levelsPage.gaugeDelegate.tanks3.width,
		Theme.geometry.levelsPage.gaugeDelegate.tanks4.width,
		Theme.geometry.levelsPage.gaugeDelegate.tanks5.width
	]
	readonly property int gaugeDelegateWidthDeltaManyTanks: gaugeDelegateWidths[gaugeDelegateWidths.length - 1] -
															gaugeDelegateWidths[gaugeDelegateWidths.length - 2]

	signal splitGauge(int index)

	implicitWidth: {
		if (model.gaugeTanks.count === 0) {
			return 0
		}
		if (model.gaugeTanks.count >= gaugeDelegateWidths.length) {
			return gaugeDelegateWidths[gaugeDelegateWidths.length - 1] +
					((model.gaugeTanks.count - gaugeDelegateWidths.length) * gaugeDelegateWidthDeltaManyTanks)
		}

		return gaugeDelegateWidths[model.gaugeTanks.count - 1]
	}
	height: interactive ? Theme.geometry.levelsPage.gaugeDelegate.height.interactive : Theme.geometry.levelsPage.gaugeDelegate.height.fullScreen
	color: Theme.color.levelsPage.gauge.backgroundColor
	radius: Theme.geometry.levelsPage.gauge.radius

	border.width: Theme.geometry.levelsPage.gauge.border.width
	border.color: _tankProperties[type].borderColor

	Behavior on height {
		NumberAnimation {
			duration: Theme.animation.page.idleResize.duration
			easing.type: Easing.InOutQuad
		}
	}

	SequentialAnimation {
		id: removeAnimation

		running: gaugeTanks.count === 0
		NumberAnimation {
			target: root
			property: "opacity"
			to: 0
			duration: Theme.animation.levelsPage.animation.duration
			easing.type: Easing.InOutQuad
		}
	}
	OpacityAnimator on opacity {
		from: 0
		to: 1
		duration: Theme.animation.levelsPage.animation.duration
	}
	Item {
		id: img
		width: Theme.geometry.levelsPage.gauge.icon.width
		height: width
		anchors {
			top: parent.top
			topMargin: Theme.geometry.levelsPage.gauge.icon.topMargin
			horizontalCenter: parent.horizontalCenter
			horizontalCenterOffset: Theme.geometry.levelsPage.gauge.icon.horizontalCenterOffset
		}
		CP.ColorImage {
			anchors.centerIn: parent
			source: _tankProperties[type].icon
			color: Theme.color.levelsPage.tankIcon
		}
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
		text: model.gaugeTanks.count === 1 ? model.gaugeTanks.get(0).name : model.tankTypeName
	}
	ListView {
		id: subgauges // contains 1 or more gauges of a single type

		anchors {
			top: label.bottom
			topMargin: Theme.geometry.levelsPage.subgauges.topMargin
			left: parent.left
			leftMargin: Theme.geometry.levelsPage.subgauges.leftMargin
			bottom: percentageText.top
			bottomMargin: Theme.geometry.levelsPage.subgauges.bottomMargin
		}
		width: parent.width
		spacing: Theme.geometry.levelsPage.subgauges.spacing
		model: gaugeTanks
		orientation: ListView.Horizontal
		delegate: TankGauge {
			interactive: root.interactive
			width: subgauges.count > _subgaugeWidths.length ? _subgaugeWidths[_subgaugeWidths.length - 1] : _subgaugeWidths[subgauges.count - 1]
			height: subgauges.height
			percentage: model.percentage
			isGrouped: subgauges.count > 1
		}
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
		height: Theme.geometry.levelsPage.gauge.valueText.height
		font.pixelSize: Theme.font.size.xs
		opacity: Theme.geometry.levelsPage.gauge.percentage.opacity
		text: ("%1/%2ℓ").arg((percentage * 1000).toFixed(0)).arg(totalCapacity) // TODO connect to real tank capacity
	}
	MouseArea {
		anchors.fill: parent
		enabled: model.gaugeTanks.count > 1
		onClicked: root.splitGauge(index)
	}
}
