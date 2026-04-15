/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

/*
	Shows a gauge bar with additional information around it.

	Portrait layout:

	| Icon | Name       Quantity |
	|      | Gauge content       |

	Landscape layout:

	|   Name   |
	|   Icon   |
	|          |
	|  Gauge   |
	| content  |
	|          |
	| Quantity |
*/
Item {
	id: root

	required property string name
	required property url iconSource
	required property real value
	required property int unit
	required property Component gauge
	property real gaugeHorizontalPadding
	property color iconColor: Theme.color_font_primary
	property string unitText
	property int quantityFormatHints

	implicitHeight: Theme.screenSize === Theme.Portrait ? gaugeContentLoader.y + gaugeContentLoader.height : 0

	// Name label is only visible in portrait.
	// In landscape, the name is part of the background or separately in the contentItem.
	Label {
		id: nameLabel

		anchors {
			left: icon.right
			leftMargin: Theme.geometry_levelsGauge_horizontalSpacing
			right: quantityLabel.left
			rightMargin: Theme.geometry_levelsGauge_horizontalSpacing
			bottom: quantityLabel.bottom
		}
		font.pixelSize: Theme.font_size_body1
		elide: Text.ElideRight
		text: root.name
		visible: Theme.screenSize === Theme.Portrait
		color: Theme.color_font_primary
	}

	CP.ColorImage {
		id: icon

		anchors {
			verticalCenter: Theme.screenSize === Theme.Portrait ? gaugeContentLoader.top : undefined
			horizontalCenter: Theme.screenSize === Theme.Portrait ? undefined : parent.horizontalCenter
		}
		color: root.iconColor
		source: root.iconSource
	}

	Label {
		id: unitTextLabel

		anchors {
			left: parent.left
			right: parent.right
			top: icon.bottom
		}
		height: text.length ? implicitHeight : 0
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: Theme.font_size_body2
		text: Theme.screenSize === Theme.Portrait ? "" : root.unitText
	}

	QuantityLabel {
		id: quantityLabel

		anchors {
			left: Theme.screenSize === Theme.Portrait ? undefined : parent.left
			right: parent.right
			top: Theme.screenSize === Theme.Portrait ? parent.top : gaugeContentLoader.bottom
			topMargin: Theme.screenSize === Theme.Portrait ? 0 : Theme.geometry_levelsGauge_verticalSpacing
		}
		font.pixelSize: Theme.font_levelsGauge_quantity
		value: root.value
		unit: root.unit
		formatHints: root.quantityFormatHints
	}

	Loader {
		id: gaugeContentLoader

		anchors {
			left: Theme.screenSize === Theme.Portrait ? nameLabel.left : parent.left
			leftMargin: root.gaugeHorizontalPadding
			right: parent.right
			rightMargin: root.gaugeHorizontalPadding
			top: Theme.screenSize === Theme.Portrait
				 ? nameLabel.bottom
				 : unitTextLabel.bottom
			topMargin: Theme.geometry_levelsGauge_verticalSpacing
			bottom: Theme.screenSize === Theme.Portrait ? undefined : parent.bottom
			bottomMargin: quantityLabel.height + Theme.geometry_levelsGauge_verticalSpacing
		}
		sourceComponent: root.gauge
	}
}
