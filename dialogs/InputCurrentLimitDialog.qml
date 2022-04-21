/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int currentLimit
	property int inputType
	property int inputIndex
	property alias ampOptions: buttonRow.model

	function currentLimitText(type) {
		switch (type) {
		case Enums.Inverters_InputType_Grid:
			//% "Grid current limit"
			return qsTrId("inverter_current_limit_grid")
		case Enums.Inverters_InputType_Generator:
			//% "Generator current limit"
			return qsTrId("inverter_current_limit_generator")
		case Enums.Inverters_InputType_Shore:
			//% "Shore current limit"
			return qsTrId("inverter_current_limit_shore")
		default:
			return ""
		}
	}

	title: currentLimitText(inputType)

	contentItem: Column {
		id: contentColumn

		anchors.topMargin: Theme.geometry.modalDialog.content.topMargin
		anchors.top: root.header.bottom
		spacing: Theme.geometry.modalDialog.content.spacing

		SpinBox {
			id: spinbox

			width: parent.width - 2*Theme.geometry.modalDialog.content.horizontalMargin
			anchors.horizontalCenter: parent.horizontalCenter
			stepSize: 100 // mA
			to: 1000000 // mA
			contentItem: Label {
				//% "%1 A"
				text: qsTrId("%1 A").arg(spinbox.value/1000)
				font.pixelSize: Theme.font.size.xxl
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
			}
			value: root.currentLimit
			onValueChanged: root.currentLimit = value
		}

		SegmentedButtonRow {
			id: buttonRow

			width: spinbox.width
			anchors.horizontalCenter: parent.horizontalCenter
			onButtonClicked: function (buttonIndex){
				currentIndex = buttonIndex
				root.currentLimit = model[currentIndex] * 1000 // mA
				spinbox.value = model[currentIndex] * 1000 // mA
			}
		}
	}
}
