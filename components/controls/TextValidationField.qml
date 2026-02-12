/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

TextField {
	id: root

	property var validateInput
	property bool validateOnFocusLost: true
	property var flickable

	property int toast

	property string _initialText
	property bool _showErrorHighlight
	property bool _validateBeforeSaving
	property bool _inputCancelled

	signal inputValidated

	function forceInputFocus() {
		_aboutToFocus()
		root.forceActiveFocus()
	}

	function runValidation(mode) {
		const resultStatus = _doValidateInput(mode)
		if (mode === VenusOS.InputValidation_ValidateAndSave
				&& (resultStatus === VenusOS.InputValidation_Result_OK
					|| resultStatus === VenusOS.InputValidation_Result_Warning)) {
			inputValidated()
		}
		return resultStatus
	}

	function _doValidateInput(mode) {
		if (!validateInput) {
			return VenusOS.InputValidation_Result_OK
		}

		const result = validateInput()
		if (!result) {
			console.warn("validateInput() did not return a valid object!")
			return VenusOS.InputValidation_Result_Unknown
		}
		if (result.status === undefined) {
			console.warn("validateInput() did not return a valid result status!")
			return VenusOS.InputValidation_Result_Unknown
		}

		// If attempting to save, then show any errors and adjust the input text.
		if (mode === VenusOS.InputValidation_ValidateAndSave) {
			if (root.toast) {
				ToastModel.requestClose(root.toast)
			}
			if (result.notificationText.length > 0) {
				const notificationType = result.status === VenusOS.InputValidation_Result_Error ? VenusOS.Notification_Alarm
						: VenusOS.Notification_Info
				root.toast = Global.showToastNotification(notificationType, result.notificationText, 5000)
			}
			if (result.adjustedText != null) {
				text = result.adjustedText
			}
		}

		return result.status
	}

	function _aboutToFocus() {
		// Intercept the event before the VKB opens and scroll the parent flickable to
		// ensure the whole textfield is visible.
		Global.aboutToFocusTextField(root,
				parent,
				root.flickable)
	}

	borderColor: _showErrorHighlight ? Theme.color_red : Theme.color_ok
	focusPolicy: Qt.ClickFocus

	onTextEdited: {
		// When the input is marked as invalid, run the validation again each time the input is
		// edited. If validation produces a result code that is not InputValidation_Result_Error,
		// clear the invalid marker.
		if (_showErrorHighlight && root.runValidation(VenusOS.InputValidation_ValidateOnly) !== VenusOS.InputValidation_Result_Error) {
			_showErrorHighlight = false
		}
		// Dismiss error notification if visible.
		if (root.toast) {
			ToastModel.requestDismiss(root.toast)
		}
		_validateBeforeSaving = true
	}

	onAccepted: {
		// When input is accepted, validate and remove focus if text is valid.
		if (_validateBeforeSaving) {
			_showErrorHighlight = root.runValidation(VenusOS.InputValidation_ValidateAndSave) === VenusOS.InputValidation_Result_Error
			_validateBeforeSaving = false
		}
		if (!_showErrorHighlight) {
			root.focus = false
		}
	}

	onActiveFocusChanged: {
		if (activeFocus) {
			_initialText = text
		} else if (_validateBeforeSaving && !_inputCancelled) {
			if (validateOnFocusLost) {
				// When focus is lost and the text was changed, validate and save the text.
				_showErrorHighlight = root.runValidation(VenusOS.InputValidation_ValidateAndSave) === VenusOS.InputValidation_Result_Error
			}
			_validateBeforeSaving = false
		}
	}

	// When the cursor is on the left/right edges, consume left/right key events so that they do
	// not travel higher up the item hierarchy and activate key navigation.
	Keys.onLeftPressed: (event) => { event.accepted = root.activeFocus && root.cursorPosition === 0 }
	Keys.onRightPressed: (event) => { event.accepted = root.activeFocus && root.cursorPosition === text.length }

	// When the text field is focused, consume up/down key events so that the user does not
	// activate key navigation and move the focus elsewhere if the text is not yet accepted.
	Keys.onUpPressed: (event) => { event.accepted = root.activeFocus }
	Keys.onDownPressed: (event) => { event.accepted = root.activeFocus }

	// When escape is pressed, revert to the original text.
	Keys.onEscapePressed: {
		text = _initialText
		_inputCancelled = true // flag to prevent validation from running when focus is lost
		focus = false
		_inputCancelled = false
	}

	MouseArea {
		anchors.fill: parent
		onPressed: function(mouse) {
			root._aboutToFocus()
			mouse.accepted = false
		}
	}
}
