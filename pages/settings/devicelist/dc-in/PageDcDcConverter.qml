/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a dcdc device.
*/
DevicePage {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Dc/0/Temperature"
	}
	VeQuickItem {
		id: modeItem
		uid: root.bindPrefix + "/Mode"
	}

	serviceUid: bindPrefix

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			preferredVisible: modeItem.valid
			ListSwitch {
				text: CommonWords.switch_mode
				dataItem.uid: root.bindPrefix + "/Mode"
				valueTrue: 1
				valueFalse: 4
			}
		}

		DelegateComponent {
			ListDcInputQuantityGroup {
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			ListDcOutputQuantityGroup {
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem.valid
			ListTemperature {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
				unit: Global.systemSettings.temperatureUnit
			}
		}

		DelegateComponent {
			ListText {
				text: CommonWords.state
				secondaryText: VenusOS.system_stateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}
		}

		DelegateComponent {
			ListText {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
			}
		}

		DelegateComponent {
			DcHistorySettingsColumn {
				width: parent?.width ?? 0
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			id: setupOutputItemDC
			dataItem: VeQuickItem { uid: bindPrefix + "/Settings/OutputBattery" }
			preferredVisible: setupOutputItemDC.dataItem.valid
			ListNavigation {
				text: CommonWords.settings
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/DcBmsSettingsPage.qml", {
						bindPrefix: root.bindPrefix,
						settingsPage: root,
					})
				}

				VeQuickItem {
					id: setupOutputItem
					uid: bindPrefix + "/Settings/OutputBattery"
				}
			}
		}
	}
}