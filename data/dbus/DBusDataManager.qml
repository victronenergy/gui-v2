/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS

QtObject {
	id: root

	property var acInputs: AcInputsImpl { }
	property var battery: BatteryImpl { veSystem: root.veSystem }
	property var dcInputs: DcInputsImpl { veDBus: root.veDBus }
	property var environmentInputs: EnvironmentInputsImpl { veDBus: root.veDBus }
	property var ess: EssImpl { veSettings: root.veSettings }
	property var generators: GeneratorsImpl { veDBus: root.veDBus }
	property var inverters: InvertersImpl { veDBus: root.veDBus; veSettings: root.veSettings }
	property var notifications: NotificationsImpl {}
	property var relays: RelaysImpl {}
	property var solarChargers: SolarChargersImpl { veDBus: root.veDBus }
	property var system: SystemImpl { veDBus: root.veDBus; veSystem: root.veSystem }
	property var systemSettings: SystemSettingsImpl { veSettings: root.veSettings }
	property var tanks: TanksImpl { veDBus: root.veDBus }

	// Commonly used dbus objects
	property var veDBus: VeQuickItem { uid: "dbus" }
	property var veSystem: VeQuickItem { uid: "dbus/com.victronenergy.system" }
	property var veSettings: VeQuickItem { uid: "dbus/com.victronenergy.settings" }
}
