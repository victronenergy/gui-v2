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
	property int decimals: -1 // if -1, use default decimals
	property int formatHints

	// Layout has 2 columns, 2 rows. The caption spans across both columns.
	// | Primary label | Quantity label |
	// | Caption                        |
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.height

		GridLayout {
			id: contentLayout

			anchors {
				left: parent.left
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
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
				font.pixelSize: Theme.font_listItem_secondary_size
				value: root.value
				valueColor: root.valueColor
				unit: root.unit
				unitColor: root.unitColor
				decimals: root.decimals
				formatHints: root.formatHints

				Layout.alignment: Qt.AlignRight
			}

			CaptionLabel {
				text: root.caption
				visible: text.length > 0

				Layout.columnSpan: 2
				Layout.maximumWidth: root.availableWidth
			}
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
