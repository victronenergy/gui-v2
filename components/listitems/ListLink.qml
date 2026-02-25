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

	property string url
	readonly property string formattedUrl: "<font color=\"%1\">%2</font>".arg(Theme.color_font_primary).arg(url)

	function click() {
		if (root.clickable) {
			if (Qt.platform.os === "wasm") {
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

	// Use an Item instead of a layout, so that the button doesn't stretch the height of the
	// content.
	// Standard layout is:
	// | Primary label | "Open link" or button (spans across both rows) |
	// | Caption       |                                                |
	//
	// In Portrait layout, if there is a caption, then do this instead:
	// | Primary label | "Open link" or button (spans across both rows) |
	// | Caption                                                        |                                            |
	contentItem: Item {
		readonly property bool stretchCaption: Theme.screenSize === Theme.Portrait
				&& root.caption.length > 0

		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: captionLabel.y + (root.caption.length ? captionLabel.height : 0)

		Label {
			id: primaryLabel

			width: parent.width - (linkLabel.visible ? linkLabel.width : button.width) - root.spacing
			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap
		}

		Label {
			id: captionLabel

			y: parent.stretchCaption
			   ? Math.max(primaryLabel.y + primaryLabel.height,
						linkLabel.visible ? linkLabel.y + linkLabel.height : button.y + button.height)
			   : primaryLabel.y + primaryLabel.height
			topPadding: Theme.geometry_listItem_content_verticalSpacing
			width: parent.stretchCaption ? parent.width : primaryLabel.width
			text: root.caption
			font.pixelSize: Theme.font_listItem_caption_size
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0
		}

		SecondaryListLabel {
			id: linkLabel

			anchors {
				right: parent.right
				verticalCenter: parent.stretchCaption ? primaryLabel.verticalCenter : parent.verticalCenter
			}

			//% "Open link"
			text: qsTrId("listlink_open_link")
			visible: Qt.platform.os === "wasm"
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

		ListItemButton {
			id: button

			anchors {
				right: parent.right
				verticalCenter: parent.stretchCaption ? primaryLabel.verticalCenter : parent.verticalCenter
			}

			//% "Show QR code"
			text: qsTrId("listlink_show_qr_code")
			visible: Qt.platform.os !== "wasm"
			down: root.clickable && (pressed || checked)
			enabled: root.clickable
			focusPolicy: Qt.NoFocus

			onClicked: root.click()
		}
	}

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor

		ListPressArea {
			anchors.fill: parent
			enabled: root.interactive && Qt.platform.os === "wasm"
			onClicked: root.click()
		}
	}

	caption: Qt.platform.os === "wasm" ? ""
		  //: %1 = url text
		  //% "Open the QR code to scan it with your portable device.<br />Or insert the link: %1"
		: qsTrId("listlink_scan_qr_code").arg(formattedUrl)

	Keys.onSpacePressed: click()

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
