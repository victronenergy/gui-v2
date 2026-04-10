/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListSetting {
	id: root

	property string qrData

	function click() {
		if (root.clickable) {
			Global.dialogLayer.open(largeQrCodeComponent)
		}
	}

	interactive: true

	writeAccessLevel: VenusOS.User_AccessType_User

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelsColumn.height

		ColumnLayout {
			id: labelsColumn

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
				   - button.width
				   - root.spacing
			spacing: Theme.geometry_listItem_content_verticalSpacing

			Label {
				width: parent.width
				text: root.text
				textFormat: root.textFormat
				font: root.font
				wrapMode: Text.Wrap

				Layout.fillWidth: true
			}

			CaptionLabel {
				width: parent.width
				text: root.caption
				visible: text.length > 0

				Layout.fillWidth: true
			}
		}

		ListItemButton {
			id: button

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}

			//% "Show QR code"
			text: qsTrId("listlink_show_qr_code")
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
