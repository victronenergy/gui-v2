/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property var model: []
	property bool smallTextMode

	function _quantityColumnWidth(unit) {
		// "kWh" unit name is longer, so give that column more space.
		const widthMultiplier = (unit === VenusOS.Units_Energy_KiloWattHour) ? 1.2 : 1
		return ((width - Theme.geometry.quantityTable.header.widthBoost) / model.length) * widthMultiplier
	}

	width: parent ? parent.width : 0
	height: quantityRow.height + (2 * Theme.geometry.quantityTableSummary.verticalMargin)

	Item {
		anchors.verticalCenter: parent.verticalCenter
		width: root.width - quantityRow.width
		height: firstColumnSubLabel.y + firstColumnSubLabel.height

		Label {
			id: firstColumnTitleLabel

			width: parent.width
			elide: Text.ElideRight
			rightPadding: Theme.geometry.listItem.content.spacing
			font.pixelSize: Theme.font.size.caption
			text: root.model[0].title
			color: Theme.color.quantityTable.quantityValue
		}

		Label {
			id: firstColumnSubLabel

			anchors {
				top: firstColumnTitleLabel.bottom
				topMargin: Theme.geometry.quantityTableSummary.verticalSpacing
			}
			width: parent.width
			elide: Text.ElideRight
			rightPadding: Theme.geometry.listItem.content.spacing
			font.pixelSize: root.smallTextMode ? Theme.font.size.body2 : Theme.font.size.body3
			text: root.model[0].text
			color: firstColumnTitleLabel.text ? Theme.color.font.primary : Theme.color.quantityTable.quantityValue
			opacity: firstColumnTitleLabel.text.length ? 1 : 0
		}

		// When there is no title for the first column, this larger sub label is shown. Adding this
		// label (instead of just changing firstColumnSubLabel's font size) allows the text baseline
		// to be correctly aligned.
		Label {
			anchors.baseline: firstColumnSubLabel.baseline
			width: parent.width
			elide: Text.ElideRight
			rightPadding: Theme.geometry.listItem.content.spacing
			font.pixelSize: root.smallTextMode ? Theme.font.size.h1 : Theme.font.size.h2
			text: firstColumnSubLabel.text
			color: firstColumnSubLabel.color
			opacity: firstColumnTitleLabel.text.length ? 0 : 1
		}
	}

	Row {
		id: quantityRow

		anchors.verticalCenter: parent.verticalCenter

		Repeater {
			id: quantityRepeater

			model: root.model.length - 1

			delegate: Column {
				width: root._quantityColumnWidth(root.model[model.index + 1].unit)
				spacing: Theme.geometry.quantityTableSummary.verticalSpacing

				Label {
					width: parent.width
					elide: Text.ElideRight
					font.pixelSize: Theme.font.size.caption
					text: root.model[model.index + 1].title
					color: Theme.color.quantityTable.quantityValue
				}

				QuantityLabel {
					width: parent.width
					alignment: Qt.AlignLeft
					font.pixelSize: root.smallTextMode ? Theme.font.size.body2 : Theme.font.size.body3
					value: root.model[model.index + 1].value
					unit: root.model[model.index + 1].unit
				}
			}

		}
	}
}
