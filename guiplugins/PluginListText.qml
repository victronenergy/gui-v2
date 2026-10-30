/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A row with a label, and read-only text on the right.

	The text on the right is secondaryText. By default, that is the value of dataItem.
*/
PluginListRow {
	id: root

	property string text
	property string caption
	property string secondaryText: root.dataItem.valid ? root.dataItem.value : ""
	readonly property PluginDataItem dataItem: PluginDataItem {}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	ListText {
		id: inner

		text: root.text
		caption: root.caption
		secondaryText: root.secondaryText
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
	}
}
