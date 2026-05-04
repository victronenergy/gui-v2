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
	property real labelFontSize: Theme.font_size_body2
	property int voltDecimals: Units.defaultUnitDecimals(VenusOS.Units_Volt_AC)

	columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_small
	header: Rectangle {
		width: root.width
		height: Theme.geometry_vebusDeviceListPage_quantityTable_header_height
		topLeftRadius: Theme.geometry_listItem_radius
		topRightRadius: Theme.geometry_listItem_radius
		color: Theme.color_quantityTable_row_background

		Label {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_listItem_content_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			font.pixelSize: root.labelFontSize
			text: root.labelText
		}

		Column {
			anchors {
				right: parent.right
				rightMargin: Theme.geometry_listItem_content_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			visible: root.totalPowerUid.length > 0

			QuantityLabel {
				anchors.right: parent.right
				font.pixelSize: root.labelFontSize
				unit: VenusOS.Units_Watt
				value: totalPowerItem.valid ? totalPowerItem.value : NaN
			}
			Label {
				anchors.right: parent.right
				//% "Total Power"
				text: qsTrId("vebus_device_page_total_power")
				color: Theme.color_quantityTable_quantityValue
				font.pixelSize: Theme.font_quantityTable_header_size
			}
		}
	}

	delegate: QuantityTable.TableRow {
		headerText: `L${index + 1}`
		labelAlignment: Qt.AlignRight
		model: QuantityObjectModel {
			QuantityObject { object: phase; key: "power"; unit: VenusOS.Units_Watt }
			QuantityObject { object: phase; key: "voltage"; unit: VenusOS.Units_Volt_AC; decimals: root.voltDecimals }
			QuantityObject { object: phase; key: "current"; unit: VenusOS.Units_Amp }
			QuantityObject { object: phase; key: "frequency"; unit: VenusOS.Units_Hertz }
		}

		AcPhase {
			id: phase
			serviceUid: root.phaseUidPrefix.length ? `${root.phaseUidPrefix}/L${index + 1}` : ""
		}
	}

	VeQuickItem {
		id: totalPowerItem
		uid: root.totalPowerUid
	}
}
