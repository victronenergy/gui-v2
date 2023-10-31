/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Device {
	id: veBusDevice

	readonly property int state: _state.value === undefined ? -1 : _state.value
	readonly property int mode: _mode.value === undefined ? -1 : _mode.value
	readonly property bool modeAdjustable: _modeAdjustable.value !== undefined && _modeAdjustable.value > 0
	readonly property real nominalInverterPower: _nominalInverterPower.value === undefined ? NaN : _nominalInverterPower.value

	readonly property int numberOfAcInputs: _numberOfAcInputs.value === undefined ? NaN : _numberOfAcInputs.value
	readonly property bool isMulti: !isNaN(numberOfAcInputs) && numberOfAcInputs !== 0

	property ListModel inputSettings: ListModel {}


	readonly property int productId: _productId.value === undefined ? -1 : _productId.value
	readonly property int productType: _productUpperByte === 0x19 || _productUpperByte === 0x26
			? VenusOS.VeBusDevice_ProductType_EuProduct
			: (_productUpperByte === 0x20 || _productUpperByte === 0x27 ? VenusOS.VeBusDevice_ProductType_UsProduct : -1)
	readonly property var ampOptions: productType === VenusOS.VeBusDevice_ProductType_EuProduct
			? _euAmpOptions
			: (productType === VenusOS.VeBusDevice_ProductType_UsProduct ? _usAmpOptions : [])

	/* - Mask the Product id with `0xFF00`
	 * - If the result is `0x1900` or `0x2600` it is an EU model (230VAC)
	 * - If the result is `0x2000` or `0x2700` it is an US model (120VAC)
	 */
	readonly property int _productUpperByte: productId > 0 ? productId / 0x100 : 0
	readonly property var _euAmpOptions: [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ].map(function(v) { return { value: v } })
	readonly property var _usAmpOptions: [ 10.0, 15.0, 20.0, 30.0, 50.0, 100.0 ].map(function(v) { return { value: v } })

	readonly property VeQuickItem _state: VeQuickItem {
		uid: veBusDevice.serviceUid + "/State"
	}

	readonly property VeQuickItem _productId: VeQuickItem {
		uid: veBusDevice.serviceUid + "/ProductId"
	}

	readonly property VeQuickItem _nominalInverterPower: VeQuickItem {
		uid: veBusDevice.serviceUid + "/Ac/Out/NominalInverterPower"
		onValueChanged: if (!!Global.veBusDevices) Global.veBusDevices.refreshNominalInverterPower()
	}

	readonly property VeQuickItem _mode: VeQuickItem {
		uid: veBusDevice.serviceUid + "/Mode"
	}

	readonly property VeQuickItem _modeAdjustable: VeQuickItem {
		uid: veBusDevice.serviceUid + "/ModeIsAdjustable"
	}

	readonly property VeQuickItem _numberOfAcInputs: VeQuickItem {
		uid: veBusDevice.serviceUid + "/Ac/NumberOfAcInputs"
	}

	onValidChanged: {
		if (!!Global.veBusDevices) {
			if (valid) {
				Global.veBusDevices.addVeBusDevice(veBusDevice)
			} else {
				Global.veBusDevices.removeVeBusDevice(veBusDevice)
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
			serviceUid: veBusDevice.serviceUid
			inputNumber: model.index + 1
		}

		onObjectAdded: function(index, object) {
			veBusDevice._addInputSettings(object)
		}
		onObjectRemoved: function(index, object) {
			veBusDevice._removeInputSettings(object)
		}
	}
}
