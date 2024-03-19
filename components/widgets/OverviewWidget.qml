/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property int type: VenusOS.OverviewWidget_Type_Unknown
	property int size: VenusOS.OverviewWidget_Size_M

	property alias icon: widgetHeader.icon
	property alias title: widgetHeader.title
	property alias quantityLabel: quantityLabel

	signal clicked

	property int rightPadding
	property alias extraContent: extraContent
	property var connectors: []

	property real compactY
	property real expandedY
	readonly property int compactHeight: getCompactHeight(size)
	readonly property int expandedHeight: getExpandedHeight(size)
	property real verticalMargin: Theme.geometry_overviewPage_widget_content_verticalMargin
	property bool expanded
	property bool animateGeometry
	property bool animationEnabled
	property list<QtObject> extraContentChildren

	function getCompactHeight(s) {
		return s === VenusOS.OverviewWidget_Size_XL ? Theme.geometry_overviewPage_widget_compact_xl_height
			: s === VenusOS.OverviewWidget_Size_L ? Theme.geometry_overviewPage_widget_compact_l_height
			: s === VenusOS.OverviewWidget_Size_M ? Theme.geometry_overviewPage_widget_compact_m_height
			: s === VenusOS.OverviewWidget_Size_S ? Theme.geometry_overviewPage_widget_compact_s_height
			: s === VenusOS.OverviewWidget_Size_XS ? Theme.geometry_overviewPage_widget_compact_xs_height
			: 0
	}

	function getExpandedHeight(s) {
		return s === VenusOS.OverviewWidget_Size_XL ? Theme.geometry_overviewPage_widget_expanded_xl_height
			: s === VenusOS.OverviewWidget_Size_L ? Theme.geometry_overviewPage_widget_expanded_l_height
			: s === VenusOS.OverviewWidget_Size_M ? Theme.geometry_overviewPage_widget_expanded_m_height
			: s === VenusOS.OverviewWidget_Size_S ? Theme.geometry_overviewPage_widget_expanded_s_height
			: s === VenusOS.OverviewWidget_Size_XS ? Theme.geometry_overviewPage_widget_expanded_xs_height
			: 0
	}

	y: compactY
	height: compactHeight
	visible: size !== VenusOS.OverviewWidget_Size_Zero
	radius: Theme.geometry_overviewPage_widget_radius
	color: Theme.color_overviewPage_widget_background

	border.width: enabled ? Theme.geometry_overviewPage_widget_border_width : 0
	border.color: Theme.color_overviewPage_widget_border
	enabled: false

	states: State {
		name: "expanded"
		when: root.expanded

		PropertyChanges {
			target: root
			y: root.expandedY
			height: root.expandedHeight
			verticalMargin: Theme.geometry_overviewPage_widget_content_expanded_verticalMargin
		}
	}

	transitions: Transition {
		enabled: root.animateGeometry

		NumberAnimation {
			properties: "y,height,verticalMargin"
			duration: Theme.animation_page_idleResize_duration
			easing.type: Easing.InOutQuad
		}
	}

	Item {
		id: header

		x: Theme.geometry_overviewPage_widget_content_horizontalMargin
		y: root.verticalMargin
		width: parent.width - 2*Theme.geometry_overviewPage_widget_content_horizontalMargin
		height: widgetHeader.height + (quantityLabel.visible ? quantityLabel.height : 0)

		WidgetHeader {
			id: widgetHeader
			width: parent.width
		}

		ElectricalQuantityLabel {
			id: quantityLabel

			anchors.top: widgetHeader.bottom
			font.pixelSize: root.size === VenusOS.OverviewWidget_Size_XS
					  ? Theme.font_overviewPage_widget_quantityLabel_minimumSize
					  : Theme.font_overviewPage_widget_quantityLabel_maximumSize
			alignment: Qt.AlignLeft
		}
	}

	Item {
		id: extraContent
		anchors {
			left: parent.left
			right: parent.right
			rightMargin: root.rightPadding
			top: header.bottom
			bottom: parent.bottom
		}
		children: root.extraContentChildren
		visible: root.size >= VenusOS.OverviewWidget_Size_M
	}

	PressArea {
		radius: root.radius
		anchors.fill: parent
		onClicked: root.clicked()
	}
}
