/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A number with its unit, such as "230 V", drawn as the GUI draws its own numbers, in the font
	for numbers.

	The value is that of dataItem by default. Set unit to one of the PluginUnit values. fontSize is
	a pixel size, as for PluginLabel. The label is as big as its text, unless its width or height
	is set.
*/
Item {
	id: root

	property real value: root.dataItem.valid ? root.dataItem.value : NaN
	property int unit: PluginUnit.None
	property int decimals: -1
	readonly property PluginDataItem dataItem: PluginDataItem {}
	property int fontSize: PluginPalette.font_size_medium
	property color valueColor: PluginPalette.color_font_primary
	property color unitColor: PluginPalette.color_font_secondary
	property int horizontalAlignment: Text.AlignLeft
	property int verticalAlignment: Text.AlignTop

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	QuantityLabel {
		id: inner

		anchors.fill: parent
		value: root.value
		// The PluginUnit values are the VenusOS.Units_* values (see pluginunit.cpp).
		unit: root.unit
		decimals: root.decimals
		font.pixelSize: root.fontSize
		valueColor: root.valueColor
		unitColor: root.unitColor
		// QuantityLabel has no top anchor, so with Text.AlignTop it stays at the top.
		alignment: root.horizontalAlignment | root.verticalAlignment
	}
}
