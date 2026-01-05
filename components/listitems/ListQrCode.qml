/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property string qrData
	property string caption

	interactive: true

	content.children: [

		ListItemButton {
			id: button

			focusPolicy: Qt.NoFocus
			//% "Show QR code"
			text: qsTrId("listlink_show_qr_code")

			onClicked: Global.dialogLayer.open(largeQrCodeComponent)
		}
	]

	caption: caption ?? ""

	onClicked: {
		Global.dialogLayer.open(largeQrCodeComponent)
	}

	Component {
		id: largeQrCodeComponent

		ModalDialog {
			id: dialog

			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions
			closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
			header: null
			contentItem: Rectangle {
				id: quietZone

				anchors.fill: parent

				Image {
					// i.e. if a QR code (including quiet zone) is 100 px wide, the
					// quiet zone will be 30px wide, or 15px on each side.
					readonly property real _quietZoneFractionalSize: 0.3
					readonly property int qrCodeSize: quietZone.height * (1 - _quietZoneFractionalSize)

					anchors.centerIn: parent
					source: `image://QZXing/encode/${root.qrData}?correctionLevel=M&format=qrcode`
					sourceSize: Qt.size(qrCodeSize, qrCodeSize)
					fillMode: Image.PreserveAspectFit
				}

				CloseButton {
					anchors {
						right: parent.right
						top: parent.top
					}
					onClicked: dialog.close()
				}
			}
		}
	}
}
