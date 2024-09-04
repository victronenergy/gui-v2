/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property alias model: quantityRepeater.model
	property alias quantityMetrics: quantityMetrics

	// In table mode, items are spaced out without separators between them.
	// (TODO if not tableMode, then invalid items should be hidden, instead of showing them as "--".)
	property bool tableMode

	readonly property bool _showSeparators: !tableMode
	readonly property int _textAlignment: tableMode ? Qt.AlignLeft : Qt.AlignHCenter

	height: Theme.geometry_listItem_height

	Repeater {
		id: quantityRepeater

		delegate: Row {
			id: quantityDelegate

			 // Visibility is determined by optional 'visible' property.
			readonly property bool showValue: modelData.visible !== false
			readonly property var dataValue: modelData.value
			readonly property bool isStringValue: typeof(dataValue) === 'string'

			height: root.height

			Item {
				anchors.verticalCenter: parent.verticalCenter
				width: Theme.geometry_listItem_separator_width + (Theme.geometry_listItem_content_spacing / 2)
				height: textLabel.height
				visible: root._showSeparators
						&& quantityDelegate.showValue
						&& model.index !== 0

				Rectangle {
					anchors.horizontalCenter: parent.horizontalCenter
					width: Theme.geometry_listItem_separator_width
					height: textLabel.height
					color: Theme.color_listItem_separator
				}
			}

			QuantityLabel {
				id: quantityLabel
				visible: quantityDelegate.showValue && !textLabel.visible
				width: quantityMetrics.columnWidth(unit)
				height: root.height
				alignment: root._textAlignment
				font.pixelSize: Theme.font_size_body2
				unit: modelData.unit || VenusOS.Units_None
				precision: modelData.precision || VenusOS.Units_Precision_Default
				value: isNaN(quantityDelegate.dataValue) ? NaN : quantityDelegate.dataValue
				valueColor: Theme.color_quantityTable_quantityValue
				unitColor: Theme.color_quantityTable_quantityUnit
			}

			// Show a plain label instead of a QuantityLabel if modelData.value is a string instead of
			// a number.
			Label {
				id: textLabel
				anchors.verticalCenter: parent.verticalCenter
				visible: quantityDelegate.showValue && quantityDelegate.isStringValue
				leftPadding: Theme.geometry_listItem_content_spacing
				rightPadding: Theme.geometry_listItem_content_spacing
				text: visible ? quantityDelegate.dataValue : ""
				horizontalAlignment: root._textAlignment
				font.pixelSize: Theme.font_size_body2
				color: Theme.color_quantityTable_quantityValue
			}
		}
	}

	QuantityTableMetrics {
		id: quantityMetrics
		count: quantityRepeater.count
		availableWidth: root.width
		spacing: Theme.geometry_quantityGroupRow_spacing
	}
}
