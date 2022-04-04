/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Rectangle {
	id: root

	property int tankType
	property alias title: label.text
	property alias icon: img
	property bool expanded

	property real level // 0-100. Could calculate from value/capacity, but might as well use backend value
	property real totalRemaining
	property real totalCapacity

	property ListModel gaugeTanks
	property bool mergeTanks

	readonly property var tankProperties: Gauges.tankProperties(tankType)

	readonly property var _subgaugeWidths: [
		Theme.geometry.levelsPage.subgauge.width1,
		Theme.geometry.levelsPage.subgauge.width2,
		Theme.geometry.levelsPage.subgauge.width3,
		Theme.geometry.levelsPage.subgauge.width4
	]

	readonly property int _gaugeDelegateWidth: {
		if (!mergeTanks) {
			return Theme.geometry.levelsPage.subgauge.width1
		}
		return _subgaugeWidths[gaugeTanks.count - 1] || Theme.geometry.levelsPage.subgauge.width4
	}

	implicitWidth: mergeTanks
			? (_gaugeDelegateWidth * gaugeTanks.count)
				+ (Theme.geometry.levelsPage.subgauges.spacing * (gaugeTanks.count - 1))
				+ (Theme.geometry.levelsPage.subgauges.horizontalMargin * 2)
			: Theme.geometry.levelsPage.gaugeDelegate.width

	height: root.expanded
			? Theme.geometry.levelsPage.gaugeDelegate.expanded.height
			: Theme.geometry.levelsPage.gaugeDelegate.compact.height
	color: Theme.color.levelsPage.gauge.backgroundColor
	radius: Theme.geometry.levelsPage.gauge.radius

	border.width: Theme.geometry.levelsPage.gauge.border.width
	border.color: tankProperties.borderColor

	Behavior on height {
		enabled: PageManager.animatingIdleResize
		NumberAnimation {
			duration: Theme.animation.page.idleResize.duration
			easing.type: Easing.InOutQuad
		}
	}

	CP.ColorImage {
		id: img

		anchors {
			top: parent.top
			topMargin: Theme.geometry.levelsPage.gauge.icon.topMargin
			horizontalCenter: parent.horizontalCenter
		}
		height: Theme.geometry.levelsPage.gauge.icon.height
		fillMode: Image.PreserveAspectFit
		color: Theme.color.levelsPage.tankIcon
		source: root.tankProperties.icon
	}

	Label {
		id: label

		anchors {
			top: img.bottom
			topMargin: Theme.geometry.levelsPage.gauge.label.topMargin
			left: parent.left
			leftMargin: Theme.geometry.levelsPage.gauge.label.horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry.levelsPage.gauge.label.horizontalMargin
		}
		font.pixelSize: Theme.font.size.s
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight
	}

	Row {
		id: subgauges // contains 1 or more gauges of a single type

		anchors {
			top: label.bottom
			topMargin: Theme.geometry.levelsPage.subgauges.topMargin
			left: parent.left
			leftMargin: Theme.geometry.levelsPage.subgauges.horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry.levelsPage.subgauges.horizontalMargin
			bottom: percentageText.top
			bottomMargin: Theme.geometry.levelsPage.subgauges.bottomMargin
		}
		spacing: Theme.geometry.levelsPage.subgauges.spacing

		Repeater {
			model: root.gaugeTanks
			delegate: Loader {
				active: model.index === 0 || root.mergeTanks
				sourceComponent: TankGauge {
					width: root._gaugeDelegateWidth
					height: subgauges.height
					gaugeValueType: root.tankProperties.valueType
					value: (root.mergeTanks ? model.tank.level : root.level) / 100
					isGrouped: root.mergeTanks
				}
			}
		}
	}

	ValueQuantityDisplay {
		id: percentageText

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: valueText.top
			bottomMargin: Theme.geometry.levelsPage.gauge.valueText.topMargin
		}
		font.pixelSize: Theme.levelsPage.percentageText.font.size
		physicalQuantity: Units.PhysicalQuantity.Percentage
		value: root.level
	}

	Label {
		id: valueText

		anchors {
			bottom: parent.bottom
			bottomMargin: Theme.geometry.levelsPage.gauge.valueText.bottomMargin
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: Theme.font.size.xs
		color: Theme.color.font.secondary
		text: Units.getCapacityDisplayText(root.gaugeTanks.unit,
				root.totalCapacity,
				root.totalRemaining,
				Theme.geometry.levelsPage.gauge.valueText.precision)
	}
}
