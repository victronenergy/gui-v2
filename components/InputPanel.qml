/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.VirtualKeyboard as QtVirtualKeyboard
import QtQuick.VirtualKeyboard.Settings
import Victron.VenusOS

// *** This file can be edited directly on the cerbo filesystem,
// *** but you will also need to edit ApplicationContent.qml
// *** so that the loader's source property is:
// *** "file:///opt/victronenergy/gui-v2/Victron/VenusOS/components/InputPanel.qml"

/*
	An implementation of the Qt VKB InputPanel. This is only shown on the GX device.
*/
QtVirtualKeyboard.InputPanel {
	id: root

	property Item focusedItem
	property Item focusedView

	property real toContentY
	property real toHeight
	property real initialBottomMargin

	readonly property string localeName: Language.currentLocaleName

	readonly property bool requiresRotation: Global.main && Global.main.requiresRotation

	visible: Qt.inputMethod.visible || yAnimator.running

	y: requiresRotation ? 312 // manually-found coordinate transform for rpi5, see #2702
	 : Qt.inputMethod.visible ? Theme.geometry_screen_height - root.height
	 : Theme.geometry_screen_height

	x: requiresRotation ? 480 // manually-found coordinate transform for rpi5, see #2702
	 : 0

	transformOrigin: Item.Center
	transform: Rotation {
		origin.x: width / 2
		origin.y: height / 2
		angle: requiresRotation ? 270 : 0
	}

	Behavior on y {
		enabled: !root.requiresRotation
		YAnimator {
			id: yAnimator
			duration: Theme.animation_inputPanel_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	width: Theme.geometry_screen_width

	states: [
		State {
			name: "scrollVertically"
			when: Qt.inputMethod.visible && !!root.focusedView && root.focusedView?.orientation === Qt.Vertical

			PropertyChanges {
				target: root.focusedView
				bottomMargin: root.initialBottomMargin + root.height
			}

			// In case the user scrolls the view to a new contentY, do not revert the contentY
			// change, so trigger it manually instead of via PropertyChanges. Theoretically
			// restoreEntryValues=false should do the same thing, but the state changes become
			// confused when toContentY changes.
			StateChangeScript {
				script: verticalScrollAnimation.start()
			}
		},
		State {
			name: "scrollHorizontally"
			when: Qt.inputMethod.visible && !!root.focusedView && root.focusedView?.orientation !== Qt.Vertical

			PropertyChanges {
				target: root.focusedView
				contentY: root.toContentY
			}
		}
	]

	transitions: [
		Transition {
			enabled: Global.animationEnabled

			NumberAnimation {
				properties: "contentY,bottomMargin"
				duration: Theme.animation_inputPanel_slide_duration
				easing.type: Easing.InOutQuad
			}
		}
	]

	NumberAnimation {
		id: verticalScrollAnimation

		target: root.focusedView
		property: "contentY"
		to: root.toContentY
		duration: Theme.animation_inputPanel_slide_duration
		easing.type: Easing.InOutQuad
	}

	Connections {
		target: Global

		// Auto-scrolling in dialogs is handled by ModalDialog, so don't handle it here.
		enabled: !Global.dialogLayer.currentDialog

		function onAboutToFocusTextField(textField, viewToScroll) {
			if (!textField || !viewToScroll) {
				console.warn("onAboutToFocusTextField(): invalid item/viewToScroll:", textField, viewToScroll)
				return
			}

			root.focusedItem = textField
			root.focusedView = viewToScroll

			const inputPanelY = Global.mainView.height - root.height

			// Find the bottom of the text field within the main view.
			const toWinY = textField.mapToItem(Global.mainView, 0, textField.height).y
					+ Theme.geometry_inputPanel_topMargin

			// Find the distance between the top of the input panel and the bottom of the text
			// field container.
			const delta = toWinY - inputPanelY
			if (delta < 0) {
				// View does not need to be scrolled to see the VKB.
				root.toContentY = viewToScroll.contentY
			} else {
				// Scroll the flickable upwards to show the item above the VKB.
				root.toContentY = viewToScroll.contentY + delta
			}
			root.initialBottomMargin = viewToScroll.bottomMargin
		}
	}

	LanguageModel {
		id: languageModel
	}

	Instantiator {
		id: instantiator

		model: languageModel
		delegate: FontLoader {
			source: model.fontFileUrl
			onStatusChanged: {
				if (status === FontLoader.Ready) {
					languageModel.setFontFamily(source, name)
				}
			}
		}
	}

	function _setVkbLocale() {
		let locale = localeName
		// fixup "ar_EG" -> "ar_AR" if necessary
		if (localeName.startsWith("ar_")) {
			locale = "ar_AR"
		}
		if (VirtualKeyboardSettings.activeLocales.indexOf(locale) >= 0) {
			VirtualKeyboardSettings.locale = locale
		} else if (VirtualKeyboardSettings.activeLocales.length) {
			console.warn("Unknown locale: " + locale + " not in " + VirtualKeyboardSettings.activeLocales)
		}
	}

	onLocaleNameChanged: _setVkbLocale()
	Component.onCompleted: {
		// turn off the Virtual Keyboard Text Selection Handles as they don't position properly
		// under certain circumstances: see https://bugreports.qt.io/browse/QTBUG-114551
		VirtualKeyboardSettings.inputMethodHints = Qt.ImhNoTextHandles
		VirtualKeyboardSettings.activeLocales = ["en_US", "af_ZA", "cs_CZ", "da_DK", "de_DE", "es_ES", "fr_FR", "it_IT", "nl_NL", "pl_PL", "pt_PT", "ru_RU", "ro_RO", "sv_SE", "th_TH", "tr_TR", "uk_UA", "zh_CN", "ar_AR"]
		_setVkbLocale()
	}
}
