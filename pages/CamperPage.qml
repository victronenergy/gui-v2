/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Camper

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

	// The /State of every alternator, or -1 where it is not known.
	property list<int> _alternatorStates

	function _updateAlternatorStates() {
		const states = []
		for (let i = 0; i < alternatorStateItems.count; ++i) {
			const item = alternatorStateItems.objectAt(i) as VeQuickItem
			states.push(item?.valid ? item.value : -1)
		}
		_alternatorStates = states
	}

	//% "RV"
	title: qsTrId("nav_rv")
	iconSource: "qrc:/images/overview.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/CamperPage.qml"

	CamperOverviewView {
		id: camperView

		anchors.fill: parent

		colorScheme: Theme.colorScheme === Theme.Light ? 0 : 1
		theme.fontFamily: Global.fontFamily
		theme.quantityFontFamily: Global.quantityFontFamily
		powerFormatter: (watts) => Units.getDisplayText(VenusOS.Units_Watt, watts)

		activeInputSource: Services.acInputs.activeInSourceValid ? Services.acInputs.activeInSource : -1
		acInputSources: [Services.acInputs.input1?.source ?? -1, Services.acInputs.input2?.source ?? -1]
		systemState: systemStateItem.valid ? systemStateItem.value : -1
		inverterChargerPower: inverterChargerPowerItem.valid ? inverterChargerPowerItem.value : NaN
		alternatorStates: root._alternatorStates
		lowSocAlarm: lowSocAlarmItem.valid ? lowSocAlarmItem.value : -1
		veBusLowBatteryAlarm: veBusLowBatteryAlarmItem.valid ? veBusLowBatteryAlarmItem.value : -1
		solarDeviceCount: Services.solar.inputCount

		activeInputPower: Services.acInputs.highlightedInput?.power ?? NaN
		generatorPower: root._generatorInput?.power ?? NaN
		solarPower: Services.system.solar.power
		alternatorPower: alternatorModel.count > 0 ? alternatorModel.totalPower : NaN
		batteryPower: Services.system.battery.power
		batterySoc: Services.system.battery.stateOfCharge
		dcLoadsPower: Services.system.dc.power
		acLoadsPower: Services.system.load.ac.power

		// gui-v2's own words where it has them; the other titles are the view's translated defaults.
		shoreTitle: Services.acInputs.sourceToText(VenusOS.AcInputs_InputSource_Shore)
		gridTitle: CommonWords.grid
		generatorTitle: CommonWords.generator
		dcLoadsTitle: CommonWords.dc
		acLoadsTitle: CommonWords.ac
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

	// One /State item per alternator, so that any running alternator counts as driving.
	Instantiator {
		id: alternatorStateItems

		model: alternatorModel
		delegate: VeQuickItem {
			required property Device device
			uid: device.serviceUid + "/State"
			onValueChanged: Qt.callLater(root._updateAlternatorStates)
		}
		onObjectAdded: Qt.callLater(root._updateAlternatorStates)
		onObjectRemoved: Qt.callLater(root._updateAlternatorStates)
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
