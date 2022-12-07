/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "../../demo" as Demo

QtObject {
	id: root

	property var _mockDataSources

	property Demo.DemoManager demoManager: Demo.DemoManager {
		Component.onCompleted: {
			Global.demoManager = demoManager
			_mockDataSources = mockDataSourceComponent.createObject(root)
		}
	}

	property Component mockDataSourceComponent: Component {
		QtObject {
			property var acInputs: AcInputsImpl {}
			property var battery: BatteryImpl {}
			property var dcInputs: DcInputsImpl {}
			property var environmentInputs: EnvironmentInputsImpl {}
			property var ess: EssImpl {}
			property var generators: GeneratorsImpl {}
			property var inverters: InvertersImpl {}
			property var notifications: NotificationsImpl {}
			property var relays: RelaysImpl {}
			property var solarChargers: SolarChargersImpl {}
			property var system: SystemImpl {}
			property var systemSettings: SystemSettingsImpl {}
			property var tanks: TanksImpl {}
		}
	}
}
