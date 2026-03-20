/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListSetting {
	id: root

	readonly property alias dataItem: dataItem
	property int inputMethodHints: Qt.ImhNone
	property string secondaryText: dataItem.valid ? dataItem.value : "" // Note: this changes when text is edited
	property string placeholderText
	property int echoMode: TextInput.Normal
	property int maximumLength: 32767 // as per TextInput default
	property string suffix
	property var flickable: root.ListView ? root.ListView.view : null

	// These are functions that can optionally be overridden.
	// - validateInput: validates the TextField input, and returns the object provided by
	//   Utils.validationResult() to describe the validation result.
	// - saveInput: saves the text field input. The default implementation saves the value to the
	//   dataItem, if it has a valid uid.
	// - validateOnFocusLost: whether the text should be validated when it loses active focus
	//   (default is true).
	//
	// When the text field loses focus or is accepted, validateInput is called; if it returns a result
	// of InputValidation_Result_OK or InputValidation_Result_Warning, then saveInput() is called.
	// validateInput() is also called to check whether the user has corrected the input to make it
	// valid, if the input was previously found to be invalid.
	property var validateInput
	property var saveInput: function() {
		if (dataItem.uid) {
			dataItem.setValue(secondaryText)
		}
	}
	property bool validateOnFocusLost: true

	function runValidation(mode) {
		if (contentItem?.runValidation) {
			return contentItem.runValidation(mode)
		} else {
			console.warn("contentItem does not support validation!")
			return VenusOS.InputValidation_Result_Error
		}
	}

	// Remove vertical padding, so that the text field does not stretch the height of the item.
	topPadding: 0
	bottomPadding: 0

	interactive: (dataItem.uid === "" || dataItem.valid)

	// Layout has 2 columns, 2 rows. The caption spans across both columns.
	// | Primary label | Text field |
	// | Caption                    |
	contentItem: GridLayout {
		function runValidation(mode) {
			return textField.runValidation(mode)
		}

		function forceInputFocus() {
			textField.forceInputFocus()
		}

		columns: 2
		columnSpacing: root.spacing
		rowSpacing: 0 // not needed, there is padding below the primary label already

		Label {
			// Since the root top/bottomPadding is 0, need to add some padding here.
			topPadding: Theme.geometry_listItem_content_verticalMargin
			bottomPadding: Theme.geometry_listItem_content_verticalMargin
			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap

			Layout.fillWidth: true
		}

		TextValidationField {
			id: textField

			rightPadding: suffixLabel.text.length ? suffixLabel.implicitWidth : leftPadding
			horizontalAlignment: root.suffix ? Text.AlignRight : Text.AlignHCenter
			text: root.secondaryText
			enabled: root.clickable
			visible: root.clickable
			echoMode: root.echoMode
			inputMethodHints: root.inputMethodHints
			placeholderText: root.placeholderText
			maximumLength: root.maximumLength

			flickable: root.flickable
			validateInput: root.validateInput
			validateOnFocusLost: root.validateOnFocusLost

			onInputValidated: root.saveInput()
			onTextChanged: root.secondaryText = text

			Layout.minimumWidth: Theme.geometry_listItem_textField_minimumWidth
			Layout.maximumWidth: Theme.geometry_listItem_textField_maximumWidth

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
		}

		SecondaryListLabel {
			text: secondaryText.length > 0 ? secondaryText + root.suffix : "--"
			wrapMode: Text.Wrap
			visible: !textField.visible
			opacity: textField.echoMode === TextInput.Password ? 0 : 1

			Layout.fillWidth: true
		}

		Label {
			text: root.caption
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0

			Layout.columnSpan: 2
			Layout.maximumWidth: root.availableWidth
			Layout.bottomMargin: Theme.geometry_listItem_content_verticalMargin
		}
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

	Keys.onSpacePressed: {
		if (root.checkWriteAccessLevel() && root.clickable && !!contentItem?.forceInputFocus) {
			contentItem.forceInputFocus()
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
