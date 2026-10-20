/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	The main page stack for the application.

	This is used to add above the main application layer in a stack-like manner, where pages can be
	pushed on top and then "popped" to reveal the last-pushed page.

	When the first page is pushed, the stack slides into view, and when the last page is popped, the
	stack slides out of view.
*/
StackView {
	id: root

	// True when fully opened (i.e. opened, and not animating in or out of the opened state).
	readonly property bool opened: _fullyOpened
	readonly property Page currentPage: opened ? currentItem : null

	// Use Global.animationEnabled, not MainView.allowPageAnimations.
	// allowPageAnimations is false while this stack is busy, which made the
	// first drill-down slide duration 0.
	readonly property int animationDuration: Global.animationEnabled ? Theme.animation_page_slide_duration : 0
	// First-page slide-in duration. Set before push(), so a busy stack cannot
	// set it to 0.
	readonly property int fakePushDuration: fakePushAnimation.duration
	readonly property bool animating: busy || fakePushTransition.running || fakePopTransition.running

	// The file url of the top page on the stack. Undefined if depth=0 or not opened, or an empty
	// string if the top page is from a component (and so no url is available).
	property var topPageUrl: opened ? _topPageUrl : undefined

	property var _pageUrls: []
	property Page _poppedPage
	property var _topPageUrl
	property bool _fullyOpened

	// Slide new drill-down pages in from the right
	pushEnter: Transition {
		XAnimator {
			from: width
			to: 0
			duration: root.animationDuration
			easing.type: Easing.InOutQuad
		}
	}

	pushExit: Transition {
		XAnimator {
			from: 0
			to: -width
			duration: root.animationDuration
			easing.type: Easing.InOutQuad
		}
	}
	popEnter: Transition {
		XAnimator {
			from: -width
			to: 0
			duration: root.animationDuration
			easing.type: Easing.InOutQuad
		}
	}

	popExit: Transition {
		SequentialAnimation {
			XAnimator {
				from: 0
				to: width
				duration: root.animationDuration
				easing.type: Easing.InOutQuad
			}
			ScriptAction {
				script: {
					// Clean up the page object that was created on push.
					if (root._poppedPage && !Theme.objectHasQObjectParent(root._poppedPage)) {
						root._poppedPage.destroy()
					}
					root._poppedPage = null
				}
			}
		}
	}

	function pushPage(obj, properties, operation) {
		if (root.animating) {
			return null
		}
		if (state === "hidden") {
			// If the stack was hidden, it now contains pages that are no longer relevant. Clear all
			// pages on the stack, without changing the state to closed.
			_popAndDestroyAllPages(StackView.Immediate)
		}

		const pageUrl = typeof(obj) === "string" ? obj : ""
		let objectOrUrl = typeof(obj) !== "string" ? obj
			: obj.indexOf("qrc:") === 0 ? obj
			: ".." + obj
		let createdPageObject = null
		if (typeof(obj) === "string") {
			// pre-construct the object to make sure there are no errors
			// to avoid messing up the page stack state.
			// Qt.createComponent() has no parent. Destroy it on every path, or it stays allocated.
			// The page does not need it after createObject() returns.
			let checkComponent = Qt.createComponent(objectOrUrl)
			if (checkComponent.status !== Component.Ready) {
				console.warn("Aborted attempt to push page with errors: " + obj + ": " + checkComponent.errorString())
				checkComponent.destroy()
				return null
			}
			createdPageObject = checkComponent.createObject(null, properties)
			if (!createdPageObject) {
				console.warn("Aborted attempt to push page because createObject() failed: " + obj + ": " + checkComponent.errorString())
				checkComponent.destroy()
				return null
			}
			checkComponent.destroy()
			if (!createdPageObject.__is_venus_gui_page__) {
				createdPageObject.destroy()
				console.warn("Aborted attempt to push page whose root is not a Page: " + obj
						+ ". Use pushPluginPage() for the pages of GUI plugins.")
				return null
			}
			objectOrUrl = createdPageObject
		}
		return _pushPageObject(objectOrUrl, properties, createdPageObject, pageUrl, operation)
	}

	// Pushes a page from a GUI plugin. The root of a plugin page is a PluginPage (or a type
	// derived from it) from Victron.GuiPlugins, never a Page. It is shown inside a page of
	// type PluginHostPage, which owns it, so the two are destroyed together.
	// 'url' is the full URL of the plugin's QML file, such as "qrc:/MyPlugin/MyPage.qml".
	function pushPluginPage(url, properties, operation) {
		if (root.animating) {
			return null
		}
		if (state === "hidden") {
			_popAndDestroyAllPages(StackView.Immediate)
		}

		// Qt.createComponent() has no parent. Destroy it on every path, or it stays allocated.
		// The page does not need it after createObject() returns.
		const component = Qt.createComponent(url)
		if (component.status !== Component.Ready) {
			console.warn("Aborted attempt to push plugin page with errors: " + url + ": " + component.errorString())
			component.destroy()
			return null
		}
		const hostPage = pluginHostPageComponent.createObject(null)
		if (!hostPage) {
			component.destroy()
			console.warn("Aborted attempt to push plugin page because its host page could not be created: " + url)
			return null
		}
		// The host page is the plugin page's parent (both the QObject parent and the visual
		// parent), so the plugin page stops and is destroyed when the host page is destroyed.
		const pluginPage = component.createObject(hostPage, properties)
		if (!pluginPage) {
			const error = component.errorString()
			component.destroy()
			hostPage.destroy()
			console.warn("Aborted attempt to push plugin page because createObject() failed: " + url + ": " + error)
			return null
		}
		component.destroy()
		if (pluginPage.__is_venus_gui_page__) {
			hostPage.destroy()
			console.warn("Aborted attempt to push plugin page whose root is a Page: " + url
					+ ". The root of a plugin page must be a PluginPage from Victron.GuiPlugins.")
			return null
		}
		// Assigning a non-item, such as a QtObject, only warns, and the blank host would still open.
		if (!(pluginPage instanceof Item)) {
			hostPage.destroy()
			console.warn("Aborted attempt to push plugin page whose root is not an item: " + url
					+ ". The root of a plugin page must be a PluginPage from Victron.GuiPlugins.")
			return null
		}
		hostPage.pluginPage = pluginPage
		return _pushPageObject(hostPage, undefined, hostPage, url, operation)
	}

	function _pushPageObject(objectOrUrl, pushProperties, createdPageObject, pageUrl, operation) {
		let pushedPage = null
		if (root.state !== "opened") {
			// Closed or hidden: push the page immediately, then slide the stack in.
			// Set the duration before push(). An Immediate push can mark the stack
			// busy, which used to set the duration to 0.
			const slideDuration = _animationDuration(operation)
			pushedPage = root.push(objectOrUrl, pushProperties, StackView.Immediate)
			if (!pushedPage) {
				if (createdPageObject && !Theme.objectHasQObjectParent(createdPageObject)) {
					createdPageObject.destroy()
				}
				console.warn("Aborted attempt to push page because StackView rejected the page object: " + pageUrl)
				return null
			}
			root._pageUrls.push(pageUrl)
			root._topPageUrl = pageUrl
			fakePushAnimation.duration = slideDuration
			root.state = "opened"
		} else {
			// Otherwise, push the push onto the visible stack, possibly with an animation.
			pushedPage = root.push(objectOrUrl, pushProperties, _adjustedStackOperation(operation))
			if (!pushedPage) {
				if (createdPageObject && !Theme.objectHasQObjectParent(createdPageObject)) {
					createdPageObject.destroy()
				}
				console.warn("Aborted attempt to push page because StackView rejected the page object: " + pageUrl)
				return null
			}
			root._pageUrls.push(pageUrl)
			root._topPageUrl = pageUrl
		}
		return pushedPage
	}

	function popAllPages(operation) {
		if (!_canPopTo(null)) {
			return
		}
		fakePopAnimation.duration = _animationDuration(operation)
		root.state = "closed"
	}

	function popPage(toPage, operation) {
		if (toPage === null) {
			popAllPages(operation)
			return
		}

		if (!_canPopTo(toPage)) {
			return
		}
		root._pageUrls.pop()
		root._topPageUrl = root._pageUrls[root._pageUrls.length-1]

		if (root.depth === 1) {
			// When the last page is removed from the stack, move the stack out of view.
			fakePopAnimation.duration = _animationDuration(operation)
			root.state = "closed"
		} else {
			// Pop and delay destruction of the popped page until the animation completes,
			// otherwise the page disappears immediately.
			_poppedPage = root.pop(toPage, _adjustedStackOperation(operation))
		}
	}

	function show() {
		if (animating || state === "opened" || depth === 0) {
			return false
		}
		fakePushAnimation.duration = _animationDuration(StackView.PushTransition)
		state = "opened"
		return true
	}

	function hide() {
		if (animating || state !== "opened") {
			return false
		}
		fakePopAnimation.duration = _animationDuration(StackView.PopTransition)
		state = "hidden"
		return true
	}

	function _popAndDestroyAllPages(operation) {
		root._pageUrls = []
		root._topPageUrl = undefined

		while (root.depth > 1) {
			const page = root.pop(operation)
			if (page && !Theme.objectHasQObjectParent(page)) {
				page.destroy()
			}
		}

		// pop() only works for depth > 1
		const obj = root.currentItem
		root.clear()

		// Clean up the page object that was created in pushPage().
		if (obj && !Theme.objectHasQObjectParent(obj)) {
			obj.destroy()
		}
	}

	function _canPopTo(toPage) {
		if (root.animating
				|| (!!root.currentItem && !!root.currentItem.tryPop && !root.currentItem.tryPop(toPage))) {
			return false
		}
		return true
	}

	function _animationDuration(operation) {
		return Global.allPagesLoaded && operation !== StackView.Immediate ? root.animationDuration : 0
	}

	function _adjustedStackOperation(operation) {
		return Global.allPagesLoaded && operation !== StackView.Immediate ? operation : StackView.Immediate
	}

	// The stack is initially off-screen, and slides into view when the first page is pushed.
	x: Theme.geometry_screen_width
	width: Theme.geometry_screen_width
	state: "closed"
	enabled: opened

	states: [
		State {
			name: "opened"
			PropertyChanges {
				target: root
				x: 0
			}
		}
	]

	transitions: [
		Transition {
			id: fakePushTransition

			to: "opened"

			SequentialAnimation {
				NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
					id: fakePushAnimation

					property: "x"
					easing.type: Easing.InOutQuad
				}
				ScriptAction {
					script: root._fullyOpened = true
				}
			}
		},
		Transition {
			id: fakePopTransition

			from: "opened"

			SequentialAnimation {
				ScriptAction {
					script: root._fullyOpened = false
				}
				NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
					id: fakePopAnimation
					property: "x"
					easing.type: Easing.InOutQuad
				}
				ScriptAction {
					script: {
						if (root.state === "hidden") {
							// The stack is just being hidden temporarily; do not pop all pages.
							return
						}

						// When leaving the page stack destroy all the pages
						root._popAndDestroyAllPages(fakePopAnimation.duration > 0 ? StackView.PopTransition : StackView.Immediate)
					}
				}
			}
		}
	]

	Component {
		id: pluginHostPageComponent

		PluginHostPage {}
	}
}
