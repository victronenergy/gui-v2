/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

/*
	A generic modal dialog that appears over all other UI layers.

	If the contentItem contains focusable UI controls, the contentItem should extend
	ModalDialog.FocusableContentItem, so that the contentItem can receive the Enter/Return/Escape
	shortcuts for accepting/rejecting the dialog, and also move the focus between the header and
	footer.
*/
T.Dialog {
	id: root

	property string secondaryTitle
	property color backgroundColor: Theme.color_background_secondary
	property int dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_SetAndCancel
	property alias canAccept: doneButton.enabled
	readonly property real centeredY: (parent.height - height) / 2

	// Optional functions: called when accept/reject is attempted.
	// These should return true if the accept/reject can be executed, and false otherwise.
	property var tryAccept
	property var tryReject

	readonly property alias acceptButton: doneButton
	property string acceptText: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_SetAndCancel
			  //% "Set"
			? qsTrId("modaldialog_set")
			: CommonWords.ok

	readonly property alias rejectButton: rejectButton
	property string rejectText: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkOnly
			? ""
			: rejectTextCancel

	readonly property string rejectTextCancel: CommonWords.cancel

	function handleAccept() {
		if (!root.canAccept || (!!root.tryAccept && !root.tryAccept())) {
			return
		}
		root.accept()
	}

	function handleReject() {
		if (!!root.tryReject && !root.tryReject()) {
			return
		}
		root.reject()
	}

	// Base type for contentItem of child dialogs.
	component FocusableContentItem : FocusScope {
		// Give the initial focus to this content item so that child UI controls will receive focus.
		focus: true

		KeyNavigation.down: root.footer
		Keys.onReturnPressed: root.handleAccept()
		Keys.onEnterPressed: root.handleAccept()
		Keys.onEscapePressed: root.handleReject()
		Keys.enabled: Global.keyNavigationEnabled
	}

	// Use x/y positioning instead of anchors, so that the dialog can be moved upwards when needed.
	x: (parent.width - width) / 2
	y: centeredY

	/*
	If you specify implicitWidth & implicitHeight here, and shrink the browser (or desktop app) window from 100% -> 0%,
	the dialog scales correctly with the rest of the app down to ~60%, and then scales down at a faster rate than the
	rest of the app. Specifying 'width' and 'height' instead of 'implicitWidth' and 'implicitHeight' for ModalDialog
	makes it scale properly when you shrink the window. See https://bugreports.qt.io/browse/QTBUG-127068
	*/
	width: Theme.geometry_modalDialog_width
	height: Theme.geometry_modalDialog_height
	verticalPadding: 0
	horizontalPadding: 0
	modal: true
	closePolicy: T.Popup.NoAutoClose

	// Ideally, focus would be false and the user could enable key navigation while the dialog was
	// open, by pressing a navigation key. However, if focus=false to begin with, then no key events
	// would be received. So, just enable it when the dialog is opened, if key nav is enabled.
	focus: Global.keyNavigationEnabled

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
		color: root.backgroundColor
		border.color: Theme.color_modalDialog_border

		DialogShadow {}
	}

	header: Item {
		width: root.width
		height: Theme.geometry_modalDialog_header_height

		Label {
			id: headerLabel

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: secondaryHeaderLabel.text.length ? -secondaryHeaderLabel.height / 2 : 0
			}
			x: Theme.geometry_page_content_horizontalMargin
			width: parent.width - 2*x
			horizontalAlignment: Text.AlignHCenter
			color: Theme.color_font_primary
			font.pixelSize: root.secondaryTitle.length ? Theme.font_size_body1 : Theme.font_size_body3
			text: root.title
			elide: Text.ElideRight
		}

		Label {
			id: secondaryHeaderLabel

			anchors.top: headerLabel.bottom
			x: Theme.geometry_page_content_horizontalMargin
			width: parent.width - 2*x
			horizontalAlignment: Text.AlignHCenter
			color: Theme.color_font_primary
			font.pixelSize: Theme.font_size_body2
			text: root.secondaryTitle
			elide: Text.ElideRight
		}
	}

	footer: FocusScope {
		visible: root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_NoOptions
		height: visible ? Theme.geometry_modalDialog_footer_height : 0
		focus: false

		// Do not allow enter/return to accept the dialog when the footer buttons are
		// focused, as it would be confusing as to whether the Enter/Return key is
		// accepting the dialog or pressing the Cancel button to reject the dialog.
		Keys.onEscapePressed: root.handleReject()
		Keys.enabled: Global.keyNavigationEnabled

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
			focus: enabled
			text: root.rejectText
			onClicked: root.handleReject()
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
			focus: enabled && !rejectButton.enabled
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_primary
			spacing: 0
			text: root.acceptText
			KeyNavigation.left: rejectButton
			onClicked: root.handleAccept()
		}
	}

	property QtObject _stateManager: QtObject {
		id: stateManager

		readonly property Item inputItem: root.visible && Qt.inputMethod.visible ?
											  (root.contentItem.Window.activeFocusItem as TextField ??
											   root.contentItem.Window.activeFocusItem as TextInput ??
											   // root.contentItem.Window.activeFocusItem as TextArea ?? // not used
											   root.contentItem.Window.activeFocusItem as TextEdit) : null

		property real targetDialogY: 0

		onInputItemChanged: {
			if (!inputItem) {
				dialogStateGroup.state = "default"
				return
			}

			const currentDialogOffset = root.y - root.centeredY // 0 or negative
			const inputItemBottomPos = inputItem.mapToItem(Global.mainView, 0, inputItem.implicitHeight).y - currentDialogOffset

			targetDialogY = root.centeredY

			const vkbTopPos = Global.mainView.height - Qt.inputMethod.keyboardRectangle.height

			if (inputItemBottomPos > vkbTopPos) {
				// Note: moving the Dialog while in "focused" state will change to
				// the new location immediately without any animation.
				targetDialogY += (vkbTopPos - inputItemBottomPos)
			}

			dialogStateGroup.state = "focused"
		}
		property StateGroup dialogStateGroup: StateGroup {

			state: "default"

			states: [
				State {
					name: "default"
					PropertyChanges {
						// reset to the "default" binding explicitly
						// so we can get the transition
						root.y: root.centeredY
					}
				},
				State {
					name: "focused"
					PropertyChanges {
						root.y: stateManager.targetDialogY
					}
				}
			]

			transitions: [
				Transition {
					to: "*"
					NumberAnimation {
						target: root
						property: "y"
						duration: Theme.animation_inputPanel_slide_duration
						easing.type: Easing.InOutQuad
					}
				}
			]
		}
	}

	MouseArea {
		// placed behind the background, contentItem, header and footer
		parent: contentItem.parent
		anchors.fill: parent
		z: -1
		enabled: !!stateManager.inputItem
		onClicked: focus = true
	}
}

