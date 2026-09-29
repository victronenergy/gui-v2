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

	function _qmlTypeNameFromUrl(pageUrl) {
		const slash = pageUrl.lastIndexOf("/")
		const fileName = slash >= 0 ? pageUrl.slice(slash + 1) : pageUrl
		return fileName.endsWith(".qml") ? fileName.slice(0, -4) : fileName
	}

	function _hasValidStackPage(expectedPageUrl) {
		const pageStack = Global.pageManager.pageStack
		if (!pageStack) {
			return false
		}
		if ((pageStack.topPageUrl ?? "") !== expectedPageUrl) {
			return false
		}
		const page = pageStack.currentPage
		return !!page && page.__is_venus_gui_page__ === true
	}

	function _targetIsShown(expectedPageUrl) {
		if (!expectedPageUrl) {
			return false
		}
		const current = Global.mainView ? Global.mainView.currentPage : null
		if (current && current.url && current.url.toString().indexOf(expectedPageUrl) >= 0) {
			return true
		}
		if (_hasValidStackPage(expectedPageUrl)) {
			return true
		}
		const typeName = _qmlTypeNameFromUrl(expectedPageUrl)
		if (!typeName || !Global.mainView) {
			return false
		}
		const obj = findObject(Global.mainView, {}, typeName)
		if (!obj) {
			return false
		}
		return obj.visible !== false
	}

	function _overlaysIdle() {
		if (!Global.mainView || Global.mainView.animating) {
			return false
		}
		const page = Global.mainView.currentPage
		return !(page && (page.overlayIncubating || page.overlayAnimating))
	}

	function _screenSizeName() {
		return Theme.screenSize === Theme.Portrait ? "Portrait"
			: Theme.screenSize === Theme.SevenInch ? "SevenInch"
			: "FiveInch"
	}

	function _skipRouteStep(index, reason) {
		const step = routeSteps[index]
		const candidates = (step.values && step.values.length > 0)
			? step.values.join(" | ")
			: "<none>"
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return true },
			message: "Skip %1 click for %2 (%3, screenSize=%4)"
				.arg(step.type)
				.arg(step.expectedPage || candidates)
				.arg(reason)
				.arg(_screenSizeName()),
		})
		runSteps(_clickRouteStep, [index + 1])
	}

	// Convert QVariantList route steps into a plain JS array of { type, values, expectedPage, verify } objects.
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
					if (candidate.length > 0 && values.indexOf(candidate) < 0) {
						values.push(candidate)
					}
				}
			}
			normalized.push({
				type: (step.type ?? "text").toString(),
				values: values,
				expectedPage: (step.expectedPage ?? "").toString(),
				verify: (step.verify ?? "stack").toString(),
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
		// TabBar labels live on a child Label; ListNavigation text is often
		// on the clickable item itself. Prefer an ancestor Button/MouseArea.
		if (!item) {
			return null
		}
		return findClickableParent(item) || findClickableChild(item)
	}

	// Find a clickable item matching any route-step candidate value.
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

	// Recursively find an item whose icon.source matches the given value.
	function _findItemByIconSource(parent, iconSource) {
		if (!parent) {
			return null
		}
		// Check if this item has an icon group with matching source
		if (parent.icon && parent.icon.source !== undefined) {
			if (parent.icon.source.toString().indexOf(iconSource) >= 0) {
				return parent
			}
		}
		for (let i = 0; i < parent.children.length; ++i) {
			const found = _findItemByIconSource(parent.children[i], iconSource)
			if (found) {
				return found
			}
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
		addStep(UiTestStep.WaitUntil, { callable: ()=> _overlaysIdle() })
		runSteps(callback)
	}

	// Confirm the target QML type was constructed and shown.
	function _verifyTargetShown() {
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> _overlaysIdle() && _targetIsShown(targetPageUrl),
			message: "Waiting for target type to be shown: %1".arg(targetPageUrl),
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				if (!_targetIsShown(targetPageUrl)) {
					throw new Error("Target type was not constructed/shown: %1".arg(targetPageUrl))
				}
				return true
			},
			message: "Target type verified: %1".arg(targetPageUrl),
		})
		runSteps()
	}

	// Click each pre-resolved step in order, then verify the target page.
	function _clickRouteStep(index) {
		if (index >= routeSteps.length) {
			_verifyTargetShown()
			return
		}

		const step = routeSteps[index]
		// ShownType clicks are layout-specific (e.g. landscape StatusBar side
		// panel). Skip them when the type is already visible, as in portrait
		// where BriefSidePanel is loaded with the Brief page.
		if (step.verify === "type" && step.expectedPage && _targetIsShown(step.expectedPage)) {
			_skipRouteStep(index, "type already visible")
			return
		}
		const target = _findClickTarget(Global.mainView.currentPage, step)
		if (!target) {
			// Fall back to searching the full mainView (for StatusBar buttons, etc.)
			const fallbackTarget = _findClickTarget(Global.mainView, step)
			if (!fallbackTarget) {
				const candidates = (step.values && step.values.length > 0)
					? step.values.join(" | ")
					: "<none>"
				if (step.verify === "type") {
					_skipRouteStep(index, "action not available in this orientation")
					return
				}
				addStep(UiTestStep.Abort, {
					passed: false,
					message: "Unable to find route click target: %1 (type: %2, screenSize: %3)"
						.arg(candidates).arg(step.type).arg(_screenSizeName()),
				})
				runSteps()
				return
			}
			addStep(UiTestStep.Invoke, {
				callable: ()=> { return mouseClick(fallbackTarget.clickable) },
				message: "Click %1: %2".arg(step.type).arg(fallbackTarget.matchedValue),
			})
		} else {
			addStep(UiTestStep.Invoke, {
				callable: ()=> { return mouseClick(target.clickable) },
				message: "Click %1: %2".arg(step.type).arg(target.matchedValue),
			})
		}
		addStep(UiTestStep.WaitUntil, { callable: ()=> _overlaysIdle() })

		// Verify we landed on the expected intermediate page or overlay type.
		if (step.expectedPage && step.expectedPage.length > 0) {
			const expectedPage = step.expectedPage
			const stepIndex = index + 1
			const verifyType = step.verify === "type"
			addStep(UiTestStep.WaitUntil, {
				callable: ()=> verifyType
					? _targetIsShown(expectedPage)
					: _hasValidStackPage(expectedPage),
				message: "Waiting for step %1 to show: %2".arg(stepIndex).arg(expectedPage),
			})
			addStep(UiTestStep.Invoke, {
				callable: ()=> {
					if (verifyType) {
						if (!_targetIsShown(expectedPage)) {
							throw new Error("Navigation step %1 did not construct/show '%2'."
								.arg(stepIndex).arg(expectedPage))
						}
						return true
					}
					const actualPage = Global.pageManager.pageStack.topPageUrl
					if (actualPage !== expectedPage) {
						throw new Error("Navigation step %1 opened '%2' instead of expected '%3'. The target page may not be reachable with the current mock configuration."
							.arg(stepIndex).arg(actualPage).arg(expectedPage))
					}
					if (!_hasValidStackPage(expectedPage)) {
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
			_openEntryPage(()=> _verifyTargetShown())
			return
		}
		_openEntryPage(()=> _clickRouteStep(0))
	}
}
