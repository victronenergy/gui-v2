/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
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
	property var presets: []

	// Error text shown when user tries to set a value < from or > to.
	property string fromErrorText
	property string toErrorText

	onAboutToShow: {
		if (presets.length) {
			let presetsIndex = -1
			for (let i = 0; i < presets.length; ++i) {
				if (presets[i].value === value) {
					presetsIndex = i
					break
				}
			}
			presetsRow.currentIndex = presetsIndex
		}
	}

	contentItem: ModalDialog.FocusableContentItem {
		id: dialogContent

		function valueModified() {
			root.value = decimalConverter.intToDecimal(spinBox.value)
		}

		// Show error label above the spinbox, as items below it may be obscured by the VKB.
		Label {
			id: errorLabel

			anchors {
				bottom: spinBoxColumn.top
				bottomMargin: Theme.geometry_modalWarningDialog_description_spacing
				horizontalCenter: parent.horizontalCenter
			}
			width: Math.min(implicitWidth, spinBoxColumn.width)
			leftPadding: alarmIcon.width +  Theme.geometry_modalWarningDialog_description_spacing
			opacity: errorLabel.text.length > 0 ? 1 : 0
			wrapMode: Text.Wrap

			Behavior on opacity {
				NumberAnimation { easing.type: Easing.InOutQuad }
			}

			CP.IconImage {
				id: alarmIcon
				anchors.verticalCenter: parent.verticalCenter
				source: "qrc:/images/icon_alarm_32.svg"
				color: Theme.color_red
			}
		}

		Column {
			id: spinBoxColumn

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_modalDialog_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_modalDialog_content_horizontalMargin
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: -Theme.geometry_modalDialog_content_margins
			}
			width: parent.width
			spacing: Theme.geometry_modalDialog_content_margins

			SpinBox {
				id: spinBox

				width: parent.width
				height: Theme.geometry_timeSelector_spinBox_height
				editable: true
				indicatorImplicitWidth: root.decimals > 0
						? Theme.geometry_spinBox_indicator_minimumWidth
						: Theme.geometry_spinBox_indicator_maximumWidth
				suffix: root.suffix
				from: decimalConverter.intFrom
				to: decimalConverter.intTo
				stepSize: decimalConverter.intStepSize
				value: decimalConverter.decimalToInt(root.value)
				textFromValue: (value, locale) => decimalConverter.textFromValue(value)
				valueFromText: (text, locale) => {
					const v = decimalConverter.valueFromText(text)
					return isNaN(v) ? decimalConverter.decimalToInt(root.value) : v // if invalid, use the previous value
				}

				// Use BeforeItem priority to override the default key Spinbox event handling, else
				// up/down keys will modify the number even when SpinBox is not in "edit" mode.
				focus: true
				KeyNavigation.priority: KeyNavigation.BeforeItem
				KeyNavigation.up: spinBox
				KeyNavigation.down: presetsRow.enabled ? presetsRow : root.footer

				onValueModified: {
					dialogContent.valueModified()
					presetsRow.currentIndex = -1
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

				width: parent.width
				model: root.presets
				visible: model.length > 0
				enabled: visible
				onButtonClicked: function (buttonIndex) {
					spinBox.value = decimalConverter.decimalToInt(model[buttonIndex].value)
					dialogContent.valueModified()
				}

				KeyNavigation.down: root.footer
			}
		}
	}
}
