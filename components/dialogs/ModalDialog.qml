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
	property int titleTextFormat: Text.AutoText
	property color backgroundColor: Theme.color_background_secondary
	property Item acceptButtonBackground
	property int dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_SetAndCancel
	property bool canAccept: true

	readonly property real centeredY: (Theme.geometry_screen_height - height) / 2

	// Optional functions: called when accept/reject is attempted.
	// These should return true if the accept/reject can be executed, and false otherwise.
	property var tryAccept
	property var tryReject

	readonly property alias acceptButton: doneButton
	property string acceptText: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_SetAndCancel
			  //% "Set"
			? qsTrId("modaldialog_set")
			: CommonWords.ok

	property string rejectText: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkOnly
			? ""
			: rejectTextCancel

	readonly property string rejectTextCancel: CommonWords.cancel

	readonly property Item focusedInputItem: root.visible
		&& (Qt.inputMethod.visible || BackendConnection.needsWasmKeyboardHandler)
			? (root.contentItem.Window.activeFocusItem as TextField ??
				root.contentItem.Window.activeFocusItem as TextInput ??
				// root.contentItem.Window.activeFocusItem as TextArea ?? // not used
				root.contentItem.Window.activeFocusItem as TextEdit)
			: null
	onFocusedInputItemChanged: _stateManager.updateState()

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

		implicitWidth: Theme.geometry_screen_width - root.leftMargin - root.rightMargin
		implicitHeight: Theme.geometry_modalDialog_contentItem_defaultHeight

		KeyNavigation.down: Global.keyNavigationEnabled ? root.footer : null
		Keys.onEscapePressed: root.handleReject()
		Keys.enabled: Global.keyNavigationEnabled

		// If a text field is focused and the Qt/native VKB is shown, and the user clicks outside of
		// the focused item, then close the VKB (by removing the focus).
		MouseArea {
			anchors.fill: parent
			enabled: !!root.focusedInputItem
			onClicked: root.focusedInputItem.focus = false
		}
	}

	// Use x/y positioning instead of anchors, so that the dialog can be moved for the VKB and by
	// the DialogDragger.
	x: (Theme.geometry_screen_width - width) / 2
	y: root.centeredY
	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding + (header?.height ?? 0) + (footer?.height ?? 0))
	leftMargin: Theme.geometry_modalDialog_horizontalMargin
	rightMargin: Theme.geometry_modalDialog_horizontalMargin
	modal: true
	closePolicy: T.Popup.NoAutoClose

	// Ideally, focus would be false and the user could enable key navigation while the dialog was
	// open, by pressing a navigation key. However, if focus=false to begin with, then no key events
	// would be received. So, just enable it when the dialog is opened, if key nav is enabled.
	focus: Global.keyNavigationEnabled

	// Only provide transitions if animations are enabled. Ideally the transitions would always be
	// set but with 'enabled' set to only run when needed, but due to QTBUG-142410 the enabled value
	// is not respected.
	enter: Global.animationEnabled ? enterTransition : null
	exit: Global.animationEnabled ? exitTransition : null

	Transition {
		id: enterTransition
		NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Theme.animation_page_fade_duration }
	}
	Transition {
		id: exitTransition
		NumberAnimation {
			loops: Qt.platform.os == "wasm" ? 0 : 1 // workaround wasm crash, see https://bugreports.qt.io/browse/QTBUG-121382
			property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animation_page_fade_duration
		}
	}

	background: Rectangle {
		// Allow dialog to stretch to screen width in portrait.
		implicitWidth: Theme.geometry_screen_width - root.leftMargin - root.rightMargin
		implicitHeight: Theme.geometry_modalDialog_height
		radius: Theme.geometry_modalDialog_radius
		color: root.backgroundColor
		border.color: Theme.color_modalDialog_border

		DialogDragger {
			anchors.fill: parent
			dialog: root
			shadow: dialogShadow
		}

		DialogShadow { id: dialogShadow }
	}

	header: Item {
		implicitHeight: Math.max(
				labelColumn.height,
				roundCloseButton.visible ? roundCloseButton.y + roundCloseButton.height + Theme.geometry_modalDialog_content_spacing : 0,
				Theme.geometry_modalDialog_header_height)

		RoundCloseButton {
			id: roundCloseButton
			x: Theme.geometry_page_content_horizontalMargin
			y: Theme.geometry_modalDialog_content_spacing
			visible: Theme.screenSize === Theme.Portrait
					&& root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_OkOnly
			onClicked: root.handleReject()
		}

		Column {
			id: labelColumn

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_page_content_horizontalMargin
						+ (roundCloseButton.visible ? roundCloseButton.width : 0)
				right: parent.right
				rightMargin: Theme.geometry_page_content_horizontalMargin
						+ (roundCloseButton.visible ? roundCloseButton.width : 0)
				verticalCenter: parent.verticalCenter
			}
			topPadding: Theme.geometry_modalDialog_header_verticalPadding
			bottomPadding: Theme.geometry_modalDialog_header_verticalPadding
			spacing: Theme.geometry_modalDialog_header_spacing

			Label {
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				color: Theme.color_font_primary
				font.pixelSize: Theme.font_dialog_secondaryTitle_size
				text: root.secondaryTitle
				textFormat: root.titleTextFormat
				elide: Text.ElideRight
				visible: text.length > 0
			}

			Label {
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				color: Theme.color_font_primary
				font.pixelSize: root.secondaryTitle.length ? Theme.font_dialog_header_smallSize : Theme.font_dialog_header_largeSize
				text: root.title
				textFormat: root.titleTextFormat
				elide: Text.ElideRight
			}
		}
	}

	footer: FocusScope {
		visible: root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_NoOptions
		implicitHeight: visible ? Theme.geometry_modalDialog_footer_height : 0
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
			visible: Theme.screenSize !== Theme.Portrait
		}
		Button {
			id: rejectButton
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
			visible: root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_OkOnly
					&& Theme.screenSize !== Theme.Portrait
			enabled: visible
			focus: enabled
			text: root.rejectText

			onClicked: root.handleReject()
		}

		SeparatorBar {
			id: footerMidSeparator
			visible: rejectButton.visible
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
				left: rejectButton.visible ? footerMidSeparator.right : parent.left
				right: parent.right
				rightMargin: root.background.border.width
				top: footerTopSeparator.bottom
				bottom: parent.bottom
				bottomMargin: root.background.border.width
			}
			focus: enabled && !rejectButton.enabled
			font.pixelSize: Theme.font_dialog_acceptButton_size
			spacing: 0
			text: root.acceptText
			enabled: root.canAccept

			// In portrait layout, the accept button fills the width of the dialog, and has a
			// coloured background.
			leftInset: Theme.geometry_modalDialog_acceptButton_horizontalInset
			rightInset: Theme.geometry_modalDialog_acceptButton_horizontalInset
			topInset: Theme.geometry_modalDialog_acceptButton_topInset
			bottomInset: Theme.geometry_modalDialog_acceptButton_bottomInset
			flat: Theme.screenSize !== Theme.Portrait
			checked: !flat

			KeyNavigation.left: rejectButton
			onClicked: root.handleAccept()

			Binding {
				when: !!root.acceptButtonBackground
				target: doneButton
				property: "background"
				value: root.acceptButtonBackground
			}
		}
	}

	property QtObject _stateManager: QtObject {
		id: stateManager

		property real targetDialogY: 0

		// To ensure the focused text field is not hidden behind the VKB, move the dialog when a
		// text field is focused, and the Qt VKB (on GX) or the native mobile VKB (on Wasm) appears.
		function updateState() {
			if (!root.focusedInputItem) {
				dialogStateGroup.state = "default"
				return
			}

			if (Qt.inputMethod.visible) {
				// Move the dialog so that the text field is visible above the VKB.
				const currentDialogOffset = root.y - root.centeredY // 0 or negative
				const inputItemBottomPos = root.focusedInputItem.mapToItem(Global.mainView, 0, root.focusedInputItem.implicitHeight).y - currentDialogOffset

				targetDialogY = root.centeredY

				const vkbTopPos = Global.mainView.height - Qt.inputMethod.keyboardRectangle.height

				if (inputItemBottomPos > vkbTopPos) {
					// Note: moving the Dialog while in "focused" state will change to
					// the new location immediately without any animation.
					targetDialogY += (vkbTopPos - inputItemBottomPos)
				}
			} else {
				// We don't know how high the built-in keyboard is on Wasm, so just move the dialog
				// to the top of the window, and hopefully that is enough to see the text field.
				targetDialogY = 0
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
						root.y: Theme.screenSize === Theme.Portrait
								? Theme.geometry_screen_height - root.implicitHeight
								: root.centeredY
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
					enabled: Global.animationEnabled
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

	Component.onCompleted: {
		if (Global.main && Global.main.requiresRotation) {
			// we cannot manually position the header or footer.
			// just reject the dialog for now.
			// TODO: use eglfs and rotate the entire surface.
			// See: issue #2702.
			Qt.callLater(reject)
		}
	}
}

