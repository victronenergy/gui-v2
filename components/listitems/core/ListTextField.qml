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

	signal editingFinished()
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
			if (textField.currentNotification) {
				textField.currentNotification.close(true)
			}
			if (result.notificationText.length > 0) {
				const notificationType = result.status === VenusOS.InputValidation_Result_Error ? VenusOS.Notification_Alarm
						: VenusOS.Notification_Info
				textField.currentNotification = Global.showToastNotification(notificationType, result.notificationText, 5000)
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

		property var currentNotification
		property bool _showErrorHighlight
		property bool _validateBeforeSaving

		enabled: root.clickable
		visible: root.clickable
		width: Math.max(Theme.geometry_listItem_textField_minimumWidth,
						Math.min(Theme.geometry_listItem_textField_maximumWidth,
								 implicitWidth + leftPadding + rightPadding))
		text: dataItem.valid ? dataItem.value : ""
		rightPadding: suffixLabel.text.length ? suffixLabel.implicitWidth : leftPadding
		horizontalAlignment: root.suffix ? Text.AlignRight : Text.AlignHCenter
		borderColor: _showErrorHighlight ? Theme.color_red : Theme.color_ok

		onTextEdited: {
			// When the input is marked as invalid, run the validation again each time the input is
			// edited. If validation produces a result code that is not InputValidation_Result_Error,
			// clear the invalid marker.
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

		// Consume arrow key events so that they do not go higher up the item hierarchy and trigger
		// key navigation events while the text field is focused.
		Keys.onLeftPressed: {}
		Keys.onRightPressed: {}

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

	SecondaryListLabel {
		id: readonlyLabel

		text: textField.text.length > 0 ? textField.text : "--"
		width: Math.min(implicitWidth, root.maximumContentWidth)
		visible: !textField.visible
	}

	VeQuickItem {
		id: dataItem
	}
}
