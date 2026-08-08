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

	// Destroying a QML object is deferred: it is gone not when destroy() returns
	// but when control next reaches the event loop. Every measurement therefore
	// gets a step of its own with a wait after it, so that what one measurement
	// built has been destroyed before the next one is timed. Run as a single
	// step instead, nothing would be destroyed until the whole benchmark had
	// finished, and each measurement would be taken with everything the earlier
	// ones built still alive - the further down the list, the more of it.
	//
	// What matters is reaching the event loop at all, not the length of the wait:
	// a WaitStep is itself driven by a Qt timer, so it cannot complete without
	// events having been processed. The value is generous rather than tuned,
	// since a benchmark that takes a quarter of a minute longer costs nothing.
	readonly property int _teardownWait: 250

	function initTestCase() {
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !!findItem(Global.mainView, { text: "Settings" }) } })
		_addPageSteps("cold")
		_addPageSteps("warm")
		_addComponentSteps()
		runSteps()
	}

	function _addPageSteps(pass) {
		addStep(UiTestStep.Invoke, { callable: ()=> {
			root._totalCompile = 0
			root._totalCreate = 0
			root._measured = 0
			return true
		} })
		for (let i = 0; i < pageUrls.length; ++i) {
			const url = pageUrls[i]
			addStep(UiTestStep.Invoke, { callable: ()=> { root._measurePage(pass, url); return true } })
			addStep(UiTestStep.Wait, { timeout: root._teardownWait })
		}
		addStep(UiTestStep.Invoke, { callable: ()=> {
			console.warn("PAGEBENCH-TOTAL\t" + pass + "\t" + root._measured
					+ "\t" + root._totalCompile + "\t" + root._totalCreate)
			return true
		} })
	}

	function _addComponentSteps() {
		for (let t = 0; t < benchTypes.length; ++t) {
			const name = benchTypes[t][0]
			const component = benchTypes[t][1]
			// Construct one in a step of its own, so that the one-time costs of
			// the type - whatever it initialises lazily on first use - are paid,
			// and that instance destroyed, before the timed loop starts.
			addStep(UiTestStep.Invoke, { callable: ()=> {
				const warm = component.createObject(root)
				if (warm) {
					warm.destroy()
				}
				return true
			} })
			addStep(UiTestStep.Wait, { timeout: root._teardownWait })
			addStep(UiTestStep.Invoke, { callable: ()=> { root._benchComponent(name, component); return true } })
			addStep(UiTestStep.Wait, { timeout: root._teardownWait })
		}
	}


	// Per-component costs, to attribute the page instantiation cost to the list
	// item machinery that every settings page is built from.
	//
	// The types are declared as Components rather than as source strings, so
	// that each is compiled once here and the timed loop below only instantiates
	// it. Qt.createQmlObject() recompiles its source on every call, which for
	// these one-line sources costs far more than constructing the object does,
	// and would be charged to every type equally.
	readonly property var benchTypes: [
		["Item",                   itemComponent],
		["Label",                  labelComponent],
		["VeQuickItem",            veQuickItemComponent],
		["ThreeLabelLayout",       threeLabelLayoutComponent],
		["ListItem",               listItemComponent],
		["ListSetting",            listSettingComponent],
		["ListNavigation",         listNavigationComponent],
		["SettingsListNavigation", settingsListNavigationComponent],
		["ListSwitch",             listSwitchComponent],
		["ListQuantity",           listQuantityComponent],
		["ListRadioButtonGroup",   listRadioButtonGroupComponent],
	]

	Component { id: itemComponent; Item {} }
	Component { id: labelComponent; Label { text: "abc" } }
	Component { id: veQuickItemComponent; VeQuickItem {} }
	Component { id: threeLabelLayoutComponent; ThreeLabelLayout { primaryText: "abc" } }
	Component { id: listItemComponent; ListItem {} }
	Component { id: listSettingComponent; ListSetting { text: "abc" } }
	Component { id: listNavigationComponent; ListNavigation { text: "abc" } }
	Component { id: settingsListNavigationComponent; SettingsListNavigation { text: "abc" } }
	Component { id: listSwitchComponent; ListSwitch { text: "abc" } }
	Component { id: listQuantityComponent; ListQuantity { text: "abc" } }
	Component { id: listRadioButtonGroupComponent; ListRadioButtonGroup { text: "abc" } }

	function _benchComponent(name, component) {
		const N = 100
		const objects = []
		const t0 = Date.now()
		for (let i = 0; i < N; ++i) {
			objects.push(component.createObject(root))
		}
		const t1 = Date.now()
		console.warn("COMPBENCH\t" + ((t1 - t0) / N).toFixed(3) + "\t" + name)
		for (let i = 0; i < objects.length; ++i) {
			if (objects[i]) {
				objects[i].destroy()
			}
		}
	}

	property int _totalCompile
	property int _totalCreate
	property int _measured

	function _measurePage(pass, url) {
		const t0 = Date.now()
		const component = Qt.createComponent("qrc:/qt/qml/Victron/VenusOS" + url)
		const t1 = Date.now()
		if (component.status !== Component.Ready) {
			console.warn("PAGEBENCH-SKIP\t" + url + "\t" + component.errorString())
			return
		}
		const page = component.createObject(null, {})
		const t2 = Date.now()
		console.warn("PAGEBENCH\t" + pass + "\t" + (t1 - t0) + "\t" + (t2 - t1) + "\t" + url)
		root._totalCompile += t1 - t0
		root._totalCreate += t2 - t1
		root._measured++
		if (page) {
			page.destroy()
		}
	}
}
