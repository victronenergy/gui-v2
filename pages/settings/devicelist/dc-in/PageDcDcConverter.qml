/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListSwitch {
				text: CommonWords.switch_mode
				dataItem.uid: root.bindPrefix + "/Mode"
				valueTrue: 1
				valueFalse: 4
				allowed: defaultAllowed && dataItem.isValid
			}

			ListDcInputQuantityGroup {
				bindPrefix: root.bindPrefix
			}

			ListDcOutputQuantityGroup {
				bindPrefix: root.bindPrefix
			}

			ListTemperatureItem {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
				allowed: defaultAllowed && dataItem.isValid
				unit: Global.systemSettings.temperatureUnit
			}

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}

			ListTextItem {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				secondaryText: dataItem.isValid ? ChargerError.description(dataItem.value) : dataItem.invalidText
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
