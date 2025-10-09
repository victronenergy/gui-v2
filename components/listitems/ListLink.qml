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
	readonly property real _quietZoneFractionalSize: 0.3 // i.e. if a QR code (including quiet zone) is 100 px wide, the
	// quiet zone will be 30px wide, or 15px on each side.

	interactive: mode === VenusOS.ListLink_Mode_LinkButton

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

		Item {
			anchors.verticalCenter: parent.verticalCenter
			width: button.width
			height: button.height + 2 * Theme.geometry_listItem_content_verticalMargin
			visible: root.mode === VenusOS.ListLink_Mode_QRCode

			ListItemButton {
				id: button

				anchors.verticalCenter: parent.verticalCenter
				leftPadding: width * _quietZoneFractionalSize / 2
				rightPadding: leftPadding
				width: Theme.geometry_listLink_qrCodeSize
				height: width
				onClicked: Global.dialogLayer.open(largeQrCodeComponent)
				backgroundColor: Theme.color_white
				contentItem: Image {
					source: root.mode === VenusOS.ListLink_Mode_QRCode
							? `image://QZXing/encode/${root.url}?correctionLevel=M&format=qrcode`
							: ""
					sourceSize.width: Theme.geometry_listLink_qrCodeSize
					sourceSize.height: Theme.geometry_listLink_qrCodeSize
					fillMode: Image.PreserveAspectFit
				}
			}
		}
	]

	caption: root.mode === VenusOS.ListLink_Mode_LinkButton ? ""
															  //: %1 = url text
															  //% "Scan the QR code with your portable device.<br />Or insert the link: %1"
															: qsTrId("listlink_scan_qr_code").arg(formattedUrl)

	onClicked: BackendConnection.openUrl(root.url)

	Component {
		id: largeQrCodeComponent

		ModalDialog {
			id: dialog

			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions
			header: null
			contentItem: Rectangle {
				id: quietZone

				anchors.fill: parent

				Image {
					anchors.centerIn: parent
					objectName: "qrCodeImage"
					source: `image://QZXing/encode/${root.url}?correctionLevel=M&format=qrcode`
					sourceSize.width: quietZone.height * (1 - _quietZoneFractionalSize)
					sourceSize.height: sourceSize.width
					fillMode: Image.PreserveAspectFit
				}

				IconButton {
					anchors {
						right: parent.right
						top: parent.top
					}
					width: Theme.geometry_solarDailyHistoryDialog_closeButton_icon_size + (2 * Theme.geometry_solarDailyHistoryDialog_closeButton_icon_margins)
					height: Theme.geometry_solarDailyHistoryDialog_closeButton_icon_size + (2 * Theme.geometry_solarDailyHistoryDialog_closeButton_icon_margins)
					icon.sourceSize.height: Theme.geometry_solarDailyHistoryDialog_closeButton_icon_size
					icon.color: Theme.color_ok
					icon.source: "qrc:/images/icon_close_32.svg"
					onClicked: dialog.close()
				}
			}
		}
	}
}
