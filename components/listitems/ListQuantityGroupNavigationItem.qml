/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigationItem {
	id: root

	property alias quantityModel: quantityRepeater.model

	primaryLabel.width: availableWidth - quantityRow.width - Theme.geometry_listItem_content_horizontalMargin

	Row {
		id: quantityRow

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_listItem_content_horizontalMargin + Theme.geometry_icon_size_medium
		}
		height: parent.height - parent.spacing

		Repeater {
			id: quantityRepeater

			delegate: QuantityLabel {
				width: quantityMetrics.columnWidth(unit)
				height: quantityRow.height
				value: modelData.value
				unit: modelData.unit
				precision: modelData.precision || VenusOS.Units_Precision_Default
				alignment: Qt.AlignLeft
				font.pixelSize: Theme.font_size_body2
				valueColor: Theme.color_quantityTable_quantityValue
				unitColor: Theme.color_quantityTable_quantityUnit
			}
		}
	}

	QuantityTableMetrics {
		id: quantityMetrics
		count: quantityRepeater.count
		availableWidth: quantityRow.width
		spacing: Theme.geometry_quantityGroupRow_spacing
	}
}
