/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS


Device {
	id: root
	//% "%1 %2"
	property string _instProductName: (_deviceInstance.isValid && _productName.isValid) ? qsTrId("switchDev_InstProductName").arg (_productName.value).arg(_deviceInstance.value) : productName.value
	name: _customName.value || _instProductName || ""

	readonly property int state: _state.isValid ? _state.value : -1

	readonly property VeQuickItem _state: VeQuickItem {
		uid: root.serviceUid + "/State"
	}
	property VeQItemTableModel switchableOutputs: VeQItemTableModel {
		uids:  root.serviceUid + "/SwitchableOutput"

		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}


	onValidChanged: {
		if (!!Global.switches) {
			if (valid) {
				Global.switches.model.addDevice(root)
			} else {
				Global.switches.model.removeDevice(root.serviceUid)
			}
		}
	}
}
