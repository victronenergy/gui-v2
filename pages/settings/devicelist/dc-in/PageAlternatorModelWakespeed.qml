/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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

		DataPoint {
			id: dcVoltage
			source: root.bindPrefix + "/Dc/0/Voltage"
		}
		DataPoint {
			id: dcCurrent
			source: root.bindPrefix + "/Dc/0/Current"
		}
		DataPoint {
			id: dcPower
			source: root.bindPrefix + "/Dc/0/Power"
		}
	}

	ListQuantityItem {
		text: CommonWords.temperature
		dataSource: root.bindPrefix + "/Dc/0/Temperature"
		value: dataValid ? Global.systemSettings.convertTemperature(dataValue) : NaN
		unit: Global.systemSettings.temperatureUnit.value
	}

	ListTextItem {
		text: CommonWords.state
		secondaryText: Global.systemSettings.networkStatusToText(dataValue)
		dataSource: root.bindPrefix + "/Link/NetworkStatus"
		visible: defaultVisible && dataValid
	}

	ListTextItem {
		text: CommonWords.error
		dataSource: root.bindPrefix + "/ErrorCode"

		// TODO get error description from WakespeedError when it is ported from velib -> veutil
		secondaryText: dataValid  ? (dataValue === 0 ? CommonWords.no_error : "#" + dataValue) : ""
	}

	ListQuantityItem {
		//% "Field drive"
		text: qsTrId("alternator_wakespeed_field_drive")
		dataSource: root.bindPrefix + "/FieldDrive"
		unit: VenusOS.Units_Percentage
	}

	ListQuantityItem {
		text: CommonWords.speed
		dataSource: root.bindPrefix + "/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
	}

	ListQuantityItem {
		//% "Engine speed"
		text: qsTrId("alternator_wakespeed_engine_speed")
		dataSource: root.bindPrefix + "/Engine/Speed"
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
