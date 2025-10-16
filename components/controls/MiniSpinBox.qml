/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import QtQuick.Controls.impl as CP
import Victron.VenusOS

/*
	Provides a small SpinBox with an editable text input.

	The up/down indicators can be clicked to increase/decrease the value.

	When focused, a text cursor appears and the text can be edited directly. Press Enter/Return
	to confirm the value, or Escape to revert to the previous value.

	If focused while key key navigation is enabled, an orange frame with up/down arrow hints will
	appear around the text input, and pressing Up/Down will increase/decrease the value.
*/
CT.SpinBox {
	id: root

	property string suffix
	readonly property real indicatorWidth: width / 4
	property Item textInput

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
			implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
			implicitContentHeight + topPadding + bottomPadding)
	leftPadding: indicatorWidth
	rightPadding: indicatorWidth
	editable: true
	validator: DoubleValidator {
		locale: Units.numberFormattingLocaleName
	}

	onValueChanged: inputArea.setTextFromValue(value)
	Component.onCompleted: inputArea.setTextFromValue(value)

	contentItem: FocusScope {
		// needed for QQuickSpinBoxPrivate to read the "text" property of the contentItem
		// so that it can call the valueFromText() function
		readonly property alias text: inputArea.text

		Rectangle {
			anchors {
				fill: parent
				// Push out the left/right edges so we don't get a double border when placed
				// adjacent to the up/down indicators which also have borders.
				leftMargin: -border.width
				rightMargin: -border.width
			}
			color: root.enabled ? Theme.color_background_secondary : Theme.color_background_disabled
			border.color: enabled ? Theme.color_ok : Theme.color_font_disabled
			border.width: Theme.geometry_button_border_width
		}

		Keys.onPressed: (event) => {
			switch (event.key) {
			case Qt.Key_Return:
			case Qt.Key_Enter:
			case Qt.Key_Escape:
				// Remove the focus from the entire SpinBox, so that up/down keys do not trigger
				// the default increase/decrease behaviour (as that should only occur when the
				// orange up/down hint frame is shown).
				root.focus = false
				event.accepted = true
				break
			case Qt.Key_Up:
			case Qt.Key_Down:
				// Accept the event to avoid triggering the default SpinBox increase/decrease
				// behaviour.
				event.accepted = true
				break
			default:
				event.accepted = false
				break
			}
		}

		// The input area takes the initial focus when the SpinBox is focused during key navigation.
		// When Enter/Return/Escape is pressed, focus is removed from the SpinBox.
		SpinBoxInputArea {
			id: inputArea

			anchors.fill: parent
			clip: true
			spinBox: root
			suffix: root.suffix
			fontPixelSize: Theme.font_size_body2
			arrowKeysEnabled: upDownHintFrame.visible
			focus: Global.keyNavigationEnabled

			Component.onCompleted: root.textInput = inputArea
		}

		// Orange frame with arrow indicators, to hint that up/down keys will change the value,
		// when key navigation is enabled.
		EditFrame {
			id: upDownHintFrame
			anchors.fill: parent
			visible: Global.keyNavigationEnabled && root.activeFocus
			arrowMargin: 0
		}
	}

	down.indicator: Rectangle {
		implicitWidth: root.indicatorWidth
		implicitHeight: root.height
		topLeftRadius: Theme.geometry_button_radius
		bottomLeftRadius: Theme.geometry_button_radius
		color: enabled
			   ? (root.down.pressed ? Theme.color_ok : Theme.color_darkOk)
			   : Theme.color_background_disabled
		border.color: enabled ? Theme.color_ok : Theme.color_font_disabled
		border.width: Theme.geometry_button_border_width

		MouseArea {
			anchors.fill: parent
			onPressed: (event) => {
				if (root.editable && inputArea.activeFocus) {
					// Use the custom decrease(), which decreases the currently-entered value.
					inputArea.decrease()
					event.accepted = true
				} else {
					// Use the default SpinBox decrease(), which decreases the saved root.value.
					event.accepted = false
				}
			}
		}

		CP.ColorImage {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_minus.svg'
			color: enabled ? Theme.color_font_primary : Theme.color_font_disabled
		}
	}

	up.indicator: Rectangle {
		x: parent.width - width
		implicitWidth: root.indicatorWidth
		implicitHeight: root.height
		topRightRadius: Theme.geometry_button_radius
		bottomRightRadius: Theme.geometry_button_radius
		color: enabled
			   ? (root.up.pressed ? Theme.color_ok : Theme.color_darkOk)
			   : Theme.color_background_disabled
		border.color: enabled ? Theme.color_ok : Theme.color_font_disabled
		border.width: Theme.geometry_button_border_width

		MouseArea {
			anchors.fill: parent
			onPressed: (event) => {
				if (root.editable && inputArea.activeFocus) {
					// Use the custom increase(), which increases the currently-entered value.
					inputArea.increase()
					event.accepted = true
				} else {
					// Use the default SpinBox increase(), which increases the saved root.value.
					event.accepted = false
				}
			}
		}

		CP.ColorImage {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_plus.svg'
			color: enabled ? Theme.color_font_primary : Theme.color_font_disabled
		}
	}
}
