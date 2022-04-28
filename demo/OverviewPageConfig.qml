/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var configs: [
		{
			name: "ESS - AC & DC coupled.  PV Inverter on AC Bus + AC output",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Grid ] },
			solar: { chargers: [ { acPower: 123, dcPower: 456 } ] },
			system: { state: VenusOS.System_State_Inverting, ac: {}, dc: {} },
			battery: { stateOfCharge: 64, current: 1 },
		},
		{
			name: "ESS - AC & DC coupled. PV Inverter on AC Out",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Grid ] },
			solar: { chargers: [ { acPower: 123, dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 73, current: -1 },
		},
		// TODO "ESS - AC & DC coupled. PV Inverter on AC Out (Amps version)",
		{
			name: "Phase self consumption",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Generator ] },
			solar: { chargers: [ { acPower: 123, dcPower: 456 } ] },
			system: { state: VenusOS.System_State_PassThrough, ac: {} },
			battery: { stateOfCharge: 29, current: 1 },
		},
		{
			name: "Off grid",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Generator ] },  // TODO 'stopped' state
			solar: { chargers: [ { acPower: 123, dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 95, current: 1 },
		},
		{
			name: "ESS - AC coupled on AC Output",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Grid ] },  // TODO what does up arrow icon in Grid indicate?
			solar: { chargers: [ { acPower: 123 } ] },
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 100, current: 0 },
		},
		{
			name: "Pure Energy Storage - no PV",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Grid ] },
			// TODO state should be 'Scheduled charging', but not in dbus API?
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Combo one (amps): Shore / DC Generator / Left & Right Alternator / Solar",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ], phaseCount: 3 },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_DcGenerator, VenusOS.DcInputs_InputType_Alternator ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single-phase Shore",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single phase + solar",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Small RV with alternator or small boat",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_Alternator ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Catamaran with wind: Shore / Solar / Left alternator / Right alternator / Wind",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_Alternator, VenusOS.DcInputs_InputType_Wind ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Boat with DC generator",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_DcGenerator, VenusOS.DcInputs_InputType_Alternator, VenusOS.DcInputs_InputType_Wind ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
	]

	function loadConfig(config) {
		Global.demoManager.setAcInputsRequested(config.acInputs)
		Global.demoManager.setDcInputsRequested(config.dcInputs)
		Global.demoManager.setSolarChargersRequested(config.solar)
		Global.demoManager.setSystemRequested(config.system)
		Global.demoManager.setBatteryRequested(config.battery)
	}
}
