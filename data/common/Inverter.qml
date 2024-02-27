/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: inverter

	readonly property int state: _state.value === undefined ? -1 : _state.value

	readonly property VeQuickItem _state: VeQuickItem {
		uid: inverter.serviceUid + "/State"
	}

	readonly property var currentPhase: acOutL3.bindPrefix !== "" ? acOutL3
			: acOutL2.bindPrefix !== "" ? acOutL2
			: acOutL1

	readonly property AcData acOutL1: AcData {
		bindPrefix: _phase.value === 0 || _phase.value === undefined ? inverter.serviceUid + "/Ac/Out/L1" : ""
	}
	readonly property AcData acOutL2: AcData {
		bindPrefix:  _phase.value === 1 ? inverter.serviceUid + "/Ac/Out/L2" : ""
	}
	readonly property AcData acOutL3: AcData {
		bindPrefix:  _phase.value === 2 ? inverter.serviceUid + "/Ac/Out/L3" : ""
	}

	readonly property VeQuickItem _phase: VeQuickItem {
		uid: inverter.serviceUid + "/Settings/System/AcPhase"
	}

	readonly property VeQuickItem _nominalInverterPower: VeQuickItem {
		uid: inverter.serviceUid + "/Ac/Out/NominalInverterPower"
		onValueChanged: if (!!Global.inverters) Global.inverters.refreshNominalInverterPower()
	}

	readonly property VeQuickItem _mode: VeQuickItem {
		uid: inverter.serviceUid + "/Mode"
	}

	readonly property VeQuickItem _modeAdjustable: VeQuickItem {
		uid: inverter.serviceUid + "/ModeIsAdjustable"
	}

	readonly property VeQuickItem _numberOfAcInputs: VeQuickItem {
		uid: inverter.serviceUid + "/Ac/NumberOfAcInputs"
	}

	property bool _valid: deviceInstance.value !== undefined

	on_ValidChanged: addRemoveInverter()

	property DataPoint _backuprestoreState: DataPoint {
		source: "com.victronenergy.backuprestore/Quattromulti/State"
		onValueChanged: addRemoveInverter()
	}

	function addRemoveInverter() {
		if (!!Global.inverters) {
			if (_valid || _backuprestoreState.value !== 0) {
				Global.inverters.addInverter(inverter)
			} else if (!_valid && _backuprestoreState.value === 0) {
				Global.inverters.removeInverter(inverter)
			}
		}
	}

	function setMode(newMode) {
		_mode.setValue(newMode)
	}

	function setCurrentLimit(inputIndex, currentLimit) {
		if (inputIndex < 0 || inputIndex >= inputSettings.count) {
			console.warn("setCurrentLimit(): bad settings index", inputIndex,
					"settings count:", inputSettings.count)
			return
		}
		inputSettings.get(inputIndex).inputSettings.setCurrentLimit(currentLimit)
	}

	function _addInputSettings(settings) {
		let insertionIndex = inputSettings.count
		for (let i = 0; i < inputSettings.count; ++i) {
			if (settings.inputNumber < inputSettings.get(i).inputSettings.inputNumber) {
				insertionIndex = i
				break
			}
		}
		inputSettings.insert(insertionIndex, { inputSettings: settings })
	}

	function _removeInputSettings(settings) {
		for (let i = 0; i < inputSettings.length; ++i) {
			if (inputSettings.get(i).inputSettings.inputNumber === settings.inputNumber) {
				inputSettings.remove(i)
				break
			}
		}
	}

	property Instantiator _acInputSettingsObjects: Instantiator {
		model: _numberOfAcInputs.value || null
		delegate: AcInputSettings {
			inputNumber: model.index + 1
		}

		onObjectAdded: function(index, object) {
			inverter._addInputSettings(object)
		}
		onObjectRemoved: function(index, object) {
			inverter._removeInputSettings(object)
		}
	}
}
