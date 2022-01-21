/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int newInputCurrentLimit

	signal setInputCurrentLimit(var newValue)

	//% "Input current limit"
	title: qsTrId("controlcard_input_current_limit")

	contentItem: Column {
		anchors.topMargin: 96
		anchors.top: parent.top
		width: parent.width
		spacing: 40

		SpinBox {
			id: spinbox

			anchors.horizontalCenter: parent.horizontalCenter
			width: 490
			height: 72
			//buttonWidth: 136
			stepSize: 100 // mA
			to: 1000000 // mA
			contentItem: Label {
				//% "%1 A"
				text: qsTrId("%1 A").arg(spinbox.value/1000)
				font.pixelSize: Theme.font.size.xxl
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
			}
			value: newInputCurrentLimit
			onValueChanged: newInputCurrentLimit = value
		}

		SegmentedButtonRow {
			anchors.horizontalCenter: parent.horizontalCenter
			model: [6, 10, 13, 16, 25, 32, 63] // TODO - these numbers will come from a list we get from DBus
			onButtonClicked: function (buttonIndex){
				currentIndex = buttonIndex
				newInputCurrentLimit = model[currentIndex] * 1000 // mA
				spinbox.value = model[currentIndex] * 1000 // mA
			}
		}
	}

	onAccepted: root.setInputCurrentLimit(newInputCurrentLimit)
}
