/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListSetting {
	id: root

	readonly property alias dataItem: dataItem
	property real value: dataItem.valid ? dataItem.value : NaN
	property color valueColor: Theme.color_font_primary
	property int unit: VenusOS.Units_None
	property color unitColor: Theme.color_font_secondary
	property int precision: -1 // if -1, use default precision
	property bool precisionAdjustmentAllowed: true

	// Layout has 2 columns, 2 rows. The caption spans across both columns.
	// | Primary label | Quantity label |
	// | Caption                        |
	contentItem: GridLayout {
		columns: 2
		columnSpacing: root.spacing
		rowSpacing: Theme.geometry_listItem_content_verticalSpacing

		Label {
			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap

			Layout.fillWidth: true
		}

		QuantityLabel {
			font.pixelSize: Theme.font_size_body2
			value: root.value
			valueColor: root.valueColor
			unit: root.unit
			unitColor: root.unitColor
			precision: root.precision < 0 ? quantityInfo.precision : root.precision
			precisionAdjustmentAllowed: root.precisionAdjustmentAllowed

			Layout.alignment: Qt.AlignRight
		}

		Label {
			text: root.caption
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0

			Layout.columnSpan: 2
			Layout.maximumWidth: root.availableWidth
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
