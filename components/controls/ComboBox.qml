/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as CP
import Victron.VenusOS

T.ComboBox {
	id: root

	implicitWidth: contentItem.implicitWidth + root.leftPadding + root.rightPadding
	implicitHeight: Theme.geometry_comboBox_height

	leftPadding: Theme.geometry_comboBox_leftPadding
	rightPadding: Theme.geometry_comboBox_rightPadding
	topPadding: Theme.geometry_comboBox_verticalPadding
	bottomPadding: Theme.geometry_comboBox_verticalPadding
	spacing: Theme.geometry_comboBox_spacing

	delegate: T.ItemDelegate {
		id: optionDelegate

		width: root.width
		height: root.height
		highlighted: root.highlightedIndex === index

		contentItem: Rectangle {
			anchors.fill: parent
			radius: Theme.geometry_button_radius
			color: optionDelegate.highlighted ? Theme.color_ok : "transparent"

			// Add another rectangle to fill out the bottom and/or top corners to pretend this is
			// showing a half-rounded rect for the first/last options, and no rounded corners for
			// the other options in between.
			Rectangle {
				y: index === 0 ? height : 0
				width: parent.width
				height: index === 0 || index === root.count - 1 ? parent.height / 2 : parent.height
				color: parent.color
				visible: root.count > 0
			}

			Label {
				anchors.fill: parent
				leftPadding: root.leftPadding
				rightPadding: root.leftPadding  // no indicator here, use same padding as left side
				font.pixelSize: Theme.font_size_body1
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
				text: modelData.text
				color: optionDelegate.highlighted ? Theme.color_button_down_text : Theme.color_font_primary
			}
		}

		KeyNavigationHighlight.active: ListView.isCurrentItem
	}

	indicator: CP.ColorImage {
		id: downIcon

		x: root.width - width - root.rightPadding
		y: root.topPadding + (root.availableHeight - height) / 2
		source: "qrc:/images/icon_arrow_32.svg"
		rotation: 270
		color: root.enabled
			   ? (root.pressed ? Theme.color_primary : Theme.color_ok)
			   : Theme.color_font_disabled
	}

	contentItem: Label {
		leftPadding: 0
		rightPadding: root.indicator.width + root.spacing
		font.pixelSize: Theme.font_size_body1
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
		text: root.displayText
		color: root.enabled
			   ? (root.pressed ? Theme.color_button_down_text : Theme.color_font_primary)
			   : Theme.color_font_disabled
	}

	background: Rectangle {
		border.color: root.enabled ? Theme.color_ok : Theme.color_font_disabled
		border.width: Theme.geometry_button_border_width
		radius: Theme.geometry_button_radius
		color: root.enabled
			   ? (root.pressed ? Theme.color_ok : Theme.color_darkOk)
			   : Theme.color_background_disabled
	}

	popup: T.Popup {
		width: root.width
		implicitHeight: contentItem.implicitHeight

		contentItem: ListView {
			clip: true
			interactive: false
			implicitHeight: contentHeight
			model: root.popup.visible ? root.delegateModel : null
			currentIndex: root.highlightedIndex
		}

		background: Rectangle {
			// This base rectangle is required because the inner rect below has a transparent
			// background (Theme.color_darkOk).
			border.color: Theme.color_ok
			border.width: Theme.geometry_button_border_width
			radius: Theme.geometry_button_radius
			color: Theme.color_page_background

			Rectangle {
				anchors.fill: parent
				radius: Theme.geometry_button_radius
				border.width: Theme.geometry_button_border_width
				border.color: Theme.color_ok
				color: Theme.color_darkOk
			}
		}

		// Workaround for QTBUG-121029 (popup does not open as popup visible=true even when closed)
		function _updateVisibility() { visible = opened }
		onOpenedChanged: Qt.callLater(_updateVisibility)
	}

	Keys.enabled: Global.keyNavigationEnabled
	KeyNavigationHighlight.active: root.activeFocus
}
