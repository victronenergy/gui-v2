/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property bool chargeOrDischargeDisabled: chargeDisabled.value || dischargeDisabled.value || false
	readonly property string serviceUid: BackendConnection.serviceUidForType("system")
	//% "ESS %1"
	readonly property string text: flags.length > 0 ? qsTrId("ess_flags").arg(flags.join(" ")) : ""

	readonly property var flags: {
		var r = []
		for (var i=0; i<flagItems.length; i++) {
			if (flagItems[i].value) r.push('#' + (i+1).toString(16))
		}
		return r
	}

	readonly property alias lowSoc: _lowSoc
	readonly property alias batteryLife: _batteryLife
	readonly property alias chargeDisabled: _chargeDisabled
	readonly property alias dischargeDisabled: _dischargeDisabled
	readonly property alias slowCharge: _slowCharge
	readonly property alias userChargeLimited: _userChargeLimited
	readonly property alias userDischargeLimited: _userDischargeLimited

	// Flags to monitor
	readonly property list<VeQuickItem> flagItems: [
		VeQuickItem { id: _lowSoc;					uid: serviceUid + "/SystemState/LowSoc" },
		VeQuickItem { id: _batteryLife;				uid: serviceUid + "/SystemState/BatteryLife" },
		VeQuickItem { id: _chargeDisabled;			uid: serviceUid + "/SystemState/ChargeDisabled" },
		VeQuickItem { id: _dischargeDisabled;		uid: serviceUid + "/SystemState/DischargeDisabled" },
		VeQuickItem { id: _slowCharge;				uid: serviceUid + "/SystemState/SlowCharge" },
		VeQuickItem { id: _userChargeLimited;		uid: serviceUid + "/SystemState/UserChargeLimited" },
		VeQuickItem { id: _userDischargeLimited;	uid: serviceUid + "/SystemState/UserDischargeLimited" }
	]

	function descriptionText() { // not used yet, will be needed for the new battery charging/discharge design
		if (chargeDisabled.value && dischargeDisabled.value) {
			//% "ESS %1 Charge/Discharge Disabled"
			return qsTrId("systemreason_charge_discharge_disabled").arg(flags.join(" "))
		} else if (chargeDisabled.value) {
			//% "ESS %1 Charge Disabled"
			return qsTrId("systemreason_charge_disabled").arg(flags.join(" "))
		} else if (dischargeDisabled.value) {
			//% "ESS %1 Discharge Disabled"
			return qsTrId("systemreason_discharge_disabled").arg(flags.join(" "))
		}

		return ""
	}
}
