/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Dbus

QtObject {
	id: root

	property var dcInputs: DcInputsImpl { }
	property var environmentInputs: EnvironmentInputsImpl { }
	property var ess: EssImpl { }
	property var evChargers: EvChargersImpl { }
	property var generators: GeneratorsImpl { }
	property var inverterChargers: InverterChargersImpl {}
	property var notifications: NotificationsImpl {}
	property var pvInverters: PvInvertersImpl { }
	property var systemSettings: SystemSettingsImpl { }
	property var tanks: TanksImpl { }

	property VeQItemTableModel servicesTableModel: VeQItemTableModel {
		uids: ["dbus"]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem

		Component.onCompleted: Global.dataServiceModel = servicesTableModel
	}
}
