/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.ComboBox {
	id: root

	implicitWidth: contentItem.implicitWidth + root.leftPadding + root.rightPadding
	implicitHeight: Theme.geometry.comboBox.height

	leftPadding: Theme.geometry.comboBox.leftPadding
	rightPadding: Theme.geometry.comboBox.rightPadding
	topPadding: Theme.geometry.comboBox.verticalPadding
	bottomPadding: Theme.geometry.comboBox.verticalPadding
	spacing: Theme.geometry.comboBox.spacing

	delegate: CT.ItemDelegate {
		id: optionDelegate

		width: root.width
		height: Theme.geometry.comboBox.height
		highlighted: root.highlightedIndex === index

		contentItem: Rectangle {
			anchors.fill: parent
			radius: Theme.geometry.button.radius
			color: optionDelegate.pressed ? Theme.color.ok : "transparent"

			Label {
				anchors.fill: parent
				leftPadding: root.leftPadding
				rightPadding: root.leftPadding  // no indicator here, use same padding as left side
				font.pixelSize: Theme.font.size.body1
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
				text: modelData.text
				color: optionDelegate.pressed ? Theme.color.button.down.text : Theme.color.font.primary
			}

			CP.ColorImage {
				anchors {
					right: parent.right
					rightMargin: 8
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/icon_checkmark_32"
				color: optionDelegate.pressed ? Theme.color.button.down.text : Theme.color.ok
				visible: root.currentIndex === index
			}
		}
	}

	indicator: CP.ColorImage {
		id: downIcon

		x: root.width - width - root.rightPadding
		y: root.topPadding + (root.availableHeight - height) / 2
		source: "/images/icon_back_32.svg"
		width: Theme.geometry.comboBox.indicator.height
		height: Theme.geometry.comboBox.indicator.height
		rotation: 270
		color: root.pressed ? Theme.color.primary : Theme.color.ok
		fillMode: Image.PreserveAspectFit
	}

	contentItem: Label {
		leftPadding: 0
		rightPadding: root.indicator.width + root.spacing
		font.pixelSize: Theme.font.size.body1
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
		text: root.displayText
		color: root.pressed ? Theme.color.button.down.text : Theme.color.font.primary
	}

	background: Rectangle {
		border.color: Theme.color.ok
		border.width: Theme.geometry.button.border.width
		radius: Theme.geometry.button.radius
		color: root.pressed ? Theme.color.ok : Theme.color.darkOk
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
			// background (Theme.color.darkOk).
			border.color: Theme.color.ok
			border.width: Theme.geometry.button.border.width
			radius: Theme.geometry.button.radius
			color: Theme.color.page.background

			Rectangle {
				anchors.fill: parent
				radius: Theme.geometry.button.radius
				color: Theme.color.darkOk
			}
		}
	}
}
