/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Compiles overview drill-down and overlay page types while the splash screen is showing.

	On GX devices, first open of a page that has never been compiled runs
	Qt.createComponent() and createObject() synchronously on the GUI thread
	(PageStack.pushPage()), which is a noticeable freeze, then slides the page
	in. Doing the compile here, before Brief/Overview animations start, leaves
	first open as instantiate-and-slide.

	Only compilation is warmed, not instantiation: drill-down pages need bindPrefix/serviceUid
	properties that are not known yet, and instantiating Control/Switch cards at startup would
	hold their full trees in memory even if the user never opens them.

	UI tests skip compile by default (skipCompile) so that benchmark/pages still measures cold
	compile. Isolated tests inject pageUrls and override skipCompile, timeoutMs, and
	compileOnActive to cover compile, bad URLs, and timeout without enabling preload for other
	UI tests.
*/
QtObject {
	id: root

	property bool active: false

	// UI tests skip compile by default so benchmark/pages measures cold compile.
	// Isolated tests override this to opt into the production compile path.
	property bool skipCompile: UiTest.status !== UiTest.NotConfigured

	// Overridable so tests can compile a tiny URL list instead of the production pages.
	property var pageUrls: [
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

		// First-level Settings pages (SettingsPage destinations).
		"/pages/settings/devicelist/DeviceListPage.qml",
		"/pages/settings/PageSettingsGeneral.qml",
		"/pages/settings/PageSettingsConnectivity.qml",
		"/pages/settings/PageSettingsLogger.qml",
		"/pages/settings/PageSettingsIntegrations.qml",
		"/pages/settings/PageSettingsSystem.qml",
		"/pages/settings/debug/PageDebug.qml",
	]

	property int timeoutMs: 15000

	// When false, activation starts the timeout timer but does not compile. Tests use this
	// to cover the timeout path without racing compilation.
	property bool compileOnActive: true

	// Successful compiles only. _index is the processed URL count, including errors.
	readonly property int compiledCount: _compiledCount

	property int _index: 0
	property int _compiledCount: 0
	property real _startedAt: 0

	onActiveChanged: {
		if (!active || Global.pagePreloadComplete) {
			return
		}
		if (skipCompile) {
			Global.pagePreloadComplete = true
			return
		}
		_index = 0
		_compiledCount = 0
		_startedAt = Date.now()
		console.info("PagePreloader: compiling", pageUrls.length, "pages")
		if (compileOnActive) {
			_compileNext()
		}
	}

	function _compileNext() {
		if (!active || Global.pagePreloadComplete) {
			return
		}
		if (_index >= pageUrls.length) {
			_finish()
			return
		}

		// Compile one document synchronously (no Component.Asynchronous), then yield so the
		// splash GIF can advance.
		const url = pageUrls[_index]
		const component = Qt.createComponent(url.indexOf("qrc:") === 0 ? url : ".." + url)
		if (component.status === Component.Error) {
			console.warn("PagePreloader: failed to compile", url, component.errorString())
		} else {
			_compiledCount++
		}
		_index++
		Qt.callLater(_compileNext)
	}

	function _finish() {
		if (Global.pagePreloadComplete) {
			return
		}
		console.info("PagePreloader: compiled", _compiledCount, "pages in", Date.now() - _startedAt, "ms")
		Global.pagePreloadComplete = true
	}

	property Timer _timeout: Timer {
		interval: root.timeoutMs
		running: root.active && !Global.pagePreloadComplete
		onTriggered: {
			console.warn("PagePreloader: timed out after", root._index, "of", root.pageUrls.length, "pages")
			root._finish()
		}
	}
}
