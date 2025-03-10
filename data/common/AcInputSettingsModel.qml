/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	property string serviceUid

	readonly property VeQuickItem _numberOfAcInputs: VeQuickItem {
		uid: root.serviceUid + "/Ac/NumberOfAcInputs"
	}

	property Instantiator _acInputSettingsObjects: Instantiator {
		model: _numberOfAcInputs.valid ? _numberOfAcInputs.value : null
		delegate: AcInputSettings {
			serviceUid: root.serviceUid
			inputNumber: model.index + 1
		}

		onObjectAdded: function(index, settings) {
			let insertionIndex = root.count
			for (let i = 0; i < root.count; ++i) {
				if (settings.inputNumber < root.get(i).inputSettings.inputNumber) {
					insertionIndex = i
					break
				}
			}
			root.insert(insertionIndex, { inputSettings: settings })
		}
		onObjectRemoved: function(index, settings) {
			for (let i = 0; i < root.length; ++i) {
				if (root.get(i).inputSettings.inputNumber === settings.inputNumber) {
					root.remove(i)
					break
				}
			}
		}
	}
}
