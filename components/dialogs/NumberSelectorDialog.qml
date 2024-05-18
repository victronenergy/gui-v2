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

	property int from
	property int to
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

	contentItem: Item {
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
				indicatorImplicitWidth: root.decimals > 0
						? Theme.geometry_spinBox_indicator_minimumWidth
						: Theme.geometry_spinBox_indicator_maximumWidth
				textFromValue: function(value, locale) {
					return Units.formatNumber(value / root._multiplier(), root.decimals) + root.suffix
				}
				from: root.from * root._multiplier()
				to: root.to * root._multiplier()
				stepSize: root.stepSize * root._multiplier()

				onValueChanged: {
					if (_initialized) {
						root.value = Number(spinBox.value / root._multiplier())
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
				onButtonClicked: function (buttonIndex) {
					currentIndex = buttonIndex
					spinBox.value = model[buttonIndex].value * root._multiplier()
				}
			}
		}
	}
}
