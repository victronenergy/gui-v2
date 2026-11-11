/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list item with a label, and a value with its unit on the right, such as "230 V".

	The value is that of dataItem by default. Set unit to one of the PluginUnit values. For a
	temperature, use PluginListTemperature instead, which shows it in the user's unit.
*/
PluginListItem {
	id: root

	property string text
	property string caption
	// The value to show. If it is NaN, the list item shows "--".
	property real value: root.dataItem.valid ? root.dataItem.value : NaN
	property int unit: PluginUnit.None
	// The number of decimal places. If -1, the default number of decimals for the specified unit and value will be used.
	property int decimals: -1
	readonly property PluginDataItem dataItem: PluginDataItem {}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	ListQuantity {
		id: inner

		flat: root.flat
		text: root.text
		value: root.value
		// The PluginUnit values are the VenusOS.Units_* values (see pluginunit.cpp).
		unit: root.unit
		decimals: root.decimals
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel

		// ListQuantity has no caption. Draw it under the content.
		ListCaptionAttachment {
			caption: root.caption
		}
	}
}
