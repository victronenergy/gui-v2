/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QuantityTable {
	id: root

	property string phaseUidPrefix
	property string totalPowerUid
	property string labelText

	readonly property quantityInfo _totalPowerInfo: Units.getDisplayText(VenusOS.Units_Watt, totalPowerItem.value)

	valueForModelIndex: function(phaseIndex, column) {
		if (column === 0) {
			return "L%1".arg(phaseIndex + 1)
		}

		const phase = phases.objectAt(phaseIndex)
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
		{ unit: VenusOS.Units_Volt_AC },
		{ unit: VenusOS.Units_Amp },
		{ unit: VenusOS.Units_Hertz }
	]
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
			visible: root.totalPowerUid.length > 0

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
					text: root._totalPowerInfo.number
				}

				Label {
					anchors.verticalCenter: parent.verticalCenter
					font.pixelSize: Theme.font_size_body2
					color: Theme.color_listItem_secondaryText
					text: root._totalPowerInfo.unit
				}
			}
		}
	}

	Instantiator {
		id: phases
		model: root.rowCount
		delegate: AcPhase {
			required property int index
			serviceUid: root.phaseUidPrefix.length ? root.phaseUidPrefix + "/L" + (index + 1) : ""
		}
	}

	VeQuickItem {
		id: totalPowerItem
		uid: root.totalPowerUid
	}
}
