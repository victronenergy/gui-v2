/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list item with a label, and a temperature on the right, in the user's temperature unit (Celsius or
	Fahrenheit, as chosen in the display settings).

	The temperature is the value of dataItem, which is in degrees Celsius.
*/
PluginListItem {
	id: root

	property string text
	property string caption
	// The number of decimal places. If -1, the usual number for a temperature.
	property int decimals: -1
	readonly property PluginDataItem dataItem: PluginDataItem {}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	// The inner list item reads the value through its own data item, which converts it to the user's
	// unit. Both data items have the same uid, so they share one backend value.
	ListTemperature {
		id: inner

		text: root.text
		decimals: root.decimals
		dataItem.uid: root.dataItem.uid
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel

		// ListTemperature has no caption. Draw it under the content.
		ListCaptionAttachment {
			caption: root.caption
		}
	}
}
