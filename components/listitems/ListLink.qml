/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property string url
	readonly property string formattedUrl: "<font color=\"%1\">%2</font>".arg(Theme.color_font_primary).arg(url)
	readonly property int mode: Qt.platform.os == "wasm" ? VenusOS.ListLink_Mode_LinkButton : VenusOS.ListLink_Mode_QRCode

	interactive: true

	content.children: [
		SecondaryListLabel {
			visible: root.mode === VenusOS.ListLink_Mode_LinkButton
			anchors.verticalCenter: parent.verticalCenter
			width: Math.min(implicitWidth, root.maximumContentWidth - icon.width - root.content.spacing)
			//% "Open link"
			text: qsTrId("listlink_open_link")
		},

		CP.ColorImage {
			id: icon

			visible: root.mode === VenusOS.ListLink_Mode_LinkButton
			anchors.verticalCenter: parent.verticalCenter
			source: "qrc:/images/icon_open_link_32.svg"
			color: root.down ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
		},

		ListItemButton {
			id: button

			visible: root.mode === VenusOS.ListLink_Mode_QRCode
			focusPolicy: Qt.NoFocus
			//% "Show QR code"
			text: qsTrId("listlink_show_qr_code")

			onClicked: Global.dialogLayer.open(largeQrCodeComponent)
		}
	]

	caption: root.mode === VenusOS.ListLink_Mode_LinkButton ? ""
		  //: %1 = url text
		  //% "Open the QR code to scan it with your portable device.<br />Or insert the link: %1"
		: qsTrId("listlink_scan_qr_code").arg(formattedUrl)

	onClicked: {
		if (mode === VenusOS.ListLink_Mode_LinkButton) {
			BackendConnection.openUrl(root.url)
		} else {
			Global.dialogLayer.open(largeQrCodeComponent)
		}
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
					source: `image://QZXing/encode/${root.url}?correctionLevel=M&format=qrcode`
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
