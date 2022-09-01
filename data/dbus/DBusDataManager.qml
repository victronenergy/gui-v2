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

	property var veDBus: VeQuickItem { uid: "dbus" }
}
