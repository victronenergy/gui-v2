/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls
import Victron.VenusOS
import QtTest

TestCase {
	name: "UiTestUtilsTest"

	function _hasValidCurrentPage(pageStack, expectedPageUrl) {
		if (!pageStack) {
			return false
		}
		if ((pageStack.topPageUrl ?? "") !== expectedPageUrl) {
			return false
		}
		const page = pageStack.currentPage
		return !!page && page.__is_venus_gui_page__ === true
	}

	// --- normalizePageUrl tests ---

	function test_normalizePageUrl_empty() {
		compare(UiTestUtilsHelper.normalizePageUrl(""), "")
		compare(UiTestUtilsHelper.normalizePageUrl("   "), "")
	}

	function test_normalizePageUrl_fullQrcPrefix() {
		compare(UiTestUtilsHelper.normalizePageUrl(
			"qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsConnectivity.qml"),
			"/pages/settings/PageSettingsConnectivity.qml")
	}

	function test_normalizePageUrl_resourcePrefix() {
		compare(UiTestUtilsHelper.normalizePageUrl(
			":/qt/qml/Victron/VenusOS/pages/settings/PageSettingsConnectivity.qml"),
			"/pages/settings/PageSettingsConnectivity.qml")
	}

	function test_normalizePageUrl_absolutePagesPath() {
		compare(UiTestUtilsHelper.normalizePageUrl(
			"/pages/settings/PageSettingsConnectivity.qml"),
			"/pages/settings/PageSettingsConnectivity.qml")
	}

	function test_normalizePageUrl_relativePagesPath() {
		compare(UiTestUtilsHelper.normalizePageUrl(
			"pages/settings/PageSettingsConnectivity.qml"),
			"/pages/settings/PageSettingsConnectivity.qml")
	}

	function test_normalizePageUrl_bareFilename() {
		// Bare filenames are resolved by searching QML resources for a unique match.
		compare(UiTestUtilsHelper.normalizePageUrl("PageSettingsConnectivity.qml"),
			"/pages/settings/PageSettingsConnectivity.qml")

		// Non-existent bare filenames are rejected.
		compare(UiTestUtilsHelper.normalizePageUrl("PageThatDoesNotExist.qml"), "")
	}

	function test_normalizePageUrl_backslashes() {
		compare(UiTestUtilsHelper.normalizePageUrl(
			"pages\\settings\\PageSettingsConnectivity.qml"),
			"/pages/settings/PageSettingsConnectivity.qml")
	}

	function test_normalizePageUrl_embeddedPagesPath() {
		compare(UiTestUtilsHelper.normalizePageUrl(
			"some/prefix/pages/settings/PageSettingsConnectivity.qml"),
			"/pages/settings/PageSettingsConnectivity.qml")
	}

	function test_normalizePageUrl_boatModule() {
		compare(UiTestUtilsHelper.normalizePageUrl(
			"qrc:/qt/qml/Victron/Boat/BoatPage.qml"),
			"/pages/boat/BoatPage.qml")
		compare(UiTestUtilsHelper.normalizePageUrl(
			":/qt/qml/Victron/Boat/BoatPage.qml"),
			"/pages/boat/BoatPage.qml")
		compare(UiTestUtilsHelper.normalizePageUrl("/pages/boat/BoatPage.qml"),
			"/pages/boat/BoatPage.qml")
		compare(UiTestUtilsHelper.normalizePageUrl("BoatPage.qml"),
			"/pages/boat/BoatPage.qml")
	}

	function test_normalizePageUrl_invalidInputs() {
		// Not a .qml file
		compare(UiTestUtilsHelper.normalizePageUrl("/pages/settings/SomePage.txt"), "")
		// No /pages/ prefix and not a .qml bare filename
		compare(UiTestUtilsHelper.normalizePageUrl("smoke/mock-maximal"), "")
		// Just a directory path
		compare(UiTestUtilsHelper.normalizePageUrl("/pages/settings/"), "")
		// Non-page qml file (under components, not pages)
		compare(UiTestUtilsHelper.normalizePageUrl("/components/SomeComponent.qml"), "")
	}

	function test_normalizePageUrl_whitespace() {
		compare(UiTestUtilsHelper.normalizePageUrl(
			"  /pages/settings/PageSettingsConnectivity.qml  "),
			"/pages/settings/PageSettingsConnectivity.qml")
	}

	function test_normalizeUiTestArguments_windowsTargetPageValue() {
		const args = [
			"venus-gui-v2",
			"--mock",
			"--ui-test",
			"/pages/settings/PageSettingsHub4.qml",
			"--no-mock-timers",
		]
		const normalized = UiTestUtilsHelper.normalizeUiTestArguments(args)
		compare(normalized.length, 4)
		compare(normalized[2], "--ui-test=/pages/settings/PageSettingsHub4.qml")
		compare(UiTestUtilsHelper.parseUiTestValueFromArgs(normalized),
			"/pages/settings/PageSettingsHub4.qml")
	}

	function test_normalizeUiTestArguments_shortOptionWindowsTargetPageValue() {
		const args = [
			"venus-gui-v2",
			"-uit",
			"/pages/settings/PageSettingsHub4.qml",
			"--mock",
		]
		const normalized = UiTestUtilsHelper.normalizeUiTestArguments(args)
		compare(normalized.length, 3)
		compare(normalized[1], "-uit=/pages/settings/PageSettingsHub4.qml")
		compare(UiTestUtilsHelper.parseUiTestValueFromArgs(normalized),
			"/pages/settings/PageSettingsHub4.qml")
	}

	function test_normalizeUiTestArguments_keepsNamedConfigValues() {
		const args = [
			"venus-gui-v2",
			"--ui-test",
			"smoke/mock-maximal",
			"--mock",
		]
		const normalized = UiTestUtilsHelper.normalizeUiTestArguments(args)
		compare(normalized.length, args.length)
		compare(normalized[1], "--ui-test")
		compare(normalized[2], "smoke/mock-maximal")
		compare(UiTestUtilsHelper.parseUiTestValueFromArgs(normalized), "smoke/mock-maximal")
	}

	function test_parseResolution_valid() {
		const portrait = UiTestUtilsHelper.parseResolution("480x800")
		compare(portrait.ok, true)
		compare(portrait.width, 480)
		compare(portrait.height, 800)
		compare(portrait.error, "")

		const landscape = UiTestUtilsHelper.parseResolution("1024X600")
		compare(landscape.ok, true)
		compare(landscape.width, 1024)
		compare(landscape.height, 600)
	}

	function test_parseResolution_invalid() {
		const cases = ["", "480", "480x", "x800", "480 x 800", "0x800", "-1x800"]
		for (let i = 0; i < cases.length; ++i) {
			const parsed = UiTestUtilsHelper.parseResolution(cases[i])
			compare(parsed.ok, false, "Expected invalid resolution: " + cases[i])
			compare(parsed.width, 0)
			compare(parsed.height, 0)
			verify(parsed.error.length > 0)
		}
	}

	// --- buildPageGraph tests ---

	function test_buildPageGraph_nonEmpty() {
		var summary = UiTestUtilsHelper.buildPageGraphSummary()
		// The graph should contain pages and edges from the compiled QML resources.
		verify(summary.pageCount > 0, "Graph should contain at least one page")
		verify(summary.edgeCount > 0, "Graph should contain at least one navigation edge")
	}

	function test_buildPageGraph_containsSettingsPage() {
		var summary = UiTestUtilsHelper.buildPageGraphSummary()
		var pages = summary.pages
		var hasSettingsPage = false
		for (var i = 0; i < pages.length; ++i) {
			if (pages[i] === "/pages/SettingsPage.qml") {
				hasSettingsPage = true
				break
			}
		}
		verify(hasSettingsPage, "Graph should contain /pages/SettingsPage.qml")
	}

	// --- resolveTargetRoute tests ---

	function test_resolveTargetRoute_knownSettingsSubPage() {
		// PageSettingsGeneral.qml is a direct child of SettingsPage, so it should
		// always be reachable with a single route step.
		var result = UiTestUtilsHelper.resolveTargetRoute(
			"/pages/settings/PageSettingsGeneral.qml")
		verify(result.success, "Should resolve a known settings sub-page")
		compare(result.entryNavText, "Settings")
		verify(result.routeLabels.length > 0, "Should have at least one route label")
		verify(result.routeSteps.length > 0, "Should have at least one route step")
		// Settings sub-pages should use text identifiers
		compare(result.routeSteps[0].type, "text")
		verify(result.routeSteps[0].values.length > 0,
			"Route step should have at least one candidate value")
		compare(result.routeSteps[0].expectedPage,
			"/pages/settings/PageSettingsGeneral.qml",
			"expectedPage should match the target for a single-step route")
	}

	function test_resolveTargetRoute_settingsPageWithTernaryLabel() {
		// PageSettingsHub4 is opened from a ListNavigation text expression:
		// systemType.value === "Hub-4" ? systemType.value : CommonWords.ess
		// The resolver should keep both static label candidates for runtime matching.
		var result = UiTestUtilsHelper.resolveTargetRoute(
			"/pages/settings/PageSettingsHub4.qml")
		verify(result.success, "Should resolve a settings page with a ternary text label")
		compare(result.entryNavText, "Settings")
		verify(result.routeSteps.length > 0, "Should have route steps for PageSettingsHub4")
		const hub4Step = result.routeSteps[result.routeSteps.length - 1]
		verify(hub4Step.values.length >= 2,
			"Ternary text should preserve multiple static candidate labels")
		verify(hub4Step.values.indexOf("Hub-4") >= 0,
			"Ternary candidate labels should include Hub-4")
		verify(hub4Step.values.indexOf("ESS") >= 0,
			"Ternary candidate labels should include ESS")
		compare(result.routeSteps[result.routeSteps.length - 1].expectedPage,
			"/pages/settings/PageSettingsHub4.qml",
			"Last step expectedPage should match the target page")
	}

	function test_resolveTargetRoute_swipeRootPage() {
		// SwipeView root pages are shown by clicking the nav bar; extra route
		// steps are empty because no PageStack push is required.
		var settings = UiTestUtilsHelper.resolveTargetRoute("/pages/SettingsPage.qml")
		verify(settings.success, "SettingsPage should be resolvable as a swipe root")
		compare(settings.entryNavText, "Settings")
		compare(settings.routeSteps.length, 0)

		var brief = UiTestUtilsHelper.resolveTargetRoute("/pages/BriefPage.qml")
		verify(brief.success, "BriefPage should be resolvable as a swipe root")
		compare(brief.entryNavText, "Brief")
		compare(brief.routeSteps.length, 0)

		// BoatPage is a SwipeViewPage compiled in Victron.Boat, not VenusOS/pages.
		var boat = UiTestUtilsHelper.resolveTargetRoute("/pages/boat/BoatPage.qml")
		verify(boat.success, "BoatPage should be resolvable as a swipe root")
		compare(boat.entryNavText, "Boat")
		compare(boat.routeSteps.length, 0)
	}

	function test_resolveTargetRoute_overlayType() {
		// Overlay types are constructed by clicking a StatusBar icon after
		// opening the host swipe page. They are not PageStack destinations.
		var sidePanel = UiTestUtilsHelper.resolveTargetRoute("/pages/BriefSidePanel.qml")
		verify(sidePanel.success, "BriefSidePanel should be resolvable via StatusBar")
		compare(sidePanel.entryNavText, "Brief")
		compare(sidePanel.routeSteps.length, 1)
		compare(sidePanel.routeSteps[0].type, "iconSource")
		compare(sidePanel.routeSteps[0].verify, "type")
		compare(sidePanel.routeSteps[0].expectedPage, "/pages/BriefSidePanel.qml")
		verify(sidePanel.routeSteps[0].values.some(function(value) {
			return value.indexOf("icon_sidepanel_off_32.svg") >= 0
		}), "Side panel route should click the inactive side-panel icon")

		var cards = UiTestUtilsHelper.resolveTargetRoute("/pages/ControlCardsPage.qml")
		verify(cards.success, "ControlCardsPage should be resolvable via StatusBar")
		compare(cards.entryNavText, "Brief")
		compare(cards.routeSteps.length, 1)
		compare(cards.routeSteps[0].type, "iconSource")
		compare(cards.routeSteps[0].verify, "type")
		verify(cards.routeSteps[0].values.some(function(value) {
			return value.indexOf("icon_controls_off_32.svg") >= 0
		}), "Control cards route should click the inactive controls icon")
	}

	function test_resolveTargetRoute_activeOrientationLayoutType() {
		// OverviewPage.qml declares both OverviewPage_Landscape and
		// OverviewPage_Portrait; only the Theme.screenSize branch is live.
		const landscape = UiTestUtilsHelper.resolveTargetRoute("/pages/OverviewPage_Landscape.qml")
		const portrait = UiTestUtilsHelper.resolveTargetRoute("/pages/OverviewPage_Portrait.qml")
		const briefLandscape = UiTestUtilsHelper.resolveTargetRoute("/pages/BriefPage_Landscape.qml")
		const briefPortrait = UiTestUtilsHelper.resolveTargetRoute("/pages/BriefPage_Portrait.qml")
		if (Theme.screenSize === Theme.Portrait) {
			verify(portrait.success, "OverviewPage_Portrait should resolve in portrait")
			compare(portrait.entryNavText, "Overview")
			compare(portrait.routeSteps.length, 0)
			verify(!landscape.success, "OverviewPage_Landscape should be unresolvable in portrait")
			verify(briefPortrait.success, "BriefPage_Portrait should resolve in portrait")
			compare(briefPortrait.routeSteps.length, 0)
			verify(!briefLandscape.success, "BriefPage_Landscape should be unresolvable in portrait")
		} else {
			verify(landscape.success, "OverviewPage_Landscape should resolve in landscape")
			compare(landscape.entryNavText, "Overview")
			compare(landscape.routeSteps.length, 0)
			verify(!portrait.success, "OverviewPage_Portrait should be unresolvable in landscape")
			verify(briefLandscape.success, "BriefPage_Landscape should resolve in landscape")
			compare(briefLandscape.routeSteps.length, 0)
			verify(!briefPortrait.success, "BriefPage_Portrait should be unresolvable in landscape")
		}
	}

	function test_resolveTargetRoute_portraitOrientationLayoutType() {
		const previousScreenSize = Theme.screenSize
		Theme.screenSize = Theme.Portrait
		const portrait = UiTestUtilsHelper.resolveTargetRoute("/pages/OverviewPage_Portrait.qml")
		const landscape = UiTestUtilsHelper.resolveTargetRoute("/pages/OverviewPage_Landscape.qml")
		const briefPortrait = UiTestUtilsHelper.resolveTargetRoute("/pages/BriefPage_Portrait.qml")
		const briefLandscape = UiTestUtilsHelper.resolveTargetRoute("/pages/BriefPage_Landscape.qml")
		const sidePanel = UiTestUtilsHelper.resolveTargetRoute("/pages/BriefSidePanel.qml")
		const cards = UiTestUtilsHelper.resolveTargetRoute("/pages/ControlCardsPage.qml")
		Theme.screenSize = previousScreenSize

		verify(portrait.success, "OverviewPage_Portrait should resolve when Theme is Portrait")
		compare(portrait.entryNavText, "Overview")
		compare(portrait.routeSteps.length, 0)
		verify(!landscape.success, "OverviewPage_Landscape should be unresolvable when Theme is Portrait")
		verify(briefPortrait.success, "BriefPage_Portrait should resolve when Theme is Portrait")
		compare(briefPortrait.routeSteps.length, 0)
		verify(!briefLandscape.success, "BriefPage_Landscape should be unresolvable when Theme is Portrait")
		verify(sidePanel.success, "BriefSidePanel should still resolve in portrait")
		compare(sidePanel.entryNavText, "Brief")
		compare(sidePanel.routeSteps.length, 0,
			"Portrait BriefSidePanel is inline; no StatusBar click")
		verify(cards.success, "ControlCardsPage should still resolve in portrait")
		compare(cards.entryNavText, "Brief")
		compare(cards.routeSteps.length, 1)
		compare(cards.routeSteps[0].verify, "type")
	}

	function test_resolveTargetRoute_levelsTabTypes() {
		// LevelsPage TabBar labels switch TanksTab / EnvironmentTab.
		// currentIndex is runtime (prefer an enabled tab). The click still
		// runs if that tab is already selected.
		const tanks = UiTestUtilsHelper.resolveTargetRoute("/pages/TanksTab.qml")
		verify(tanks.success, "TanksTab should resolve via the Levels TabBar")
		compare(tanks.entryNavText, "Levels")
		compare(tanks.routeSteps.length, 1)
		compare(tanks.routeSteps[0].type, "text")
		compare(tanks.routeSteps[0].verify, "type")
		compare(tanks.routeSteps[0].expectedPage, "/pages/TanksTab.qml")
		verify(tanks.routeSteps[0].values.indexOf("Tanks") >= 0,
			"TanksTab route should click the Tanks tab label")

		const environment = UiTestUtilsHelper.resolveTargetRoute("/pages/EnvironmentTab.qml")
		verify(environment.success, "EnvironmentTab should resolve via the Levels TabBar")
		compare(environment.entryNavText, "Levels")
		compare(environment.routeSteps.length, 1)
		compare(environment.routeSteps[0].type, "text")
		compare(environment.routeSteps[0].verify, "type")
		compare(environment.routeSteps[0].expectedPage, "/pages/EnvironmentTab.qml")
		verify(environment.routeSteps[0].values.indexOf("Environment") >= 0,
			"EnvironmentTab route should click the Environment tab label")

		const levels = UiTestUtilsHelper.resolveTargetRoute("/pages/LevelsPage.qml")
		verify(levels.success, "LevelsPage should remain a swipe root")
		compare(levels.entryNavText, "Levels")
		compare(levels.routeSteps.length, 0)

		const levelsTab = UiTestUtilsHelper.resolveTargetRoute("/pages/LevelsTab.qml")
		verify(!levelsTab.success,
			"LevelsTab is the shared tab base, not a navigable view")

		const previousScreenSize = Theme.screenSize
		Theme.screenSize = Theme.Portrait
		const environmentPortrait = UiTestUtilsHelper.resolveTargetRoute("/pages/EnvironmentTab.qml")
		Theme.screenSize = previousScreenSize
		verify(environmentPortrait.success,
			"EnvironmentTab should still resolve in portrait")
		compare(environmentPortrait.entryNavText, "Levels")
		compare(environmentPortrait.routeSteps.length, 1)
		verify(environmentPortrait.routeSteps[0].values.indexOf("Environment") >= 0)
	}

	function test_resolveTargetRoute_unresolvablePage() {
		var result = UiTestUtilsHelper.resolveTargetRoute(
			"/pages/ThisPageDoesNotExistAnywhere.qml")
		verify(!result.success, "Unknown pages should not be resolvable")
	}

	function test_resolveTargetRoute_nonSettingsSubPage() {
		// Non-settings pages reachable via Overview widgets should be resolvable.
		// PageVeBus is an unconditional destination from BatteryWidget.
		var result = UiTestUtilsHelper.resolveTargetRoute(
			"/pages/vebusdevice/PageVeBus.qml")
		verify(result.success, "PageVeBus should be resolvable from Overview")
		verify(result.routeSteps.length > 0,
			"Should have route steps for VeBus page")
		// Each step should have type, values, and expectedPage
		for (var i = 0; i < result.routeSteps.length; ++i) {
			verify(result.routeSteps[i].type.length > 0, "Step type should be non-empty")
			verify(result.routeSteps[i].values.length > 0, "Step values should be non-empty")
			verify(result.routeSteps[i].expectedPage.length > 0, "Step expectedPage should be non-empty")
		}
	}

	function test_resolveTargetRoute_commonWordsNonReadonlyProperty() {
		// CommonWords.ac_sensors is declared as a non-readonly string property.
		// The resolver should still map it to "AC Sensors" and keep the route.
		var result = UiTestUtilsHelper.resolveTargetRoute(
			"/pages/vebusdevice/PageAcSensors.qml")
		verify(result.success, "PageAcSensors should be resolvable")
		compare(result.entryNavText, "Overview")
		verify(result.routeSteps.length > 0,
			"Should have route steps for AC Sensors page")

		const finalStep = result.routeSteps[result.routeSteps.length - 1]
		compare(finalStep.type, "text")
		verify(finalStep.values.indexOf("AC Sensors") >= 0,
			"Final step should include CommonWords.ac_sensors source text")
		compare(finalStep.expectedPage, "/pages/vebusdevice/PageAcSensors.qml")
	}

	function test_buildPageGraph_unresolvedQsTrIdDoesNotCreateLabel() {
		const source = "/pages/invertercharger/OverviewInverterChargerPage.qml"
		const target = "/pages/vebusdevice/PageMicrogrid.qml"
		const edge = UiTestUtilsHelper.findRouteEdge(source, target)
		verify(edge.sourceEdgeCount > 0,
			"OverviewInverterChargerPage should have parsed navigation edges")
		verify(!edge.exists,
			"Unresolved qsTrId() labels must not be treated as static click text")

		// The Microgrid page should still be resolvable via a valid static route.
		const route = UiTestUtilsHelper.resolveTargetRoute(target)
		verify(route.success, "PageMicrogrid should remain resolvable")
		for (let i = 0; i < route.routeSteps.length; ++i) {
			verify(route.routeSteps[i].values.indexOf("vebus_device_page_microgrid_parameters") < 0,
				"Translation ID must not leak into route-step candidate labels")
		}
	}

	function test_countRuntimeWarningTexts_deduplicatesAndSkipsEmpty() {
		const result = UiTestUtilsHelper.countRuntimeWarningTexts(
			["warning-one", "warning-one", " ", "warning-two"])
		compare(result.addedCount, 2)
		compare(result.recordedCount, 2)
		compare(result.newWarnings.length, 2)
	}

	function test_countRuntimeWarningTexts_respectsPreviouslyRecordedWarnings() {
		const result = UiTestUtilsHelper.countRuntimeWarningTexts(
			["warning-one", "warning-two"],
			["warning-one"])
		compare(result.addedCount, 1)
		compare(result.recordedCount, 2)
		compare(result.newWarnings.length, 1)
	}

	function test_uiTestExitCode_includesRuntimeWarnings() {
		compare(UiTestUtilsHelper.uiTestExitCode(0, 0), 0)
		compare(UiTestUtilsHelper.uiTestExitCode(1, 0), 1)
		compare(UiTestUtilsHelper.uiTestExitCode(0, 1), 1)
	}

	function test_resolveTargetRoute_overviewWidgetTarget() {
		// Pages reachable from Overview widgets (e.g. BatteryListPage) should
		// be resolvable via the Overview root. BatteryWidget is an unconditional
		// module source, so the route must always be found.
		var result = UiTestUtilsHelper.resolveTargetRoute(
			"/pages/battery/BatteryListPage.qml")
		verify(result.success, "BatteryListPage should be resolvable from Overview")
		compare(result.entryNavText, "Overview")
		verify(result.routeSteps.length > 0,
			"Should have route steps for battery list page")
		// Widget routes should use 'title' identifiers (not 'text')
		compare(result.routeSteps[0].type, "title",
			"Widget route should use title identifier type")
		verify(result.routeSteps[0].expectedPage.length > 0,
			"Widget route step should have expectedPage")
	}

	function test_resolveTargetRoute_nonexistentPage() {
		var result = UiTestUtilsHelper.resolveTargetRoute(
			"/pages/settings/PageThatDoesNotExist.qml")
		verify(!result.success, "Non-existent pages should not be resolvable")
	}

	function test_resolveTargetRoute_emptyInput() {
		var result = UiTestUtilsHelper.resolveTargetRoute("")
		verify(!result.success, "Empty input should not be resolvable")
	}

	function test_resolveTargetRoute_multiHopSettings() {
		// PageSettingsDisplayUnits is 3 hops deep:
		// Settings → General → Display & Appearance → Units
		var result = UiTestUtilsHelper.resolveTargetRoute(
			"/pages/settings/PageSettingsDisplayUnits.qml")
		verify(result.success, "Deep settings page should be resolvable")
		compare(result.entryNavText, "Settings")
		compare(result.routeSteps.length, 3, "Should have 3 route steps")
		// Verify every step has all required fields
		for (var i = 0; i < result.routeSteps.length; ++i) {
			verify(result.routeSteps[i].type.length > 0,
				"Step %1 type should be non-empty".arg(i))
			verify(result.routeSteps[i].values.length > 0,
				"Step %1 values should be non-empty".arg(i))
			verify(result.routeSteps[i].expectedPage.length > 0,
				"Step %1 expectedPage should be non-empty".arg(i))
		}
		// Final step's expectedPage should be the target
		compare(result.routeSteps[2].expectedPage,
			"/pages/settings/PageSettingsDisplayUnits.qml",
			"Last step expectedPage should be the target page")
	}

	function test_findObject_groupedIconSourceProperty() {
		const source = Qt.createQmlObject(
			'import QtQuick\n'
			+ 'import QtQuick.Controls\n'
			+ 'Item {\n'
			+ '    Button {\n'
			+ '        id: targetButton\n'
			+ '        objectName: "iconSourceTargetButton"\n'
			+ '        icon.source: "qrc:/images/icon_controls_off_32.svg"\n'
			+ '    }\n'
			+ '}\n',
			this,
			"groupedIconSourceFixture")

		verify(!!source, "Fixture item should be created")
		const expectedIconUrl = Qt.url("qrc:/images/icon_controls_off_32.svg")
		const matched = UiTestUtilsHelper.findObjectByProperties(
			source,
			{ "icon.source": expectedIconUrl },
			"QQuickAbstractButton")
		verify(!!matched, "findObject() should resolve grouped icon.source paths")
		compare(matched.objectName, "iconSourceTargetButton")
		source.destroy()
	}

	function test_pushPage_failedCreationDoesNotUpdateStackUrl() {
		const stack = Qt.createQmlObject(
			'import QtQuick\n'
			+ 'import Victron.VenusOS\n'
			+ 'PageStack {}\n',
			this,
			"pageStackFailedCreation")
		verify(!!stack, "PageStack fixture should be created")
		compare(stack._pageUrls.length, 0)
		verify(stack._topPageUrl === undefined)

		const pushed = stack.pushPage("/pages/not-a-real-page.qml", {})
		compare(pushed, null)
		compare(stack._pageUrls.length, 0)
		verify(stack._topPageUrl === undefined)
		stack.destroy()
	}

	function test_pushPage_rejectedObjectDoesNotUpdateStackUrl() {
		const stack = Qt.createQmlObject(
			'import QtQuick\n'
			+ 'import Victron.VenusOS\n'
			+ 'PageStack {}\n',
			this,
			"pageStackRejectedObject")
		verify(!!stack, "PageStack fixture should be created")
		compare(stack._pageUrls.length, 0)
		verify(stack._topPageUrl === undefined)

		const pushed = stack.pushPage(42, {})
		compare(pushed, null)
		compare(stack._pageUrls.length, 0)
		verify(stack._topPageUrl === undefined)
		stack.destroy()
	}

	function test_targetPageState_requiresRealPageObject() {
		const expectedPage = "/pages/settings/PageSettingsGeneral.qml"
		verify(!_hasValidCurrentPage({
			topPageUrl: expectedPage,
			currentPage: null,
		}, expectedPage))
		verify(!_hasValidCurrentPage({
			topPageUrl: expectedPage,
			currentPage: {},
		}, expectedPage))
		verify(_hasValidCurrentPage({
			topPageUrl: expectedPage,
			currentPage: { __is_venus_gui_page__: true },
		}, expectedPage))
		verify(!_hasValidCurrentPage({
			topPageUrl: "/pages/other.qml",
			currentPage: { __is_venus_gui_page__: true },
		}, expectedPage))
	}
}
