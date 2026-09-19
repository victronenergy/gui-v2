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
		colorScheme: Theme.colorScheme === Theme.Light ? 0 : 1
		shorePower: _shorePower.valid ? _shorePower.value : 0
		solar: _solar.valid ? _solar.value : 1
		solarPower: _solarPower.valid ? _solarPower.value : 0
		alternatorPower: _alternatorPower.valid ? _alternatorPower.value : 300
		generator: _generator.valid ? _generator.value : 0
		generatorPower: _generatorPower.valid ? _generatorPower.value : 0

		batteryPower: Global.system.dc.hasPower ? root._finiteOrNaN(_batteryPower) : NaN
		batterySoc: root._finiteOrNaN(_batterySocItem)
		dcLoadsPower: _dcPower.valid ? _dcPower.value : 0
		acLoadsPower: _acPower.valid ? _acPower.value : 0
	}

	VeQuickItem {
		id: _batterySocItem
		uid: root._systemServiceUid ? root._systemServiceUid + "/Dc/Battery/Soc"
			: ""
	}

	VeQuickItem {
		id: _batteryPower
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/BatteryPower"
			: ""
	}

	VeQuickItem {
		id: _shorePower
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/ShorePower"
			: ""
	}

	VeQuickItem {
		id: _solar
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/Solar"
			: ""
	}

	VeQuickItem {
		id: _solarPower
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/SolarPower"
			: ""
	}

	VeQuickItem {
		id: _generator
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/Generator"
			: ""
	}

	VeQuickItem {
		id: _generatorPower
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/GeneratorPower"
			: ""
	}

	VeQuickItem {
		id: _alternatorPower
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/AlternatorPower"
			: ""
	}

	VeQuickItem {
		id: _dcPower
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/DcPower"
			: ""
	}

	VeQuickItem {
		id: _acPower
		uid: root._systemServiceUid ? root._systemServiceUid + "/Settings/Camper/AcPower"
			: ""
	}
}
