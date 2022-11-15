/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS

QtObject {
	id: root

	property var acInputs: AcInputsImpl { }
	property var battery: BatteryImpl { }
	property var dcInputs: DcInputsImpl { veServiceIds: veMqtt.childIds }
	property var environmentInputs: EnvironmentInputsImpl { veServiceIds: veMqtt.childIds }
	property var ess: EssImpl { }
	property var generators: GeneratorsImpl { veServiceIds: veMqtt.childIds }
	property var inverters: InvertersImpl { veServiceIds: veMqtt.childIds }
	property var notifications: NotificationsImpl {}
	property var relays: RelaysImpl {}
	property var solarChargers: SolarChargersImpl { veServiceIds: veMqtt.childIds }
	property var system: SystemImpl { }
	property var systemSettings: SystemSettingsImpl { }
	property var tanks: TanksImpl { }

	property Instantiator veMqtt:  Instantiator {
		property var childIds: []

		function _reloadChildIds() {
			let _childIds = []
			for (let i = 0; i < count; ++i) {
				const child = objectAt(i)
				const uid = child.uid.substring(5)    // remove 'mqtt/' from start of string
				_childIds.push(uid)
			}
			childIds = _childIds
		}

		model: VeQItemTableModel {
			uids: ["mqtt"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			property var uid: model.uid
		}

		onCountChanged: Qt.callLater(_reloadChildIds)
	}
}
