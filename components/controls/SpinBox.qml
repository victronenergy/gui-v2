/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import Victron.VenusOS

// SpinBox uses a binding to increase 'stepSize' when the user holds a button down for a while. This allows the spin box to quickly change arbitrarily large values.
// When the button is released, 'stepSize' reverts to its original value.
// TODO - find a way to do this without exposing the changes to 'stepSize', as it may surprise developers when the value changes unexpectedly.

/*
	Provides a SpinBox with key navigation features and an editable text input.

	The up/down indicators can be clicked to increase/decrease the value. Alternatively, to change
	the value when key navigation is enabled:

	- When the contentItem is focused with the key navigation highlight, press Space to enter "edit"
	mode. An orange frame with arrow hints appears around the text input, and pressing Up/Down will
	increase/decrease the value. If SpinBox editable=true, a text cursor is shown and the text can
	be edited directly.
	- To exit "edit" mode, press Enter/Return to confirm the value, or Escape (to revert to the
	previous value.
	- Press left/right to move the key navigation focus between the up/down indicators and the text
	input content item.

	Or, when key navigation is not enabled:

	- If SpinBox editable=true, a blue frame appears around the text. If the text is clicked, a
	text cursor is shown and the text can be edited text directly. To remove the cursor and focus,
	press Enter/Return to confirm the value, or Escape to revert to the previous value.
*/
T.SpinBox {
	id: root

	property alias secondaryText: secondaryLabel.text
	property int indicatorImplicitWidth: Theme.geometry_spinBox_indicator_minimumWidth
	property int orientation: Qt.Horizontal
	property string suffix
	property int fontPixelSize: secondaryText.length > 0 ? Theme.font_size_h2 : Theme.font_size_h3

	property int _scalingFactor: 1
	property int _originalStepSize

	signal increaseFailed()
	signal decreaseFailed()

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
			implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
			implicitContentHeight + topPadding + bottomPadding)
	leftPadding: orientation === Qt.Horizontal ? up.indicator.width + spacing : 0
	rightPadding: orientation === Qt.Horizontal ? down.indicator.width + spacing : 0
	topPadding: orientation === Qt.Vertical ? up.indicator.height + spacing : 0
	bottomPadding: orientation === Qt.Vertical ? down.indicator.height + spacing : 0
	spacing: Theme.geometry_spinBox_spacing
	validator: DoubleValidator {
		locale: Units.numberFormattingLocaleName
	}

	// Update the displayed text when the initial value is set or when the up/down buttons are
	// pressed.
	onValueChanged: inputArea.setTextFromValue(value)
	Component.onCompleted: inputArea.setTextFromValue(value)

	contentItem: FocusScope {
		id: spinBoxContentItem

		implicitWidth: contentArea.implicitWidth
		implicitHeight: contentArea.implicitHeight

		// needed for QQuickSpinBoxPrivate to read the "text" property of the contentItem
		// so that it can call the valueFromText() function
		readonly property alias text: inputArea.text

		focus: Global.keyNavigationEnabled

		KeyNavigation.left: Global.keyNavigationEnabled && root.orientation === Qt.Horizontal
				? downIndicatorPressArea
				: null
		KeyNavigation.right: Global.keyNavigationEnabled && root.orientation === Qt.Horizontal
				? upIndicatorPressArea
				: null
		KeyNavigation.up: Global.keyNavigationEnabled && root.orientation === Qt.Vertical
				? downIndicatorPressArea
				: null
		KeyNavigation.down: Global.keyNavigationEnabled && root.orientation === Qt.Vertical
				? upIndicatorPressArea
				: null

		// Called when a key is pressed while contentItem is focused, or when a key is pressed
		// within the inner inputArea but not accepted there.
		// The contentItem may be focused:
		// - during key navigation, if it is explicitly selected by the user
		// - indirectly, when the inner text input is clickable (as indicated by blue frame) and the
		//   user clicks it to give it active focus
		Keys.onPressed: (event) => {
			switch (event.key) {
			case Qt.Key_Space:
				// When using key navigation, the Space key enters "edit" mode, where the
				// upDownHintFrame is shown, and the text input area receives all key events.
				if (Global.keyNavigationEnabled
						// Don't activate if holding a press on the up/down buttons leads to this
						// being focused.
						&& !event.isAutoRepeat) {
					inputArea.focus = true
					event.accepted = true
					return
				}
				break
			case Qt.Key_Return:
			case Qt.Key_Enter:
			case Qt.Key_Escape:
				if (upDownHintFrame.visible) {
					// The user entered "edit" mode by pressing Space. Now move the focus back to
					// the contentItem so key navigation can be used to navigate to the indicators.
					inputArea.focus = false
					event.accepted = true
				} else if (clickableHintFrame.visible && inputArea.activeFocus) {
					// The user entered "edit" mode by clicking within the blue frame.
					// Remove the focus from the entire SpinBox, so that up/down keys do not trigger
					// the default increase/decrease behaviour (as that should only occur when the
					// orange up/down hint frame is shown).
					root.focus = false
					event.accepted = true
				} else {
					event.accepted = false
				}
				return
			case Qt.Key_Up:
			case Qt.Key_Down:
				if (clickableHintFrame.visible) {
					// Accept the event to prevent focus from moving elsewhere.
					event.accepted = true
					return
				} else {
					// Allow key navigation to move the focus elsewhere.
				}
				break
			default:
				break
			}
			event.accepted = false
		}

		KeyNavigationHighlight.active: Global.keyNavigationEnabled && activeFocus
		KeyNavigationHighlight.fill: contentArea

		// This acts like a Column but cannot be one, as KeyNavigationHighlight.fill injects the
		// highlight as a child with anchor bindings, which cannot be used in Row/Column.
		Item {
			id: contentArea

			anchors.centerIn: parent
			implicitWidth: Math.max(inputArea.implicitWidth, secondaryLabel.implicitWidth) + 2*Theme.geometry_textField_horizontalMargin
			implicitHeight: secondaryLabel.y + secondaryLabel.height
			width: Math.min(implicitWidth, parent.width)
			height: Math.min(implicitHeight, parent.height)

			SpinBoxInputArea {
				id: inputArea

				width: parent.width
				clip: true
				spinBox: root
				suffix: root.suffix
				fontPixelSize: root.fontPixelSize
				arrowKeysEnabled: upDownHintFrame.visible
				focus: false
				onIncreaseFailed: root.increaseFailed()
				onDecreaseFailed: root.decreaseFailed()
			}

			Label {
				id: secondaryLabel

				anchors {
					top: inputArea.bottom
					horizontalCenter: parent.horizontalCenter
				}
				width: parent.width
				height: text.length ? implicitHeight : 0
				color: Theme.color_font_secondary
				font.pixelSize: Theme.font_size_caption
				horizontalAlignment: Qt.AlignHCenter
			}

			// Blue rectangle indicateing the text area is clickable for direct text editing, when
			// editable=true. Not shown when key navigation highlight or orange frame are shown.
			Rectangle {
				id: clickableHintFrame
				anchors.fill: parent
				visible: root.editable
						 && !upDownHintFrame.visible
						 && !spinBoxContentItem.KeyNavigationHighlight.active
				color: "transparent"
				border.color: Theme.color_blue
				border.width: Theme.geometry_focus_highlight_border_size
				radius: Theme.geometry_button_radius
			}

			// Orange frame with arrow indicators, to hint that up/down keys will change the value,
			// when key navigation is enabled.
			EditFrame {
				id: upDownHintFrame
				anchors.fill: parent
				visible: Global.keyNavigationEnabled && inputArea.activeFocus
			}
		}
	}

	up.indicator: Rectangle {
		x: orientation === Qt.Horizontal
		   ? parent.width - width
		   : contentItem.x + (contentItem.width / 2) - (width / 2)
		y: orientation === Qt.Horizontal
		   ? contentItem.y + (contentItem.height / 2) - (height / 2)
		   : contentItem.y + (height / 2) + spacing
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry_spinBox_indicator_height
		radius: Theme.geometry_spinBox_indicator_radius
		color: enabled
			   ? (root.up.pressed ? Theme.color_button_down : Theme.color_button)
			   : Theme.color_background_disabled

		// Disable up/down indicators while text is edited directly, as indicators increase/decrease
		// based on the actual SpinBox value, which may be different from the value shown by the
		// text input if it has not yet been accepted.
		enabled: !inputArea.activeFocus && root.value < root.to

		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_plus.svg'
			opacity: root.enabled ? 1.0 : 0.4 // TODO add Theme opacity constants
		}
	}

	down.indicator: Rectangle {
		x: orientation === Qt.Horizontal
		   ? 0
		   : contentItem.x + (contentItem.width / 2) - (width / 2)
		y: orientation === Qt.Horizontal
		   ? contentItem.y + (contentItem.height / 2) - (height / 2)
		   : -(height / 2)
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry_spinBox_indicator_height
		radius: Theme.geometry_spinBox_indicator_radius
		color: enabled
			   ? (downIndicatorPressArea.pressed ? Theme.color_button_down : Theme.color_button)
			   : Theme.color_background_disabled
		enabled: !inputArea.activeFocus && root.value > root.from

		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_minus.svg'
			opacity: root.enabled ? 1.0 : 0.4 // TODO add Theme opacity constants
		}
	}

	// Add extra PressAreas above the up/down indicators that are always clickable, unlike the
	// up/down indicators which are disabled by the SpinBox implementation when the upper/lower
	// limits are reached. This allows increaseFailed() and decreaseFailed() to be emitted when the
	// user tries to go beyond the limits.
	PressArea {
		id: upIndicatorPressArea

		function activate() {
			if (!root.up.indicator.enabled) {
				root.increaseFailed()
				return
			}
			root.increase()
			root.valueModified()
			root.up.pressed = true
		}

		anchors.fill: root.up.indicator
		onPressed: activate()
		onReleased: root.up.pressed = false
		onCanceled: root.up.pressed = false

		Keys.enabled: Global.keyNavigationEnabled
		Keys.onSpacePressed: activate()
		Keys.onReleased: root.up.pressed = false
		KeyNavigation.left: orientation === Qt.Horizontal ? root.contentItem : null
		KeyNavigation.down: orientation === Qt.Vertical ? root.contentItem : null
		KeyNavigationHighlight.fill: root.up.indicator
		KeyNavigationHighlight.active: activeFocus
	}
	PressArea {
		id: downIndicatorPressArea

		function activate() {
			if (!root.down.indicator.enabled) {
				root.decreaseFailed()
				return
			}
			root.decrease()
			root.valueModified()
			root.down.pressed = true
		}

		anchors.fill: root.down.indicator
		onPressed: activate()
		onReleased: root.down.pressed = false
		onCanceled: root.down.pressed = false

		Keys.enabled: Global.keyNavigationEnabled
		Keys.onSpacePressed: activate()
		Keys.onReleased: root.down.pressed = false
		KeyNavigation.right: orientation === Qt.Horizontal ? root.contentItem : null
		KeyNavigation.up: orientation === Qt.Vertical ? root.contentItem : null
		KeyNavigationHighlight.fill: root.down.indicator
		KeyNavigationHighlight.active: activeFocus
	}

	textFromValue: function(value, locale) {
		return Units.formatNumber(value)
	}
	valueFromText: function(text, locale) {
		let value = Units.formattedNumberToReal(text)
		if (isNaN(value)) {
			// don't change the current value
			value = root.value
		}

		return value
	}

	Timer {
		id: pressTimer

		interval: 1000
		repeat: true
		running: up.pressed || down.pressed
		onTriggered: _scalingFactor *= 2
		onRunningChanged: {
			if (running) {
				_originalStepSize = stepSize
			} else {
				_scalingFactor = 1
			}
		}
	}

	Binding {
		root.stepSize: root._originalStepSize * _scalingFactor
		when: pressTimer.running
	}

	Timer {
		interval: 500
		repeat: true
		running: pressTimer.running
		onRunningChanged: if (!running) interval = 500
		onTriggered: {
			interval = 100
			if (up.pressed) {
				if (root.up.indicator.enabled) {
					root.increase()
					root.valueModified()
				} else {
					root.increaseFailed()
				}
			} else {
				if (root.down.indicator.enabled) {
					root.decrease()
					root.valueModified()
				} else {
					root.decreaseFailed()
				}
			}
		}
	}
}
