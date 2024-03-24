/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias value: quantityInfo.value
	property alias unit: quantityInfo.unitType
	property alias font: unitLabel.font
	property color valueColor: Theme.color_font_primary
	property alias unitColor: unitLabel.color
	property alias unitVisible: unitLabel.visible
	property int alignment: Qt.AlignHCenter
	property alias precision: quantityInfo.precision
	property alias formatHints: quantityInfo.formatHints

	implicitWidth: digitRow.width
	implicitHeight: digitRow.height

	QuantityInfo {
		id: quantityInfo
	}

	Row {
		id: digitRow

		anchors {
			verticalCenter: parent.verticalCenter
			horizontalCenter: root.alignment & Qt.AlignHCenter ? parent.horizontalCenter : undefined
			left: root.alignment & Qt.AlignLeft ? parent.left : undefined
			right: root.alignment & Qt.AlignRight ? parent.right : undefined
		}

		Repeater {
			model: quantityInfo.number.length
			delegate: Image {
				required property int index

				source: "image://digits/%1?pixelSize=%2&weight=%3&color=%4"
						.arg(quantityInfo.number[index])
						.arg(root.font.pixelSize)
						.arg(root.font.weight)
						.arg(root.valueColor)

				// Workaround for QTBUG-38127 (image providers generating blurry images due to
				// missing support for device pixel ratio).
				// Set any non-null sourceSize, in order to trigger a code path in Qt where the
				// implicit size of this image will be the size of the texture returned by the image
				// provider, divided by the device pixel ratio.
				// It's OK for this sourceSize width/height to be 0, since DigitImageProvider
				// internally ignores the sourceSize (i.e. the requestedSize passed to requestImage()).
				sourceSize.width: 0
				sourceSize.height: 0
			}
		}

		Item {
			width: Theme.geometry_quantityLabel_spacing
			height: 1
		}

		Label {
			id: unitLabel

			// At smaller font sizes, allow the unit to be vertically aligned at a sub-pixel value,
			// else it is noticeably misaligned by less than 1 pixel.
			anchors.verticalCenter: parent.verticalCenter
			anchors.alignWhenCentered: font.pixelSize >= Theme.font_size_body1
			text: quantityInfo.unit
			color: Theme.color_font_secondary
		}
	}
}
