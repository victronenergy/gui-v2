/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ModalDialog {
	id: root

	property real value
	property string suffix
	property int decimals

	property int from
	property int to
	property alias stepSize: spinBox.stepSize

	signal maxValueReached()
	signal minValueReached()

	function _multiplier() {
		return Math.pow(10, decimals)
	}

	onAboutToShow: {
		spinBox.value = value * _multiplier()
	}

	contentItem: Item {
		anchors {
			top: parent.header.bottom
			bottom: parent.footer.top
			left: parent.left
			right: parent.right
		}

		SpinBox {
			id: spinBox

			anchors {
				centerIn: parent
				verticalCenterOffset: -Theme.geometry.modalDialog.header.title.topMargin
			}
			width: parent.width - 2*Theme.geometry.modalDialog.content.horizontalMargin
			height: Theme.geometry.timeSelector.spinBox.height
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
	}
}
