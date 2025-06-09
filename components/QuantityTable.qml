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

	readonly property real availableWidth: width - leftPadding - rightPadding

	function resetRowColors() {
		let visibleRowCount = 0
		for (let i = 0; i < count; ++i) {
			const row = itemAtIndex(i)
			if (row?.preferredVisible) {
				row.color = visibleRowCount % 2 === 0
					? Theme.color_quantityTable_row_alternateBackground
					: Theme.color_quantityTable_row_background
				visibleRowCount++
			}
		}
	}

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: contentItem.height + topMargin + bottomMargin
	interactive: false

	component TableHeader: Rectangle {
		id: tableHeader

		property QuantityTable table: ListView.view
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
			fixedColumnWidth: table.equalWidthColumns ? (table.availableWidth - (table.columnSpacing * (columnCount-1))) / columnCount : NaN
		}
	}

	/*
		A coloured rectangle with a QuantityRow for displaying a series of quantities.
	*/
	component TableRow: Rectangle {
		id: tableRow

		property QuantityTable table: ListView.view
		required property int index

		// Whether the row should be visible. Set this instead of 'visible', as that value changes
		// if the item is no longer on the current page.
		property bool preferredVisible: true

		// Header column configuration
		property alias headerText: headerColumnLabel.text
		property alias headerColor: headerColumnLabel.color

		// Quantity row configuration
		property alias model: quantityRow.model
		property alias valueColor: quantityRow.valueColor
		property alias labelAlignment: quantityRow.labelAlignment

		readonly property real fixedColumnWidth: table.equalWidthColumns ? (table.availableWidth - (table.columnSpacing * (columnCount-1))) / columnCount : NaN
		readonly property int columnCount: quantityRow.count + 1 // +1 for header column

		implicitWidth: table.width
		implicitHeight: preferredVisible ? Theme.geometry_quantityTable_row_height : 0
		color: index % 2 === 0
			   ? Theme.color_quantityTable_row_alternateBackground
			   : Theme.color_quantityTable_row_background
		visible: preferredVisible

		onPreferredVisibleChanged: Qt.callLater(table.resetRowColors)

		Label {
			id: headerColumnLabel
			anchors.verticalCenter: parent.verticalCenter
			width: isNaN(tableRow.fixedColumnWidth)
				   ? parent.width - x - table.columnSpacing - quantityRow.width - quantityRow.anchors.rightMargin
				   : tableRow.fixedColumnWidth
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
			fixedColumnWidth: tableRow.fixedColumnWidth
		}
	}
}
