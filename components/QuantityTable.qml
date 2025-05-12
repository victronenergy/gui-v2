/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// TODO change this to use QuantityObjectModel for the model
Column {
	id: root

	property var units: []
	property int rowCount
	property var valueForModelIndex  // function(row,column) -> data value for this row/column
	property var rowIsVisible   // TODO remove when QuantityObjectModel is used as model instead.
	property bool headerVisible: true
	property Component headerComponent: defaultHeaderComponent
	property int labelHorizontalAlignment: Qt.AlignLeft

	property alias metrics: quantityMetrics
	readonly property int leftMargin: Theme.geometry_listItem_content_horizontalMargin

	QuantityTableMetrics {
		id: quantityMetrics

		count: units.length
		// Omit the right margin to give the table a little more space.
		availableWidth: root.width - root.leftMargin
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

				// Omit the right padding to give the table a little more space.
				leftPadding: root.leftMargin
				height: visible ? Theme.geometry_quantityTable_row_height : 0

				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: metrics.availableWidth - headerQuantityRow.width
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
							width: metrics.columnWidth(root.units[model.index + 1].unit)
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
		id: rowRepeater

		function resetRowColors() {
			let visibleRowCount = 0
			for (let i = 0; i < count; ++i) {
				const row = itemAt(i)
				if (row && row.visible) {
					row.color = visibleRowCount % 2 === 0
						? Theme.color_quantityTable_row_alternateBackground
						: Theme.color_quantityTable_row_background
					visibleRowCount++
				}
			}
		}

		model: root.rowCount

		delegate: Rectangle {
			id: rowDelegate

			readonly property var rowIndex: model.index

			width: parent.width
			height: valueRow.height
			visible: !root.rowIsVisible || root.rowIsVisible(rowIndex)
			onVisibleChanged: rowRepeater.resetRowColors()
			Component.onCompleted: rowRepeater.resetRowColors()

			Row {
				id: valueRow

				height: Theme.geometry_quantityTable_row_height
				leftPadding: root.leftMargin

				// Column 1: value is displayed by Label
				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: metrics.availableWidth - quantityRow.width
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
							width: metrics.columnWidth(unit)
							alignment: root.labelHorizontalAlignment
							value: root.valueForModelIndex(rowDelegate.rowIndex, model.index + 1)
							unit: root.units[model.index + 1].unit
							precision: root.units[model.index + 1].precision || VenusOS.Units_Precision_Default
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
