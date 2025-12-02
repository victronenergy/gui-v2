/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix
	required property Item settingsPage

	title: CommonWords.settings

	GradientListView {
		model: VisibleItemModel {
			ListOutputBatteryRadioButtonGroup {
				bindPrefix: root.bindPrefix
				settingsPage: root.settingsPage
			}
			ListText {
				id: bmsControlled
				text: CommonWords.bms_controlled
				secondaryText: CommonWords.yesOrNo(dataItem.value)
				dataItem.uid: root.bindPrefix + "/Settings/BmsPresent"
				preferredVisible: dataItem.valid
			}

			ListButton {
				text: CommonWords.bms_control
				secondaryText: CommonWords.reset
				preferredVisible: bmsControlled.dataItem.value === 1
				onClicked: {
					bmsControlled.dataItem.setValue(0)
				}
			}

			ListInfoLabel {
				text: CommonWords.bms_control_info
				preferredVisible: bmsControlled.dataItem.value === 1
			}
		}
	}
}
