/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Mock

QtObject {
	id: root

	property var _mockDataSources

	property MockDataSimulator mockDataSimulator: MockDataSimulator {
		Component.onCompleted: {
			Global.mockDataSimulator = mockDataSimulator
			_mockDataSources = mockDataSourceComponent.createObject(root)
		}
	}

	property Component mockDataSourceComponent: Component {
		QtObject {
			property var acSystemDevices: AcSystemDevicesImpl { }
			property var acInputs: AcInputsImpl {}
			property var chargers: ChargersImpl { }
			property var batteries: BatteriesImpl {}
			property var dcInputs: DcInputsImpl {}
			property var dcLoads: DcLoadsImpl { }
			property var digitalInput: DigitalInputImpl {}
			property var digitalInputs: DigitalInputsImpl {}
			property var environmentInputs: EnvironmentInputsImpl {}
			property var evChargers: EvChargersImpl {}
			property var generators: GeneratorsImpl {}
			property var heatPumps: HeatPumpsImpl { }
			property var inverterChargers: InverterChargersImpl {}
			property var meteoDevices: MeteoDevicesImpl { }
			property var motorDrives: MotorDrivesImpl { }
			property var notifications: NotificationsImpl {}
			property var pulseMeters: PulseMetersImpl { }
			property var pvInverters: PvInvertersImpl {}
			property var solarDevices: SolarDevicesImpl {}
			property var switches: SwitchesImpl {}
			property var system: SystemImpl {}
			property var systemSettings: SystemSettingsImpl {}
			property var tanks: TanksImpl {}
			property var unsupportedDevices: UnsupportedDevicesImpl { }
		}
	}

	property VeQItemTableModel servicesTableModel: VeQItemTableModel {
		uids: ["mock"]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem

		Component.onCompleted: Global.dataServiceModel = servicesTableModel
	}
}
