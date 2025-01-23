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
	property int _scalingFactor: 1
	property int _originalStepSize
	property alias suffix: suffixLabel.text

	signal maxValueReached()
	signal minValueReached()

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
		orientation === Qt.Horizontal
			? valueColumn.width + up.indicator.width + down.indicator.width + (2 * Theme.geometry_spinBox_spacing) + leftPadding + rightPadding
			: valueColumn.width + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
		orientation === Qt.Horizontal
			? Math.max(valueColumn.height, up.indicator.height, down.indicator.height) + topPadding + bottomPadding
			: valueColumn.height + up.indicator.height + down.indicator.height + (2 * Theme.geometry_spinBox_spacing) + topPadding + bottomPadding)

	spacing: Theme.geometry_spinBox_spacing
	onValueModified: {
		if (value === to) {
			root.maxValueReached()
		} else if (value === from) {
			root.minValueReached()
		}
	}

	contentItem: Item {

		// needed for QQuickSpinBoxPrivate to read the "text" property of the contentItem
		// so that it can call the valueFromText() function
		readonly property alias text: primaryTextInput.text

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

				Rectangle {
					anchors.fill: parent
					visible: root.editable
					color: "transparent"
					border.color: Theme.color_blue
					border.width: Theme.geometry_button_border_width
					radius: Theme.geometry_button_radius
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

						Connections {
							target: root
							function onValueChanged() {
								// Update the displayed text when the initial value is set or when
								// the up/down buttons are pressed.
								primaryTextInput.text = root.textFromValue(root.value, root.locale)
							}
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
	}

	up.indicator: Rectangle {
		x: orientation === Qt.Horizontal
		   ? parent.width - width
		   : contentItem.x + (contentItem.width / 2) - (width / 2)
		y: orientation === Qt.Horizontal
		   ? contentItem.y + (contentItem.height / 2) - (height / 2)
		   : contentItem.y + contentItem.height - height
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry_spinBox_indicator_height
		radius: Theme.geometry_spinBox_indicator_radius
		color: enabled
			   ? (root.up.pressed ? Theme.color_button_down : Theme.color_button)
			   : Theme.color_background_disabled

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
		   : contentItem.y
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry_spinBox_indicator_height
		radius: Theme.geometry_spinBox_indicator_radius
		color: enabled
			   ? (root.down.pressed ? Theme.color_button_down : Theme.color_button)
			   : Theme.color_background_disabled
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
