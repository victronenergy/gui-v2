/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DelegateComponentModel {
	id: root

	property string bindPrefix
	property Page page

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Mode" }
		preferredVisible: dataItem.valid
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
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Dc/0/Temperature" }
		preferredVisible: dataItem.valid
		ListTemperature {
			//% "Alternator Temperature"
			text: qsTrId("alternator_temperature")
			dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/State" }
		preferredVisible: dataItem.valid
		ListText {
			text: CommonWords.state
			secondaryText: VenusOS.system_stateToText(dataItem.value)
			dataItem.uid: root.bindPrefix + "/State"
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Link/NetworkStatus" }
		preferredVisible: dataItem.valid
		ListText {
			text: CommonWords.network_status
			secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
			dataItem.uid: root.bindPrefix + "/Link/NetworkStatus"
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/ErrorCode" }
		preferredVisible: dataItem.valid
		ListText {
			text: CommonWords.error
			dataItem.uid: root.bindPrefix + "/ErrorCode"
			secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Error/0/Id" }
		preferredVisible: dataItem.valid
		ListText {
			text: CommonWords.error
			dataItem.uid: root.bindPrefix + "/Error/0/Id"
			secondaryText: dataItem.valid ? AlternatorError.description(dataItem.value) : dataItem.invalidText
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/FieldDrive" }
		preferredVisible: dataItem.valid
		ListQuantity {
			//% "Field drive"
			text: qsTrId("alternator_wakespeed_field_drive")
			dataItem.uid: root.bindPrefix + "/FieldDrive"
			unit: VenusOS.Units_Percentage
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Utilization" }
		preferredVisible: dataItem.valid
		ListQuantity {
			//% "Utilization"
			text: qsTrId("alternator_wakespeed_utilization")
			dataItem.uid: root.bindPrefix + "/Utilization"
			unit: VenusOS.Units_Percentage
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Speed" }
		preferredVisible: dataItem.valid
		ListQuantity {
			text: CommonWords.speed
			dataItem.uid: root.bindPrefix + "/Speed"
			unit: VenusOS.Units_RevolutionsPerMinute
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Engine/Speed" }
		preferredVisible: dataItem.valid
		ListQuantity {
			//% "Engine speed"
			text: qsTrId("alternator_wakespeed_engine_speed")
			dataItem.uid: root.bindPrefix + "/Engine/Speed"
			unit: VenusOS.Units_RevolutionsPerMinute
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Engine/Temperature" }
		preferredVisible: dataItem.valid
		ListTemperature {
			//% "Engine Temperature"
			text: qsTrId("engine_temperature")
			dataItem.uid: root.bindPrefix + "/Engine/Temperature"
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
					settingsPage: root.page,
				})
			}

			VeQuickItem {
				id: setupOutputItem
				uid: bindPrefix + "/Settings/OutputBattery"
			}
		}
	}
}