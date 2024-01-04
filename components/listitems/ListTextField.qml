/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Veutil

ListItem {
	id: root

	readonly property alias dataItem: dataItem
	property alias textField: textField
	property alias secondaryText: textField.text
	property alias placeholderText: textField.placeholderText
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

	property TextField defaultContent: TextField {
		id: textField

		property string _textWhenFocused
		property bool _accepted

		width: Math.max(
				Theme.geometry_listItem_textField_minimumWidth,
				Math.min(implicitWidth + leftPadding + rightPadding, Theme.geometry_listItem_textField_maximumWidth))
		enabled: root.enabled
		text: dataItem.isValid ? dataItem.value : ""

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
