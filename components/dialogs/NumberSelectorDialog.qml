/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ModalDialog {
	id: root

	property real value
	property string suffix
	property int decimals

	property real from
	property real to
	property real stepSize
	property var stepSizeForValue: null
	property var presets: []

	// Error text shown when user tries to set a value < from or > to.
	property string fromErrorText
	property string toErrorText

	property var customIncrease: null

	function _presetIndexForValue(v) {
		const epsilon = 0.0001
		const valueAsNumber = Number(v)
		for (let i = 0; i < presets.length; ++i) {
			const presetValue = Number(presets[i].value)
			if (!isNaN(presetValue) && !isNaN(valueAsNumber)) {
				if (Math.abs(presetValue - valueAsNumber) <= epsilon * Math.max(1, Math.abs(presetValue), Math.abs(valueAsNumber))) {
					return i
				}
			} else if (presets[i].value === v) {
				return i
			}
		}
		return -1
	}

	onAboutToShow: {
		if (presets.length) {
			presetsRow.currentIndex = root._presetIndexForValue(value)
		}
	}

	contentItem: ModalDialog.FocusableContentItem {
		id: dialogContent

		function valueModified() {
			root.value = decimalConverter.intToDecimal(spinBox.value)
		}

		implicitHeight: contentLayout.implicitHeight

		ColumnLayout {
			id: contentLayout

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_modalDialog_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_modalDialog_content_horizontalMargin
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: -Theme.geometry_numberSelector_spinBox_bottomPadding / 2
			}
			spacing: Theme.geometry_modalDialog_content_spacing

			// Show error label above the spinbox, as items below it may be obscured by the VKB.
			Label {
				id: errorLabel

				leftPadding: alarmIcon.width +  Theme.geometry_modalWarningDialog_description_spacing
				visible: errorLabel.text.length > 0
				font.pixelSize: Theme.font_dialog_body_secondary_size
				wrapMode: Text.Wrap

				Layout.fillWidth: true

				CP.IconImage {
					id: alarmIcon
					anchors.verticalCenter: parent.verticalCenter
					source: "qrc:/images/icon_alarm_32.svg"
					color: Theme.color_red
				}
			}

			SpinBox {
				id: spinBox

				width: parent.width
				height: Theme.geometry_timeSelector_spinBox_height
				editable: true
				indicatorImplicitWidth: implicitContentWidth
						+ (2 * Theme.geometry_textField_horizontalMargin) + (2 * spinBox.spacing)
						+ (2 * Theme.geometry_spinBox_indicator_maximumWidth)
							> root.implicitBackgroundWidth
						? Theme.geometry_spinBox_indicator_minimumWidth
						: Theme.geometry_spinBox_indicator_maximumWidth
				suffix: root.suffix
				from: decimalConverter.intFrom
				to: decimalConverter.intTo
				stepSize: decimalConverter.intStepSize
				stepSizeForValue: (v, increasing) => {
					if (!root.stepSizeForValue) {
						return spinBox.stepSize
					}
					// At this point, the value we receive will be "decimal converter scaled"
					// whereas the CurrentLimitDialog does pure value comparison in its
					// stepSizeForValue implementation.  So, we need to convert the
					// scaled value into a raw value, ask the root implementation what
					// the step size should be, and then scale that step size up appropriately.
					const decimalValue = decimalConverter.intToDecimal(v)
					const decimalStepSize = root.stepSizeForValue(decimalValue, increasing)
					return decimalConverter.decimalToInt(decimalStepSize)
				}
				value: decimalConverter.decimalToInt(root.value)
				textFromValue: (value, locale) => decimalConverter.textFromValue(value)
				valueFromText: (text, locale) => {
					const v = decimalConverter.valueFromText(text)
					return isNaN(v) ? decimalConverter.decimalToInt(root.value) : v // if invalid, use the previous value
				}
				updateValueTo: (v, text) => {
					// Manually set the root value from the text,
					// rather than attempting to determine the appropriate next
					// spinbox value for the given text (as SpinBoxInputArea does),
					// because the text value might be associated with
					// a different number of decimals than the current spinbox value.
					let value = Units.formattedNumberToReal(text)
					if (isNaN(value)) {
						// don't change the current value
						value = root.value
					} else if (value < root.from) {
						spinBox.decreaseFailed()
						value = root.from
					} else if (value > root.to) {
						spinBox.increaseFailed()
						value = root.to
					}
					root.value = value
				}
				customIncrease: root.customIncrease

				// Use BeforeItem priority to override the default key Spinbox event handling, else
				// up/down keys will modify the number even when SpinBox is not in "edit" mode.
				focus: true
				KeyNavigation.priority: KeyNavigation.BeforeItem
				KeyNavigation.up: spinBox
				KeyNavigation.down: presetsRow.enabled ? presetsRow : root.footer

				Layout.fillWidth: true

				onValueModified: {
					dialogContent.valueModified()
				}
				onDecreaseFailed: {
					if (root.fromErrorText) {
						errorLabel.text = root.fromErrorText
						errorLabel.opacity = 1
						errorTimeout.restart()
					}
				}
				onIncreaseFailed: {
					if (root.toErrorText) {
						errorLabel.text = root.toErrorText
						errorLabel.opacity = 1
						errorTimeout.restart()
					}
				}

				Timer {
					id: errorTimeout
					interval: 3000
					onTriggered: errorLabel.opacity = 0
				}

				SpinBoxDecimalConverter {
					id: decimalConverter

					decimals: root.decimals
					from: root.from
					to: root.to
					stepSize: root.stepSize
				}
			}

			SegmentedButtonRow {
				id: presetsRow

				showBorderWhenDisabled: true
				model: root.presets
				visible: model.length > 0
				enabled: visible
				onButtonClicked: function (buttonIndex) {
					root.value = model[buttonIndex].value
				}

				property real rootValue: root.value
				onRootValueChanged: {
					presetsRow.currentIndex = root._presetIndexForValue(rootValue)
				}

				KeyNavigation.down: root.footer
				Layout.fillWidth: true
			}
		}
	}
}
