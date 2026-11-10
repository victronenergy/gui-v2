/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginConfirmationDialogTest"
	when: windowShown
	// A dialog opens only in a visible window.
	visible: true
	width: 800
	height: 480

	property DialogLayer dialogLayer

	Component {
		id: dialogLayerComponent

		DialogLayer {}
	}

	Component {
		id: dialogComponent

		PluginConfirmationDialog {
			title: "Turn off the pump?"
			description: "The tank will stop filling."
			acceptText: "Turn off"
			rejectText: "Keep running"
		}
	}

	SignalSpy {
		id: acceptedSpy

		signalName: "accepted"
	}

	SignalSpy {
		id: rejectedSpy

		signalName: "rejected"
	}

	function initTestCase() {
		// DialogLayer watches Global.mainView, which is undefined until set. Set it
		// before creating the layer, to avoid a warning.
		Global.mainView = null
		dialogLayer = dialogLayerComponent.createObject(root)
		Global.dialogLayer = dialogLayer
	}

	function cleanupTestCase() {
		Global.dialogLayer = null
		dialogLayer.destroy()
	}

	function init() {
		failOnWarning(/TypeError/)
	}

	function cleanup() {
		if (dialogLayer.currentDialog) {
			dialogLayer.currentDialog.destroy()
		}
		tryVerify(function() { return dialogLayer.currentDialog === null })
		acceptedSpy.clear()
		rejectedSpy.clear()
	}

	// Opens the dialog of a new PluginConfirmationDialog, and waits for it to be shown.
	function openNewDialog() {
		const confirmation = createTemporaryObject(dialogComponent, root)
		verify(confirmation !== null)
		acceptedSpy.target = confirmation
		rejectedSpy.target = confirmation
		confirmation.open()
		verify(dialogLayer.currentDialog !== null)
		tryVerify(function() { return dialogLayer.currentDialog.opened })
		return confirmation
	}

	function test_openShowsTheTexts() {
		openNewDialog()
		const dialog = dialogLayer.currentDialog
		compare(dialog.title, "Turn off the pump?")
		compare(dialog.description, "The tank will stop filling.")
		compare(dialog.acceptText, "Turn off")
		compare(dialog.rejectText, "Keep running")
	}

	function test_textChangesWhileShownUpdateTheDialog() {
		const confirmation = openNewDialog()
		confirmation.title = "Stop the pump?"
		confirmation.acceptText = "Stop"
		compare(dialogLayer.currentDialog.title, "Stop the pump?")
		compare(dialogLayer.currentDialog.acceptText, "Stop")
	}

	function test_acceptButtonEmitsAccepted() {
		const confirmation = openNewDialog()
		const dialog = dialogLayer.currentDialog
		mouseClick(dialog.acceptButton)
		compare(acceptedSpy.count, 1)
		compare(rejectedSpy.count, 0)
		tryVerify(function() { return dialogLayer.currentDialog === null })

		// Once the closed dialog is gone, open() shows a new one.
		confirmation.open()
		verify(dialogLayer.currentDialog !== null)
		verify(dialogLayer.currentDialog !== dialog)
		tryVerify(function() { return dialogLayer.currentDialog.opened })
	}

	function test_cancelEmitsRejected() {
		openNewDialog()
		// The cancel button and the portrait close button both call handleReject().
		dialogLayer.currentDialog.handleReject()
		compare(rejectedSpy.count, 1)
		compare(acceptedSpy.count, 0)
		tryVerify(function() { return dialogLayer.currentDialog === null })
	}

	function test_openWhileShownKeepsOneDialog() {
		const confirmation = openNewDialog()
		const dialog = dialogLayer.currentDialog
		confirmation.open()
		compare(dialogLayer.currentDialog, dialog)
		verify(dialog.opened)
	}

	function test_destroyingTheObjectClosesTheDialog() {
		const confirmation = dialogComponent.createObject(root)
		verify(confirmation !== null)
		confirmation.open()
		verify(dialogLayer.currentDialog !== null)
		tryVerify(function() { return dialogLayer.currentDialog.opened })

		confirmation.destroy()
		tryVerify(function() { return dialogLayer.currentDialog === null })
	}
}
