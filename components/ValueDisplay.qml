/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root


	property int alignment: Qt.AlignLeft    // if right-aligned, icon is on right side
	property int fontSize: Theme.font.size.xl

	property alias icon: icon
	property alias title: title
	property alias value: quantityRow.value
	property alias physicalQuantity: quantityRow.physicalQuantity
	property alias precision: quantityRow.precision

	property alias quantityRow: quantityRow
	property alias titleRow: titleRow

	implicitWidth: Math.max(titleRow.width, quantityRow.width)
	implicitHeight: titleRow.height + (quantityRow.visible ? quantityRow.height : 0)

	Item {
		id: titleRow

		anchors {
			left: root.alignment == Qt.AlignLeft ? parent.left : undefined
			right: root.alignment == Qt.AlignRight ? parent.right : undefined
			horizontalCenter: root.alignment == Qt.AlignHCenter ? parent.horizontalCenter : undefined
		}
		width: Math.max(title.width, icon.width)
		height: Math.max(title.height, icon.height)

		Image {
			id: icon

			anchors {
				verticalCenter: parent.verticalCenter
				left: root.alignment != Qt.AlignRight ? parent.left : undefined
				right: root.alignment == Qt.AlignRight ? parent.right : undefined
			}
			width: Theme.geometry.valueDisplay.icon.width
			height: width
			fillMode: Image.Pad
		}

		Label {
			id: title

			anchors {
				verticalCenter: parent.verticalCenter
				left: root.alignment != Qt.AlignRight ? icon.right : undefined
				leftMargin: Theme.geometry.valueDisplay.titleRow.spacing
				right: root.alignment == Qt.AlignRight ? icon.left : undefined
				rightMargin: Theme.geometry.valueDisplay.titleRow.spacing
			}
		}
	}

	ValueQuantityDisplay {
		id: quantityRow

		anchors {
			top: titleRow.bottom
			left: root.alignment == Qt.AlignLeft ? parent.left : undefined
			right: root.alignment == Qt.AlignRight ? parent.right : undefined
			horizontalCenter: root.alignment == Qt.AlignHCenter ? parent.horizontalCenter : undefined
		}
		font.pixelSize: root.fontSize
		visible: root.physicalQuantity >= 0
	}
}
