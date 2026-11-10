/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A dialog that asks the user to confirm a change, such as "Turn off the pump?", drawn as the
	GUI's own confirmation dialogs are.

	Declare it in a page or in a list item, and call open() to show it. accepted() is emitted when
	the user confirms, and rejected() when the user cancels. The GUI closes the dialog without
	emitting either signal when the page changes, when the screen blanks, or when the screen
	changes between portrait and landscape.
*/
QtObject {
	id: root

	property string title
	property string description
	property string acceptText: CommonWords.ok
	property string rejectText: CommonWords.cancel

	signal accepted
	signal rejected

	function open() {
		if (!helper.dialog) {
			helper.dialog = Global.dialogLayer.open(helper.dialogComponent)
		}
	}

	// A QtObject cannot have child objects, so the private parts are in this property. Its
	// members are not part of the plugin API.
	readonly property QtObject __private__: QtObject {
		id: helper

		// The shown dialog. Null once the GUI destroys it after it closes.
		property QtObject dialog

		readonly property Component dialogComponent: Component {
			ModalWarningDialog {
				dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
				title: root.title
				description: root.description
				acceptText: root.acceptText
				rejectText: root.rejectText

				onAccepted: root.accepted()
				onRejected: root.rejected()
			}
		}
	}

	// If this is destroyed while the dialog is shown, for example with its page, the dialog's
	// buttons could no longer emit this object's signals, so destroy the dialog too.
	Component.onDestruction: {
		if (helper.dialog) {
			helper.dialog.destroy()
		}
	}
}
