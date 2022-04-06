/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	enum Type {
		UnknownType,
		Grid,
		Shore,
		AcGenerator,
		DcGenerator,
		Alternator,
		Wind,
		Solar,
		Inverter,
		Battery,
		AcLoads,
		DcLoads
	}

	enum Size {
		Zero, // i.e. not visible
		XS,
		S,
		M,
		L,
		XL
	}

	property int type: OverviewWidget.Type.UnknownType
	property int size: OverviewWidget.Size.M

	property alias physicalQuantity: valueDisplay.physicalQuantity
	property alias value: valueDisplay.value
	property alias precision: valueDisplay.precision
	property alias icon: valueDisplay.icon
	property alias title: valueDisplay.title

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

	function getCompactHeight(s) {
		return s === OverviewWidget.Size.XL
		  ? Theme.geometry.overviewPage.widget.compact.xl.height
		  : s === OverviewWidget.Size.L
			? Theme.geometry.overviewPage.widget.compact.l.height
			: s === OverviewWidget.Size.M
			  ? Theme.geometry.overviewPage.widget.compact.m.height
			  : s === OverviewWidget.Size.S
			  ? Theme.geometry.overviewPage.widget.compact.s.height
			  : Theme.geometry.overviewPage.widget.compact.xs.height
	}

	function getExpandedHeight(s) {
		return s === OverviewWidget.Size.XL
			? Theme.geometry.overviewPage.widget.expanded.xl.height
			: s === OverviewWidget.Size.L
			  ? Theme.geometry.overviewPage.widget.expanded.l.height
			  : s === OverviewWidget.Size.M
				? Theme.geometry.overviewPage.widget.expanded.m.height
				: s === OverviewWidget.Size.S
				? Theme.geometry.overviewPage.widget.expanded.s.height
				: Theme.geometry.overviewPage.widget.expanded.xs.height
	}

	y: expanded ? expandedY : compactY
	width: Theme.geometry.overviewPage.widget.width
	height: expanded
			? expandedHeight + (isSegment ? segmentExpandedMargin : 0)
			: compactHeight + (isSegment ? segmentCompactMargin : 0)
	visible: size !== OverviewWidget.Size.Zero
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
	}

	ValueDisplay {
		id: valueDisplay

		x: Theme.geometry.overviewPage.widget.content.horizontalMargin
		y: root.size > OverviewWidget.Size.S
		   ? Theme.geometry.overviewPage.widget.content.verticalMargin
		   : parent.height/2 - height/2
		fontSize: root.size === OverviewWidget.Size.XS
				  ? Theme.geometry.overviewPage.widget.value.minimumFontSize
				  : Theme.geometry.overviewPage.widget.value.maximumFontSize
	}

	Item {
		id: extraContent
		anchors {
			left: parent.left
			right: sideGauge.visible ? sideGauge.left : parent.right
			rightMargin: sideGauge.visible ? sideGauge.anchors.margins : 0
			top: valueDisplay.bottom
			bottom: parent.bottom
		}
		visible: root.size >= OverviewWidget.Size.M
	}
}
