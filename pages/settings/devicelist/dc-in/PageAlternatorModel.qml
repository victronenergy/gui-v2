/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VisibleItemModel {
	id: root

	property string bindPrefix
	property Page page

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
		//% "Alternator Temperature"
		text: qsTrId("alternator_temperature")
		dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
		preferredVisible: dataItem.valid
	}

	ListText {
		text: CommonWords.state
		secondaryText: Global.system.systemStateToText(dataItem.value)
		preferredVisible: dataItem.valid
		dataItem.uid: root.bindPrefix + "/State"
	}

	ListText {
		text: CommonWords.network_status
		secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
		dataItem.uid: root.bindPrefix + "/Link/NetworkStatus"
		preferredVisible: dataItem.valid
	}

	ListText {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/ErrorCode"
		preferredVisible: dataItem.valid
		secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
	}

	ListText {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/Error/0/Id"
		preferredVisible: dataItem.valid
		secondaryText: dataItem.valid ? AlternatorError.description(dataItem.value) : dataItem.invalidText
	}

	ListQuantity {
		//% "Field drive"
		text: qsTrId("alternator_wakespeed_field_drive")
		dataItem.uid: root.bindPrefix + "/FieldDrive"
		unit: VenusOS.Units_Percentage
		preferredVisible: dataItem.valid
	}

	ListQuantity {
		//% "Utilization"
		text: qsTrId("alternator_wakespeed_utilization")
		dataItem.uid: root.bindPrefix + "/Utilization"
		unit: VenusOS.Units_Percentage
		preferredVisible: dataItem.valid
	}

	ListQuantity {
		text: CommonWords.speed
		dataItem.uid: root.bindPrefix + "/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
		preferredVisible: dataItem.valid
	}

	ListQuantity {
		//% "Engine speed"
		text: qsTrId("alternator_wakespeed_engine_speed")
		dataItem.uid: root.bindPrefix + "/Engine/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
		preferredVisible: dataItem.valid
	}

	ListTemperature {
		//% "Engine Temperature"
		text: qsTrId("engine_temperature")
		dataItem.uid: root.bindPrefix + "/Engine/Temperature"
		preferredVisible: dataItem.valid
	}

	DcHistorySettingsColumn {
		width: parent?.width ?? 0
		bindPrefix: root.bindPrefix
	}

	ListNavigation {
		text: CommonWords.settings
		preferredVisible: setupOutputItem.valid
		onClicked: {
			Global.pageManager.pushPage(settingsComponent)
		}

		VeQuickItem {
			id: setupOutputItem
			uid: bindPrefix + "/Settings/OutputBattery"
		}

		Component {
			id: settingsComponent

			Page {
				title: CommonWords.settings

				GradientListView {
					model: VisibleItemModel {
						ListOutputBatteryRadioButtonGroup {
							bindPrefix: root.bindPrefix
							settingsPage: root.page
						}
					}
				}
			}
		}
	}

	ListNavigation {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}
