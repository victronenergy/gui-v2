/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list item with a label, and the current option on the right. A click, or the Space key when the list item
	has the key navigation focus, opens a page that lists the options, and the user picks one.

	optionModel is an array of options. Each option is an object with:
	- display: the text shown for the option, and
	- value: the option's value.
	For example: [ { display: "Off", value: 0 }, { display: "On", value: 1 } ].

	currentIndex is the index of the current option in optionModel, or -1 if there is none. By
	default, it is the option whose value is equal to dataItem.value, and picking an option writes
	the option's value to dataItem. Without a dataItem, set currentIndex yourself, for example in
	onOptionClicked.

	If the user does not have writeAccessLevel, the page does not open, and a message says so.
*/
PluginListItem {
	id: root

	property string text
	property string caption
	property var optionModel: []
	property int currentIndex: root.dataItem.valid
			? root.optionModel.findIndex(option => option.value === root.dataItem.value)
			: -1
	// The text on the right when there is no current option. By default, "Unknown".
	property string defaultSecondaryText: inner.defaultSecondaryText
	readonly property PluginDataItem dataItem: PluginDataItem {}
	// Set to false so that picking an option does not write to dataItem. Handle onOptionClicked
	// instead, for example to ask the user to confirm before writing the value.
	property bool updateDataOnClick: true

	// The lowest access level that can pick an option.
	property int writeAccessLevel: PluginAccessLevel.Installer
	// True if the list item can be clicked. By default, when there is no dataItem.uid, or its value is
	// valid.
	property bool interactive: root.dataItem.uid === "" || root.dataItem.valid

	// Emitted when the user picks an option. 'index' is the option's index in optionModel.
	signal optionClicked(index: int)

	// Clicks the list item, as a touch on it does.
	function click() {
		inner.click()
	}

	// Returns true if the user has writeAccessLevel. If not, shows a message saying so.
	function checkWriteAccessLevel() {
		return inner.checkWriteAccessLevel()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	ListRadioButtonGroup {
		id: inner

		flat: root.flat
		text: root.text
		caption: root.caption
		optionModel: root.optionModel
		currentIndex: root.currentIndex
		// Uses root.defaultSecondaryText. Binding the inner list item's defaultSecondaryText to it instead
		// would make a binding loop, as the default value of root.defaultSecondaryText reads the
		// inner one.
		secondaryText: root.currentIndex >= 0 && root.currentIndex < root.optionModel.length
			? root.optionModel[root.currentIndex].display
			: root.defaultSecondaryText
		dataItem.uid: root.dataItem.uid
		updateDataOnClick: root.updateDataOnClick
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
		writeAccessLevel: root.writeAccessLevel
		interactive: root.interactive

		onOptionClicked: (index) => root.optionClicked(index)
	}
}
