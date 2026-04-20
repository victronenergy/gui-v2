/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

T.Control {
	id: root

	required property string title
	required property int type
	property int size: VenusOS.OverviewWidget_Size_Zero
	property int preferredSize: VenusOS.OverviewWidget_PreferredSize_Any
	property var connectors: []

	property real compactY
	property real expandedY
	readonly property int compactHeight: getCompactHeight(size)
	readonly property int expandedHeight: getExpandedHeight(size)
	property bool expanded
	property bool animateGeometry
	property bool animationEnabled

	signal clicked

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
	leftPadding: Theme.geometry_overviewPage_widget_content_horizontalMargin
	rightPadding: Theme.geometry_overviewPage_widget_content_horizontalMargin
	topPadding: Theme.geometry_overviewPage_widget_content_topMargin
	bottomPadding: size >= VenusOS.OverviewWidget_Size_L
			? Theme.geometry_overviewPage_widget_content_bottomMargin_large
			: Theme.geometry_overviewPage_widget_content_bottomMargin_small
	height: compactHeight
	visible: size !== VenusOS.OverviewWidget_Size_Zero
	enabled: false

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)

	background: Rectangle {
		implicitWidth: Theme.geometry_overviewPage_widget_leftWidgetWidth
		implicitHeight: Theme.geometry_overviewPage_widget_compact_l_height
		border.width: enabled ? Theme.geometry_overviewPage_widget_border_width : 0
		border.color: Theme.color_overviewPage_widget_border
		color: Theme.color_overviewPage_widget_background
		radius: Theme.geometry_overviewPage_widget_radius

		PressArea {
			radius: parent.radius
			anchors.fill: parent
			onClicked: root.clicked()
		}
	}

	states: State {
		name: "expanded"
		when: root.expanded

		PropertyChanges {
			target: root
			y: root.expandedY
			height: root.expandedHeight
		}
	}

	transitions: Transition {
		enabled: root.animationEnabled && root.animateGeometry

		NumberAnimation {
			properties: "y,height"
			duration: Theme.animation_page_idleResize_duration
			easing.type: Easing.InOutQuad
		}
	}

	Keys.onSpacePressed: clicked()
	Keys.enabled: Global.keyNavigationEnabled
	KeyNavigationHighlight.active: root.activeFocus
}
