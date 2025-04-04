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
	property alias descriptionLabel: consequencesLabel

	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
	header: null

	// Since there are no focusable UI controls in the contentItem, give the initial focus to the
	// footer.
	footer.focus: true

	contentItem: Item {
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			bottom: parent.footer.top
		}

		CP.IconImage {
			id: alarmIcon
			anchors {
				top: parent.top
				topMargin: Theme.geometry_modalWarningDialog_alarmIcon_topMargin
				horizontalCenter: parent.horizontalCenter
			}

			sourceSize.width: Theme.geometry_modalWarningDialog_alarmIcon_width
			sourceSize.height: Theme.geometry_modalWarningDialog_alarmIcon_width
			source: "qrc:/images/icon_alarm_48.svg"
			color: Theme.color_red
		}

		Label {
			id: titleLabel
			anchors {
				top: alarmIcon.bottom
				topMargin: Theme.geometry_modalWarningDialog_title_spacing
				left: parent.left
				leftMargin: Theme.geometry_modalWarningDialog_title_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_modalWarningDialog_title_horizontalMargin
			}

			text: root.title
			font.pixelSize: Theme.font_size_h1
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			wrapMode: Text.Wrap
		}

		Label {
			id: consequencesLabel
			anchors {
				top: titleLabel.bottom
				topMargin: Theme.geometry_modalWarningDialog_description_spacing
				left: parent.left
				leftMargin: Theme.geometry_modalWarningDialog_description_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_modalWarningDialog_description_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_modalWarningDialog_description_spacing
			}

			horizontalAlignment: Text.AlignHCenter
			text: root.description
			font.pixelSize: Theme.font_size_body2
			wrapMode: Text.Wrap
			fontSizeMode: Text.Fit
		}
	}
}
