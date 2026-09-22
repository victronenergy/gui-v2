/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

/*
	Compiles overview drill-down and overlay page types while the splash screen is showing.

	On GX devices a page that has never been opened is compiled on first use. That compile is
	noticeable, and if it runs while Brief/Overview animations are already saturating the frame
	budget, asynchronous loading stretches into seconds. Doing the compile here, before those
	animations start, leaves first open as instantiate-and-slide.

	Only compilation is warmed, not instantiation: drill-down pages need bindPrefix/serviceUid
	properties that are not known yet, and instantiating Control/Switch cards at startup would
	hold their full trees in memory even if the user never opens them.

	Skipped when UI tests are configured so that benchmark/pages still measures cold compile.
*/
QtObject {
	id: root

	property bool active: false

	readonly property var pageUrls: [
		// Overlays first: Brief is the start page, and these are the first things the user opens.
		"/pages/BriefSidePanel.qml",
		"/pages/ControlCardsPage.qml",
		"/pages/AuxCardsPage.qml",

		// Overview widget drill-downs.
		"/pages/settings/devicelist/battery/PageBattery.qml",
		"/pages/vebusdevice/PageVeBus.qml",
		"/pages/battery/BatteryListPage.qml",
		"/pages/solar/SolarDevicePage.qml",
		"/pages/solar/PvInverterPage.qml",
		"/pages/solar/SolarInputListPage.qml",
		"/pages/solar/PageSolarCharger.qml",
		"/pages/loads/AcLoadListPage.qml",
		"/pages/loads/DcLoadListPage.qml",
		"/pages/evcs/EvChargerPage.qml",
		"/pages/evcs/EvChargerListPage.qml",
		"/pages/invertercharger/InverterChargerListPage.qml",
		"/pages/invertercharger/OverviewInverterChargerPage.qml",
		"/pages/settings/devicelist/PageAcCharger.qml",
		"/pages/settings/devicelist/rs/PageRsSystem.qml",
		"/pages/settings/devicelist/PageGenset.qml",
		"/pages/settings/devicelist/ac-in/PageAcIn.qml",
		"/pages/settings/devicelist/dc-in/PageAlternator.qml",
		"/pages/settings/devicelist/dc-in/PageDcMeter.qml",
		"/pages/settings/PageDcGensets.qml",
	]

	property int _index: 0
	property real _startedAt: 0

	onActiveChanged: {
		if (!active || Global.pagePreloadComplete) {
			return
		}
		if (UiTest.status !== UiTest.NotConfigured) {
			Global.pagePreloadComplete = true
			return
		}
		_index = 0
		_startedAt = Date.now()
		console.info("PagePreloader: compiling", pageUrls.length, "pages")
		_compileNext()
	}

	function _compileNext() {
		if (!active || Global.pagePreloadComplete) {
			return
		}
		if (_index >= pageUrls.length) {
			_finish()
			return
		}

		// Compile one document, then yield so the splash GIF can advance. Synchronous compile
		// is used so this cannot be starved the way an asynchronous incubator is on GX.
		const url = pageUrls[_index]
		const component = Qt.createComponent(url.indexOf("qrc:") === 0 ? url : ".." + url)
		if (component.status === Component.Error) {
			console.warn("PagePreloader: failed to compile", url, component.errorString())
		}
		_index++
		Qt.callLater(_compileNext)
	}

	function _finish() {
		if (Global.pagePreloadComplete) {
			return
		}
		console.info("PagePreloader: compiled", _index, "pages in", Date.now() - _startedAt, "ms")
		Global.pagePreloadComplete = true
	}

	property Timer _timeout: Timer {
		interval: 15000
		running: root.active && !Global.pagePreloadComplete
		onTriggered: {
			console.warn("PagePreloader: timed out after", root._index, "of", root.pageUrls.length, "pages")
			root._finish()
		}
	}
}
