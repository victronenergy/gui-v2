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
	property real sideGaugeValue

	property alias extraContent: extraContent
	property bool isSegment

	property real interactiveY
	property real nonInteractiveY
	readonly property int interactiveHeight: getInteractiveHeight(size)
	readonly property int nonInteractiveHeight: getNonInteractiveHeight(size)
	property bool expanded

	function getInteractiveHeight(s) {
		return s === OverviewWidget.Size.XL
		  ? Theme.geometry.overviewPage.widget.interactive.xl.height
		  : s === OverviewWidget.Size.L
			? Theme.geometry.overviewPage.widget.interactive.l.height
			: s === OverviewWidget.Size.M
			  ? Theme.geometry.overviewPage.widget.interactive.m.height
			  : s === OverviewWidget.Size.Size
			  ? Theme.geometry.overviewPage.widget.interactive.Size.height
			  : Theme.geometry.overviewPage.widget.interactive.xs.height
	}

	function getNonInteractiveHeight(s) {
		return s === OverviewWidget.Size.XL
			? Theme.geometry.overviewPage.widget.noninteractive.xl.height
			: s === OverviewWidget.Size.L
			  ? Theme.geometry.overviewPage.widget.noninteractive.l.height
			  : s === OverviewWidget.Size.M
				? Theme.geometry.overviewPage.widget.noninteractive.m.height
				: s === OverviewWidget.Size.S
				? Theme.geometry.overviewPage.widget.noninteractive.s.height
				: Theme.geometry.overviewPage.widget.noninteractive.xs.height
	}

	signal clicked()

	y: expanded ? nonInteractiveY : interactiveY
	width: Theme.geometry.overviewPage.widget.width
	height: expanded ? nonInteractiveHeight : interactiveHeight
	visible: size !== OverviewWidget.Size.Zero
	radius: isSegment ? 0 : Theme.geometry.overviewPage.widget.radius
	border.width: enabled && !isSegment ? Theme.geometry.overviewPage.widget.border.width : 0
	border.color: Theme.color.overviewPage.widget.border
	color: isSegment ? "transparent" : Theme.color.overviewPage.widget.background

	Behavior on height {
		enabled: PageManager.animatingIdleResize
		NumberAnimation {
			duration: Theme.animation.page.idleResize.duration
			easing.type: Easing.InOutQuad
		}
	}

	Behavior on y {
		NumberAnimation {
			duration: Theme.animation.overviewPage.interactive.duration
			easing.type: Easing.InOutQuad
		}
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked: root.clicked()
	}

	Rectangle {
		id: sideGauge
		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry.overviewPage.widget.sideGauge.margins
		}

		property real value: Math.max(0, Math.min(1.0, root.sideGaugeValue)) // 0.0 -> 1.0
		visible: false
		width: Theme.geometry.overviewPage.widget.sideGauge.width
		radius: Theme.geometry.overviewPage.widget.sideGauge.radius
		color: Theme.color.overviewPage.widget.sideGauge.background

		// We could do the highlight more accurately (and it would scale nicer)
		// with a single full-height rounded rectangle inside a clip item.
		// However, that would require adding a clip, which can affect performance.

		Rectangle {
			id: highlightTop
			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
			}

			radius: parent.radius
			height: parent.value === 1.0 ? 2*radius : 0
			color: Theme.color.overviewPage.widget.sideGauge.highlight
		}

		Rectangle {
			id: highlight
			anchors {
				bottom: highlightBottom.verticalCenter
				left: parent.left
				right: parent.right
			}
			height: Math.max(0, (parent.value * parent.height) - 2*parent.radius)
			color: Theme.color.overviewPage.widget.sideGauge.highlight
		}

		Rectangle {
			id: highlightBottom
			anchors {
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}

			radius: parent.radius
			height: parent.value > 0.0004 ? 2*radius : 0
			color: Theme.color.overviewPage.widget.sideGauge.highlight
		}
	}

	ValueDisplay {
		id: valueDisplay
		anchors {
			top: parent.top
			topMargin: Theme.geometry.overviewPage.widget.content.verticalMargin
			left: parent.left
			leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
		}
		fontSize: root.size === OverviewWidget.Size.XS
				  ? Theme.font.size.l
				  : Theme.font.size.xl
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
