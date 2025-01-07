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
	property string caption: root.mode === VenusOS.ListLink_Mode_LinkButton ? ""
		  //: %1 = url text
		  //% "Scan the QR code with your portable device.<br />Or insert the link: %1"
		: qsTrId("listlink_scan_qr_code").arg(formattedUrl)
	readonly property string formattedUrl: "<font color=\"%1\">%2</font>".arg(Theme.color_font_primary).arg(url)

	readonly property int mode: Qt.platform.os == "wasm" ? VenusOS.ListLink_Mode_LinkButton : VenusOS.ListLink_Mode_QRCode

	down: pressArea.containsPress

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
			rotation: 180
			color: pressArea.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
		},

		Item {
			visible: root.mode === VenusOS.ListLink_Mode_QRCode
			width: Theme.geometry_listLink_qrCodeSize
			height: Theme.geometry_listLink_qrCodeSize + (2 * Theme.geometry_listItem_content_verticalMargin)

			Image {
				anchors.centerIn: parent
				source: root.mode === VenusOS.ListLink_Mode_QRCode
						? `image://QZXing/encode/${root.url}?correctionLevel=M&format=qrcode`
						: ""
				sourceSize.width: Theme.geometry_listLink_qrCodeSize
				sourceSize.height: Theme.geometry_listLink_qrCodeSize
			}
		}
	]

	bottomContentChildren: [
		PrimaryListLabel {
			font.pixelSize: Theme.font_size_body1
			horizontalAlignment: Text.AlignLeft
			color: Theme.color_listItem_secondaryText
			text: root.caption
			visible: root.mode === VenusOS.ListLink_Mode_QRCode
		}
	]

	ListPressArea {
		id: pressArea

		enabled: root.mode === VenusOS.ListLink_Mode_LinkButton
		radius: backgroundRect.radius
		anchors.fill: root.backgroundRect
		onClicked: {
			BackendConnection.openUrl(root.url)
		}
	}
}
