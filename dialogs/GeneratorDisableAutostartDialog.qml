/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ModalDialog {
	id: root

	dialogDoneOptions: ModalDialog.DialogDoneOptions.OkAndCancel

	contentItem: Item {
		anchors {
			top: parent.top
			bottom: parent.footer.bottom
		}
		
		width: parent.width

		CP.IconImage {
			id: alarmIcon
			anchors {
				top: parent.top
				topMargin: 44
				horizontalCenter: parent.horizontalCenter
			}

			width: 48
			height: width
			source: "qrc:/images/icon_alarm_48.svg"
		}

		Label {
			id: titleLabel
			anchors {
				top: alarmIcon.bottom
				topMargin: 32
				left: parent.left
				leftMargin: 24
				right: parent.right
				rightMargin: 24
			}
			height: 24

			//% "Disable Autostart?"
			text: qsTrId("controlcard_generator_disableautostartdialog_title")
			font.pixelSize: Theme.fontSizeWarningDialogHeader
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}

		Label {
			id: consequencesLabel
			anchors {
				top: titleLabel.bottom
				topMargin: 12
				left: parent.left
				leftMargin: 24
				right: parent.right
				rightMargin: 24
				bottom: parent.bottom
				bottomMargin: 12
			}

			horizontalAlignment: Text.AlignHCenter
			//% "Consequences description..."
			text: qsTrId("controlcard_generator_disableautostartdialog_consequences")
			font.pixelSize: Theme.fontSizeControlValue
		}
	}
}
