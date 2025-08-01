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

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
		ListSwitch {
			text: CommonWords.switch_mode
			dataItem.uid: root.bindPrefix + "/Mode"
			valueTrue: 1
			valueFalse: 4
			preferredVisible: dataItem.valid
		}

		ListDcInputQuantityGroup {
			bindPrefix: root.bindPrefix
		}

		ListDcOutputQuantityGroup {
			bindPrefix: root.bindPrefix
		}

		ListTemperature {
			text: CommonWords.battery_temperature
			dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
			preferredVisible: dataItem.valid
			unit: Global.systemSettings.temperatureUnit
		}

		ListText {
			text: CommonWords.state
			secondaryText: Global.system.systemStateToText(dataItem.value)
			dataItem.uid: root.bindPrefix + "/State"
		}

		ListText {
			text: CommonWords.error
			dataItem.uid: root.bindPrefix + "/ErrorCode"
			secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
		}

		DcHistorySettingsColumn {
			width: parent?.width ?? 0
			bindPrefix: root.bindPrefix
		}

		ListNavigation {
			text: CommonWords.settings
			preferredVisible: setupOutputItem.valid
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
