/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigationItem {
	id: root

	property real energy: NaN
	property real voltage: NaN
	property real current: NaN
	property real power: NaN

	primaryLabel.width: availableWidth - Theme.geometry_solarListPage_quantityRow_width - Theme.geometry_listItem_content_horizontalMargin

	Row {
		id: quantityRow

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_listItem_content_horizontalMargin + Theme.geometry_icon_size_medium
		}
		width: Theme.geometry_solarListPage_quantityRow_width
		height: parent.height - parent.spacing

		Repeater {
			id: quantityRepeater

			model: [
				{ value: root.energy, unit: VenusOS.Units_Energy_KiloWattHour },
				{ value: root.voltage, unit: VenusOS.Units_Volt },
				{ value: root.current, unit: VenusOS.Units_Amp },
				{ value: root.power, unit: VenusOS.Units_Watt },
			]

			delegate: QuantityLabel {
				width: (quantityRow.width / quantityRepeater.count) * (model.index === 0 ? 1.2 : 1)
				height: quantityRow.height
				value: modelData.value
				unit: modelData.unit
				alignment: Qt.AlignLeft
				font.pixelSize: Theme.font_size_body2
				valueColor: Theme.color_quantityTable_quantityValue
				unitColor: Theme.color_quantityTable_quantityUnit
			}
		}
	}
}
