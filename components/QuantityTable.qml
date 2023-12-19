/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property var units: []
	property int rowCount
	property var valueForModelIndex  // function(row,column) -> data value for this row/column
	property bool headerVisible: true
	property bool equalWidthColumns
	property Component headerComponent: defaultHeaderComponent
	property int labelHorizontalAlignment: Qt.AlignLeft

	// If specified, allows for a custom column width for the 'Units_None' column.
	// Eg. label columns with cells like "L1", "L2" can be thinner to allow wider columns elsewhere.
	property int firstColumnWidth

	property real availableWidth: width - Theme.geometry_listItem_content_horizontalMargin

	function _quantityColumnWidth(unit) {
		if (!!firstColumnWidth) {
			if (unit === VenusOS.Units_None) {
				return firstColumnWidth
			}
			return (availableWidth - firstColumnWidth) / (units.length - 1)
		}

		if (equalWidthColumns) {
			return availableWidth / units.length
		}
		// "kWh" unit name is longer, so give that column more space.
		const widthMultiplier = (unit === VenusOS.Units_Energy_KiloWattHour) ? 1.2 : 1
		return ((availableWidth - Theme.geometry_quantityTable_header_widthBoost) / units.length) * widthMultiplier
	}

	width: parent ? parent.width : 0
	height: visible ? implicitHeight : 0

	Component {
		id: defaultHeaderComponent

		Rectangle {
			width: root.width
			height: headerRow.height
			color: Theme.color_quantityTable_row_background

			Row {
				id: headerRow

				// Omit rightPadding to give the table a little more space.
				leftPadding: Theme.geometry_listItem_content_horizontalMargin
				height: visible ? Theme.geometry_quantityTable_row_height : 0

				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: root.availableWidth - headerQuantityRow.width
					rightPadding: Theme.geometry_listItem_content_spacing
					font.pixelSize: Theme.font_size_caption
					elide: Text.ElideRight
					text: root.units[0].title || ""
					color: Theme.color_quantityTable_quantityValue
				}

				Row {
					id: headerQuantityRow

					anchors.verticalCenter: parent.verticalCenter

					Repeater {
						model: headerRow.visible ? units.length - 1 : null
						delegate: Label {
							anchors.verticalCenter: parent.verticalCenter
							width: root._quantityColumnWidth(root.units[model.index + 1].unit)
							rightPadding: Theme.geometry_gradientList_spacing
							font.pixelSize: Theme.font_size_caption
							elide: Text.ElideRight
							text: root.units[model.index + 1].title || ""
							color: Theme.color_quantityTable_quantityValue
						}
					}
				}
			}
		}
	}

	Loader {
		id: header
		sourceComponent: headerVisible ? headerComponent : null
	}

	Repeater {
		model: root.rowCount

		delegate: Rectangle {
			id: rowDelegate

			readonly property var rowIndex: model.index

			width: parent.width
			height: valueRow.height
			color: model.index % 2 === 0
				   ? Theme.color_quantityTable_row_alternateBackground
				   : Theme.color_quantityTable_row_background

			Row {
				id: valueRow

				leftPadding: Theme.geometry_listItem_content_horizontalMargin
				rightPadding: Theme.geometry_listItem_content_horizontalMargin
				height: Theme.geometry_quantityTable_row_height

				// Column 1: value is displayed by Label
				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: root.availableWidth - quantityRow.width
					rightPadding: Theme.geometry_listItem_content_spacing
					elide: Text.ElideRight
					text: root.valueForModelIndex(rowDelegate.rowIndex, 0) || ""
					color: Theme.color_quantityTable_quantityValue
				}

				Row {
					id: quantityRow

					anchors.verticalCenter: parent.verticalCenter

					// Column 2 onwards: value is displayed by QuantityLabel
					Repeater {
						id: quantityRepeater

						model: root.units.length - 1    // omit the first (non-quantity) column
						delegate: QuantityLabel {
							width: root._quantityColumnWidth(unit)
							alignment: root.labelHorizontalAlignment
							value: root.valueForModelIndex(rowDelegate.rowIndex, model.index + 1)
							unit: root.units[model.index + 1].unit
							font.pixelSize: Theme.font_size_body1
							valueColor: Theme.color_quantityTable_quantityValue
							unitColor: Theme.color_quantityTable_quantityUnit
						}
					}
				}
			}
		}
	}
}
