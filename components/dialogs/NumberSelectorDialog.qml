/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Utils

ModalDialog {
	id: root

	property real value
	property string suffix
	property int decimals

	property int from
	property int to
	property alias stepSize: spinBox.stepSize
	property var presets: []

	signal maxValueReached()
	signal minValueReached()

	function _multiplier() {
		return Math.pow(10, decimals)
	}

	onAboutToShow: {
		spinBox.value = value * _multiplier()

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
		anchors {
			top: parent.header.bottom
			bottom: parent.footer.top
			left: parent.left
			right: parent.right
		}

		Column {
			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
			spacing: Theme.geometry.modalDialog.content.spacing

			SpinBox {
				id: spinBox

				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - 2*Theme.geometry.modalDialog.content.horizontalMargin
				height: Theme.geometry.timeSelector.spinBox.height
				indicatorImplicitWidth: Theme.geometry.spinBox.indicator.maximumWidth
				textFromValue: function(value, locale) {
					return Number(value / root._multiplier()).toLocaleString(locale, 'f', root.decimals) + root.suffix
				}
				from: root.from * root._multiplier()
				to: root.to * root._multiplier()

				onValueChanged: {
					root.value = Number(value / root._multiplier())
				}

				onMinValueReached: root.minValueReached()
				onMaxValueReached: root.maxValueReached()
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
