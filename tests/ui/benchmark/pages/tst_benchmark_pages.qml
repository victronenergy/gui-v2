/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
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
			addStep(UiTestStep.Invoke, { callable: ()=> { return root._measurePage(pass, url) } })
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
				if (!warm) {
					console.warn("COMPBENCH-FAIL\t" + name + "\twarm-up createObject returned null")
					return false
				}
				warm.destroy()
				return true
			} })
			addStep(UiTestStep.Wait, { timeout: root._teardownWait })
			addStep(UiTestStep.Invoke, { callable: ()=> { return root._benchComponent(name, component) } })
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
		["Item",                     itemComponent],
		["Label",                    labelComponent],
		["Text",                     textComponent],
		["VeQuickItem",              veQuickItemComponent],
		["QuantityLabel",            quantityLabelComponent],
		["ColorImage",               colorImageComponent],
		["Image",                    imageComponent],
		["ThreeLabelLayout",         threeLabelLayoutComponent],
		["ThreeLabelLayout+secondary", threeLabelSecondaryComponent],
		["ListItem",                 listItemComponent],
		["ListSetting",              listSettingComponent],
		["ListNavigation",           listNavigationComponent],
		["ListNavigation+secondary", listNavigationSecondaryComponent],
		["SettingsListNavigation",   settingsListNavigationComponent],
		["ListSwitch",               listSwitchComponent],
		["ListQuantity",             listQuantityComponent],
		["ListRadioButtonGroup",     listRadioButtonGroupComponent],
		["ListRadioButtonGroup-8",   listRadioButtonGroup8Component],
	]

	Component { id: itemComponent; Item {} }
	Component { id: labelComponent; Label { text: "abc" } }
	Component { id: textComponent; Text { text: "abc" } }
	Component { id: veQuickItemComponent; VeQuickItem {} }
	Component { id: quantityLabelComponent; QuantityLabel {} }
	Component {
		id: colorImageComponent
		CP.ColorImage {
			source: "qrc:/images/icon_chevron_right_32.svg"
			color: Theme.color_listItem_forwardIcon
		}
	}
	Component {
		id: imageComponent
		Image { source: "qrc:/images/icon_chevron_right_32.svg" }
	}
	Component { id: threeLabelLayoutComponent; ThreeLabelLayout { primaryText: "abc" } }
	Component {
		id: threeLabelSecondaryComponent
		ThreeLabelLayout {
			primaryText: "abc"
			secondaryText: "xyz"
		}
	}
	Component { id: listItemComponent; ListItem {} }
	Component { id: listSettingComponent; ListSetting { text: "abc" } }
	Component { id: listNavigationComponent; ListNavigation { text: "abc" } }
	Component {
		id: listNavigationSecondaryComponent
		ListNavigation {
			text: "abc"
			secondaryText: "xyz"
		}
	}
	Component {
		id: settingsListNavigationComponent
		SettingsPage.SettingsListNavigation {
			text: "abc"
			pageSource: "/pages/settings/PageSettingsGeneral.qml"
			pageIconSource: "qrc:/images/icon_general_32.svg"
		}
	}
	Component { id: listSwitchComponent; ListSwitch { text: "abc" } }
	Component { id: listQuantityComponent; ListQuantity { text: "abc" } }
	Component { id: listRadioButtonGroupComponent; ListRadioButtonGroup { text: "abc" } }
	Component {
		id: listRadioButtonGroup8Component
		ListRadioButtonGroup {
			text: "abc"
			optionModel: [
				{ display: "a", value: 0 },
				{ display: "b", value: 1 },
				{ display: "c", value: 2 },
				{ display: "d", value: 3 },
				{ display: "e", value: 4 },
				{ display: "f", value: 5 },
				{ display: "g", value: 6 },
				{ display: "h", value: 7 }
			]
		}
	}

	function _benchComponent(name, component) {
		const N = 100
		const objects = []
		const t0 = Date.now()
		for (let i = 0; i < N; ++i) {
			const object = component.createObject(root)
			if (!object) {
				console.warn("COMPBENCH-FAIL\t" + name + "\tcreateObject returned null")
				for (let j = 0; j < objects.length; ++j) {
					objects[j].destroy()
				}
				return false
			}
			objects.push(object)
		}
		const t1 = Date.now()
		console.warn("COMPBENCH\t" + ((t1 - t0) / N).toFixed(3) + "\t" + name)
		for (let i = 0; i < objects.length; ++i) {
			objects[i].destroy()
		}
		return true
	}

	property int _totalCompile
	property int _totalCreate
	property int _measured

	FilteredDeviceModel {
		id: benchAcLoadDevices
		serviceTypes: ["acload", "evcharger", "heatpump"]
	}
	FilteredDeviceModel {
		id: benchDcSystemLoads
		serviceTypes: ["dcsystem"]
	}
	FilteredDeviceModel {
		id: benchDcNonSystemLoads
	}

	function _uid(serviceName) {
		return BackendConnection.uidPrefix() + "/" + serviceName
	}

	function _pageProperties(url) {
		switch (url) {
		case "/pages/settings/devicelist/battery/PageBattery.qml":
		case "/pages/settings/devicelist/battery/PageBatterySettings.qml":
			return { bindPrefix: _uid("com.victronenergy.battery.ttyUSB1") }
		case "/pages/settings/devicelist/ac-in/PageAcIn.qml":
			return { bindPrefix: _uid("com.victronenergy.pvinverter.socketcan_vecan0_vi0_uc451502") }
		case "/pages/vebusdevice/PageVeBus.qml":
			return { bindPrefix: _uid("com.victronenergy.vebus.ttyS2") }
		case "/pages/solar/SolarDevicePage.qml":
			return { serviceUid: _uid("com.victronenergy.solarcharger.ttyO0") }
		case "/pages/evcs/EvChargerPage.qml":
			return { bindPrefix: _uid("com.victronenergy.evcharger.evc_ABC123456") }
		case "/pages/settings/devicelist/inverter/PageInverter.qml":
			return { bindPrefix: _uid("com.victronenergy.inverter.socketcan_can0_vi0_uc87197") }
		case "/pages/loads/AcLoadListPage.qml":
			return {
				measurements: Global.system.load.ac,
				model: benchAcLoadDevices
			}
		case "/pages/loads/DcLoadListPage.qml":
			return {
				systemModel: benchDcSystemLoads,
				nonSystemModel: benchDcNonSystemLoads
			}
		default:
			return {}
		}
	}

	function _measurePage(pass, url) {
		const t0 = Date.now()
		const component = Qt.createComponent("qrc:/qt/qml/Victron/VenusOS" + url)
		const t1 = Date.now()
		if (component.status !== Component.Ready) {
			console.warn("PAGEBENCH-FAIL\t" + url + "\t" + component.errorString())
			return false
		}
		const page = component.createObject(null, _pageProperties(url))
		const t2 = Date.now()
		if (!page) {
			console.warn("PAGEBENCH-FAIL\t" + url + "\tcreateObject returned null")
			return false
		}
		console.warn("PAGEBENCH\t" + pass + "\t" + (t1 - t0) + "\t" + (t2 - t1) + "\t" + url)
		root._totalCompile += t1 - t0
		root._totalCreate += t2 - t1
		root._measured++
		page.destroy()
		return true
	}
}
