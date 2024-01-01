/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.ComboBox {
	id: root

	implicitWidth: contentItem.implicitWidth + root.leftPadding + root.rightPadding
	implicitHeight: Theme.geometry_comboBox_height

	leftPadding: Theme.geometry_comboBox_leftPadding
	rightPadding: Theme.geometry_comboBox_rightPadding
	topPadding: Theme.geometry_comboBox_verticalPadding
	bottomPadding: Theme.geometry_comboBox_verticalPadding
	spacing: Theme.geometry_comboBox_spacing

	delegate: CT.ItemDelegate {
		id: optionDelegate

		width: root.width
		height: Theme.geometry_comboBox_height
		highlighted: root.highlightedIndex === index

		contentItem: Rectangle {
			anchors.fill: parent
			radius: Theme.geometry_button_radius
			color: optionDelegate.pressed ? Theme.color_ok : "transparent"

			Label {
				anchors.fill: parent
				leftPadding: root.leftPadding
				rightPadding: root.leftPadding  // no indicator here, use same padding as left side
				font.pixelSize: Theme.font_size_body1
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
				text: modelData.text
				color: optionDelegate.pressed ? Theme.color_button_down_text : Theme.color_font_primary
			}

			CP.ColorImage {
				anchors {
					right: parent.right
					rightMargin: 8
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/icon_checkmark_32"
				color: optionDelegate.pressed ? Theme.color_button_down_text : Theme.color_ok
				visible: root.currentIndex === index
			}
		}
	}

	indicator: CP.ColorImage {
		id: downIcon

		x: root.width - width - root.rightPadding
		y: root.topPadding + (root.availableHeight - height) / 2
		source: "qrc:/images/icon_back_32.svg"
		width: Theme.geometry_comboBox_indicator_height
		height: Theme.geometry_comboBox_indicator_height
		rotation: 270
		color: root.pressed ? Theme.color_primary : Theme.color_ok
		fillMode: Image.PreserveAspectFit
	}

	contentItem: Label {
		leftPadding: 0
		rightPadding: root.indicator.width + root.spacing
		font.pixelSize: Theme.font_size_body1
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
		text: root.displayText
		color: root.pressed ? Theme.color_button_down_text : Theme.color_font_primary
	}

	background: Rectangle {
		border.color: Theme.color_ok
		border.width: Theme.geometry_button_border_width
		radius: Theme.geometry_button_radius
		color: root.pressed ? Theme.color_ok : Theme.color_darkOk
	}

	popup: CT.Popup {
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
				color: Theme.color_darkOk
			}
		}
	}
}
