/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

UiTestCase {
	id: root

	window: Global.main
	property string targetPageUrl: ""
	property string routeEntryLabel: ""
	property var routeSteps: []

	function _hasValidCurrentPage(expectedPageUrl) {
		const pageStack = Global.pageManager.pageStack
		if (!pageStack)
			return false
		if ((pageStack.topPageUrl ?? "") !== expectedPageUrl)
			return false
		const page = pageStack.currentPage
		return !!page && page.__is_venus_gui_page__ === true
	}

	// Convert QVariantList route steps into a plain JS array of { type, values, expectedPage } objects.
	function _routeStepsAsArray(value) {
		if (!value || value.length === undefined) {
			return []
		}
		const normalized = []
		for (let i = 0; i < value.length; ++i) {
			const step = value[i]
			const values = []
			const rawValues = step.values
			if (Array.isArray(rawValues) || (rawValues && rawValues.length !== undefined)) {
				for (let j = 0; j < rawValues.length; ++j) {
					const candidate = (rawValues[j] ?? "").toString()
					if (candidate.length > 0 && values.indexOf(candidate) < 0)
						values.push(candidate)
				}
			}
			normalized.push({
				type: (step.type ?? "text").toString(),
				values: values,
				expectedPage: (step.expectedPage ?? "").toString(),
			})
		}
		return normalized
	}

	function _findClickTargetByValue(parent, type, value) {
		let item = null
		if (type === "text") {
			item = findItem(parent, { text: value })
		} else if (type === "title") {
			item = findItem(parent, { title: value })
		} else if (type === "objectName") {
			item = findItem(parent, { objectName: value })
		} else if (type === "iconSource") {
			// icon.source is a grouped property; search children for matching icon source.
			item = _findItemByIconSource(parent, value)
		}
		return item ? findClickableChild(item) : null
	}

	// Side-effect-free: do not scroll or forceLayout. Used from WaitUntil.
	function _findClickTarget(parent, step) {
		const candidates = (step.values && step.values.length > 0) ? step.values : []
		for (let i = 0; i < candidates.length; ++i) {
			const clickable = _findClickTargetByValue(parent, step.type, candidates[i])
			if (clickable) {
				return { clickable: clickable, matchedValue: candidates[i] }
			}
		}
		return null
	}

	function _currentPageListView() {
		const page = Global.mainView ? Global.mainView.currentPage : null
		return page ? findObject(page, {}, "BaseListView") : null
	}

	function _currentPageListViewHasDelegate() {
		const listView = _currentPageListView()
		return !!(listView && listView.count > 0 && listView.itemAtIndex(0))
	}

	function _itemMatchesStep(item, step, value) {
		if (!item)
			return false
		if (step.type === "text")
			return (item.text ?? "").toString() === value
		if (step.type === "title")
			return (item.title ?? "").toString() === value
		if (step.type === "objectName")
			return (item.objectName ?? "").toString() === value
		if (step.type === "iconSource") {
			const source = item.icon && item.icon.source !== undefined
				? item.icon.source.toString()
				: ""
			return source.indexOf(value) >= 0
		}
		return false
	}

	// Off-screen DelegateComponentModel rows are not built until they have been in view.
	// Only the current page's BaseListView is scrolled, and only when clicking, not while waiting.
	function _findClickTargetInCurrentPageListView(step) {
		const listView = _currentPageListView()
		if (!listView)
			return null
		const candidates = (step.values && step.values.length > 0) ? step.values : []
		for (let i = 0; i < listView.count; ++i) {
			let item = listView.itemAtIndex(i)
			if (!item) {
				listView.positionViewAtIndex(i, ListView.Contain)
				if (listView.forceLayout)
					listView.forceLayout()
				item = listView.itemAtIndex(i)
			}
			if (!item)
				continue
			for (let j = 0; j < candidates.length; ++j) {
				if (!_itemMatchesStep(item, step, candidates[j]))
					continue
				const clickable = findClickableChild(item) || _findClickableFromItemOrAncestors(item)
				if (clickable)
					return { clickable: clickable, matchedValue: candidates[j] }
			}
		}
		return null
	}

	function _resolveClickTarget(step) {
		return _findClickTarget(Global.mainView.currentPage, step)
			|| _findClickTarget(Global.mainView, step)
			|| _findClickTargetInCurrentPageListView(step)
	}

	// Recursively find an item whose icon.source matches the given value.
	function _findItemByIconSource(parent, iconSource) {
		if (!parent)
			return null
		// Check if this item has an icon group with matching source
		if (parent.icon && parent.icon.source !== undefined) {
			if (parent.icon.source.toString().indexOf(iconSource) >= 0) {
				return parent
			}
		}
		for (let i = 0; i < parent.children.length; ++i) {
			const found = _findItemByIconSource(parent.children[i], iconSource)
			if (found)
				return found
		}
		return null
	}

	// Open the root main-page section (e.g. Settings) before walking the resolved click route.
	function _findClickableFromItemOrAncestors(item) {
		let current = item
		while (current) {
			const clickable = findClickableChild(current)
			if (clickable) {
				return clickable
			}
			current = current.parent
		}
		return null
	}

	function _findRootNavItemClickTarget() {
		const navBar = Global.mainView ? Global.mainView.navBar : null
		if (!navBar) {
			return null
		}

		const directNavItem = findItem(navBar, { text: routeEntryLabel })
		const directClickable = findClickableChild(directNavItem)
		if (directClickable) {
			return {
				clickable: directClickable,
				requiresMoreDialog: false,
			}
		}

		const moreButton = findItem(
			navBar,
			{ "icon.source": Qt.url("qrc:/images/icon_more_dots.svg") },
			"NavButton")
		const moreClickable = findClickableChild(moreButton)
		if (moreClickable) {
			return {
				clickable: moreClickable,
				requiresMoreDialog: true,
			}
		}
		return null
	}

	function _openEntryPage(callback) {
		if (routeEntryLabel.length === 0) {
			addStep(UiTestStep.Abort, {
				passed: false,
				message: "No route entry label configured for target page: %1".arg(targetPageUrl),
			})
			runSteps()
			return
		}

		const navTarget = _findRootNavItemClickTarget()
		if (!navTarget || !navTarget.clickable) {
			addStep(UiTestStep.Abort, {
				passed: false,
				message: "Unable to find root navigation item: %1".arg(routeEntryLabel),
			})
			runSteps()
			return
		}

		if (navTarget.requiresMoreDialog) {
			addStep(UiTestStep.Invoke, {
				callable: ()=> { return mouseClick(navTarget.clickable) },
				message: "Open More navigation dialog",
			})
			addStep(UiTestStep.WaitUntil, {
				callable: ()=> !!Global.dialogLayer.currentDialog,
				message: "Waiting for More dialog to open",
			})
			addStep(UiTestStep.Invoke, {
				callable: ()=> {
					const dialog = Global.dialogLayer.currentDialog
					const labelItem = findItem(dialog, { text: routeEntryLabel })
					const clickable = _findClickableFromItemOrAncestors(labelItem)
					if (!clickable) {
						throw new Error("Unable to find root navigation item in More dialog: %1".arg(routeEntryLabel))
					}
					return mouseClick(clickable)
				},
				message: "Open root page from More: %1".arg(routeEntryLabel),
			})
			addStep(UiTestStep.WaitUntil, {
				callable: ()=> !Global.mainView.animating && !Global.dialogLayer.currentDialog,
			})
			runSteps(callback)
			return
		}

		addStep(UiTestStep.Invoke, {
			callable: ()=> { return mouseClick(navTarget.clickable) },
			message: "Open root page: %1".arg(routeEntryLabel),
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps(callback)
	}

	// Confirm the navigation route ended on the requested page URL.
	function _verifyTargetPageOpen() {
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> _hasValidCurrentPage(targetPageUrl),
			message: "Waiting for target page to appear on stack: %1".arg(targetPageUrl),
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const actualPage = Global.pageManager.pageStack.topPageUrl
				if (actualPage !== targetPageUrl) {
					throw new Error("Target page URL mismatch: expected '%1', got '%2'"
						.arg(targetPageUrl).arg(actualPage))
				}
				if (!_hasValidCurrentPage(targetPageUrl)) {
					throw new Error("Target page URL is set but no valid page object is on the stack: %1"
						.arg(targetPageUrl))
				}
				return true
			},
			message: "Target page verified: %1".arg(targetPageUrl),
		})
		runSteps()
	}

	// Click each pre-resolved step in order, then verify the target page.
	function _clickRouteStep(index) {
		if (index >= routeSteps.length) {
			_verifyTargetPageOpen()
			return
		}

		const step = routeSteps[index]
		const candidates = (step.values && step.values.length > 0)
			? step.values.join(" | ")
			: "<none>"

		// DCM rows are created on ListView polish, after !animating. Do not scroll here:
		// WaitUntil polls every 16ms and must not mutate other pages' lists.
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> !!_findClickTarget(Global.mainView.currentPage, step)
				|| !!_findClickTarget(Global.mainView, step)
				|| _currentPageListViewHasDelegate(),
			message: "Waiting for route click target: %1 (type: %2)".arg(candidates).arg(step.type),
		})
		runSteps(_clickResolvedTarget, [index])
	}

	function _clickResolvedTarget(index) {
		const step = routeSteps[index]
		const candidates = (step.values && step.values.length > 0)
			? step.values.join(" | ")
			: "<none>"
		const target = _resolveClickTarget(step)
		if (!target) {
			addStep(UiTestStep.Abort, {
				passed: false,
				message: "Unable to find route click target: %1 (type: %2)"
					.arg(candidates).arg(step.type),
			})
			runSteps()
			return
		}

		addStep(UiTestStep.Invoke, {
			callable: ()=> { return mouseClick(target.clickable) },
			message: "Click %1: %2".arg(step.type).arg(target.matchedValue),
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })

		// Verify we landed on the expected intermediate page.
		if (step.expectedPage && step.expectedPage.length > 0) {
			const expectedPage = step.expectedPage
			const stepIndex = index + 1
			addStep(UiTestStep.Invoke, {
				callable: ()=> {
					const actualPage = Global.pageManager.pageStack.topPageUrl
					if (actualPage !== expectedPage) {
						throw new Error("Navigation step %1 opened '%2' instead of expected '%3'. The target page may not be reachable with the current mock configuration."
							.arg(stepIndex).arg(actualPage).arg(expectedPage))
					}
					if (!_hasValidCurrentPage(expectedPage)) {
						throw new Error("Navigation step %1 reached URL '%2' but no valid page object was pushed."
							.arg(stepIndex).arg(expectedPage))
					}
					return true
				},
				message: "Verify step %1 reached: %2".arg(stepIndex).arg(step.expectedPage),
			})
		}

		runSteps(_clickRouteStep, [index + 1])
	}

	// Entry test: read resolved route settings and execute deterministic navigation clicks.
	function test_target_page() {
		// Already normalized to "/pages/...qml" by UiTestUtils::normalizePageUrl() in C++.
		targetPageUrl = UiTest.settingValue("TargetPage", "").toString()
		routeEntryLabel = UiTest.settingValue("RouteEntryLabel", "").toString()
		routeSteps = _routeStepsAsArray(UiTest.settingValue("RouteSteps", []))
		if (targetPageUrl.length === 0) {
			addStep(UiTestStep.Abort, {
				passed: false,
				message: "No target page specified! Pass --ui-test with a valid page URL or path.",
			})
			runSteps()
			return
		}
		if (routeSteps.length === 0) {
			addStep(UiTestStep.Abort, {
				passed: false,
				message: "No route steps configured for target page: %1".arg(targetPageUrl),
			})
			runSteps()
			return
		}
		_openEntryPage(()=> _clickRouteStep(0))
	}
}
