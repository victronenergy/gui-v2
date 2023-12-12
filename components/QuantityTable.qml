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

	property real availableWidth: width - Theme.geometry.listItem.content.horizontalMargin

	function _quantityColumnWidth(unit) {
		if (!!firstColumnWidth) {
			if (unit === Enums.Units_None) {
				return firstColumnWidth
			}
			return (availableWidth - firstColumnWidth) / (units.length - 1)
		}

		if (equalWidthColumns) {
			return availableWidth / units.length
		}
		// "kWh" unit name is longer, so give that column more space.
		const widthMultiplier = (unit === Enums.Units_Energy_KiloWattHour) ? 1.2 : 1
		return ((availableWidth - Theme.geometry.quantityTable.header.widthBoost) / units.length) * widthMultiplier
	}

	width: parent ? parent.width : 0
	height: visible ? implicitHeight : 0

	Component {
		id: defaultHeaderComponent

		Rectangle {
			width: root.width
			height: headerRow.height
			color: Theme.color.quantityTable.row.background

			Row {
				id: headerRow

				// Omit rightPadding to give the table a little more space.
				leftPadding: Theme.geometry.listItem.content.horizontalMargin
				height: visible ? Theme.geometry.quantityTable.row.height : 0

				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: root.availableWidth - headerQuantityRow.width
					rightPadding: Theme.geometry.listItem.content.spacing
					font.pixelSize: Theme.font.size.caption
					elide: Text.ElideRight
					text: root.units[0].title || ""
					color: Theme.color.quantityTable.quantityValue
				}

				Row {
					id: headerQuantityRow

					anchors.verticalCenter: parent.verticalCenter

					Repeater {
						model: headerRow.visible ? units.length - 1 : null
						delegate: Label {
							anchors.verticalCenter: parent.verticalCenter
							width: root._quantityColumnWidth(root.units[model.index + 1].unit)
							rightPadding: Theme.geometry.gradientList.spacing
							font.pixelSize: Theme.font.size.caption
							elide: Text.ElideRight
							text: root.units[model.index + 1].title || ""
							color: Theme.color.quantityTable.quantityValue
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
				   ? Theme.color.quantityTable.row.alternateBackground
				   : Theme.color.quantityTable.row.background

			Row {
				id: valueRow

				leftPadding: Theme.geometry.listItem.content.horizontalMargin
				rightPadding: Theme.geometry.listItem.content.horizontalMargin
				height: Theme.geometry.quantityTable.row.height

				// Column 1: value is displayed by Label
				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: root.availableWidth - quantityRow.width
					rightPadding: Theme.geometry.listItem.content.spacing
					elide: Text.ElideRight
					text: root.valueForModelIndex(rowDelegate.rowIndex, 0) || ""
					color: Theme.color.quantityTable.quantityValue
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
							font.pixelSize: Theme.font.size.body1
							valueColor: Theme.color.quantityTable.quantityValue
							unitColor: Theme.color.quantityTable.quantityUnit
						}
					}
				}
			}
		}
	}
}
