/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ModalDialog {
	id: root

	property string description

	dialogDoneOptions: Enums.ModalDialog_DoneOptions_OkOnly
	header: null

	contentItem: Item {
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			bottom: parent.footer.bottom
		}

		CP.IconImage {
			id: alarmIcon
			anchors {
				top: parent.top
				topMargin: Theme.geometry.modalWarningDialog.alarmIcon.topMargin
				horizontalCenter: parent.horizontalCenter
			}

			width: Theme.geometry.modalWarningDialog.alarmIcon.width
			height: width
			source: "qrc:/images/icon_alarm_48.svg"
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
			height: Theme.geometry.modalWarningDialog.title.height

			text: root.title
			font.pixelSize: Theme.font.size.xl
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
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
			font.pixelSize: Theme.font.size.m
			wrapMode: Text.Wrap
		}
	}
}
