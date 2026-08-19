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

	VeQuickItem {
		id: bmsPresentItem
		uid: root.bindPrefix + "/Settings/BmsPresent"
	}

	title: CommonWords.settings

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListOutputBatteryRadioButtonGroup {
					bindPrefix: root.bindPrefix
					settingsPage: root.settingsPage
				}
			}
			DelegateComponent {
				id: bmsControlledDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/BmsPresent" }
				preferredVisible: bmsPresentItem.valid
				ListText {
					id: bmsControlled
					text: CommonWords.bms_controlled
					secondaryText: CommonWords.yesOrNo(dataItem.value)
					dataItem.uid: root.bindPrefix + "/Settings/BmsPresent"
				}
			}

			DelegateComponent {
				preferredVisible: bmsControlledDC.dataItem.value === 1
				ListButton {
					text: CommonWords.bms_control
					secondaryText: CommonWords.reset
					onClicked: {
						bmsControlledDC.dataItem.setValue(0)
					}
				}
			}

			DelegateComponent {
				preferredVisible: bmsControlledDC.dataItem.value === 1
				ListInfoLabel {
					text: CommonWords.bms_control_info
				}
			}
		}
	}
}