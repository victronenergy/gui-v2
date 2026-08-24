/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string _systemServiceUid: BackendConnection.serviceUidForType("system")
	readonly property string _alternatorServiceUid: BackendConnection.serviceUidForType("alternator")
	readonly property int _inputSourceNotAvailable: 0

	function _inputSourceOrNotAvailable(item) {
		return item.valid ? Number(item.value)
				: _inputSourceNotAvailable
	}

	function _finiteOrNaN(item) {
		return item.valid && isFinite(Number(item.value)) ? Number(item.value)
				: NaN
	}

	CamperOverviewView {
		anchors.fill: parent
		activeInputSource: root._inputSourceOrNotAvailable(_activeInputSourceItem)
		activeInputPower: root._finiteOrNaN(_activeInputPowerItem)
		solarDcPower: root._finiteOrNaN(_solarDcPowerItem)
		solarAcL1Power: root._finiteOrNaN(_solarAcL1PowerItem)
		solarAcL2Power: root._finiteOrNaN(_solarAcL2PowerItem)
		solarAcL3Power: root._finiteOrNaN(_solarAcL3PowerItem)
		batteryPower: root._finiteOrNaN(_batteryPowerItem)
		batterySoc: root._finiteOrNaN(_batterySocItem)
		alternatorPower: root._finiteOrNaN(_alternatorPowerItem)
		dcLoadsPower: root._finiteOrNaN(_dcLoadsPowerItem)
		acLoadsL1Power: root._finiteOrNaN(_acLoadsL1PowerItem)
		acLoadsL2Power: root._finiteOrNaN(_acLoadsL2PowerItem)
		acLoadsL3Power: root._finiteOrNaN(_acLoadsL3PowerItem)
	}

	VeQuickItem {
		id: _activeInputSourceItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Ac/ActiveIn/Source"
			: ""
	}

	VeQuickItem {
		id: _activeInputPowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Ac/ActiveIn/P"
			: ""
	}

	VeQuickItem {
		id: _solarDcPowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Dc/Pv/Power"
			: ""
	}

	VeQuickItem {
		id: _solarAcL1PowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Ac/PvOnOutput/L1/Power"
			: ""
	}

	VeQuickItem {
		id: _solarAcL2PowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Ac/PvOnOutput/L2/Power"
			: ""
	}

	VeQuickItem {
		id: _solarAcL3PowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Ac/PvOnOutput/L3/Power"
			: ""
	}

	VeQuickItem {
		id: _batteryPowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Dc/Battery/Power"
			: ""
	}

	VeQuickItem {
		id: _batterySocItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Dc/Battery/Soc"
			: ""
	}

	VeQuickItem {
		id: _alternatorPowerItem
		uid: root._alternatorServiceUid ? root._alternatorServiceUid + "/Dc/0/Power"
			: ""
	}

	VeQuickItem {
		id: _dcLoadsPowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Dc/System/Power"
			: ""
	}

	VeQuickItem {
		id: _acLoadsL1PowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Ac/Consumption/L1/Power"
			: ""
	}

	VeQuickItem {
		id: _acLoadsL2PowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Ac/Consumption/L2/Power"
			: ""
	}

	VeQuickItem {
		id: _acLoadsL3PowerItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Ac/Consumption/L3/Power"
			: ""
	}
}
