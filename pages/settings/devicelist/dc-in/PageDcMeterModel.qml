/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DelegateComponentModel {
	id: root

	property string bindPrefix

	readonly property bool isSssDcEnergyMeter: productId.value === 0xB013

	readonly property VeQuickItem productId: VeQuickItem {
		uid: root.bindPrefix + "/ProductId"
	}

	DelegateComponent {
		id: monitorModeDC
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/MonitorMode" }
		ListDcOutputQuantityGroup {
			text: VenusOS.dcMeter_typeToText(VenusOS.dcMeter_type(BackendConnection.serviceTypeFromUid(root.bindPrefix), monitorModeDC.dataItem.value))
			bindPrefix: root.bindPrefix
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Dc/0/Temperature" }
		preferredVisible: dataItem.valid
		ListTemperature {
			text: CommonWords.temperature
			dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Dc/1/Voltage" }
		preferredVisible: dataItem.valid
		ListQuantity {
			//% "Aux voltage"
			text: qsTrId("dcmeter_aux_voltage")
			dataItem.uid: root.bindPrefix + "/Dc/1/Voltage"
			unit: VenusOS.Units_Volt_DC
		}
	}

	DelegateComponent {
		ListRelayState {
			dataItem.uid: root.bindPrefix + "/Relay/0/State"
		}
	}

	DelegateComponent {
		ListAlarmState {
			dataItem.uid: root.bindPrefix + "/Alarms/Alarm"
		}
	}

	DelegateComponent {
		preferredVisible: !isSssDcEnergyMeter
		ListNavigation {
			text: CommonWords.alarms
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeterAlarms.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}
		}
	}

	DelegateComponent {
		preferredVisible: !isSssDcEnergyMeter
		ListNavigation {
			text: CommonWords.history
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeterHistory.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}
		}
	}
}