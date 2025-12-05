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

	// A map of { viewObject: navigationItem } containing the last list navigation item clicked in
	// each view (which may be a nested view).
	property var lastClickedViewItems: ({})

	// A map of { viewObject: imageId } containing the last image id (int) used to capture an image
	// in each view.
	property var viewImageIds: ({})

	// A map of { viewObject: int } containing a count of the screens captured within this view.
	// E.g. if this view can be scrolled down, the number will be > 1.
	property var pageCaptureCounts: ({})

	// The function to be called when all pages have been captured.
	// Note: make sure this callback calls runSteps(), otherwise any following test cases will not
	// be executed.
	property var doneCallback

	// The stack view urls that should not be captured.
	property var excludedPageUrls: []

	function start(baseImageName, doneCallback) {
		root.viewImageIds = {}
		root.doneCallback = doneCallback
		_captureNext([baseImageName])
	}

	/*
		Perform a capture+compare on the screens of the current page, then click the next
		clickable item on the page; recursively repeat this until all child screens have been
		captured.
	*/
	function _captureNext(imageNameSequence) {
		// console.log("_captureNext():", imageNameSequence)

		// First, capture all screens within this list view.
		if (_canCaptureCurrentPage() && pageCaptureCounts[Global.mainView.currentPage] === undefined) {
			// No screens have been captured yet for this page. Call _captureNextScreen() to grab
			// all screens for this page, and that function will call _captureNext() again when the
			// screen captures are completed.
			_captureNextScreen(imageNameSequence)
			return
		}

		// Then, find all clickable list items within this view, and click to open those pages and
		// capture them as well.
		let nextClickableItem
		const listView = _canCaptureCurrentPage() ? testCase.findObject(Global.mainView.currentPage, {}, "BaseListView") : null
		if (listView) {
			nextClickableItem = _yieldNextClickableItem(listView)
		}

		if (nextClickableItem) {
			// There's a clickable in the list, so click it and call _captureNext() again.
			const nextImageId = viewImageIds[listView] ?? 1
			viewImageIds[listView] = nextImageId + 1
			imageNameSequence.push(nextImageId)
			testCase.addStep(UiTestStep.Invoke, {
				callable: ()=> { return testCase.mouseClick(testCase.findClickableChild(nextClickableItem)) },
				message: "Click menu: %1".arg(nextClickableItem.text ?? ""),
			})
			testCase.addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating && Global.mainView.currentPage !== listView.parent } })
			testCase.runSteps(_captureNext, [imageNameSequence])
		} else {
			// There is no ListView in this page, or there are no more items to be clicked in the
			// ListView.
			const isInitialPage = imageNameSequence.length === 1
			if (isInitialPage) {
				// All child pages have been opened; end the tests without further captures.
				testCase.runSteps(root.doneCallback)
			} else {
				// Pop to the previous page.
				testCase.addStep(UiTestStep.Invoke, {
					callable: ()=> { Global.pageManager.popPage() },
					message: "Finished page: %1".arg(listView?.parent?.title ?? ""),
				})
				testCase.addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
				imageNameSequence.pop()
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
		const isFirstCapture = pageCaptureCounts[Global.mainView.currentPage] === undefined
		if (isFirstCapture) {
			pageCaptureCounts[Global.mainView.currentPage] = 1
		}
		if (listView) {
			// Capture the current screen of the ListView.
			const currentCaptureCount = pageCaptureCounts[Global.mainView.currentPage]
			pageCaptureCounts[Global.mainView.currentPage] += 1
			testCase.addStep(UiTestStep.CaptureAndCompare, {
				imageName: "%1-screen%2".arg(imageNameSequence.join('_')).arg(currentCaptureCount),
				message: Global.mainView.currentPage.title,
			})
			testCase.addStep(UiTestStep.Invoke, {
				// If more screens are expected, return the result of pageDown() so that this returns
				// false (and aborts the test) if pageDown() does not scroll anywhere; otherwise the
				// test continues indefinitely as it continuously attempts to scroll down.
				callable: ()=> { return _atListEnd(listView) ? true : listView.pageDown() && (listView.forceLayout() ?? true) },
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
				imageName: "%1-screen1".arg(imageNameSequence.join('_')),
				message: Global.mainView.currentPage.title + "(no sub-pages found here)",
			})
			runSteps(_captureNext, [imageNameSequence])
		}
	}

	/*
		Find the next clickable item in the given view and keeps a record of it so it can be used
		in the next search for a clickable item.

		Note, it would be nice if we could just keep a current index and then look for the item at
		the next index on the next run, but we can't because gui-v2 settings views are complicated:
		they may have list items in nested SettingsColumns, headers/footers, etc. So we need to
		track the last clicked item and look for the next one from there.
	*/
	function _yieldNextClickableItem(listView) {
		let searchParams = { lastClickedItem: lastClickedViewItems[listView] }

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

		lastClickedViewItems[listView] = searchParams.nextClickableItem
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
		const navHelper = view.__navHelper ?? view.item?.__navHelper
		if (!navHelper) {
			return searchParams
		}
		// console.log("_findNextClickableItem in view:", view, navHelper)

		// Find the last clicked item, and the next item to be clicked.
		let lastDebug = searchParams.lastClickedItem?.text ?? searchParams.lastClickedItem?.item?.text ?? ""
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
			if (item.__navHelper || item.item?.__navHelper) {
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

	function _atListEnd(listView) {
		return (listView.orientation === Qt.Vertical && listView.atYEnd)
				|| (listView.orientation === Qt.Horizontal && listView.atXEnd)
	}
}
