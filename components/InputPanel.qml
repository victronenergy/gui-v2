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

	property real cardsYOffset

	readonly property string localeName: Language.currentLocaleName

	readonly property bool requiresRotation: Global.main && Global.main.requiresRotation

	function acceptMouseEvent(item, itemMouseX, itemMouseY) {
		if (!Qt.inputMethod.visible || !item || !focusedItem) {
			return false
		}
		const mappedPoint = focusedItem.mapFromItem(item, itemMouseX, itemMouseY)
		if (!focusedItem.contains(mappedPoint)) {
			// The screen was clicked outside of the text field. Remove focus from the text field,
			// so that the VKB will close. Return true to swallow the mouse event.
			focusedItem.focus = false
			focusedItem = null
			focusedView = null
			return true
		}
		// The mouse was clicked within the text field, so allow it to receive the mouse event.
		return false
	}

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
			name: "openedForFlickable"
			when: Qt.inputMethod.visible
				  && !!root.focusedView
				  && root.focusedView !== Global.mainView.cardsLoader

			PropertyChanges {
				target: root.focusedView
				contentY: root.toContentY
				height: root.toHeight
			}
		},
		State {
			name: "openedForCards"
			when: Qt.inputMethod.visible
				  && !!root.focusedView
				  && root.focusedView === Global.mainView.cardsLoader

			// No PropertyChanges, the Transitions will trigger the cardsLoader to slide up/down.
		}
	]

	transitions: [
		Transition {
			NumberAnimation {
				properties: "contentY,height"
				duration: Theme.animation_inputPanel_slide_duration
				easing.type: Easing.InOutQuad
			}
		},
		Transition {
			to: "openedForCards"
			ScriptAction {
				script: Global.mainView.cardsLoader.setYOffset(root.cardsYOffset, true)
			}
		},
		Transition {
			from: "openedForCards"
			ScriptAction {
				script: Global.mainView.cardsLoader.clearYOffset()
			}
		}
	]

	Connections {
		target: Global

		function onAboutToFocusTextField(textField, textFieldContainer, viewToScroll) {
			if (!textField || !textFieldContainer || !viewToScroll) {
				console.warn("onAboutToFocusTextField(): invalid item/container/viewToScroll:", textField, textFieldContainer, viewToScroll)
				return
			}
			const inputPanelY = Global.mainView.height - root.height

			// Find the bottom of the text field's container item (e.g. the ListTextField) within
			// the main view.
			const textFieldVerticalMargin = textFieldContainer.height - textField.height
			const textFieldBottom = textFieldContainer.height - textFieldVerticalMargin/2
			const toWinY = textFieldContainer.mapToItem(Global.mainView, 0, textFieldBottom).y

			// Find the distance between the top of the input panel and the bottom of the text
			// field container.
			const delta = toWinY - inputPanelY
			if (delta < 0) {
				// View does not need to be scrolled to see the VKB.
				return
			}

			if (viewToScroll === Global.mainView.cardsLoader) {
				// The text field is in the main cards view.
				root.cardsYOffset = viewToScroll.y - delta
			} else {
				// The text field is in some other flickable.
				// Scroll the flickable upwards to show the item above the vkb.
				const flickable = viewToScroll
				root.toContentY = flickable.contentY + delta

				if (flickable.contentY + delta + flickable.height > flickable.contentHeight) {
					// Item is too close to bottom of flickable, so it will still be hidden after
					// scrolling upwards. Reduce the flickable height so that item can be seen.
					root.toHeight = flickable.height - root.height
				} else {
					// No flickable height changes required.
					root.toHeight = flickable.height
				}
			}

			root.focusedItem = textField
			root.focusedView = viewToScroll
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
		VirtualKeyboardSettings.activeLocales = ["en_US", "af_ZA", "cs_CZ", "da_DK", "de_DE", "es_ES", "fr_FR", "it_IT", "nl_NL", "pl_PL", "ru_RU", "ro_RO", "sv_SE", "th_TH", "tr_TR", "uk_UA", "zh_CN", "ar_AR"]
		_setVkbLocale()
	}
}
