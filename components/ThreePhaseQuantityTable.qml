/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QuantityTable {
	id: root

	property quantityInfo totalPower
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

	metrics.availableWidth: width - 2*Theme.geometry_listItem_content_horizontalMargin
	metrics.firstColumnWidth: Theme.geometry_vebusDeviceListPage_quantityTable_firstColumn_width
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
		height: Theme.geometry_vebusDeviceListPage_quantityTable_header_height
		roundedSide: VenusOS.AsymmetricRoundedRectangle_RoundedSide_Top
		flat: true
		color: Theme.color_quantityTable_row_background

		Label {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_listItem_content_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			font.pixelSize: Theme.font_size_body2
			text: root.labelText
		}

		Column {
			anchors {
				right: parent.right
				rightMargin: Theme.geometry_listItem_content_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			Label {
				anchors.right: parent.right
				//% "Total Power"
				text: qsTrId("vebus_device_page_total_power")
				color: Theme.color_quantityTable_quantityValue
				font.pixelSize: Theme.font_size_caption
			}
			Row {
				anchors.right: parent.right

				Label {
					anchors.verticalCenter: parent.verticalCenter
					font.pixelSize: Theme.font_size_body2
					color: Theme.color_font_primary
					text: root.totalPower ? root.totalPower.number : ""
				}

				Label {
					anchors.verticalCenter: parent.verticalCenter
					font.pixelSize: Theme.font_size_body2
					color: Theme.color_listItem_secondaryText
					text: root.totalPower ? root.totalPower.unit : ""
				}
			}
		}
	}
}
