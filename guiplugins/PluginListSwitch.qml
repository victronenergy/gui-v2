/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list item with a label and a toggle switch.

	There are two ways to use it:

	1. Set dataItem.uid to a backend value. The switch shows whether the value is valueTrue, and a
	   click writes valueFalse or valueTrue to it.
	2. Set checkable to true, and use 'checked' and onClicked. The list item's click handler writes
	   a new value to 'checked', which replaces any binding on it.

	The switch is clicked by touch, or by the Space key when the list item has the key navigation focus.
*/
PluginListItem {
	id: root

	property string text
	property string caption
	property string secondaryText

	property bool checked: inner.checked
	property bool checkable
	property var valueTrue: 1
	property var valueFalse: 0
	readonly property PluginDataItem dataItem: PluginDataItem {}
	// Set to false so that a click does not write to dataItem. Handle onClicked instead, for
	// example to ask the user to confirm before writing the value.
	property bool updateDataOnClick: true

	// The lowest access level that can click the switch.
	property int writeAccessLevel: PluginAccessLevel.Installer
	// True if the switch can be clicked. By default, when there is no dataItem.uid, or its value
	// is valid.
	property bool interactive: inner.defaultInteractive

	signal clicked

	// Clicks the switch, as a touch on it does.
	function click() {
		inner.click()
	}

	// Returns true if the user has writeAccessLevel. If not, shows a message saying so.
	function checkWriteAccessLevel() {
		return inner.checkWriteAccessLevel()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	// 'checked' is synced both ways: the plugin may bind it, and the inner list item assigns its own
	// 'checked' when a checkable switch is clicked.
	onCheckedChanged: {
		if (inner.checked !== root.checked) {
			inner.checked = root.checked
		}
	}

	ListSwitch {
		id: inner

		text: root.text
		caption: root.caption
		secondaryText: root.secondaryText
		checkable: root.checkable
		valueTrue: root.valueTrue
		valueFalse: root.valueFalse
		dataItem.uid: root.dataItem.uid
		updateDataOnClick: root.updateDataOnClick
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
		writeAccessLevel: root.writeAccessLevel
		interactive: root.interactive

		onCheckedChanged: {
			if (root.checked !== inner.checked) {
				root.checked = inner.checked
			}
		}
		onClicked: root.clicked()
	}

	Component.onCompleted: {
		// If the plugin set 'checked', the inner list item shows that instead of the backend value.
		if (inner.checked !== root.checked) {
			inner.checked = root.checked
		}
	}
}
