/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Shows the RV illustration. This page is available when /Settings/Gui/CustomIllustration is 1.
*/
SwipeViewPage {
	id: root

	readonly property AcInput _generatorInput: {
		const acInputs = Services.acInputs
		return acInputs.input1?.source === VenusOS.AcInputs_InputSource_Generator ? acInputs.input1
			: acInputs.input2?.source === VenusOS.AcInputs_InputSource_Generator ? acInputs.input2
			: null
	}

	//% "RV"
	title: qsTrId("nav_rv")
	iconSource: "qrc:/images/overview.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/CamperPage.qml"

	CamperOverviewView {
		anchors.fill: parent

		colorScheme: Theme.colorScheme === Theme.Light ? 0 : 1

		activeInputSource: Services.acInputs.activeInSource
		systemState: systemStateItem.valid ? systemStateItem.value : -1
		inverterChargerPower: inverterChargerPowerItem.valid ? inverterChargerPowerItem.value : NaN
		alternatorState: alternatorStateItem.valid ? alternatorStateItem.value : -1
		lowSocAlarm: lowSocAlarmItem.valid ? lowSocAlarmItem.value : 0
		veBusLowBatteryAlarm: veBusLowBatteryAlarmItem.valid ? veBusLowBatteryAlarmItem.value : 0

		solarPresent: Services.solar.inputCount > 0
		generatorPresent: !!root._generatorInput

		activeInputPower: Services.acInputs.highlightedInput?.power ?? NaN
		generatorPower: root._generatorInput?.power ?? NaN
		solarPower: Services.system.solar.power
		alternatorPower: alternatorModel.count > 0 ? alternatorModel.totalPower : NaN
		batteryPower: Services.system.battery.power
		batterySoc: Services.system.battery.stateOfCharge
		dcLoadsPower: Services.system.dc.power
		acLoadsPower: Services.system.load.ac.power

		//% "Shore"
		shoreTitle: qsTrId("camper_card_shore")
		gridTitle: CommonWords.grid
		//% "PV"
		solarTitle: qsTrId("camper_card_solar_pv")
		generatorTitle: CommonWords.generator
		//% "Alternator"
		alternatorTitle: qsTrId("camper_card_alternator")
		//% "DC"
		dcLoadsTitle: qsTrId("camper_card_dc_loads")
		//% "AC"
		acLoadsTitle: qsTrId("camper_card_ac_loads")
	}

	DcMeterDeviceModel {
		id: alternatorModel
		serviceTypes: ["alternator"]
	}

	VeQuickItem {
		id: systemStateItem
		uid: Services.system.serviceUid + "/SystemState/State"
	}

	VeQuickItem {
		id: inverterChargerPowerItem
		uid: Services.system.serviceUid + "/Dc/InverterCharger/Power"
	}

	VeQuickItem {
		id: veBusLowBatteryAlarmItem
		uid: Services.system.veBus.serviceUid ? Services.system.veBus.serviceUid + "/Alarms/LowBattery" : ""
	}

	VeQuickItem {
		id: alternatorStateItem
		uid: alternatorModel.firstObject ? alternatorModel.firstObject.serviceUid + "/State" : ""
	}

	VeQuickItem {
		id: activeBatteryServiceItem
		uid: Services.system.serviceUid + "/ActiveBatteryService"
	}

	VeQuickItem {
		id: lowSocAlarmItem
		uid: {
			if (!activeBatteryServiceItem.valid || AllDevicesModel.count === 0) {
				return ""
			}
			const info = BackendConnection.portableIdInfo(activeBatteryServiceItem.value)
			const device = AllDevicesModel.findDeviceWithTypeAndInstance(info.type, parseInt(info.instance))
			return device ? device.serviceUid + "/Alarms/LowSoc" : ""
		}
	}
}
