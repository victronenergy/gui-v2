/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A row with a label, and a value with its unit on the right, such as "230 V".

	The value is that of dataItem by default. Set unit to one of the PluginUnit values. For a
	temperature, use PluginListTemperature instead, which shows it in the user's unit.
*/
PluginListRow {
	id: root

	property string text
	property string caption
	// The value to show. If it is NaN, the row shows "--".
	property real value: root.dataItem.valid ? root.dataItem.value : NaN
	property int unit: PluginUnit.None
	// The number of decimal places. If -1, the usual number for the unit and the size of the value.
	property int decimals: -1
	readonly property PluginDataItem dataItem: PluginDataItem {}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	ListQuantity {
		id: inner

		text: root.text
		caption: root.caption
		value: root.value
		// The PluginUnit values are the VenusOS.Units_* values (see pluginunit.cpp).
		unit: root.unit
		decimals: root.decimals
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
	}
}
