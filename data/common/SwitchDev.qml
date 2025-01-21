/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS


Device {
	id: switchDev
	//% "%1 %2"
	property string _instProductName: (_deviceInstance.isValid && _productName.isValid) ? qsTrId("switchDev_InstProductName").arg (_productName.value).arg(_deviceInstance.value) : productName.value
	name: _customName.value || _instProductName || ""

	readonly property int state: _state.isValid ? _state.value : -1

	readonly property VeQuickItem _state: VeQuickItem {
		uid: switchDev.serviceUid + "/State"
	}
	property VeQItemTableModel channels: VeQItemTableModel {
		uids:  switchDev.serviceUid + "/Channel"
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}


	onValidChanged: {
		if (!!Global.switches) {
			if (valid) {
				Global.switches.model.addDevice(switchDev)
			} else {
				Global.switches.model.removeDevice(switchDev.serviceUid)
			}
		}
	}
}
