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
	property var tryAcceptInput
	property var flickable: root.ListView ? root.ListView.view : null
	readonly property bool hasActiveFocus: textField.activeFocus

	signal accepted(text: string)
	signal editingFinished()

	function forceActiveFocus() {
		_aboutToFocus()
		textField.forceActiveFocus()
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

		property string _textWhenFocused
		property bool _accepted

		function _tryAcceptInput(keyEvent) {
			if (!!root.tryAcceptInput) {
				const result = root.tryAcceptInput(text)
				if (result === undefined) {
					keyEvent.accepted = true
					return
				}
				text = result
			}
			keyEvent.accepted = false
		}

		width: Math.max(
				Theme.geometry_listItem_textField_minimumWidth,
				Math.min(implicitWidth + leftPadding + rightPadding, Theme.geometry_listItem_textField_maximumWidth))
		enabled: root.enabled
		text: dataItem.isValid ? dataItem.value : ""
		rightPadding: suffixLabel.text.length ? suffixLabel.implicitWidth : leftPadding
		horizontalAlignment: root.suffix ? Text.AlignRight : Text.AlignHCenter

		Keys.onEnterPressed: function (keyEvent) { textField._tryAcceptInput(keyEvent) }
		Keys.onReturnPressed: function (keyEvent) { textField._tryAcceptInput(keyEvent) }

		onAccepted: {
			let newValue = text
			_accepted = true
			if (dataItem.uid) {
				dataItem.setValue(newValue)
			}
			textField.focus = false
			root.accepted(newValue)
		}

		onEditingFinished: root.editingFinished()

		onActiveFocusChanged: {
			if (activeFocus) {
				_textWhenFocused = text
				_accepted = false
			} else if (!_accepted && _textWhenFocused !== text) {
				text = _textWhenFocused
				revertedAnimation.to = textField.color
				revertedAnimation.start()
			}
		}

		ColorAnimation on color {
			id: revertedAnimation

			from: Theme.color_orange
			duration: 400
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
		defaultContent
	]

	VeQuickItem {
		id: dataItem
	}
}
