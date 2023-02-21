/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: inverter

	property string serviceUid

	readonly property int productId: _productId.value === undefined ? -1 : _productId.value
	readonly property string productName: _productName.value || ""
	readonly property int productType: _productUpperByte === 0x19 || _productUpperByte === 0x26
			? VenusOS.Inverters_ProductType_EuProduct
			: (_productUpperByte === 0x20 || _productUpperByte === 0x27 ? VenusOS.Inverters_ProductType_UsProduct : -1)
	readonly property var ampOptions: productType === VenusOS.Inverters_ProductType_EuProduct
			? _euAmpOptions
			: (productType === VenusOS.Inverters_ProductType_UsProduct ? _usAmpOptions : [])

	readonly property int state: _state.value === undefined ? -1 : _state.value
	readonly property int mode: _mode.value === undefined ? -1 : _mode.value
	readonly property bool modeAdjustable: _modeAdjustable.value !== undefined && _modeAdjustable.value > 0

	readonly property int input1Type: _acInput1.value === undefined ? -1 : _acInput1.value
	readonly property real currentLimit1: _currentLimit1.value === undefined ? -1 : _currentLimit1.value
	readonly property bool currentLimit1Adjustable: _currentLimit1Adjustable.value !== undefined && _currentLimit1Adjustable.value > 0

	readonly property int input2Type: _acInput2.value === undefined ? -1 : _acInput2.value
	readonly property real currentLimit2: _currentLimit2.value === undefined ? -1 : _currentLimit2.value
	readonly property bool currentLimit2Adjustable: _currentLimit2Adjustable.value !== undefined && _currentLimit2Adjustable.value > 0

	/* - Mask the Product id with `0xFF00`
	 * - If the result is `0x1900` or `0x2600` it is an EU model (230VAC)
	 * - If the result is `0x2000` or `0x2700` it is an US model (120VAC)
	 */
	readonly property int _productUpperByte: productId > 0 ? productId / 0x100 : 0
	readonly property var _euAmpOptions: [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ]
	readonly property var _usAmpOptions: [ 10.0, 15.0, 20.0, 30.0, 50.0, 100.0 ]

	function setMode(newMode) {
		_mode.setValue(newMode)
	}

	function setCurrentLimit1(newLimit) {
		_currentLimit1.setValue(newLimit)
	}
	function setCurrentLimit2(newLimit) {
		_currentLimit2.setValue(newLimit)
	}

	readonly property VeQuickItem _state: VeQuickItem {
		uid: inverter.serviceUid + "/State"
	}

	readonly property VeQuickItem _productId: VeQuickItem {
		uid: inverter.serviceUid + "/ProductId"
	}

	readonly property VeQuickItem _productName: VeQuickItem {
		uid: inverter.serviceUid + "/ProductName"
	}

	readonly property VeQuickItem _mode: VeQuickItem {
		uid: inverter.serviceUid + "/Mode"
	}

	readonly property VeQuickItem _modeAdjustable: VeQuickItem {
		uid: inverter.serviceUid + "/ModeIsAdjustable"
	}

	property DataPoint _acInput1: DataPoint {
		source: "com.victronenergy.settings/Settings/SystemSetup/AcInput1"
	}
	readonly property VeQuickItem _currentLimit1: VeQuickItem {
		uid: inverter.serviceUid + "/Ac/In/1/CurrentLimit"
	}
	readonly property VeQuickItem _currentLimit1Adjustable: VeQuickItem {
		uid: inverter.serviceUid + "/Ac/In/1/CurrentLimitIsAdjustable"
	}

	property DataPoint _acInput2: DataPoint {
		source: "com.victronenergy.settings/Settings/SystemSetup/AcInput2"
	}
	readonly property VeQuickItem _currentLimit2: VeQuickItem {
		uid: inverter.serviceUid + "/Ac/In/2/CurrentLimit"
	}
	readonly property VeQuickItem _currentLimit2Adjustable: VeQuickItem {
		uid: inverter.serviceUid + "/Ac/In/2/CurrentLimitIsAdjustable"
	}
}
