/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
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

	signal maxValueReached()
	signal minValueReached()

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

		Column {
			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: -Theme.geometry_modalDialog_content_margins
			}
			width: parent.width
			spacing: Theme.geometry_modalDialog_content_spacing

			SpinBox {
				id: spinBox

				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - 2*Theme.geometry_modalDialog_content_horizontalMargin
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
				onMinValueReached: root.minValueReached()
				onMaxValueReached: root.maxValueReached()

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

				width: spinBox.width
				anchors.horizontalCenter: parent.horizontalCenter
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
