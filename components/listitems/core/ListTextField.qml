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
	property Flickable flickable: root.ListView ? root.ListView.view : null

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

	interactive: (dataItem.uid === "" || dataItem.valid)

	contentItem: FocusScope {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.isMultiLine ? contentLayout.implicitHeight : 0

		function runValidation(mode) {
			if (contentLayout.sourceComponent === editableComponent
					&& !!contentLayout.secondaryItem) {
				return contentLayout.secondaryItem.runValidation(mode)
			} else {
				return VenusOS.InputValidation_Result_Unknown
			}
		}

		function forceInputFocus() {
			if (contentLayout.secondaryComponent === editableComponent
					&& !!contentLayout.secondaryItem) {
				contentLayout.secondaryItem.forceInputFocus()
			}
		}

		TwoLabelItemLayout {
			id: contentLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			captionText: root.caption
			secondaryComponent: root.clickable ? editableComponent : readOnlyComponent
		}

		Component {
			id: editableComponent

			TextValidationField {
				width: Math.min(Theme.geometry_listItem_textField_maximumWidth,
								Math.max(implicitWidth, Theme.geometry_listItem_textField_minimumWidth))
				rightPadding: suffixLabel.text.length ? suffixLabel.implicitWidth : leftPadding
				horizontalAlignment: root.suffix ? Text.AlignRight : Text.AlignHCenter
				text: root.secondaryText
				echoMode: root.echoMode
				inputMethodHints: root.inputMethodHints
				placeholderText: root.placeholderText
				maximumLength: root.maximumLength

				focus: true
				flickable: root.flickable
				validateInput: root.validateInput
				validateOnFocusLost: root.validateOnFocusLost

				onInputValidated: root.saveInput()
				onTextEdited: root.secondaryText = text

				Label {
					id: suffixLabel

					anchors {
						right: parent.right
						verticalCenter: parent.verticalCenter
						alignWhenCentered: false
					}
					text: root.suffix
					font: parent.font
					color: Theme.color_font_secondary
					rightPadding: parent.leftPadding
				}
			}
		}

		Component {
			id: readOnlyComponent

			SecondaryListLabel {
				text: secondaryText.length > 0 ? secondaryText + root.suffix : "--"
				wrapMode: Text.Wrap
				opacity: root.echoMode === TextInput.Password ? 0 : 1
			}
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

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			if (root.checkWriteAccessLevel() && root.clickable && !!contentItem?.forceInputFocus) {
				contentItem.forceInputFocus()
			}
			event.accepted = true
			return
		case Qt.Key_Escape:
		case Qt.Key_Return:
		case Qt.Key_Enter:
			if (contentItem.activeFocus) {
				contentItem.focus = false
				event.accepted = true
				return
			}
			break
		}
		event.accepted = false
	}

	VeQuickItem {
		id: dataItem
	}
}
