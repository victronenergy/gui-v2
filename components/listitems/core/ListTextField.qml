/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias dataItem: dataItem
	property alias textField: textField
	property alias secondaryText: textField.text
	property alias placeholderText: textField.placeholderText
	property string suffix
	property var flickable: root.ListView ? root.ListView.view : null

	// These are functions that can optionally be overridden.
	// - validateInput: validates the TextField input, and returns the object provided by
	//   Utils.validationResult() to describe the validation result.
	// - saveInput: saves the text field input. The default implementation saves the value to the
	//   dataItem, if it has a valid uid.
	//
	// When the text field loses focus or is accepted, validateInput is called; if it returns a result
	// of InputValidation_Result_OK or InputValidation_Result_Warning, then saveInput() is called.
	// validateInput() is also called to check whether the user has corrected the input to make it
	// valid, if the input was previously found to be invalid.
	property var validateInput
	property var saveInput: function() {
		if (dataItem.uid) {
			dataItem.setValue(textField.text)
		}
	}

	signal accepted()

	interactive: (dataItem.uid === "" || dataItem.valid)

	onClicked: forceActiveFocus()

	function forceActiveFocus() {
		_aboutToFocus()
		textField.forceActiveFocus()
	}

	function runValidation(mode) {
		const resultStatus = _doValidateInput(mode)
		if (mode === VenusOS.InputValidation_ValidateAndSave
				&& (resultStatus === VenusOS.InputValidation_Result_OK
					|| resultStatus === VenusOS.InputValidation_Result_Warning)) {
			saveInput()
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
				textField.text = result.adjustedText
			}
		}

		return result.status
	}


	function _aboutToFocus() {
		// Intercept the event before the VKB opens and scroll the parent flickable to
		// ensure the whole textfield is visible.
		Global.aboutToFocusTextField(textField,
				root,
				root.flickable)
	}

	onWindowChanged: {
		// In nested views the ListView attached property
		// might have not returned valid parent flickable.
		if (!flickable) {
			let p = parent
			while (p) {
				if (p.hasOwnProperty("originY") && p.hasOwnProperty("contentY")) {
					flickable = p
					break
				}

				p = p.parent
			}
		}
	}

	property TextField defaultContent: TextField {
		id: textField

		property string _initialText
		property bool _showErrorHighlight
		property bool _validateBeforeSaving
		property bool _inputCancelled

		enabled: root.clickable
		visible: root.clickable
		width: Math.max(Theme.geometry_listItem_textField_minimumWidth,
						Math.min(Theme.geometry_listItem_textField_maximumWidth,
								 implicitWidth + leftPadding + rightPadding))
		text: dataItem.valid ? dataItem.value : ""
		rightPadding: suffixLabel.text.length ? suffixLabel.implicitWidth : leftPadding
		horizontalAlignment: root.suffix ? Text.AlignRight : Text.AlignHCenter
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
				root.accepted()
				textField.focus = false
			}
		}

		onActiveFocusChanged: {
			if (activeFocus) {
				_initialText = text
			} else if (_validateBeforeSaving && !_inputCancelled) {
				// When focus is lost and the text was changed, validate and save the text.
				_showErrorHighlight = root.runValidation(VenusOS.InputValidation_ValidateAndSave) === VenusOS.InputValidation_Result_Error
				_validateBeforeSaving = false
			}
		}

		// When the cursor is on the left/right edges, consume left/right key events so that they do
		// not travel higher up the item hierarchy and activate key navigation.
		Keys.onLeftPressed: (event) => { event.accepted = textField.activeFocus && textField.cursorPosition === 0 }
		Keys.onRightPressed: (event) => { event.accepted = textField.activeFocus && textField.cursorPosition === textField.text.length }

		// When the text field is focused, consume up/down key events so that the user does not
		// activate key navigation and move the focus elsewhere if the text is not yet accepted.
		Keys.onUpPressed: (event) => { event.accepted = textField.activeFocus }
		Keys.onDownPressed: (event) => { event.accepted = textField.activeFocus }

		// When escape is pressed, revert to the original text.
		Keys.onEscapePressed: {
			text = _initialText
			_inputCancelled = true // flag to prevent validation from running when focus is lost
			focus = false
			_inputCancelled = false
		}

		Label {
			id: suffixLabel

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
				alignWhenCentered: false
			}
			text: root.suffix
			font: textField.font
			color: Theme.color_font_secondary
			rightPadding: textField.leftPadding
		}

		MouseArea {
			anchors.fill: parent
			onPressed: function(mouse) {
				root._aboutToFocus()
				mouse.accepted = false
			}
		}
	}

	content.children: [
		defaultContent,
		readonlyLabel
	]

	readonly property SecondaryListLabel readonlyLabel: SecondaryListLabel {
		text: textField.text.length > 0 ? textField.text + root.suffix : "--"
		width: Math.min(implicitWidth, root.maximumContentWidth)
		visible: !textField.visible && textField.echoMode !== TextInput.Password
	}

	VeQuickItem {
		id: dataItem
	}
}
