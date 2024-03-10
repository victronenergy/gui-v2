/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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

	ListDcOutputQuantityGroup {
		text: Global.dcInputs.inputTypeToText(Global.dcInputs.inputType(root.bindPrefix, monitorMode.value))
		bindPrefix: root.bindPrefix
	}

	ListTemperatureItem {
		text: CommonWords.temperature
		dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
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
