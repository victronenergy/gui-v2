/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

NativeQuantityLabel {
	id: root

	property alias value: quantityInfo.value
	property alias unit: quantityInfo.unitType
	readonly property alias quantityInfo: quantityInfo
	property alias decimals: quantityInfo.decimals
	property alias formatHints: quantityInfo.formatHints

	valueFontFamily: Global.quantityFontFamily
	baselineRoundingPixelSize: Theme.font_size_body1
	_digitRow.spacing: Theme.geometry_quantityLabel_spacing
	valueColor: Theme.color_font_primary
	valueText: quantityInfo.number
	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body1
	unitText: quantityInfo.unit
	unitColor: Theme.color_font_secondary

	QuantityInfo {
		id: quantityInfo
	}
}
