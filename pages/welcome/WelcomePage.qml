/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Rectangle {
	id: root

	property string imageUrl
	property string qrCodeUrl
	property string title
	property string text
	property bool backButtonEnabled
	property string nextButtonText

	signal backClicked
	signal nextClicked

	width: Theme.geometry_screen_width
	height: Theme.geometry_screen_height - Theme.geometry_statusBar_height
	color: Theme.color_page_background    

	Image {
		id: image
		source: root.imageUrl
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_page_content_horizontalMargin
			top: parent.top
			topMargin: Theme.geometry_page_content_verticalMargin
			bottom: parent.bottom
			bottomMargin: Theme.geometry_page_content_verticalMargin
		}
		fillMode: Image.PreserveAspectFit
	}

	ColumnLayout {
		id: column
		anchors {
			left: image.right
			leftMargin: Theme.geometry_page_content_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_page_content_horizontalMargin
			top: image.top
			bottom: image.bottom
		}
		spacing: 0

		Label {
			Layout.fillWidth: true
			bottomPadding: Theme.geometry_welcome_title_bottomMargin
			wrapMode: Text.Wrap
			text: root.title
			font.pixelSize: Theme.font_size_h1
		}

		Label {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.verticalStretchFactor: root.qrCodeUrl ? -1 : 1
			wrapMode: Text.Wrap
			text: root.text
			onLinkActivated: (linkText) => {
				BackendConnection.openUrl(linkText)
			}
		}

		Image {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.minimumHeight: 100
			Layout.maximumHeight: 200
			Layout.verticalStretchFactor: root.qrCodeUrl ? 1 : -1
			Layout.topMargin: Theme.geometry_page_content_horizontalMargin
			Layout.bottomMargin: Theme.geometry_page_content_horizontalMargin
			horizontalAlignment: Image.AlignLeft
			fillMode: Image.PreserveAspectFit
			source: root.qrCodeUrl
		}

		RowLayout {
			Layout.fillWidth: true
			Layout.preferredHeight: Theme.geometry_listItem_height
			spacing: Theme.geometry_welcome_button_spacing

			Button {
				Layout.fillWidth: true
				Layout.preferredHeight: Theme.geometry_listItem_height
				//% "Back"
				text: qsTrId("welcome_page_back")
				color: enabled ? Theme.color_white : Theme.color_font_secondary
				backgroundColor: enabled ? Theme.color_ok : Theme.color_radioButton_indicator_off
				enabled: root.backButtonEnabled
				onClicked: root.backClicked()
			}

			Button {
				Layout.fillWidth: true
				Layout.preferredHeight: Theme.geometry_listItem_height
				text: root.nextButtonText
				color: Theme.color_white
				backgroundColor: Theme.color_ok
				onClicked: root.nextClicked()
			}
		}
	}
}
