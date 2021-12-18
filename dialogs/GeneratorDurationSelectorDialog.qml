/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ModalDialog {
	id: root

	property int duration

	//% "Duration"
	titleText: qsTrId("controlcard_generator_durationselectordialog_title")

	contentItem: Item {
		anchors {
			top: parent.top
			topMargin: 100
			bottom: parent.footer.top
		}

		Label {
			id: hrLabel
			anchors {
				top: parent.top
				horizontalCenter: hrSpinbox.horizontalCenter
			}

			//% "hr"
			text: qsTrId("controlcard_generator_durationselectordialog_hr")
			color: Theme.secondaryFontColor
		}

		Label {
			id: minLabel
			anchors {
				top: parent.top
				horizontalCenter: minSpinbox.horizontalCenter
			}

			//% "min"
			text: qsTrId("controlcard_generator_durationselectordialog_min")
			color: Theme.secondaryFontColor
		}

		SpinBox {
			id: hrSpinbox
			anchors {
				top: hrLabel.bottom
				topMargin: 10
				right: parent.horizontalCenter
				rightMargin: 24
			}

			width: 238
			height: 72
			from: 0
			to: 59
			label.text: Utils.pad(value, 2)
		}

		Label {
			id: colonLabel
			anchors {
				verticalCenter: hrSpinbox.verticalCenter
				horizontalCenter: parent.horizontalCenter
			}

			text: ":"
			color: Theme.secondaryFontColor
			font.pixelSize: Theme.fontSizeExtraLarge
		}

		SpinBox {
			id: minSpinbox
			anchors {
				top: minLabel.bottom
				topMargin: 10
				left: parent.horizontalCenter
				leftMargin: 24
			}

			width: 238
			height: 72
			from: 0
			to: 59
			label.text: Utils.pad(value, 2)
		}
	}

	onAccepted: duration = Utils.composeDuration(hrSpinbox.value, minSpinbox.value)
}
