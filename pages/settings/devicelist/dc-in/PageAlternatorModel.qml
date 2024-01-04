/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

ObjectModel {
	id: root

	property string bindPrefix

	ListQuantityGroup {
		//% "Output"
		text: qsTrId("alternator_wakespeed_output")
		textModel: [
			{ value: dcVoltage.value, unit: VenusOS.Units_Volt },
			{ value: dcCurrent.value, unit: VenusOS.Units_Amp },
			{ value: dcPower.value, unit: VenusOS.Units_Watt },
		]

		VeQuickItem {
			id: dcVoltage
			uid: root.bindPrefix + "/Dc/0/Voltage"
		}
		VeQuickItem {
			id: dcCurrent
			uid: root.bindPrefix + "/Dc/0/Current"
		}
		VeQuickItem {
			id: dcPower
			uid: root.bindPrefix + "/Dc/0/Power"
		}
	}

	ListQuantityItem {
		text: CommonWords.temperature
		dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
		value: dataItem.isValid ? Global.systemSettings.convertTemperature(dataItem.value) : NaN
		unit: Global.systemSettings.temperatureUnit.value
	}

	ListTextItem {
		text: CommonWords.state
		secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
		dataItem.uid: root.bindPrefix + "/Link/NetworkStatus"
		visible: defaultVisible && dataItem.isValid
	}

	ListTextItem {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/ErrorCode"

		// TODO get error description from WakespeedError when it is ported from velib -> veutil
		secondaryText: dataItem.isValid  ? (dataItem.value === 0 ? CommonWords.no_error : "#" + dataItem.value) : ""
	}

	ListQuantityItem {
		//% "Field drive"
		text: qsTrId("alternator_wakespeed_field_drive")
		dataItem.uid: root.bindPrefix + "/FieldDrive"
		unit: VenusOS.Units_Percentage
	}

	ListQuantityItem {
		text: CommonWords.speed
		dataItem.uid: root.bindPrefix + "/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
	}

	ListQuantityItem {
		//% "Engine speed"
		text: qsTrId("alternator_wakespeed_engine_speed")
		dataItem.uid: root.bindPrefix + "/Engine/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
	}

	ListNavigationItem {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}
