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

QtVirtualKeyboard.InputPanel {
	id: root

	property var focusedItem
	property var focusedFlickable
	property real toContentY
	property real toHeight

	readonly property string localeName: Language.currentLocaleName

	function acceptMouseEvent(item, itemMouseX, itemMouseY) {
		if (!Qt.inputMethod.visible || !item || !focusedItem) {
			return false
		}
		const mappedPoint = focusedItem.mapFromItem(item, itemMouseX, itemMouseY)
		if (!focusedItem.contains(mappedPoint)) {
			// The screen was clicked outside of the text field. Remove focus from the text field,
			// so that the VKB will close. Return true to swallow the mouse event.
			focusedItem.focus = false
			return true
		}
		// The mouse was clicked within the text field, so allow it to receive the mouse event.
		return false
	}

	visible: Qt.inputMethod.visible || yAnimator.running
	y: Qt.inputMethod.visible ? Theme.geometry_screen_height - root.height : Theme.geometry_screen_height
	Behavior on y {
		YAnimator {
			id: yAnimator
			duration: Theme.animation_inputPanel_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	width: Theme.geometry_screen_width

	states: State {
		name: "visible"
		when: Qt.inputMethod.visible

		PropertyChanges {
			target: root.focusedFlickable
			contentY: root.toContentY
			height: root.toHeight
		}
	}

	transitions: Transition {
		NumberAnimation {
			properties: "contentY,height"
			duration: Theme.animation_inputPanel_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	Connections {
		target: Global

		function onAboutToFocusTextField(textField, textFieldContainer, flickable) {
			if (!textField || !textFieldContainer || !flickable) {
				console.warn("onAboutToFocusTextField(): invalid item/container/flickable:", textField, textFieldContainer, flickable)
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

			if (delta > 0) {
				// Scroll the flickable upwards to show the item above the vkb.
				root.toContentY = flickable.contentY + delta

				if (flickable.contentY + delta + flickable.height > flickable.contentHeight) {
					// Item is too close to bottom of flickable, so it will still be hidden after
					// scrolling upwards. Reduce the flickable height so that item can be seen.
					root.toHeight = flickable.height - root.height
				} else {
					// No flickable height changes required.
					root.toHeight = flickable.height
				}
			} else {
				// No position changes required, but PropertyChanges requires a valid target, so
				// set the dest values to the current values.
				root.toContentY = flickable.contentY
				root.toHeight = flickable.height
			}
			root.focusedItem = textField
			root.focusedFlickable = flickable
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
		VirtualKeyboardSettings.activeLocales = ["en_US", "cs_CZ", "da_DK", "de_DE", "es_ES", "fr_FR", "it_IT", "nl_NL", "pl_PL", "ru_RU", "ro_RO", "sv_SE", "th_TH", "tr_TR", "uk_UA", "zh_CN", "ar_AR"]
		_setVkbLocale()
	}
}
