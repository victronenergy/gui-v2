/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	enum ProductType {
		EuProduct = 0,
		UsProduct = 1
	}

	enum InverterMode {
		ChargerOnly = 1,
		InverterOnly = 2,
		On = 3,
		Off = 4
	}

	enum InputType {
		Unused = 0,
		Grid = 1,
		Generator = 2,
		Shore = 3
	}

	property ListModel model: ListModel {}

	property var _inverters: []

	function _getInverters() {
		const childIds = veConfig.childIds

		let inverterIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (!isNaN(parseInt(id))) {
				inverterIds.push(id)
			}
		}

		if (Utils.arrayCompare(_inverters, inverterIds) !== 0) {
			_inverters = inverterIds
		}
	}

	VeQuickItem {
		id: veConfig
		uid: "dbus/com.victronenergy.system/Ac/In"
	}

	Connections {
		target: veConfig
		function onChildIdsChanged() { Qt.callLater(_getInverters) }
		Component.onCompleted: _getInverters()
	}

	Instantiator {
		model: _inverters
		delegate: QtObject {
			id: inverter

			property string uid: modelData
			property string configUid: veConfig.uid + "/" + inverter.uid

			property string serviceType
			property string serviceName
			property int productId: -1
			property int productType: _productUpperByte === 0x19 || _productUpperByte === 0x26
									  ? Inverters.EuProduct
									  : (_productUpperByte === 0x20 || _productUpperByte === 0x27 ? Inverters.UsProduct : -1)
			property var ampOptions: productType === Inverters.EuProduct
									 ? _euAmpOptions
									 : (productType === Inverters.UsProduct ? _usAmpOptions : [])

			/* - Mask the Product id with `0xFF00`
			 * - If the result is `0x1900` or `0x2600` it is an EU model (230VAC)
			 * - If the result is `0x2000` or `0x2700` it is an US model (120VAC)
			 */
			property int _productUpperByte: productId > 0 ? productId / 0x100 : 0
			property var _euAmpOptions: [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ]
			property var _usAmpOptions: [ 10.0, 15.0, 20.0, 30.0, 50.0, 100.0 ]

			property int mode: -1
			property bool modeAdjustable

			property int input1Type: -1
			property real currentLimit1: -1.0
			property bool currentLimit1Adjustable

			property int input2Type: -1
			property real currentLimit2: -1.0
			property bool currentLimit2Adjustable

			function setMode(newMode) {
				_mode.value = newMode
			}

			function setCurrentLimit1(newLimit) {
				_currentLimit1.value = newLimit
			}
			function setCurrentLimit2(newLimit) {
				_currentLimit2.value = newLimit
			}

			property bool _valid: productType != -1
			on_ValidChanged: {
				const index = Utils.findIndex(root.model, inverter)
				if (_valid && index < 0) {
					root.model.append({ inverter: inverter })
				} else if (!_valid && index >= 0) {
					root.model.remove(index)
				}
			}

			property string _serviceUid: serviceName ? 'dbus/' + serviceName : ''
			property string _valuesUid: serviceName ? 'dbus/' + serviceName + "/Ac/In" : ''

			property VeQuickItem _serviceType: VeQuickItem {
				uid: configUid + "/ServiceType"
				onValueChanged: inverter.serviceType = value === undefined ? '' : value
			}
			property VeQuickItem _service: VeQuickItem {
				uid: configUid + "/ServiceName"
				onValueChanged: inverter.serviceName = value === undefined ? '' : value
			}

			property VeQuickItem _productId: VeQuickItem {
				uid: _serviceUid ? _serviceUid + "/ProductId" : ''
				onValueChanged: inverter.productId = value === undefined ? false : value
			}

			property VeQuickItem _mode: VeQuickItem {
				uid: _serviceUid ? _serviceUid + "/Mode" : ''
				onValueChanged: inverter.mode = value === undefined ? -1 : value
			}
			property VeQuickItem _modeAdjustable: VeQuickItem {
				uid: _serviceUid ? _serviceUid + "/ModeIsAdjustable" : ''
				onValueChanged: inverter.modeAdjustable = value === undefined ? false : (value > 0)
			}

			property VeQuickItem _acInput1: VeQuickItem {
				uid: veSettings.uid + "/Settings/SystemSetup/AcInput1"
				onValueChanged: inverter.input1Type = value === undefined ? -1 : value
			}
			property VeQuickItem _currentLimit1: VeQuickItem {
				uid: _valuesUid ? _valuesUid + "/1/CurrentLimit" : ''
				onValueChanged: inverter.currentLimit1 = value === undefined ? -1.0 : value
			}
			property VeQuickItem _currentLimit1Adjustable: VeQuickItem {
				uid: _valuesUid ? _valuesUid + "/1/CurrentLimitIsAdjustable" : ''
				onValueChanged: inverter.currentLimit1Adjustable = value === undefined ? false : (value > 0)
			}

			property VeQuickItem _acInput2: VeQuickItem {
				uid: veSettings.uid + "/Settings/SystemSetup/AcInput2"
				onValueChanged: inverter.input2Type = value === undefined ? -1 : value
			}
			property VeQuickItem _currentLimit2: VeQuickItem {
				uid: _valuesUid ? _valuesUid + "/2/CurrentLimit" : ''
				onValueChanged: inverter.currentLimit2 = value === undefined ? -1.0 : value
			}
			property VeQuickItem _currentLimit2Adjustable: VeQuickItem {
				uid: _valuesUid ? _valuesUid + "/2/CurrentLimitIsAdjustable" : ''
				onValueChanged: inverter.currentLimit2Adjustable = value === undefined ? false : (value > 0)
			}
		}
	}
}
