/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list item with a label and a horizontal slider, with - and + buttons on either side of it.

	The slider shows the 'value' property. By default, that is the value of dataItem, and moving
	the slider writes the new number to dataItem. Without a dataItem, moving the slider writes the
	new number to 'value', which replaces any binding on it.

	When the list item has the key navigation focus, the Space key starts changing the number: the
	Left and Right keys change it, and the Return, Enter or Escape key stops.
*/
PluginListItem {
	id: root

	property string text
	property real value: inner.value
	// The lowest and highest numbers. By default, the minimum and maximum that the system gives for
	// dataItem's value, if it gives them, or else 0 and 1.
	property real from: !isNaN(root.dataItem.min) ? root.dataItem.min : 0
	property real to: !isNaN(root.dataItem.max) ? root.dataItem.max : 1
	// The slider snaps to a multiple of stepSize, which is also how much the - and + buttons change
	// the number. By default, a tenth of the range.
	property real stepSize: (to - from) / Theme.geometry_slider_steps
	readonly property PluginDataItem dataItem: PluginDataItem {}

	// The lowest access level that can change the number.
	property int writeAccessLevel: PluginAccessLevel.Installer
	// True if the slider can be moved. By default, when there is no dataItem.uid, or its value is
	// valid.
	property bool interactive: root.dataItem.uid === "" || root.dataItem.valid

	// Returns true if the user has writeAccessLevel. If not, shows a message saying so.
	function checkWriteAccessLevel() {
		return inner.checkWriteAccessLevel()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	// 'value' is synced both ways: the plugin may bind it, and the inner list item assigns its own value
	// when the user moves the slider and there is no dataItem.
	onValueChanged: {
		if (!inner.sameNumber(inner.value, root.value)) {
			inner.value = root.value
		}
	}

	ListSlider {
		id: inner

		flat: root.flat
		text: root.text
		from: root.from
		to: root.to
		stepSize: root.stepSize
		dataItem.uid: root.dataItem.uid
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
		writeAccessLevel: root.writeAccessLevel
		interactive: root.interactive

		// NaN is not equal to NaN. Two NaN values are the same number here, or the two
		// value handlers assign back and forth forever. This lives on the inner list item so
		// it is not part of the plugin API.
		function sameNumber(a, b) {
			return a === b || (isNaN(a) && isNaN(b))
		}

		onValueChanged: {
			if (!sameNumber(root.value, inner.value)) {
				root.value = inner.value
			}
		}
	}

	Component.onCompleted: {
		// If the plugin set 'value', the inner list item shows that instead of the backend value.
		if (!inner.sameNumber(inner.value, root.value)) {
			inner.value = root.value
		}
	}
}
