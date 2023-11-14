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
				topMargin: Theme.geometry.modalWarningDialog.alarmIcon.topMargin
				horizontalCenter: parent.horizontalCenter
			}

			sourceSize.width: Theme.geometry.modalWarningDialog.alarmIcon.width
			sourceSize.height: Theme.geometry.modalWarningDialog.alarmIcon.width
			source: "qrc:/images/icon_alarm_48.svg"
			color: Theme.color.red
		}

		Label {
			id: titleLabel
			anchors {
				top: alarmIcon.bottom
				topMargin: Theme.geometry.modalWarningDialog.title.spacing
				left: parent.left
				leftMargin: Theme.geometry.modalWarningDialog.title.horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry.modalWarningDialog.title.horizontalMargin
			}

			text: root.title
			font.pixelSize: Theme.font.size.h1
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			wrapMode: Text.Wrap
		}

		Label {
			id: consequencesLabel
			anchors {
				top: titleLabel.bottom
				topMargin: Theme.geometry.modalWarningDialog.description.spacing
				left: parent.left
				leftMargin: Theme.geometry.modalWarningDialog.description.horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry.modalWarningDialog.description.horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry.modalWarningDialog.description.spacing
			}

			horizontalAlignment: Text.AlignHCenter
			text: root.description
			font.pixelSize: Theme.font.size.body2
			wrapMode: Text.Wrap
			fontSizeMode: Text.Fit
		}
	}
}
