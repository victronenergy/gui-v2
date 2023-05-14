/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property real currentLimit  // in amps
	property alias ampOptions: buttonRow.model

	onAboutToShow: {
		spinbox.value = currentLimit * 1000 // A -> mA

		let ampOptionsIndex = -1
		for (let i = 0; i < ampOptions.length; ++i) {
			if (ampOptions[i].value === currentLimit) {
				ampOptionsIndex = i
				break
			}
		}
		buttonRow.currentIndex = ampOptionsIndex
	}

	contentItem: Item {
		anchors {
			left: parent.left
			right: parent.right
			top: parent.header.bottom
			bottom: parent.footer.top
		}

		Column {
			id: contentColumn

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width

			spacing: Theme.geometry.modalDialog.content.spacing

			SpinBox {
				id: spinbox

				width: parent.width - 2*Theme.geometry.modalDialog.content.horizontalMargin
				anchors.horizontalCenter: parent.horizontalCenter
				stepSize: 100 // mA
				to: 1000000 // mA
				indicatorImplicitWidth: Theme.geometry.spinBox.indicator.maximumWidth
				//% "%1 A"
				label.text: qsTrId("inverter_current_limit_value").arg(spinbox.value/1000)  // TODO use UnitConverter.convertToString() or unitToString() instead
				onValueChanged: root.currentLimit = value / 1000    // mA -> A
			}

			SegmentedButtonRow {
				id: buttonRow

				width: spinbox.width
				anchors.horizontalCenter: parent.horizontalCenter
				onButtonClicked: function (buttonIndex){
					currentIndex = buttonIndex
					spinbox.value = model[buttonIndex].value * 1000 // A -> ma
				}
			}
		}
	}
}
