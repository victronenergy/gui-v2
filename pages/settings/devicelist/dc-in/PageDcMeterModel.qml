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

	readonly property bool isSssDcEnergyMeter: productId.value === 0xB013

	property VeQuickItem monitorMode: VeQuickItem {
		uid: root.bindPrefix + "/Settings/MonitorMode"
	}

	property VeQuickItem productId: VeQuickItem {
		uid: root.bindPrefix + "/ProductId"
	}

	ListQuantityGroup {
		text: Global.dcInputs.inputTypeToText(Global.dcInputs.inputType(root.bindPrefix, monitorMode.value))
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
		visible: defaultVisible && dataItem.isValid
	}

	ListQuantityItem {
		//% "Aux voltage"
		text: qsTrId("dcmeter_aux_voltage")
		dataItem.uid: root.bindPrefix + "/Dc/1/Voltage"
		unit: VenusOS.Units_Volt
		visible: defaultVisible && dataItem.isValid
	}

	ListRelayState {
		dataItem.uid: root.bindPrefix + "/Relay/0/State"
	}

	ListAlarmState {
		dataItem.uid: root.bindPrefix + "/Alarms/Alarm"
	}

	ListNavigationItem {
		text: CommonWords.alarms
		visible: !isSssDcEnergyMeter
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeterAlarms.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}

	ListNavigationItem {
		text: CommonWords.history
		visible: !isSssDcEnergyMeter
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeterHistory.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}

	ListNavigationItem {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}
