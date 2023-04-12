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

	property bool animationEnabled: true
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
		enabled: root.animationEnabled && Global.pageManager.animatingIdleResize
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
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry.levelsPage.gaugeDelegate.contentWidth
		font.pixelSize: Theme.font.size.body1
		minimumPixelSize: Theme.font.size.caption
		fontSizeMode: Text.HorizontalFit
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignBottom
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
					animationEnabled: root.animationEnabled
					width: root._gaugeDelegateWidth
					height: subgauges.height
					gaugeValueType: root.tankProperties.valueType
					value: (root.mergeTanks ? model.tank.level : root.level) / 100
					isGrouped: root.mergeTanks
				}
				onStatusChanged: if (status === Loader.Error) console.warn("Unable to load tank levels gauge:", errorString())
			}
		}
	}

	QuantityLabel {
		id: percentageText

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: valueText.top
			bottomMargin: Theme.geometry.levelsPage.gauge.valueText.topMargin
		}
		width: Theme.geometry.levelsPage.gaugeDelegate.contentWidth
		font.pixelSize: Theme.font.size.h1
		unit: VenusOS.Units_Percentage
		value: (isNaN(root.level) || root.level < 0) ? 0 : Math.round(root.level)
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
				isNaN(root.totalCapacity) ? 0 : root.totalCapacity,
				isNaN(root.totalRemaining) ? 0 : root.totalRemaining,
				Theme.geometry.quantityLabel.valueLength)
	}
}
