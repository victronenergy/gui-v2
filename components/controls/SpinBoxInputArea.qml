/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

TextInput {
	id: root

	required property T.SpinBox spinBox
	property alias suffix: suffixLabel.text
	property int fontPixelSize: Theme.font_size_h3
	property int initialValue
	property bool arrowKeysEnabled

	signal increaseFailed()
	signal decreaseFailed()

	function setTextFromValue(value) {
		text = spinBox.textFromValue(value, spinBox.locale)
	}

	// These change the displayed value (which may not yet be accepted), rather than the actual
	// spinBox value.
	function increase() {
		const nextValue = spinBox.valueFromText(text, spinBox.locale) + spinBox.stepSize
		if (nextValue > spinBox.to) {
			root.increaseFailed()
		}
		setTextFromValue(Math.min(spinBox.to, nextValue))
	}
	function decrease() {
		const nextValue = spinBox.valueFromText(text, spinBox.locale) - spinBox.stepSize
		if (nextValue < spinBox.from) {
			root.decreaseFailed()
		}
		setTextFromValue(Math.max(spinBox.from, nextValue))
	}

	onActiveFocusChanged: {
		if (activeFocus) {
			root.initialValue = root.spinBox.value
		}
	}

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Return:
		case Qt.Key_Enter:
			// Save the entered text. The text may at this time represent a value outside of the
			// to/from range, so clamp it here.
			let v = root.spinBox.valueFromText(text, root.spinBox.locale)
			if (v < root.spinBox.from) {
				root.decreaseFailed()
				v = root.spinBox.from
			} else if (v > root.spinBox.to) {
				root.increaseFailed()
				v = root.spinBox.to
			}

			// Force-update the displayed text, to guarantee the text is in sync
			// with the numeric value, even if the value has not changed due to the
			// user entering an out-of-range value on consecutive attempts.
			text = root.spinBox.textFromValue(v, root.spinBox.locale)
			if (v !== spinBox.value) {
				root.spinBox.value = v
				root.spinBox.valueModified()
			}
			break
		case Qt.Key_Escape:
			// Restore the initial value.
			setTextFromValue(root.initialValue)
			break
		case Qt.Key_Up:
		case Qt.Key_Down:
			if (arrowKeysEnabled) {
				// Change the displayed input value (which may not yet be accepted) rather than
				// calling SpinBox increase()/decrease(), which change the actual SpinBox value.
				if (event.key === Qt.Key_Up) {
					increase()
				} else {
					decrease()
				}
				event.accepted = true
				return
			}
			break
		case Qt.Key_Left:
			event.accepted = cursorPosition <= 0
			return
		case Qt.Key_Right:
			// Don't allow left/right keys to move focus away from the text input.
			event.accepted = cursorPosition >= length
			return
		}
		event.accepted = false
	}

	leftPadding: Theme.geometry_textField_horizontalMargin
	rightPadding: suffixLabel.width + Theme.geometry_quantityLabel_spacing + Theme.geometry_textField_horizontalMargin
	focus: root.spinBox.editable
	color: enabled ? Theme.color_font_primary : Theme.color_font_disabled
	font.family: Global.fontFamily
	font.pixelSize: root.fontPixelSize
	horizontalAlignment: Qt.AlignHCenter
	verticalAlignment: Qt.AlignVCenter
	selectedTextColor: Theme.color_white
	selectionColor : Theme.color_blue
	readOnly: !root.spinBox.editable
	activeFocusOnPress: !readOnly && root.spinBox.editable
	selectByMouse: activeFocusOnPress
	validator: root.spinBox.validator
	inputMethodHints: root.spinBox.inputMethodHints

	Label {
		id: suffixLabel

		anchors {
			centerIn: parent
			horizontalCenterOffset: (parent.contentWidth / 2) + Theme.geometry_quantityLabel_spacing
		}
		width: text.length ? implicitWidth : 0
		visible: text.length
		color: parent.color
		font: parent.font
		horizontalAlignment: parent.horizontalAlignment
		verticalAlignment: parent.verticalAlignment
	}
}
