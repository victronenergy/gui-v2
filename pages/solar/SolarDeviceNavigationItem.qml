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

	primaryLabel.width: availableWidth - Theme.geometry.solarListPage.quantityRow.width - Theme.geometry.listItem.content.horizontalMargin

	Row {
		id: quantityRow

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.listItem.content.horizontalMargin + Theme.geometry.statusBar.button.icon.width
		}
		width: Theme.geometry.solarListPage.quantityRow.width
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
				font.pixelSize: Theme.font.size.body2
				valueColor: Theme.color.quantityTable.quantityValue
				unitColor: Theme.color.quantityTable.quantityUnit
			}
		}
	}
}
