/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Recursively steps through a list of items and runs a capture+compare on each resulting screen.
*/
QtObject {
	id: root

	// The test case that is running this recursive capture.
	required property UiTestCase testCase

	// The last list navigation item clicked in each view (which may be a nested view), keyed by the
	// view object.
	//
	// These are Maps, and not plain objects, because a plain object keys on the *string* form of
	// the view, and repeatedly deleting and re-adding such keys hits a crash in Qt 6.8.3's QML
	// engine: at 255 redundant internal-class transitions QV4 rebuilds the class but reuses the
	// property index it computed before the rebuild, and writes through a null memberData
	// (QTBUG-147153, fixed upstream by qtdeclarative 624e90bb5, not in any released 6.8/6.9/6.10).
	// A sweep churns these keys hundreds of times per run, which segfaulted roughly one run in
	// four. A Map keys on object identity and never takes that path.
	property var lastClickedViewItems: new Map()

	// A count of the screens captured within each view, keyed by the page object. E.g. if this view
	// can be scrolled down, the number will be > 1. A Map, for the reason above.
	property var pageCaptureCounts: new Map()

	// The function to be called when all pages have been captured.
	// Note: make sure this callback calls runSteps(), otherwise any following test cases will not
	// be executed.
	property var doneCallback

	// The stack view urls that should not be captured.
	property var excludedPageUrls: []

	// If set, each capture file name is prefixed with this string.
	property string capturePrefix

	property bool _busy

	/*
		Starts the recursive capture process and calls 'doneCallback' when done.
	*/
	function start(doneCallback) {
		if (root._busy) {
			// The previous capture did not finish, most likely because one of its steps failed: a
			// failed step group skips the runSteps() callback chain and goes straight to the next
			// test function. Warn, but continue, so that a single failure does not stop every
			// following recursive capture in this test case.
			//
			// Continuing is only safe because the pages of the abandoned capture are gone by now:
			// popping them is the test case's cleanup() function's job. It cannot be done here, as
			// this capture may legitimately be starting from a page that the test just pushed.
			console.warn("Previous recursive capture did not finish; restarting at page stack depth",
					Global.pageManager.pageStack.depth)
		}
		root._busy = true
		root.doneCallback = doneCallback

		// Clear the state from any previous run, so that this run neither keeps the pages and views
		// of the last one alive nor consults their entries.
		root.pageCaptureCounts = new Map()
		root.lastClickedViewItems = new Map()

		_captureNext([])
	}

	/*
		Perform a capture+compare on the screens of the current page, then click the next
		clickable item on the page; recursively repeat this until all child screens have been
		captured.
	*/
	function _captureNext(imageNameSequence, imageNameCandidate) {
		// console.log("_captureNext():", imageNameSequence)

		// First, capture all screens within this list view.
		const canCapturePage = _canCaptureCurrentPage()
		if (canCapturePage && !pageCaptureCounts.has(Global.mainView.currentPage)) {
			// No screens have been captured yet for this page. Call _captureNextScreen() to grab
			// all screens for this page, and that function will call _captureNext() again when the
			// screen captures are completed.
			const imageName = testCase.sanitizedImageName(imageNameCandidate?.length > 0 ? imageNameCandidate : Global.mainView.currentPage.title)
			imageNameSequence.push(imageName)
			_captureNextScreen(imageNameSequence)
			return
		}

		// Then, find all clickable list items within this view, and click to open those pages and
		// capture them as well.
		let nextClickableItem
		const listView = canCapturePage ? testCase.findObject(Global.mainView.currentPage, {}, "BaseListView") : null
		if (listView) {
			nextClickableItem = _yieldNextClickableItem(listView)
		}

		if (nextClickableItem) {
			// There's a clickable in the list, so click it and call _captureNext() again.
			// Use the submenu text to identify the image when generating the file name. Do not use
			// the page title as the page may already have been captured from another submenu (for
			// example, in the solar list where multiple trackers lead to the same device page).
			// If the submenu item does not have a 'text' property, it may be a Loader, so look for
			// the loaded item's text instead.
			const subMenuText = nextClickableItem?.text ?? nextClickableItem.item?.text ?? ""
			testCase.addStep(UiTestStep.Invoke, {
				callable: ()=> { return testCase.mouseClick(testCase.findClickableChild(nextClickableItem)) },
				message: "Click menu: %1".arg(subMenuText),
			})
			testCase.addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating && Global.mainView.currentPage !== listView.parent } })
			testCase.runSteps(_captureNext, [imageNameSequence, subMenuText])
		} else {
			// There is no ListView in this page, or there are no more items to be clicked in the
			// ListView. If we have returned to the initial page, finish the tests; otherwise,
			// return to the previous page and continue the tests.
			const isInitialPage = imageNameSequence.length <= 1 // zero if initial page was not captured
			if (isInitialPage) {
				// All child pages have been opened; end the tests without further captures.
				testCase.runSteps(root.doneCallback)
				root._busy = false
			} else {
				// Pop to the previous page.
				if (canCapturePage) {
					// If the page was captured, forget its counter: the page is about to be popped
					// and destroyed, and nothing should keep a reference to it. Also update the
					// name sequence, since the page will be popped.
					pageCaptureCounts.delete(Global.mainView.currentPage)
					imageNameSequence.pop()
				}
				// Forget the clicked-item record for this page's view, for the same reason.
				if (listView) {
					lastClickedViewItems.delete(listView)
				}
				testCase.addStep(UiTestStep.Invoke, {
					callable: ()=> { Global.pageManager.popPage() },
					message: "Finished page: %1".arg(listView?.parent?.title ?? ""),
				})
				testCase.addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
				testCase.runSteps(_captureNext, [imageNameSequence])
			}
		}
	}

	/*
		Returns true if the current page should be captured.
	*/
	function _canCaptureCurrentPage() {
		return excludedPageUrls.length === 0
				|| !Global.pageManager.pageStack.topPageUrl
				|| excludedPageUrls.indexOf(Global.pageManager.pageStack.topPageUrl) < 0
	}

	/*
		Capture the next screen on the current page.

		This recursively calls itself using runSteps() until all screens on the page have been
		scrolled to and captured.
	*/
	function _captureNextScreen(imageNameSequence) {
		const listView = testCase.findObject(Global.mainView.currentPage, {}, "BaseListView")
		const isFirstCapture = !pageCaptureCounts.has(Global.mainView.currentPage)
		if (isFirstCapture) {
			pageCaptureCounts.set(Global.mainView.currentPage, 0)
		}

		pageCaptureCounts.set(Global.mainView.currentPage,
				pageCaptureCounts.get(Global.mainView.currentPage) + 1)
		const captureImageName = "%1%2_%3"
				.arg(root.capturePrefix)
				.arg(imageNameSequence.join('_'))
				.arg(pageCaptureCounts.get(Global.mainView.currentPage))
				.substring(0, 252) // limit to 255 char limit, minus 3 for png file extension.

		if (listView) {
			// Capture the current screen of the ListView.
			testCase.addStep(UiTestStep.CaptureAndCompare, {
				imageName: captureImageName,
				message: _pageDescription(),
			})
			testCase.addStep(UiTestStep.Invoke, {
				// If more screens are expected, return the result of pageDown() so that this returns
				// false (and aborts the test) if pageDown() does not scroll anywhere; otherwise the
				// test continues indefinitely as it continuously attempts to scroll down.
				callable: ()=> { return _atListEnd(listView) ? true : listView.pageDown() },
				message: "Scroll down to next screen",
			})
			if (_atListEnd(listView)) {
				// If the last screen is being captured, return to _captureNext() when this is done.
				runSteps(_captureNext, [imageNameSequence])
			} else {
				// There are more screens to be captured, so run _captureNextScreen() again.
				runSteps(_captureNextScreen, [imageNameSequence])
			}
		} else {
			// There is no ListView on this page. Capture the screen and return to _captureNext().
			testCase.addStep(UiTestStep.CaptureAndCompare, {
				imageName: captureImageName,
				message: _pageDescription() + " (no sub-pages found here)",
			})
			runSteps(_captureNext, [imageNameSequence])
		}
	}

	/*
		Find the next clickable item in the given view and keeps a record of it so it can be used
		in the next search for a clickable item.

		Note: it would be nice if we could just keep a current index and then look for the item at
		the next index on the next run, but we can't because gui-v2 settings views are complicated;
		they may have list items in nested SettingsColumns, headers/footers, etc. So we need to
		track the last clicked item and look for the next one from there.
	*/
	function _yieldNextClickableItem(listView) {
		let searchParams = { lastClickedItem: lastClickedViewItems.get(listView) }

		// Search the header for a clickable item
		if (listView.headerItem) {
			searchParams = _findNextClickableItem(listView.headerItem, searchParams)
		}

		// Search the list delegates for a clickable item
		if (!searchParams.nextClickableItem) {
			searchParams = _findNextClickableItem(listView, searchParams)

			if (searchParams.nextClickableItem
					&& searchParams.nextClickableItemView === listView) {
				// Increase the cache buffer a little, so that on the next search, the delegate
				// below this item will have been created.
				listView.cacheBuffer += searchParams.nextClickableItem.height
				listView.forceLayout()
			}
		}

		// Search the footer for a clickable item
		if (!searchParams.nextClickableItem && listView.footerItem) {
			searchParams = _findNextClickableItem(listView.footerItem, searchParams)
		}

		lastClickedViewItems.set(listView, searchParams.nextClickableItem)
		return searchParams.nextClickableItem
	}

	/*
		Look for the next item that is clickable after the specified lastClickedItem.

		searchParams is a map that specifies:
		- nextClickableItem: the next clickable menu item, if one was found.
		- nextClickableItemView: the view that contains the item (which may be different from the
		  initially specified view, if the item was found in a nested view).
		- lastClickedItem: the last item that was clicked in the view, if there was one; if not,
		  the search result will be the first clickable item found in the view.
		- foundLastClickedItem: true if lastClickedItem has been found in the view hierarchy (either
		  in the current view, or in a nested view within the current view).
	*/
	function _findNextClickableItem(view, searchParams) {
		const navHelper = view.__keyNavHelper ?? view.item?.__keyNavHelper
		if (!navHelper) {
			return searchParams
		}
		// console.log("_findNextClickableItem in view:", view, navHelper)

		// Find the last clicked item, and the next item to be clicked.
		// let lastDebug = searchParams.lastClickedItem?.text ?? searchParams.lastClickedItem?.item?.text ?? ""
		// console.log("Find next in view...", view, lastDebug)
		for (let i = 0; i < navHelper.itemCount; ++i) {
			const item = navHelper.itemAtIndex(i)
			// console.log("\titem:", i, item, item.text ?? item.item?.text ?? "",
			//             "foundLastClickedItem:", searchParams.foundLastClickedItem,
			//             "visible:", item.visble,
			//             "has sub-menu:", (item.hasSubMenu || item.item?.hasSubMenu),
			//             "interactive:", (item.interactive !== false || (!!item.item && item.item.interactive !== false)))
			if (!searchParams.foundLastClickedItem
					&& !!searchParams.lastClickedItem
					&& item === searchParams.lastClickedItem) {
				// Record that we have found the lastClickedItem.
				searchParams.foundLastClickedItem = true
				continue
			}

			// If we've gotten past the lastClickedItem (or if if the first clickable item will do)
			// and this item is clickable, then use this as the matched item. (Check the attributes
			// of the 'item' property value as well, in case this item is a Loader.)
			if (item.visible
					&& (searchParams.foundLastClickedItem || !searchParams.lastClickedItem)
					&& (item.hasSubMenu || item.item?.hasSubMenu)
					&& (item.interactive !== false || (!!item.item && item.item.interactive !== false))) {
				// Success - found the next item.
				searchParams.nextClickableItem = item
				searchParams.nextClickableItemView = view
				return searchParams
			}
			if (item.__keyNavHelper || item.item?.__keyNavHelper) {
				// console.log("\tSearch in nested view...")
				// This is a nested SettingsColumn or BaseListView.
				searchParams = _findNextClickableItem(item, searchParams)
				if (searchParams.nextClickableItem) {
					// Success - found the next item, it is within the nested view.
					return searchParams
				}
			}
		}
		return searchParams
	}

	/*
		Returns a description of the current page, including its url.
	*/
	function _pageDescription() {
		const title = Global.mainView.currentPage?.title ?? ""
		const url = Global.pageManager.pageStack.topPageUrl
		return url ? "%1 [url: %2]".arg(title).arg(url) : title
	}

	function _atListEnd(listView) {
		return (listView.orientation === Qt.Vertical && listView.atYEnd)
				|| (listView.orientation === Qt.Horizontal && listView.atXEnd)
	}
}
