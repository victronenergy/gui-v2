/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Gauges

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

	property BaseDeviceModel gaugeTanks
	property bool mergeTanks

	readonly property var tankProperties: Gauges.tankProperties(tankType)

	readonly property var _subgaugeWidths: [
		Theme.geometry_levelsPage_subgauge_width1,
		Theme.geometry_levelsPage_subgauge_width2,
		Theme.geometry_levelsPage_subgauge_width3,
		Theme.geometry_levelsPage_subgauge_width4
	]

	readonly property int _gaugeDelegateWidth: {
		if (!mergeTanks) {
			return Theme.geometry_levelsPage_subgauge_width1
		}
		return _subgaugeWidths[gaugeTanks.count - 1] || Theme.geometry_levelsPage_subgauge_width4
	}

	implicitWidth: mergeTanks
			? (_gaugeDelegateWidth * gaugeTanks.count)
				+ (Theme.geometry_levelsPage_subgauges_spacing * (gaugeTanks.count - 1))
				+ (Theme.geometry_levelsPage_subgauges_horizontalMargin * 2)
			: Theme.geometry_levelsPage_gaugeDelegate_width

	height: root.expanded
			? Theme.geometry_levelsPage_gaugeDelegate_expanded_height
			: Theme.geometry_levelsPage_gaugeDelegate_compact_height
	color: Theme.color_levelsPage_gauge_backgroundColor
	radius: Theme.geometry_levelsPage_gauge_radius

	border.width: Theme.geometry_levelsPage_gauge_border_width
	border.color: tankProperties.borderColor

	Behavior on height {
		enabled: root.animationEnabled && !!Global.pageManager && Global.pageManager.animatingIdleResize
		NumberAnimation {
			duration: Theme.animation_page_idleResize_duration
			easing.type: Easing.InOutQuad
		}
	}

	CP.ColorImage {
		id: img

		anchors {
			top: parent.top
			topMargin: Theme.geometry_levelsPage_gauge_icon_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		height: Theme.geometry_levelsPage_gauge_icon_height
		fillMode: Image.PreserveAspectFit
		color: Theme.color_levelsPage_tankIcon
		source: root.tankProperties.icon
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
	}

	Row {
		id: subgauges // contains 1 or more gauges of a single type

		anchors {
			top: label.bottom
			topMargin: Theme.geometry_levelsPage_subgauges_topMargin
			left: parent.left
			leftMargin: Theme.geometry_levelsPage_subgauges_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_levelsPage_subgauges_horizontalMargin
			bottom: percentageText.top
			bottomMargin: Theme.geometry_levelsPage_subgauges_bottomMargin
		}
		spacing: Theme.geometry_levelsPage_subgauges_spacing

		Repeater {
			model: root.gaugeTanks
			delegate: Loader {
				active: model.index === 0 || root.mergeTanks
				sourceComponent: TankGauge {
					animationEnabled: root.animationEnabled
					width: root._gaugeDelegateWidth
					height: subgauges.height
					gaugeValueType: root.tankProperties.valueType
					value: (root.mergeTanks ? model.device.level : root.level) / 100
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
			bottomMargin: Theme.geometry_levelsPage_gauge_valueText_topMargin
		}
		width: Theme.geometry_levelsPage_gaugeDelegate_contentWidth
		font.pixelSize: Theme.font_size_h1
		unit: VenusOS.Units_Percentage
		visible: !isNaN(root.level)
		value: (isNaN(root.level) || root.level < 0) ? 0 : Math.round(root.level)
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
		visible: !isNaN(root.totalCapacity) && !isNaN(root.totalRemaining)
		text: Units.getCapacityDisplayText(Global.systemSettings.volumeUnit,
				isNaN(root.totalCapacity) ? 0 : root.totalCapacity,
				isNaN(root.totalRemaining) ? 0 : root.totalRemaining)
	}
}
