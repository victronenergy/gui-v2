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
	readonly property alias quantityInfo: quantityInfo
	property alias font: unitLabel.font
	property alias valueColor: valueLabel.color
	property alias verticalAlignment: valueLabel.verticalAlignment
	property alias unitColor: unitLabel.color
	property alias valueText: valueLabel.text
	property alias unitText: unitLabel.text
	property int alignment: Qt.AlignHCenter
	property alias precision: quantityInfo.precision
	property alias formatHints: quantityInfo.formatHints
	property alias leftPadding: digitRow.leftPadding
	property alias rightPadding: digitRow.rightPadding

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

		Label {
			id: valueLabel

			color: Theme.color_font_primary
			text: quantityInfo.number
			font.pixelSize: root.font.pixelSize
			font.weight: root.font.weight
			font.family: Global.quantityFontFamily
		}

		Item {
			width: Theme.geometry_quantityLabel_spacing
			height: 1
		}

		Label {
			id: unitLabel

			// At smaller font sizes, allow the unit to be vertically aligned at a sub-pixel value,
			// else it is noticeably misaligned by less than 1 pixel.
			anchors.baseline: valueLabel.baseline
			anchors.alignWhenCentered: font.pixelSize >= Theme.font_size_body1
			verticalAlignment: valueLabel.verticalAlignment
			text: quantityInfo.unit
			color: Theme.color_font_secondary
		}
	}
}
