/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as CT
import QtQuick.Controls.impl as CP
import QtQuick.Layouts
import Victron.VenusOS

// SpinBox uses a binding to increase 'stepSize' when the user holds a button down for a while. This allows the spin box to quickly change arbitrarily large values.
// When the button is released, 'stepSize' reverts to its original value.
// TODO - find a way to do this without exposing the changes to 'stepSize', as it may surprise developers when the value changes unexpectedly.

CT.SpinBox {
	id: root

	property alias textInput: primaryTextInput
	property alias secondaryText: secondaryLabel.text
	property int indicatorImplicitWidth: Theme.geometry_spinBox_indicator_minimumWidth
	property int orientation: Qt.Horizontal
	property alias suffix: suffixLabel.text

	property int focusMode: Global.keyNavigationEnabled
			? VenusOS.SpinBox_FocusMode_Navigate
			: VenusOS.SpinBox_FocusMode_NoAction

	property int _scalingFactor: 1
	property int _originalStepSize

	signal maxValueReached()
	signal minValueReached()

	function _handleContentItemKeyPress(event) {
		// When key navigation is enabled, press space key to enter 'edit' mode. In edit mode:
		// - an edit frame appears around the text, with up/down arrow indicators
		// - up/down keys increases/decreases the value
		// - left/right keys are disabled
		// - enter/return/escape keys exit 'edit' mode (if text input is directly editable, the
		//   text is also accepted)
		//   (TODO: would be nice if Escape key reverted to previous value; currently it only does
		//   this if the text input is directly editable)
		switch (event.key) {
		case Qt.Key_Space:
			if (root.focusMode === VenusOS.SpinBox_FocusMode_Navigate) {
				root.focusMode = VenusOS.SpinBox_FocusMode_Edit
				if (root.editable) {
					primaryTextInput.forceActiveFocus()
				}
				return true
			}
			break
		case Qt.Key_Return:
		case Qt.Key_Enter:
		case Qt.Key_Escape:
			if (root.focusMode === VenusOS.SpinBox_FocusMode_Edit) {
				root.focusMode = VenusOS.SpinBox_FocusMode_Navigate
				return true
			}
			break
		case Qt.Key_Escape:
			if (root.focusMode === VenusOS.SpinBox_FocusMode_Edit) {
				root.focusMode = VenusOS.SpinBox_FocusMode_Navigate
				return true
			}
			break
		case Qt.Key_Up:
		case Qt.Key_Down:
			if (root.focusMode === VenusOS.SpinBox_FocusMode_Edit) {
				if (event.key === Qt.Key_Up) {
					root.increase()
				} else {
					root.decrease()
				}
				return true
			}
			break
		case Qt.Key_Left:
		case Qt.Key_Right:
			if (root.focusMode === VenusOS.SpinBox_FocusMode_Edit) {
				return true
			}
			break
		}
		return false
	}

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
		orientation === Qt.Horizontal
			? valueColumn.width + up.indicator.width + down.indicator.width + (2 * spacing) + leftPadding + rightPadding
			: valueColumn.width + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
		orientation === Qt.Horizontal
			? Math.max(valueColumn.height, up.indicator.height, down.indicator.height) + topPadding + bottomPadding
			: valueColumn.height + up.indicator.height + down.indicator.height + (2 * spacing) + topPadding + bottomPadding)

	spacing: Theme.geometry_spinBox_spacing
	onValueModified: {
		if (value === to) {
			root.maxValueReached()
		} else if (value === from) {
			root.minValueReached()
		}
	}

	onValueChanged: primaryTextInput.updateText()

	Component.onCompleted: primaryTextInput.updateText()

	contentItem: Item {
		// needed for QQuickSpinBoxPrivate to read the "text" property of the contentItem
		// so that it can call the valueFromText() function
		readonly property alias text: primaryTextInput.text

		focus: Global.keyNavigationEnabled

		Keys.onPressed: (event) => event.accepted = root._handleContentItemKeyPress(event)
		Keys.enabled: Global.keyNavigationEnabled
		KeyNavigation.left: root.down.indicator.enabled
					&& root.focusMode === VenusOS.SpinBox_FocusMode_Navigate
					&& root.orientation === Qt.Horizontal
				? root.down.indicator
				: null
		KeyNavigation.right: root.up.indicator.enabled
					&& root.focusMode === VenusOS.SpinBox_FocusMode_Navigate
					&& root.orientation === Qt.Horizontal
				? root.up.indicator
				: null
		KeyNavigation.up: root.up.indicator.enabled
					&& root.focusMode === VenusOS.SpinBox_FocusMode_Navigate
					&& root.orientation === Qt.Vertical
				? root.up.indicator
				: null
		KeyNavigation.down: root.down.indicator.enabled
					&& root.focusMode === VenusOS.SpinBox_FocusMode_Navigate
					&& root.orientation === Qt.Vertical
				? root.down.indicator
				: null

		Column {
			id: valueColumn

			width: Math.max(primaryTextInputItem.implicitWidth, secondaryLabel.implicitWidth)
			anchors.centerIn: parent

			Item  {
				id: primaryTextInputItem

				width: primaryRowLayout.implicitWidth + Theme.geometry_textField_horizontalMargin * 2
				height: primaryRowLayout.height
				anchors.horizontalCenter: parent.horizontalCenter

				MouseArea {
					anchors.fill: parent
					enabled: root.editable
					onClicked: primaryTextInput.forceActiveFocus()
				}

				RowLayout {
					id: primaryRowLayout

					anchors.centerIn: parent

					TextInput {
						id: primaryTextInput

						color: root.enabled ? Theme.color_font_primary : Theme.color_background_disabled
						font.family: Global.fontFamily
						font.pixelSize: root.secondaryText.length > 0 ? Theme.font_size_h2 : Theme.font_size_h3
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						selectedTextColor: Theme.color_white
						selectionColor : Theme.color_blue
						readOnly: !root.editable
						selectByMouse: !readOnly
						validator: root.validator
						inputMethodHints: root.inputMethodHints

						onActiveFocusChanged: {
							if (activeFocus && Global.keyNavigationEnabled) {
								root.focusMode = VenusOS.SpinBox_FocusMode_Edit
							}
						}

						onAccepted: {
							// Note that the text may at this time represent a value out of SpinBox
							// to/from range, so clamp it here.
							let v = root.valueFromText(text, root.locale)
							if (v < root.from) {
								v = root.from
							} else if (v > root.to) {
								v = root.to
							}

							// Force-update the displayed text, to guarantee the text is in sync
							// with the numeric value, even if the value has not changed due to the
							// user entering an out-of-range value on consecutive attempts.
							text = root.textFromValue(v, root.locale)
							root.value = v

							primaryTextInput.focus = false
						}

						Keys.onEscapePressed: (event) => {
							// Restore the previous value and clear the focus.
							text = root.textFromValue(root.value, root.locale)
							primaryTextInput.focus = false
							if (Global.keyNavigationEnabled) {
								root.focusMode = VenusOS.SpinBox_FocusMode_Navigate
							}
							event.accepted = true
						}

						function updateText() {
							// Update the displayed text when the initial value is set or when
							// the up/down buttons are pressed.
							primaryTextInput.text = root.textFromValue(root.value, root.locale)
						}
					}

					Label {
						id: suffixLabel

						visible: text.length
						color: primaryTextInput.color
						font: primaryTextInput.font
						horizontalAlignment: primaryTextInput.horizontalAlignment
						verticalAlignment: primaryTextInput.verticalAlignment
					}
				}
			}

			Label {
				id: secondaryLabel

				height: text.length ? implicitHeight : 0
				color: Theme.color_font_secondary
				font.pixelSize: Theme.font_size_caption
				horizontalAlignment: Qt.AlignHCenter
			}
		}

		// Shows a highlight box around the text when key navigation is enabled and the SpinBox is
		// in navigation mode.
		KeyNavigationHighlight {
			id: navigationHighlight
			anchors.centerIn: parent
			width: primaryTextInputItem.width
			height: valueColumn.height
			active: Global.keyNavigationEnabled
					&& root.focusMode === VenusOS.SpinBox_FocusMode_Navigate
					&& parent.activeFocus
		}

		// Shows a box around the text when the SpinBox text can be edited directly (to indicate it
		// can be clicked) or when key navigation is enabled and the SpinBox is in edit mode (to
		// show up/down arrows indicating that the arrow keys can be used to change the value).
		EditFrame {
			anchors.fill: navigationHighlight
			visible: !navigationHighlight.visible
					&& (root.focusMode === VenusOS.SpinBox_FocusMode_Edit || root.editable)
			border.color: root.focusMode === VenusOS.SpinBox_FocusMode_Edit
				  ? Theme.color_focus_highlight
				  : Theme.color_blue
			arrowHintsVisible: root.focusMode === VenusOS.SpinBox_FocusMode_Edit
		}
	}

	up.indicator: Rectangle {
		x: orientation === Qt.Horizontal
		   ? parent.width - width
		   : contentItem.x + (contentItem.width / 2) - (width / 2)
		y: orientation === Qt.Horizontal
		   ? contentItem.y + (contentItem.height / 2) - (height / 2)
		   : contentItem.y - root.spacing
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry_spinBox_indicator_height
		radius: Theme.geometry_spinBox_indicator_radius
		color: enabled
			   ? (root.up.pressed ? Theme.color_button_down : Theme.color_button)
			   : Theme.color_background_disabled

		KeyNavigation.left: orientation === Qt.Horizontal ? root.contentItem : null
		KeyNavigation.down: orientation === Qt.Vertical ? root.contentItem : null
		Keys.onSpacePressed: {
			root.increase()
			if (!enabled) {
				// Ensure focus is not in limbo if the button becomes disabled
				root.contentItem.focus = true
			}
		}
		Keys.enabled: Global.keyNavigationEnabled

		KeyNavigationHighlight {
			anchors.fill: parent
			active: parent.activeFocus
		}

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
		   : contentItem.y + root.spacing + contentItem.height - height
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry_spinBox_indicator_height
		radius: Theme.geometry_spinBox_indicator_radius
		color: enabled
			   ? (root.down.pressed ? Theme.color_button_down : Theme.color_button)
			   : Theme.color_background_disabled

		KeyNavigation.right: orientation === Qt.Horizontal ? root.contentItem : null
		KeyNavigation.up: orientation === Qt.Vertical ? root.contentItem : null
		Keys.onSpacePressed: {
			root.decrease()
			if (!enabled) {
				// Ensure focus is not in limbo if the button becomes disabled
				root.contentItem.focus = true
			}
		}
		Keys.enabled: Global.keyNavigationEnabled

		KeyNavigationHighlight {
			anchors.fill: parent
			active: parent.activeFocus
		}

		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_minus.svg'
			opacity: root.enabled ? 1.0 : 0.4 // TODO add Theme opacity constants
		}
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
			up.pressed ? root.increase() : root.decrease()
		}
	}
}
