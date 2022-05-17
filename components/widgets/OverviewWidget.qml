/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property int type: VenusOS.OverviewWidget_Type_UnknownType
	property int size: VenusOS.OverviewWidget_Size_M

	property alias icon: widgetHeader.icon
	property alias title: widgetHeader.title
	property alias quantityLabel: quantityLabel

	property alias sideGaugeVisible: sideGauge.visible
	property alias sideGaugeValue: sideGauge.value

	property alias extraContent: extraContent
	property bool isSegment

	property real compactY
	property real expandedY
	readonly property int compactHeight: getCompactHeight(size)
	readonly property int expandedHeight: getExpandedHeight(size)
	property real segmentCompactMargin
	property real segmentExpandedMargin
	property bool expanded
	property bool animateGeometry
	property bool animationEnabled: true

	function getCompactHeight(s) {
		return s === VenusOS.OverviewWidget_Size_XL
		  ? Theme.geometry.overviewPage.widget.compact.xl.height
		  : s === VenusOS.OverviewWidget_Size_L
			? Theme.geometry.overviewPage.widget.compact.l.height
			: s === VenusOS.OverviewWidget_Size_M
			  ? Theme.geometry.overviewPage.widget.compact.m.height
			  : s === VenusOS.OverviewWidget_Size_S
			  ? Theme.geometry.overviewPage.widget.compact.s.height
			  : Theme.geometry.overviewPage.widget.compact.xs.height
	}

	function getExpandedHeight(s) {
		return s === VenusOS.OverviewWidget_Size_XL
			? Theme.geometry.overviewPage.widget.expanded.xl.height
			: s === VenusOS.OverviewWidget_Size_L
			  ? Theme.geometry.overviewPage.widget.expanded.l.height
			  : s === VenusOS.OverviewWidget_Size_M
				? Theme.geometry.overviewPage.widget.expanded.m.height
				: s === VenusOS.OverviewWidget_Size_S
				? Theme.geometry.overviewPage.widget.expanded.s.height
				: Theme.geometry.overviewPage.widget.expanded.xs.height
	}

	y: expanded ? expandedY : compactY
	width: Theme.geometry.overviewPage.widget.width
	height: expanded
			? expandedHeight + (isSegment ? segmentExpandedMargin : 0)
			: compactHeight + (isSegment ? segmentCompactMargin : 0)
	visible: size !== VenusOS.OverviewWidget_Size_Zero
	radius: isSegment ? 0 : Theme.geometry.overviewPage.widget.radius
	border.width: enabled && !isSegment ? Theme.geometry.overviewPage.widget.border.width : 0
	border.color: Theme.color.overviewPage.widget.border
	color: isSegment ? "transparent" : Theme.color.overviewPage.widget.background

	Behavior on height {
		enabled: root.animateGeometry
		NumberAnimation {
			duration: Theme.animation.page.idleResize.duration
			easing.type: Easing.InOutQuad
		}
	}

	Behavior on y {
		enabled: root.animateGeometry
		NumberAnimation {
			duration: Theme.animation.page.idleResize.duration
			easing.type: Easing.InOutQuad
		}
	}

	VerticalGauge {
		id: sideGauge

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry.overviewPage.widget.sideGauge.margins
		}
		width: Theme.geometry.overviewPage.widget.sideGauge.width
		radius: Theme.geometry.overviewPage.widget.sideGauge.radius
		backgroundColor: Theme.color.overviewPage.widget.sideGauge.background
		foregroundColor: Theme.color.overviewPage.widget.sideGauge.highlight
		visible: false
		animationEnabled: root.animationEnabled
	}

	Item {
		id: header

		x: Theme.geometry.overviewPage.widget.content.horizontalMargin
		y: root.size > VenusOS.OverviewWidget_Size_S
		   ? Theme.geometry.overviewPage.widget.content.verticalMargin
		   : parent.height/2 - height/2
		width: parent.width - 2*Theme.geometry.overviewPage.widget.content.horizontalMargin
		height: widgetHeader.height + (quantityLabel.visible ? quantityLabel.height : 0)

		WidgetHeader {
			id: widgetHeader

			width: parent.width
		}

		EnergyQuantityLabel {
			id: quantityLabel

			anchors {
				top: widgetHeader.bottom
				topMargin: Theme.geometry.overviewPage.widget.header.spacing
			}
			font.pixelSize: root.size === VenusOS.OverviewWidget_Size_XS
					  ? Theme.geometry.overviewPage.widget.value.minimumFontSize
					  : Theme.geometry.overviewPage.widget.value.maximumFontSize
		}
	}

	Item {
		id: extraContent
		anchors {
			left: parent.left
			right: sideGauge.visible ? sideGauge.left : parent.right
			rightMargin: sideGauge.visible ? sideGauge.anchors.margins : 0
			top: header.bottom
			bottom: parent.bottom
		}
		visible: root.size >= VenusOS.OverviewWidget_Size_M
	}
}
