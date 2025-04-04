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

	function _multiplier() {
		return Math.pow(10, decimals)
	}

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
		Column {
			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: -Theme.geometry_modalDialog_content_margins
			}
			width: parent.width
			spacing: Theme.geometry_modalDialog_content_spacing

			SpinBox {
				id: spinBox

				property bool _initialized: false

				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - 2*Theme.geometry_modalDialog_content_horizontalMargin
				height: Theme.geometry_timeSelector_spinBox_height
				editable: true
				indicatorImplicitWidth: root.decimals > 0
						? Theme.geometry_spinBox_indicator_minimumWidth
						: Theme.geometry_spinBox_indicator_maximumWidth
				textFromValue: function(value, locale) {
					return Units.formatNumber(value / root._multiplier(), root.decimals)
				}
				valueFromText: function(text, locale) {
					let value = Units.formattedNumberToReal(text) * root._multiplier()
					if (isNaN(value)) {
						// don't change the current value
						value = spinBox.value
					}
					return value
				}
				from: Math.max(Global.int32Min, root.from * root._multiplier())
				to: Math.min(Global.int32Max, root.to * root._multiplier())
				stepSize: root.stepSize * root._multiplier()
				suffix: root.suffix

				// Use BeforeItem priority to override the default key Spinbox event handling, else
				// up/down keys will modify the number even when SpinBox is not in "edit" mode.
				focus: true
				KeyNavigation.priority: KeyNavigation.BeforeItem
				KeyNavigation.up: spinBox
				KeyNavigation.down: presetsRow.enabled ? presetsRow : root.footer

				onValueChanged: {
					if (_initialized) {
						root.value = Number(spinBox.value / root._multiplier())
						presetsRow.currentIndex = -1
					}
				}

				onMinValueReached: root.minValueReached()
				onMaxValueReached: root.maxValueReached()
				Component.onCompleted: {
					spinBox.value = Math.round(root.value * root._multiplier())
					_initialized = true
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
					spinBox.value = model[buttonIndex].value * root._multiplier()
				}

				KeyNavigation.down: root.footer
			}
		}
	}
}
