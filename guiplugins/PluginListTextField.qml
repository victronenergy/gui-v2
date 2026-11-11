/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list item with a label and an editable text field.

	The field shows secondaryText. By default, that is the value of dataItem, and when the user
	finishes editing, the new text is written to dataItem. The field's edit handler writes a new
	value to secondaryText, which replaces any binding on it.

	If the user does not have writeAccessLevel, the text is shown but cannot be edited.
*/
PluginListItem {
	id: root

	property string text
	property string caption
	property string secondaryText: inner.secondaryText
	property string placeholderText
	property int maximumLength: 32767
	readonly property PluginDataItem dataItem: PluginDataItem {}

	// The lowest access level that can edit the text.
	property int writeAccessLevel: PluginAccessLevel.Installer

	// Returns true if the user has writeAccessLevel. If not, shows a message saying so.
	function checkWriteAccessLevel() {
		return inner.checkWriteAccessLevel()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	// 'secondaryText' is synced both ways: the plugin may bind it, and the inner list item assigns its
	// own secondaryText when the text is edited.
	onSecondaryTextChanged: {
		if (inner.secondaryText !== root.secondaryText) {
			inner.secondaryText = root.secondaryText
		}
	}

	ListTextField {
		id: inner

		flat: root.flat
		text: root.text
		placeholderText: root.placeholderText
		maximumLength: root.maximumLength
		dataItem.uid: root.dataItem.uid
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
		writeAccessLevel: root.writeAccessLevel

		// The outer list item is the list's item, not this inner list item, so the inner
		// list item cannot find the list through its own ListView attached property.
		flickable: root.ListView.view

		// ListTextField has no caption, and its vertical padding is only the inset.
		ListCaptionAttachment {
			caption: root.caption
			contentBottomMargin: 0
		}

		onSecondaryTextChanged: {
			if (root.secondaryText !== inner.secondaryText) {
				root.secondaryText = inner.secondaryText
			}
		}
	}

	Component.onCompleted: {
		// If the plugin set secondaryText, the inner list item shows that instead of the backend value.
		if (inner.secondaryText !== root.secondaryText) {
			inner.secondaryText = root.secondaryText
		}
	}
}
