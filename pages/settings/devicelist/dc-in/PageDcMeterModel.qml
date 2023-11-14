/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ObjectModel {
	id: root

	property string bindPrefix
	property string serviceType

	readonly property bool isSssDcEnergyMeter: productId.value === 0xB013

	property DataPoint monitorMode: DataPoint {
		source: root.bindPrefix + "/Settings/MonitorMode"
	}

	property DataPoint productId: DataPoint {
		source: root.bindPrefix + "/ProductId"
	}

	ListQuantityGroup {
		text: Global.dcInputs.inputTypeToText(Global.dcInputs.inputType(root.serviceType, monitorMode.value))
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
		visible: defaultVisible && dataValid
	}

	ListQuantityItem {
		//% "Aux voltage"
		text: qsTrId("dcmeter_aux_voltage")
		dataSource: root.bindPrefix + "/Dc/1/Voltage"
		unit: VenusOS.Units_Volt
		visible: defaultVisible && dataValid
	}

	ListRelayState {
		dataSource: root.bindPrefix + "/Relay/0/State"
	}

	ListAlarmState {
		dataSource: root.bindPrefix + "/Alarms/Alarm"
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
