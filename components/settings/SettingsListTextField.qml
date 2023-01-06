/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.VirtualKeyboard
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias source: dataPoint.source
	property alias value: dataPoint.value
	readonly property alias dataPoint: dataPoint
	readonly property alias valid: dataPoint.valid
	property alias textField: textField
	property alias secondaryText: textField.text
	property alias placeholderText: textField.placeholderText
	readonly property bool hasActiveFocus: textField.activeFocus

	signal accepted()
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

	function onAccepted(text) {
		if (dataPoint.source) {
			dataPoint.setValue(text)
		}
		textField.focus = false
		root.accepted()
	}

	enabled: source === "" || dataPoint.valid
	content.children: [
		TextField {
			id: textField

			width: Math.max(
					Theme.geometry.settingsListItem.textField.minimumWidth,
					Math.min(implicitWidth + leftPadding + rightPadding, Theme.geometry.settingsListItem.textField.maximumWidth))
			enabled: root.userHasWriteAccess
			text: dataPoint.valid ? dataPoint.value : ""

			EnterKeyAction.actionId: EnterKeyAction.Done
			onAccepted: root.onAccepted(text)
			onEditingFinished: root.editingFinished()

			MouseArea {
				anchors.fill: parent
				onPressed: function(mouse) {
					root._aboutToFocus()
					mouse.accepted = false
				}
			}
		}
	]

	DataPoint {
		id: dataPoint
	}
}
