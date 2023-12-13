/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

T.Dialog {
	id: root

	property var acceptButtonBackground
	property var _contentItem
	property string secondaryTitle
	property int dialogDoneOptions: Enums.ModalDialog_DoneOptions_SetAndClose
	property alias canAccept: doneButton.enabled
	property var tryAccept  // optional function: called when accept is attempted, return true if can accept.

	readonly property alias acceptButton: doneButton
	property string acceptText: dialogDoneOptions === Enums.ModalDialog_DoneOptions_SetAndClose
			  //% "Set"
			? qsTrId("controlcard_set")
			: CommonWords.ok

	property string rejectText: dialogDoneOptions === Enums.ModalDialog_DoneOptions_OkOnly
			? ""
			: dialogDoneOptions === Enums.ModalDialog_DoneOptions_OkAndCancel
				//% "Cancel"
				? qsTrId("controlcard_cancel")
				//% "Close"
				: qsTrId("controlcard_close")

	anchors.centerIn: parent
	implicitWidth: background.implicitWidth
	implicitHeight: background.implicitHeight
	verticalPadding: 0
	horizontalPadding: 0
	modal: true

	contentItem: _contentItem
	acceptButton.Background: acceptButtonBackground

	enter: Transition {
		NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Theme.animation.page.fade.duration }
	}
	exit: Transition {
		NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animation.page.fade.duration }
	}

	background: Rectangle {
		implicitWidth: Theme.geometry.modalDialog.width
		implicitHeight: Theme.geometry.modalDialog.height
		radius: Theme.geometry.modalDialog.radius
		color: Theme.color.background.secondary
		border.color: Theme.color.modalDialog.border

		DialogShadow {
			backgroundRect: parent
			dialog: root
		}
	}

	header: Item {
		width: root.width
		height: Theme.geometry.modalDialog.header.height

		Label {
			id: headerLabel

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: secondaryHeaderLabel.text.length ? -secondaryHeaderLabel.height / 2 : 0
			}
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			color: Theme.color.font.primary
			font.pixelSize: root.secondaryTitle.length ? Theme.font.size.body1 : Theme.font.size.body3
			text: root.title
			wrapMode: Text.Wrap
		}

		Label {
			id: secondaryHeaderLabel

			anchors.top: headerLabel.bottom
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			color: Theme.color.font.primary
			font.pixelSize: Theme.font.size.body2
			text: root.secondaryTitle
			wrapMode: Text.Wrap
		}
	}

	footer: Item {
		visible: root.dialogDoneOptions !== Enums.ModalDialog_DoneOptions_NoOptions
		height: visible ? Theme.geometry.modalDialog.footer.height : 0
		SeparatorBar {
			id: footerTopSeparator
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: root.background.border.width
				right: parent.right
				rightMargin: root.background.border.width
			}
		}
		Button {
			visible: root.dialogDoneOptions !== Enums.ModalDialog_DoneOptions_OkOnly
			anchors {
				left: parent.left
				right: footerMidSeparator.left
				top: footerTopSeparator.bottom
				bottom: parent.bottom
				bottomMargin: root.background.border.width
			}

			font.pixelSize: Theme.font.size.body2
			color: Theme.color.font.primary
			spacing: 0
			enabled: root.dialogDoneOptions !== Enums.ModalDialog_DoneOptions_OkOnly
			text: root.dialogDoneOptions === Enums.ModalDialog_DoneOptions_OkOnly ?
					""
				: root.dialogDoneOptions === Enums.ModalDialog_DoneOptions_OkAndCancel ?
					//% "Cancel"
					qsTrId("controlcard_cancel")
				: /* SetAndClose */
					//% "Close"
					qsTrId("controlcard_close")
			onClicked: root.reject()
		}
		SeparatorBar {
			id: footerMidSeparator
			visible: root.dialogDoneOptions !== Enums.ModalDialog_DoneOptions_OkOnly
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: root.background.border.width
				top: footerTopSeparator.bottom
			}
			width: Theme.geometry.modalDialog.footer.midSeparator.width
		}
		Button {
			id: doneButton
			anchors {
				left: root.dialogDoneOptions === Enums.ModalDialog_DoneOptions_OkOnly ? parent.left : footerMidSeparator.right
				right: parent.right
				rightMargin: root.background.border.width
				top: footerTopSeparator.bottom
				bottom: parent.bottom
				bottomMargin: root.background.border.width
			}

			font.pixelSize: Theme.font.size.body2
			color: Theme.color.font.primary
			spacing: 0
			text: root.acceptText
			onClicked: {
				if (!!root.tryAccept && !root.tryAccept()) {
					return
				}
				root.accept()
			}
		}
	}
}

