/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A table of quantity values.

	The TableHeader and TableRow types can be used to implement header and delegate components that
	automatically integrate with the look and feel of the table.
*/
ListView {
	id: root

	// Main font sizes in the table
	property int headerFontSize: Theme.font_size_caption
	property int bodyFontSize: Theme.font_size_body1

	// Parameters for sizing the columns in the table.
	property int metricsFontSize: bodyFontSize
	property int columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_large
	property bool equalWidthColumns

	property real leftPadding: Theme.geometry_listItem_content_horizontalMargin
	property real rightPadding: Theme.geometry_listItem_content_horizontalMargin

	function resetRowColors() {
		let visibleRowCount = 0
		for (let i = 0; i < count; ++i) {
			const row = itemAtIndex(i)
			if (row && !row.hidden) {
				row.color = visibleRowCount % 2 === 0
					? Theme.color_quantityTable_row_alternateBackground
					: Theme.color_quantityTable_row_background
				visibleRowCount++
			}
		}
	}

	function _fixedColumnWidth(columnCount) {
		return equalWidthColumns
				? (width - leftPadding - rightPadding - (columnSpacing * (columnCount-1))) / columnCount
				: NaN
	}

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: visible ? contentItem.height + topMargin + bottomMargin : 0
	interactive: false

	component TableHeader: Rectangle {
		id: tableHeader

		required property QuantityTable table
		property alias model: groupHeader.model
		property alias headerText: groupHeader.headerText

		implicitWidth: table.width
		implicitHeight: Theme.geometry_quantityTable_row_height
		color: Theme.color_quantityTable_row_background

		QuantityGroupListHeader {
			id: groupHeader
			width: parent.width
			height: Theme.geometry_quantityTable_row_height
			leftPadding: table.leftPadding
			rightPadding: table.rightPadding
			fontSize: table.headerFontSize
			metricsFontSize: table.metricsFontSize
			spacing: table.columnSpacing
			fixedColumnWidth: table._fixedColumnWidth(columnCount)
		}
	}

	/*
		A coloured rectangle with a QuantityRow for displaying a series of quantities.
	*/
	component TableRow: Rectangle {
		id: tableRow

		required property int index
		required property QuantityTable table
		property bool hidden

		// Header column configuration
		property alias headerText: headerColumnLabel.text
		property alias headerColor: headerColumnLabel.color

		// Quantity row configuration
		property alias model: quantityRow.model
		property alias valueColor: quantityRow.valueColor
		property alias labelAlignment: quantityRow.labelAlignment

		readonly property real _fixedColumnWidth: table._fixedColumnWidth(quantityRow.count + 1) // +1 for header column

		implicitWidth: table.width
		implicitHeight: hidden ? 0 : Theme.geometry_quantityTable_row_height
		color: index % 2 === 0
			   ? Theme.color_quantityTable_row_alternateBackground
			   : Theme.color_quantityTable_row_background
		visible: !hidden

		onHiddenChanged: table.resetRowColors()

		Label {
			id: headerColumnLabel
			anchors.verticalCenter: parent.verticalCenter
			width: isNaN(tableRow._fixedColumnWidth)
				   ? parent.width - x - table.columnSpacing - quantityRow.width - quantityRow.anchors.rightMargin
				   : tableRow._fixedColumnWidth
			x: table.leftPadding
			elide: Text.ElideRight
			font.pixelSize: table.bodyFontSize
			color: quantityRow.valueColor
		}

		QuantityRow {
			id: quantityRow
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: table.rightPadding
			}
			tableMode: true
			fontSize: table.bodyFontSize
			metricsFontSize: table.metricsFontSize
			spacing: table.columnSpacing
			fixedColumnWidth: tableRow._fixedColumnWidth
		}
	}
}
