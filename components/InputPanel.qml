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

	KeyboardInputScroller {}

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
