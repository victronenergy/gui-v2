/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS
import QtQuick.Controls as C

T.Dialog {
	id: root

	property string secondaryTitle
	property int dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_SetAndClose
	property alias canAccept: doneButton.enabled

	// Optional functions: called when accept/reject is attempted.
	// These should return true if the accept/reject can be executed, and false otherwise.
	property var tryAccept
	property var tryReject

	readonly property alias acceptButton: doneButton
	property string acceptText: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_SetAndClose
			  //% "Set"
			? qsTrId("modaldialog_set")
			: CommonWords.ok

	readonly property alias rejectButton: rejectButton
	property string rejectText: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkOnly
			? ""
			: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkAndCancel
				? rejectTextCancel
				: rejectTextClose

	//% "Cancel"
	readonly property string rejectTextCancel: qsTrId("modaldialog_cancel")
	//% "Close"
	readonly property string rejectTextClose: qsTrId("modaldialog_close")

	anchors.centerIn: parent
	implicitWidth: Theme.geometry_modalDialog_width
	implicitHeight: Theme.geometry_modalDialog_height
	verticalPadding: 0
	horizontalPadding: 0
	modal: true
	closePolicy: T.Popup.NoAutoClose

	enter: Transition {
		NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Theme.animation_page_fade_duration }
	}
	exit: Transition {
		NumberAnimation {
			loops: Qt.platform.os == "wasm" ? 0 : 1 // workaround wasm crash, see https://bugreports.qt.io/browse/QTBUG-121382
			property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animation_page_fade_duration
		}
	}

	background: Rectangle {
		radius: Theme.geometry_modalDialog_radius
		color: Theme.color_background_secondary
	}
	C.Overlay.modal: DialogShadow {}

	header: Item {
		width: root.width
		height: Theme.geometry_modalDialog_header_height

		Label {
			id: headerLabel

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: secondaryHeaderLabel.text.length ? -secondaryHeaderLabel.height / 2 : 0
			}
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			color: Theme.color_font_primary
			font.pixelSize: root.secondaryTitle.length ? Theme.font_size_body1 : Theme.font_size_body3
			text: root.title
			wrapMode: Text.Wrap
		}

		Label {
			id: secondaryHeaderLabel

			anchors.top: headerLabel.bottom
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			color: Theme.color_font_primary
			font.pixelSize: Theme.font_size_body2
			text: root.secondaryTitle
			wrapMode: Text.Wrap
		}
	}

	footer: Item {
		visible: root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_NoOptions
		height: visible ? Theme.geometry_modalDialog_footer_height : 0
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
			id: rejectButton
			visible: root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_OkOnly
			anchors {
				left: parent.left
				right: footerMidSeparator.left
				top: footerTopSeparator.bottom
				bottom: parent.bottom
				bottomMargin: root.background.border.width
			}

			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_primary
			spacing: 0
			enabled: root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_OkOnly
			text: root.rejectText
			onClicked: {
				if (!!root.tryReject && !root.tryReject()) {
					return
				}
				root.reject()
			}
		}

		SeparatorBar {
			id: footerMidSeparator
			visible: root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_OkOnly
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: root.background.border.width
				top: footerTopSeparator.bottom
			}
			width: Theme.geometry_modalDialog_footer_midSeparator_width
		}
		Button {
			id: doneButton
			anchors {
				left: root.dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkOnly ? parent.left : footerMidSeparator.right
				right: parent.right
				rightMargin: root.background.border.width
				top: footerTopSeparator.bottom
				bottom: parent.bottom
				bottomMargin: root.background.border.width
			}

			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_primary
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

