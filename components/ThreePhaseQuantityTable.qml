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
	property int voltPrecision: Units.defaultUnitPrecision(VenusOS.Units_Volt_AC)

	columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_small
	header: AsymmetricRoundedRectangle {
		layer.enabled: false // if 'layer.enabled' is true, any child text looks rough on wasm builds
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
			QuantityLabel {
				anchors.right: parent.right
				font.pixelSize: Theme.font_size_body2
				unit: VenusOS.Units_Watt
				value: totalPowerItem.valid ? totalPowerItem.value : NaN
			}
		}
	}

	delegate: QuantityTable.TableRow {
		headerText: `L${index + 1}`
		labelAlignment: Qt.AlignRight
		model: QuantityObjectModel {
			QuantityObject { object: phase; key: "power"; unit: VenusOS.Units_Watt }
			QuantityObject { object: phase; key: "voltage"; unit: VenusOS.Units_Volt_AC; precision: root.voltPrecision }
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
