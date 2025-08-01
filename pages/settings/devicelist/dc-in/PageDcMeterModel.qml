/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VisibleItemModel {
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
		text: VenusOS.dcMeter_typeToText(VenusOS.dcMeter_type(BackendConnection.serviceTypeFromUid(root.bindPrefix), monitorMode.value))
		bindPrefix: root.bindPrefix
	}

	ListTemperature {
		text: CommonWords.temperature
		dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
		preferredVisible: dataItem.valid
	}

	ListQuantity {
		//% "Aux voltage"
		text: qsTrId("dcmeter_aux_voltage")
		dataItem.uid: root.bindPrefix + "/Dc/1/Voltage"
		unit: VenusOS.Units_Volt_DC
		preferredVisible: dataItem.valid
	}

	ListRelayState {
		dataItem.uid: root.bindPrefix + "/Relay/0/State"
	}

	ListAlarmState {
		dataItem.uid: root.bindPrefix + "/Alarms/Alarm"
	}

	ListNavigation {
		text: CommonWords.alarms
		preferredVisible: !isSssDcEnergyMeter
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeterAlarms.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}

	ListNavigation {
		text: CommonWords.history
		preferredVisible: !isSssDcEnergyMeter
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeterHistory.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}
