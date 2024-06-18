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

		width: Math.max(Theme.geometry_listItem_textField_minimumWidth,
						Math.min(Theme.geometry_listItem_textField_maximumWidth,
								 implicitWidth + leftPadding + rightPadding))
		visible: root.enabled
		text: dataItem.isValid ? dataItem.value : ""
		rightPadding: suffixLabel.text.length ? suffixLabel.implicitWidth : leftPadding
		horizontalAlignment: root.suffix ? Text.AlignRight : Text.AlignHCenter

		function accept() {
			let newValue = text
			if (dataItem.uid) {
				dataItem.setValue(newValue)
			}
			root.accepted(newValue)
		}

		onAccepted: textField.focus = false
		onEditingFinished: root.editingFinished()
		onActiveFocusChanged: if (!activeFocus) accept()

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
