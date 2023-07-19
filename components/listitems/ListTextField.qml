/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	property alias dataInvalidate: dataPoint.invalidate
	function setDataValue(v) { dataPoint.setValue(v) }

	property alias textField: textField
	property alias secondaryText: textField.text
	property alias placeholderText: textField.placeholderText
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
				root.ListView ? root.ListView.view : null)
	}

	property TextField defaultContent: TextField {
		id: textField

		property string _textWhenFocused
		property bool _accepted

		width: Math.max(
				Theme.geometry.listItem.textField.minimumWidth,
				Math.min(implicitWidth + leftPadding + rightPadding, Theme.geometry.listItem.textField.maximumWidth))
		enabled: root.enabled
		text: dataValid ? dataValue : ""

		onAccepted: {
			let newValue = text
			_accepted = true
			if (dataPoint.source) {
				dataPoint.setValue(newValue)
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

			from: Theme.color.orange
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

	enabled: userHasWriteAccess && (dataSource === "" || dataValid)
	content.children: [
		defaultContent
	]

	DataPoint {
		id: dataPoint
	}
}
