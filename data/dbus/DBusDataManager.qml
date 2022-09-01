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
	property var dcInputs: DcInputsImpl { veDBus: root.veDBus }
	property var environmentInputs: EnvironmentInputsImpl { veDBus: root.veDBus }
	property var ess: EssImpl { }
	property var generators: GeneratorsImpl { veDBus: root.veDBus }
	property var inverters: InvertersImpl { veDBus: root.veDBus }
	property var notifications: NotificationsImpl {}
	property var relays: RelaysImpl {}
	property var solarChargers: SolarChargersImpl { veDBus: root.veDBus }
	property var system: SystemImpl { }
	property var systemSettings: SystemSettingsImpl { }
	property var tanks: TanksImpl { veDBus: root.veDBus }

	// Commonly used dbus objects
	property var veDBus: VeQuickItem { uid: "dbus" }
	property var veSystem: VeQuickItem { uid: "dbus/com.victronenergy.system" }
}
