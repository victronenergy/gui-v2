/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ModalDialog {
	id: root

	property string description
	property alias icon: alarmIcon

	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
	header: null

	// Since there are no focusable UI controls in the contentItem, give the initial focus to the
	// footer.
	footer.focus: true

	contentItem: Column {
		topPadding: Theme.geometry_modalDialog_header_height
		bottomPadding: Theme.geometry_modalDialog_header_height
		spacing: Theme.geometry_modalDialog_content_spacing

		CP.IconImage {
			id: alarmIcon
			anchors.horizontalCenter: parent.horizontalCenter
			source: "qrc:/images/icon_alarm_48.svg"
			color: Theme.color_red
		}

		Label {
			id: titleLabel
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_page_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_page_content_horizontalMargin
			}
			text: root.title
			font.pixelSize: Theme.font_dialog_title_size
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			wrapMode: Text.Wrap
		}

		Label {
			id: consequencesLabel
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_page_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_page_content_horizontalMargin
			}
			horizontalAlignment: Text.AlignHCenter
			text: root.description
			font.pixelSize: Theme.font_dialog_body_size
			wrapMode: Text.Wrap
		}
	}
}
