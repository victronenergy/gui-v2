/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A row with a label, and a number on the right. A click, or the Space key when the row has the
	key navigation focus, opens a dialog in which the user picks a new number.

	The number is 'value'. By default, that is the value of dataItem, and the number the user picks
	is written to dataItem. Without a dataItem, the number the user picks is set as 'value', which
	replaces any binding on it.

	If the user does not have writeAccessLevel, the dialog does not open, and a message says so.
*/
PluginListRow {
	id: root

	property string text
	property string caption
	property real value: inner.value
	// The text after the number, such as "%" or " V".
	property string suffix
	// The number of decimal places.
	property int decimals
	// The lowest and highest numbers the user can pick. By default, the minimum and maximum that
	// the system gives for dataItem's value, if it gives them.
	property real from: !isNaN(root.dataItem.min) ? root.dataItem.min : 0
	property real to: !isNaN(root.dataItem.max) ? root.dataItem.max : Global.int32Max / Math.pow(10, root.decimals)
	// How much the dialog's + and - buttons change the number.
	property real stepSize: 1
	readonly property PluginDataItem dataItem: PluginDataItem {}

	// The lowest access level that can change the number.
	property int writeAccessLevel: PluginAccessLevel.Installer
	// True if the row can be clicked. By default, when there is no dataItem.uid, or its value is
	// valid.
	property bool interactive: root.dataItem.uid === "" || root.dataItem.valid

	// Clicks the row, as a touch on it does.
	function click() {
		inner.click()
	}

	// Returns true if the user has writeAccessLevel. If not, shows a message saying so.
	function checkWriteAccessLevel() {
		return inner.checkWriteAccessLevel()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	// 'value' is synced both ways: the plugin may bind it, and the inner row assigns its own value
	// when the user picks a number and there is no dataItem.
	onValueChanged: {
		if (inner.value !== root.value) {
			inner.value = root.value
		}
	}

	ListSpinBox {
		id: inner

		text: root.text
		caption: root.caption
		suffix: root.suffix
		decimals: root.decimals
		from: root.from
		to: root.to
		stepSize: root.stepSize
		dataItem.uid: root.dataItem.uid
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
		writeAccessLevel: root.writeAccessLevel
		interactive: root.interactive

		onValueChanged: {
			if (root.value !== inner.value) {
				root.value = inner.value
			}
		}
	}

	Component.onCompleted: {
		// If the plugin set 'value', the inner row shows that instead of the backend value.
		if (inner.value !== root.value) {
			inner.value = root.value
		}
	}
}
