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
	property var dcInputs: DcInputsImpl { veServiceIds: veDBus.childIds }
	property var environmentInputs: EnvironmentInputsImpl { veServiceIds: veDBus.childIds }
	property var ess: EssImpl { }
	property var generators: GeneratorsImpl { veServiceIds: veDBus.childIds }
	property var inverters: InvertersImpl { veServiceIds: veDBus.childIds }
	property var notifications: NotificationsImpl {}
	property var relays: RelaysImpl {}
	property var solarChargers: SolarChargersImpl { veServiceIds: veDBus.childIds }
	property var system: SystemImpl { }
	property var systemSettings: SystemSettingsImpl { }
	property var tanks: TanksImpl { veServiceIds: veDBus.childIds }

	property Instantiator veDBus:  Instantiator {
		property var childIds: []

		function _reloadChildIds() {
			let _childIds = []
			for (let i = 0; i < count; ++i) {
				const child = objectAt(i)
				const uid = child.uid.substring(5)    // remove 'dbus/' from start of string
				_childIds.push(uid)
			}
			childIds = _childIds
			Global.dataServices = childIds
		}

		model: VeQItemTableModel {
			uids: ["dbus"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			property var uid: model.uid
		}

		onCountChanged: Qt.callLater(_reloadChildIds)
	}
}
