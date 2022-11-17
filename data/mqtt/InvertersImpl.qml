/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veServiceIds
	onVeServiceIdsChanged: Qt.callLater(_getInverters)

	property var _inverters: []

	function _getInverters() {
		let inverterIds = []
		for (let i = 0; i < veServiceIds.length; ++i) {
			let id = veServiceIds[i]
			inverterIds.push(id)
		}

		if (Utils.arrayCompare(_inverters, inverterIds) !== 0) {
			_inverters = inverterIds
		}
	}

	readonly property Instantiator _uids: Instantiator {
		property var childIds: []

		onCountChanged: Qt.callLater(_reloadChildIds)

		function _reloadChildIds() {
			let _childIds = []
			for (let i = 0; i < count; ++i) {
				const child = objectAt(i)
				const uid = child.uid
				_childIds.push(uid)
			}
			veServiceIds = _childIds
		}

		model: VeQItemTableModel {
			uids: ["mqtt/vebus"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			property var uid: model.uid
		}
	}

	property Instantiator inverterObjects: Instantiator {
		model: _inverters
		delegate: QtObject {
			id: inverter

			property string uid: modelData
			property string serviceUid: inverter.uid

			property int productId: -1
			property string productName
			property int productType: _productUpperByte === 0x19 || _productUpperByte === 0x26
									  ? VenusOS.Inverters_ProductType_EuProduct
									  : (_productUpperByte === 0x20 || _productUpperByte === 0x27 ? VenusOS.Inverters_ProductType_UsProduct : -1)
			property var ampOptions: productType === VenusOS.Inverters_ProductType_EuProduct
									 ? _euAmpOptions
									 : (productType === VenusOS.Inverters_ProductType_UsProduct ? _usAmpOptions : [])

			/* - Mask the Product id with `0xFF00`
			 * - If the result is `0x1900` or `0x2600` it is an EU model (230VAC)
			 * - If the result is `0x2000` or `0x2700` it is an US model (120VAC)
			 */
			property int _productUpperByte: productId > 0 ? productId / 0x100 : 0
			property var _euAmpOptions: [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ]
			property var _usAmpOptions: [ 10.0, 15.0, 20.0, 30.0, 50.0, 100.0 ]

			property int state: -1
			property int mode: -1
			property bool modeAdjustable

			property int input1Type: -1
			property real currentLimit1: -1.0
			property bool currentLimit1Adjustable

			property int input2Type: -1
			property real currentLimit2: -1.0
			property bool currentLimit2Adjustable

			function setMode(newMode) {
				_mode.setValue(newMode)
			}

			function setCurrentLimit1(newLimit) {
				_currentLimit1.setValue(newLimit)
			}
			function setCurrentLimit2(newLimit) {
				_currentLimit2.setValue(newLimit)
			}

			property bool _valid: productType != -1
			on_ValidChanged: {
				const index = Utils.findIndex(Global.inverters.model, inverter)
				if (_valid && index < 0) {
					Global.inverters.addInverter(inverter)
				} else if (!_valid && index >= 0) {
					Global.inverters.remove(index)
				}
			}

			property VeQuickItem _state: VeQuickItem {
				uid: inverter.serviceUid + "/State"
				onValueChanged: inverter.state = value === undefined ? -1 : value
			}

			property VeQuickItem _productId: VeQuickItem {
				uid: inverter.serviceUid + "/ProductId"
				onValueChanged: inverter.productId = value === undefined ? false : value
			}

			property VeQuickItem _productName: VeQuickItem {
				uid: inverter.serviceUid + "/ProductName"
				onValueChanged: inverter.productName = value === undefined ? "" : value
			}

			property VeQuickItem _mode: VeQuickItem {
				uid: inverter.serviceUid + "/Mode"
				onValueChanged: inverter.mode = value === undefined ? -1 : value
			}

			property VeQuickItem _modeAdjustable: VeQuickItem {
				uid: inverter.serviceUid + "/ModeIsAdjustable"
				onValueChanged: inverter.modeAdjustable = value === undefined ? false : (value > 0)
			}

			property DataPoint _acInput1: DataPoint {
				source: "settings/0/Settings/SystemSetup/AcInput1"
				onValueChanged: inverter.input1Type = value === undefined ? -1 : value
			}
			property VeQuickItem _currentLimit1: VeQuickItem {
				uid: inverter.serviceUid + "/Ac/In/1/CurrentLimit"
				onValueChanged: inverter.currentLimit1 = value === undefined ? -1.0 : value
			}
			property VeQuickItem _currentLimit1Adjustable: VeQuickItem {
				uid: inverter.serviceUid + "/Ac/In/1/CurrentLimitIsAdjustable"
				onValueChanged: inverter.currentLimit1Adjustable = value === undefined ? false : (value > 0)
			}

			property DataPoint _acInput2: DataPoint {
				source: "settings/0/Settings/SystemSetup/AcInput2"
				onValueChanged: inverter.input2Type = value === undefined ? -1 : value
			}
			property VeQuickItem _currentLimit2: VeQuickItem {
				uid: inverter.serviceUid + "/Ac/In/2/CurrentLimit"
				onValueChanged: inverter.currentLimit2 = value === undefined ? -1.0 : value
			}
			property VeQuickItem _currentLimit2Adjustable: VeQuickItem {
				uid: inverter.serviceUid + "/Ac/In/2/CurrentLimitIsAdjustable"
				onValueChanged: inverter.currentLimit2Adjustable = value === undefined ? false : (value > 0)
			}
		}
	}
}
