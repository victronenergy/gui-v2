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

	settingsModel: VisibleItemModel {
		ListSwitch {
			text: CommonWords.switch_mode
			dataItem.uid: root.serviceUid + "/Mode"
			valueTrue: 1
			valueFalse: 4
			preferredVisible: dataItem.valid
		}

		ListDcInputQuantityGroup {
			bindPrefix: root.serviceUid
		}

		ListDcOutputQuantityGroup {
			bindPrefix: root.serviceUid
		}

		ListTemperature {
			text: CommonWords.battery_temperature
			dataItem.uid: root.serviceUid + "/Dc/0/Temperature"
			preferredVisible: dataItem.valid
			unit: Global.systemSettings.temperatureUnit
		}

		ListText {
			text: CommonWords.state
			secondaryText: VenusOS.system_stateToText(dataItem.value)
			dataItem.uid: root.serviceUid + "/State"
		}

		ListText {
			text: CommonWords.error
			dataItem.uid: root.serviceUid + "/ErrorCode"
			secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
		}

		DcHistorySettingsColumn {
			width: parent?.width ?? 0
			bindPrefix: root.serviceUid
		}

		ListNavigation {
			text: CommonWords.settings
			preferredVisible: setupOutputItem.valid
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/DcBmsSettingsPage.qml", {
					bindPrefix: root.serviceUid,
					settingsPage: root,
				})
			}

			VeQuickItem {
				id: setupOutputItem
				uid: serviceUid + "/Settings/OutputBattery"
			}
		}
	}
}
