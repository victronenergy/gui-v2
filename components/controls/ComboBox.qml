/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.ComboBox {
	id: root

	property var _displayIcon

	implicitWidth: 240
	implicitHeight: 48
	leftPadding: 22
	rightPadding: 14

	delegate: C.ItemDelegate {
		id: itemDelegate

		width: root.width
		height: root.height - 2
		leftPadding: 0
		rightPadding: 0
		topPadding: -2
		bottomPadding: 0

		contentItem: Item {
			CP.ColorImage {
				id: delegateIcon

				x: root.leftPadding - 2
				anchors.verticalCenter: parent.verticalCenter
				source: model.icon
				color: !!model.enabled ? Theme.primaryFontColor : Theme.secondaryFontColor
			}

			Label {
				anchors {
					left: delegateIcon.right
					leftMargin: 10
					right: parent.right
					verticalCenter: parent.verticalCenter
				}

				text: model.text
				font.pixelSize: 22 // TODO add to Theme if size is used elsewhere
				elide: Text.ElideRight
				color: delegateIcon.color
			}
		}

		background: Rectangle {
			color: itemDelegate.down || model.index === root.currentIndex
				   ? Theme.okColor
				   : Theme.okSecondaryColor
		}

		highlighted: root.highlightedIndex === model.index
		enabled: !!model.enabled
	}

	indicator: CP.ColorImage {
		x: root.width - width - root.rightPadding
		y: root.topPadding + (root.availableHeight - height) / 2

		source: 'qrc:/images/dropdown.svg'
		color: Theme.okColor
	}

	contentItem: Item {
		width: root.width
		height: root.height

		Image {
			id: mainItemIcon

			source: root._displayIcon
			anchors.verticalCenter: parent.verticalCenter
		}

		Label {
			anchors {
				left: mainItemIcon.right
				leftMargin: 10
				right: parent.right
				rightMargin: 18
				verticalCenter: parent.verticalCenter
			}

			text: root.displayText
			font.pixelSize: 22 // TODO add to Theme if size is used elsewhere
			elide: Text.ElideRight
		}
	}

	background: Rectangle {
		width: root.width
		height: root.height
		border.color: Theme.okColor
		border.width: 2
		radius: 6
		color: root.pressed ? Theme.okColor : Theme.okSecondaryColor
	}

	popup: C.Popup {
		width: root.width
		implicitHeight: contentItem.implicitHeight
		padding: 2

		contentItem: ListView {
			clip: true
			implicitHeight: contentHeight + 4
			model: root.popup.visible ? root.delegateModel : null
			currentIndex: root.highlightedIndex
			boundsBehavior: Flickable.StopAtBounds
		}

		background: Rectangle {
			color: Theme.okSecondaryColor
			border.color: Theme.okColor
			border.width: 2
			radius: 6
		}
	}

	onCurrentIndexChanged: {
		var current = model.get(currentIndex)
		displayText = current.text
		_displayIcon = current.icon
	}
}
