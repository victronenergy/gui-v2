/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	required property int type
	property int size: VenusOS.OverviewWidget_Size_M
	property int preferredSize: VenusOS.OverviewWidget_PreferredSize_Any

	property alias icon: widgetHeader.icon
	property alias title: widgetHeader.title
	property alias secondaryTitle: widgetHeader.secondaryText
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
		const availableHeight = Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height
		return s === VenusOS.OverviewWidget_Size_XL ? availableHeight
			: s === VenusOS.OverviewWidget_Size_L ? Theme.geometry_overviewPage_widget_compact_l_height
			: s === VenusOS.OverviewWidget_Size_M ? (availableHeight - 2*Theme.geometry_overviewPage_widget_spacing)/3
			: s === VenusOS.OverviewWidget_Size_S ? (availableHeight - 3*Theme.geometry_overviewPage_widget_spacing)/4
			: s === VenusOS.OverviewWidget_Size_XS ? (availableHeight - 4*Theme.geometry_overviewPage_widget_spacing)/5
			: 0
	}

	function getExpandedHeight(s) {
		const availableHeight = Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_overviewPage_layout_expanded_bottomMargin
		return s === VenusOS.OverviewWidget_Size_XL ? availableHeight
			: s === VenusOS.OverviewWidget_Size_L ? Theme.geometry_overviewPage_widget_expanded_l_height
			: s === VenusOS.OverviewWidget_Size_M ? (availableHeight - 2*Theme.geometry_overviewPage_widget_spacing)/3
			: s === VenusOS.OverviewWidget_Size_S ? (availableHeight - 3*Theme.geometry_overviewPage_widget_spacing)/4
			: s === VenusOS.OverviewWidget_Size_XS ? (availableHeight - 4*Theme.geometry_overviewPage_widget_spacing)/5
			: 0
	}

	function acceptsKeyNavigation() {
		return enabled && size > VenusOS.OverviewWidget_Size_Zero
	}

	function connectedTo(widget) {
		if (widget) {
			let connector
			for (connector of connectors) {
				if (connector.startWidget === widget || connector.endWidget === widget) {
					return true
				}
			}
			for (connector of widget.connectors) {
				if (connector.startWidget === root || connector.endWidget === root) {
					return true
				}
			}
		}
		return false
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

	Keys.onSpacePressed: clicked()
	Keys.enabled: Global.keyNavigationEnabled

	Item {
		id: header

		x: Theme.geometry_overviewPage_widget_content_horizontalMargin
		y: root.verticalMargin
		width: parent.width - 2*Theme.geometry_overviewPage_widget_content_horizontalMargin
		height: widgetHeader.height + (quantityLabel.visible ? quantityLabel.height : 0)

		WidgetHeader {
			id: widgetHeader
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
	}

	PressArea {
		radius: root.radius
		anchors.fill: parent
		onClicked: root.clicked()
	}

	KeyNavigationHighlight {
		anchors.fill: parent
		active: root.activeFocus
	}
}
