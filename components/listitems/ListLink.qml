/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

/*
	A list setting item with a URL link.

	The UI is different on Wasm compared to other platforms.

	On Wasm:
	- Shows "Open link" on the right
	- When the item is clicked, a new browser window is opened with the link.

	On other platforms:
	- A "Show QR code" button is shown on the right; when clicked, opens a dialog with the QR code
	for the URL.
	- The default caption directs the user to open the QR code dialog.
*/
ListSetting {
	id: root

	property int mode: Qt.platform.os === "wasm" ? VenusOS.ListLink_Mode_LinkButton : VenusOS.ListLink_Mode_QRCode
	property string url
	readonly property string formattedUrl: "<font color=\"%1\">%2</font>".arg(Theme.color_font_primary).arg(url)

	function click() {
		if (root.clickable) {
			if (root.mode === VenusOS.ListLink_Mode_LinkButton) {
				BackendConnection.openUrl(root.url)
			} else {
				Global.dialogLayer.open(largeQrCodeComponent)
			}
		}
	}

	interactive: true

	// By default, allow user-level access to click the button. The button/link simply opens a web
	// page or the QR code dialog, so there is no destructive behaviour involved.
	writeAccessLevel: VenusOS.User_AccessType_User

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.isMultiLine ? contentLayout.implicitHeight : 0

		TwoLabelItemLayout {
			id: contentLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			captionText: root.caption
			secondaryComponent: root.mode === VenusOS.ListLink_Mode_LinkButton ? linkButtonComponent : qrCodeComponent

			Component {
				id: linkButtonComponent

				SecondaryListLabel {
					//% "Open link"
					text: qsTrId("listlink_open_link")
					rightPadding: arrowIcon.width + root.spacing

					CP.ColorImage {
						id: arrowIcon

						anchors {
							right: parent.right
							verticalCenter: parent.verticalCenter
						}
						source: "qrc:/images/icon_open_link_32.svg"
						color: Theme.color_listItem_forwardIcon
					}
				}
			}

			Component {
				id: qrCodeComponent

				ListItemButton {
					//% "Show QR code"
					text: qsTrId("listlink_show_qr_code")
					down: root.clickable && (pressed || checked)
					enabled: root.clickable
					focusPolicy: Qt.NoFocus

					onClicked: root.click()
				}
			}
		}
	}

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor

		ListPressArea {
			anchors.fill: parent
			enabled: root.interactive && root.mode === VenusOS.ListLink_Mode_LinkButton
			onClicked: root.click()
		}
	}

	caption: root.mode === VenusOS.ListLink_Mode_LinkButton ? ""
		  //: %1 = url text
		  //% "Open the QR code to scan it with your portable device.<br />Or insert the link: %1"
		: qsTrId("listlink_scan_qr_code").arg(formattedUrl)

	Keys.onSpacePressed: click()

	Component {
		id: largeQrCodeComponent

		ModalDialog {
			id: dialog

			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions
			header: null
			footer: null
			backgroundColor: Theme.color_white // provide start contrast to QR code image
			contentItem: Item {
				id: quietZone

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
						rightMargin: Theme.geometry_modalDialog_content_spacing
					}
					onClicked: dialog.close()
				}
			}
		}
	}
}
