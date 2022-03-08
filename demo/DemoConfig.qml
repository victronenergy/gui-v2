/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data" as DBusData

Item {
	id: root

	property var overviewConfigs: [
		{
			name: "ESS - AC & DC coupled.  PV Inverter on AC Bus + AC output",
			acInputs: { types: [ DBusData.AcInputs.Grid ] },
			solar: {},
			system: { state: DBusData.System.State.Inverting, ac: {}, dc: {} },
			battery: { stateOfCharge: 64, current: 1 },
		},
		{
			name: "ESS - AC & DC coupled. PV Inverter on AC Out",
			acInputs: { types: [ DBusData.AcInputs.Grid ] },
			solar: {},
			system: { state: DBusData.System.State.AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 73, current: -1 },
		},
		// TODO "ESS - AC & DC coupled. PV Inverter on AC Out (Amps version)",
		{
			name: "Phase self consumption",
			acInputs: { types: [ DBusData.AcInputs.Generator ] },
			solar: {},
			system: { state: DBusData.System.State.PassThrough, ac: {} },
			battery: { stateOfCharge: 29, current: 1 },
		},
		{
			name: "Off grid",
			acInputs: { types: [ DBusData.AcInputs.Generator ] },  // TODO 'stopped' state
			solar: {},
			system: { state: DBusData.System.State.AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 95, current: 1 },
		},
		{
			name: "ESS - AC coupled on AC Output",
			acInputs: { types: [ DBusData.AcInputs.Grid ] },  // TODO what does up arrow icon in Grid indicate?
			solar: {},
			system: { state: DBusData.System.State.FloatCharging, ac: {} },
			battery: { stateOfCharge: 100, current: 0 },
		},
		{
			name: "Pure Energy Storage - no PV",
			acInputs: { types: [ DBusData.AcInputs.Grid ] },
			// TODO state should be 'Scheduled charging', but not in dbus API?
			system: { state: DBusData.System.State.FloatCharging, ac: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Combo (amps): Shore / DC Generator / Left & Right Alternator / Solar",
			acInputs: { types: [ DBusData.AcInputs.Shore ], phases: 3 },
			dcInputs: { types: [ DBusData.DcInputs.DcGenerator, DBusData.DcInputs.Alternator ] },
			solar: {},
			system: { state: DBusData.System.State.AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single-phase Shore",
			acInputs: { types: [ DBusData.AcInputs.Shore ] },
			system: { state: DBusData.System.State.AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single phase + solar",
			acInputs: { types: [ DBusData.AcInputs.Shore ] },
			solar: {},
			system: { state: DBusData.System.State.AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Small RV with alternator or small boat",
			acInputs: { types: [ DBusData.AcInputs.Shore ] },
			dcInputs: { types: [ DBusData.DcInputs.Alternator ] },
			solar: {},
			system: { state: DBusData.System.State.AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Catamaran with wind: Shore / Solar / Left alternator / Right alternator / Wind",
			acInputs: { types: [ DBusData.AcInputs.Shore ] },
			dcInputs: { types: [ DBusData.DcInputs.Alternator, DBusData.DcInputs.Wind ] },
			solar: {},
			system: { state: DBusData.System.State.AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Boat with DC generator",
			acInputs: { types: [ DBusData.AcInputs.Shore ] },
			dcInputs: { types: [ DBusData.DcInputs.DcGenerator, DBusData.DcInputs.Alternator, DBusData.DcInputs.Wind ] },
			solar: {},
			system: { state: DBusData.System.State.AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
	]

	property int overviewConfigIndex: -1
	property bool randomizeOverviewConfig: true
	property bool _updating

	function setConfigIndex(configIndex) {
		overviewConfigIndex = configIndex
		let config = overviewConfigs[configIndex]
		if (config) {
			let i = 0
			acInputs.model.clear()
			if (config.acInputs) {
				for (i = 0; i < config.acInputs.types.length; ++i) {
					acInputs.addInput(config.acInputs.types[i], config.acInputs.phases || 1)
				}
			}
			dcInputs.model.clear()
			if (config.dcInputs) {
				for (i = 0; i < config.dcInputs.types.length; ++i) {
					dcInputs.addInput(config.dcInputs.types[i])
				}
			}
			solarChargers.clear()
			if (config.solar) {
				solarChargers.populate()
			}
			if (config.system) {
				system.state = config.system.state
				system.ac.demoTimer.running = config.system.ac !== undefined
				system.dc.demoTimer.running = config.system.dc !== undefined
			}
			if (config.battery) {
				battery.stateOfCharge = config.battery.stateOfCharge
				battery.current = config.battery.current
			}

			demoTitle.text = (configIndex + 1) + ". " + config.name

		} else {
			// Return to app default state: populate all models with random data
			randomizeOverviewConfig = true
			resetDemoData()
		}

		// Force page reload
		_updating = true
		PageManager.navBar.buttonClicked(0)
		PageManager.navBar.buttonClicked(1)
		_updating = false
	}

	function nextOverviewLayout() {
		randomizeOverviewConfig = false
		setConfigIndex(overviewConfigIndex == overviewConfigs.length-1 ? -1 : overviewConfigIndex+1)
	}

	function prevOverviewLayout() {
		randomizeOverviewConfig = false
		setConfigIndex(overviewConfigIndex < 0 ? overviewConfigs.length-1 : overviewConfigIndex-1)
	}

	function resetDemoData() {
		acInputs.populate()
		dcInputs.populate()
		solarChargers.populate()
		system.ac.demoTimer.running = true
		system.dc.demoTimer.running = true
		demoTitle.text = ""
	}

	Component.onCompleted: resetDemoData()

	Rectangle {
		id: demoTitleBackground

		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		width: demoTitle.width * 1.1
		height: demoTitle.height * 1.1
		color: "white"
		opacity: 0.9
		visible: demoTitleTimer.running && !randomizeOverviewConfig

		Label {
			id: demoTitle
			anchors.centerIn: parent
			color: "black"
			onTextChanged: demoTitleTimer.restart()
		}

		Timer {
			id: demoTitleTimer
			interval: 3000
		}
	}

	Connections {
		target: PageManager.navBar || null
		function onCurrentUrlChanged() {
			if (randomizeOverviewConfig && !root._updating
					&& PageManager.navBar.currentUrl === "qrc:/pages/OverviewPage.qml") {
				setConfigIndex(Math.floor(Math.random() * overviewConfigs.length))
			}
		}
	}
}
