/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS


QuantityTable {
	id: root

	property var totalPower
	property string labelText
	property int numberOfPhases
	property var acPhases

	valueForModelIndex: function(phaseIndex, column) {
		if (column === 0) {
			return "L%1".arg(phaseIndex + 1)
		}

		if (!numberOfPhases || !acPhases || acPhases.length < phaseIndex + 1) {
			return NaN
		}

		let phase = root.acPhases[phaseIndex]
		if (phase) {
			switch(column) {
			case 1:
				return phase.power
			case 2:
				return phase.voltage
			case 3:
				return phase.current
			case 4:
				return phase.frequency
			}
		}
		return NaN
	}

	availableWidth: width - 2*Theme.geometry.listItem.content.horizontalMargin
	firstColumnWidth: Theme.geometry.vebusDeviceListPage.quantityTable.firstColumn.width
	units: [
		{ unit: VenusOS.Units_None },
		{ unit: VenusOS.Units_Watt },
		{ unit: VenusOS.Units_Volt },
		{ unit: VenusOS.Units_Amp },
		{ unit: VenusOS.Units_Hertz }
	]
	rowCount: 3
	labelHorizontalAlignment: Qt.AlignRight
	headerComponent: AsymmetricRoundedRectangle {
		width: root.width
		height: Theme.geometry.vebusDeviceListPage.quantityTable.header.height
		roundedSide: VenusOS.AsymmetricRoundedRectangle_RoundedSide_Top
		flat: true
		color: Theme.color.quantityTable.row.background

		Label {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.listItem.content.horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			font.pixelSize: Theme.font.size.body2
			text: root.labelText
		}

		Column {
			anchors {
				right: parent.right
				rightMargin: Theme.geometry.listItem.content.horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			Label {
				anchors.right: parent.right
				//% "Total Power"
				text: qsTrId("vebus_device_page_total_power")
				color: Theme.color.quantityTable.quantityValue
				font.pixelSize: Theme.font.size.caption
			}
			Row {
				anchors.right: parent.right

				Label {
					anchors.verticalCenter: parent.verticalCenter
					font.pixelSize: Theme.font.size.body2
					color: Theme.color.font.primary
					text: root.totalPower ? root.totalPower.number : ""
				}

				Label {
					anchors.verticalCenter: parent.verticalCenter
					font.pixelSize: Theme.font.size.body2
					color: Theme.color.listItem.secondaryText
					text: root.totalPower ? root.totalPower.unit : ""
				}
			}
		}
	}
}
