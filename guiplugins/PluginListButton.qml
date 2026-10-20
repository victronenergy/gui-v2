/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A row with a label, and a button on the right. The button shows secondaryText.

	A click on the button, or the Space key when the row has the key navigation focus, emits
	clicked(). If the user does not have writeAccessLevel, clicked() is not emitted, and a message
	says so.
*/
PluginListRow {
	id: root

	property string text
	property string caption
	// The text on the button.
	property string secondaryText

	// The lowest access level that can click the button.
	property int writeAccessLevel: PluginAccessLevel.Installer
	// True if the button can be clicked.
	property bool interactive: true

	signal clicked

	// Clicks the button, as a touch on it does.
	function click() {
		inner.click()
	}

	// Returns true if the user has writeAccessLevel. If not, shows a message saying so.
	function checkWriteAccessLevel() {
		return inner.checkWriteAccessLevel()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	ListButton {
		id: inner

		text: root.text
		caption: root.caption
		secondaryText: root.secondaryText
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
		writeAccessLevel: root.writeAccessLevel
		interactive: root.interactive

		onClicked: root.clicked()
	}
}
