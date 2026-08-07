/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

/*
	Measures how long each page takes to compile and to instantiate.

	Every page that is reachable via a pageSource in the UI is created and
	destroyed twice: the first pass measures the cold cost (QML compilation plus
	instantiation) and the second the warm cost (instantiation only, as Qt caches
	the compiled unit). The pages are created detached rather than pushed onto
	the page stack, so that the measurement is not perturbed by the push
	transition, and so that pages which require properties we do not have still
	contribute their construction cost.
*/
UiTestCase {
	id: root

	window: Global.main

	readonly property var pageUrls: [
		"/pages/settings/devicelist/battery/PageBattery.qml",
		"/pages/settings/devicelist/ac-in/PageAcIn.qml",
		"/pages/vebusdevice/PageVeBus.qml",
		"/pages/solar/SolarDevicePage.qml",
		"/pages/solar/SolarInputListPage.qml",
		"/pages/loads/AcLoadListPage.qml",
		"/pages/loads/DcLoadListPage.qml",
		"/pages/evcs/EvChargerPage.qml",
		"/pages/battery/BatteryListPage.qml",
		"/pages/invertercharger/InverterChargerListPage.qml",
		"/pages/settings/devicelist/DeviceListPage.qml",
		"/pages/settings/PageSettingsGeneral.qml",
		"/pages/settings/PageSettingsConnectivity.qml",
		"/pages/settings/PageSettingsSystem.qml",
		"/pages/settings/PageSettingsDvcc.qml",
		"/pages/settings/PageSettingsDisplay.qml",
		"/pages/settings/PageSettingsHub4.qml",
		"/pages/settings/devicelist/battery/PageBatterySettings.qml",
		"/pages/settings/devicelist/inverter/PageInverter.qml",
		"/pages/settings/PageControllableLoads.qml",
	]

	function initTestCase() {
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !!findItem(Global.mainView, { text: "Settings" }) } })
		addStep(UiTestStep.Invoke, { callable: ()=> { root._measure("cold"); root._measure("warm"); root._componentBench(); return true } })
		runSteps()
	}


	// Per-component costs, to attribute the page instantiation cost to the list
	// item machinery that every settings page is built from.
	readonly property var benchTypes: [
		["Item",                   "import QtQuick; Item {}"],
		["Label",                  "import QtQuick.Controls; Label { text: 'abc' }"],
		["VeQuickItem",            "import Victron.VenusOS; VeQuickItem {}"],
		["ThreeLabelLayout",       "import Victron.VenusOS; ThreeLabelLayout { primaryText: 'abc' }"],
		["ListItem",               "import Victron.VenusOS; ListItem {}"],
		["ListSetting",            "import Victron.VenusOS; ListSetting { text: 'abc' }"],
		["ListNavigation",         "import Victron.VenusOS; ListNavigation { text: 'abc' }"],
		["SettingsListNavigation", "import Victron.VenusOS; SettingsListNavigation { text: 'abc' }"],
		["ListSwitch",             "import Victron.VenusOS; ListSwitch { text: 'abc' }"],
		["ListQuantity",           "import Victron.VenusOS; ListQuantity { text: 'abc' }"],
		["ListRadioButtonGroup",   "import Victron.VenusOS; ListRadioButtonGroup { text: 'abc' }"],
	]

	function _componentBench() {
		const N = 100
		for (let t = 0; t < benchTypes.length; ++t) {
			const name = benchTypes[t][0]
			const src = benchTypes[t][1]
			// Warm up so the string is compiled before the timed loop.
			let warm = Qt.createQmlObject(src, root)
			if (warm) warm.destroy()
			const objects = []
			const t0 = Date.now()
			for (let i = 0; i < N; ++i) {
				objects.push(Qt.createQmlObject(src, root))
			}
			const t1 = Date.now()
			console.warn("COMPBENCH\t" + ((t1 - t0) / N).toFixed(3) + "\t" + name)
			for (let i = 0; i < objects.length; ++i) {
				if (objects[i]) objects[i].destroy()
			}
		}
	}

	function _measure(pass) {
		let totalCompile = 0
		let totalCreate = 0
		let measured = 0
		for (let i = 0; i < pageUrls.length; ++i) {
			const url = pageUrls[i]
			const t0 = Date.now()
			const component = Qt.createComponent("qrc:/qt/qml/Victron/VenusOS" + url)
			const t1 = Date.now()
			if (component.status !== Component.Ready) {
				console.warn("PAGEBENCH-SKIP\t" + url + "\t" + component.errorString())
				continue
			}
			const page = component.createObject(null, {})
			const t2 = Date.now()
			console.warn("PAGEBENCH\t" + pass + "\t" + (t1 - t0) + "\t" + (t2 - t1) + "\t" + url)
			totalCompile += t1 - t0
            totalCreate += t2 - t1
			measured++
			if (page) {
				page.destroy()
			}
		}
		console.warn("PAGEBENCH-TOTAL\t" + pass + "\t" + measured + "\t" + totalCompile + "\t" + totalCreate)
	}
}
