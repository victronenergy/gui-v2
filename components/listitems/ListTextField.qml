/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
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
	//   validationResult() to describe the validation result.
	// - save: saves the text field input. The default implementation saves the value to the dataItem.
	//
	// When the text field loses focus or is accepted, validate is called(); if it returns a result
	// of InputValidation_Result_OK, then saveInput() is called. validateInput() is also called to check
	// whether the user has corrected the input to make it valid, if the input was previously found
	// to be invalid.
	property var validateInput
	property var saveInput: function() {
		if (dataItem.uid) {
			dataItem.setValue(textField.text)
		}
	}

	signal editingFinished()
	signal accepted()

	function forceActiveFocus() {
		_aboutToFocus()
		textField.forceActiveFocus()
	}

	// Returns an object to return from validateInput(). The status can be:
	// - InputValidation_Result_Error: the input text is invalid; highlight the input with a red border
	// - InputValidation_Result_OK: the input text is valid, and can be saved, or red highlight can be removed
	// - InputValidation_Result_Unknown: the input text should not be saved, but is not invalid, so
	//   do not highlight with a red border. This is useful when the input string is empty.
	function validationResult(status, errorText = "", adjustedText = undefined) {
		return { status: status, errorText = errorText, adjustedText = adjustedText }
	}

	function runValidation(mode) {
		const resultStatus = _doValidateInput(mode)
		if (mode === VenusOS.InputValidation_ValidateAndSave
				&& resultStatus === VenusOS.InputValidation_Result_OK) {
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
			if (result.status === VenusOS.InputValidation_Result_Error) {
				let errorText = result.errorText
				if (errorText.length === 0) {
					//% "The entered text does not have the correct format. Try again."
					errorText = qsTrId("text_field_default_error_text")
				}
				if (textField.currentNotification) {
					textField.currentNotification.close(true)
				}
				textField.currentNotification = Global.showToastNotification(VenusOS.Notification_Info, errorText, 5000)
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
		const textFieldVerticalMargin = root.height - textField.height
		const textFieldBottom = root.height - textFieldVerticalMargin/2
		Global.aboutToFocusTextField(textField,
				textFieldBottom,
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

		property var currentNotification
		property bool _showErrorHighlight
		property bool _validateBeforeSaving

		width: Math.max(Theme.geometry_listItem_textField_minimumWidth,
						Math.min(Theme.geometry_listItem_textField_maximumWidth,
								 implicitWidth + leftPadding + rightPadding))
		visible: root.enabled
		text: dataItem.isValid ? dataItem.value : ""
		rightPadding: suffixLabel.text.length ? suffixLabel.implicitWidth : leftPadding
		horizontalAlignment: root.suffix ? Text.AlignRight : Text.AlignHCenter
		borderColor: _showErrorHighlight ? Theme.color_red : Theme.color_ok

		onTextEdited: {
			// When the input is marked as invalid, run the validation again each time the input is
			// edited. If the result is either OK or unknown, then clear the invalid marker.
			if (_showErrorHighlight && root.runValidation(VenusOS.InputValidation_ValidateOnly) !== VenusOS.InputValidation_Result_Error) {
				_showErrorHighlight = false
			}
			// Close error notification if visible.
			if (textField.currentNotification) {
				textField.currentNotification.close(false)
				textField.currentNotification = null
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
			// When focus is lost and the text was changed, validate and save the text.
			if (_validateBeforeSaving) {
				_showErrorHighlight = root.runValidation(VenusOS.InputValidation_ValidateAndSave) === VenusOS.InputValidation_Result_Error
				_validateBeforeSaving = false
			}
			root.editingFinished()
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

	enabled: userHasWriteAccess && (dataItem.uid === "" || dataItem.isValid)
	content.children: [
		defaultContent,
		readonlyLabel
	]

	ListTextItemSecondaryLabel {
		id: readonlyLabel

		text: textField.text.length > 0 ? textField.text : "--"
		width: Math.min(implicitWidth, root.maximumContentWidth)
		visible: !root.enabled
	}

	VeQuickItem {
		id: dataItem
	}
}
