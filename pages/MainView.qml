/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	readonly property color backgroundColor: !!currentPage ? currentPage.backgroundColor : Theme.color_page_background
	property PageManager pageManager
	property bool controlsActive
	readonly property Page currentPage: controlsActive && controlCardsLoader.status === Loader.Ready ? controlCardsLoader.item
			   : !!pageStack.currentItem ? pageStack.currentItem
			   : !!swipeView ? swipeView.currentItem
			   : null

	property alias navBarAnimatingOut: animateNavBarOut.running

	// To reduce the animation load, disable page animations when the PageStack is transitioning
	// between pages, or when flicking between the main pages. Note that animations are still
	// allowed when dragging between the main pages, as it looks odd if animations stop abruptly
	// when the user drags slowly between pages.
	property bool allowPageAnimations: BackendConnection.applicationVisible
			&& !pageStack.busy && (!swipeView || !swipeView.flicking)
			&& !Global.splashScreenVisible

	readonly property bool screenIsBlanked: !!Global.screenBlanker && Global.screenBlanker.blanked

	property int _loadedPages: 0

	readonly property bool _readyToInit: !!Global.pageManager && Global.dataManagerLoaded && !Global.needPageReload
	on_ReadyToInitChanged: {
		if (_readyToInit && swipeViewLoader.active == false) {
			_loadUi()
		}
	}

	function loadStartPage() {
		Global.systemSettings.startPageConfiguration.loadStartPage(swipeView, pageStack.pageUrls)
	}

	function clearUi() {
		swipeViewLoader.active = false
		pageStack.clear()
		_loadedPages = 0
	}

	function _loadUi() {
		console.warn("Data sources ready, loading pages")
		swipeViewLoader.active = true
	}

	// Revert to the start page when the application is inactive.
	Timer {
		running: !!Global.systemSettings
				 && Global.systemSettings.startPageConfiguration.hasStartPage
				 && Global.systemSettings.startPageConfiguration.startPageTimeout > 0
				 && root.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Idle
		interval: Global.systemSettings.startPageConfiguration.startPageTimeout * 1000
		onTriggered: root.loadStartPage()
	}

	// Auto-select the start page when the application is idle, if configured to do so.
	Connections {
		target: Global
		enabled: !!Global.systemSettings && Global.systemSettings.startPageConfiguration.autoSelect
		function onApplicationActiveChanged() {
			if (!Global.applicationActive) {
				const mainPageName = root.pageManager.navBar.getCurrentPage()
				const mainPage = swipeView.getCurrentPage()
				Global.systemSettings.startPageConfiguration.autoSelectStartPage(mainPageName, mainPage, pageStack.pageUrls)
			}
		}
	}

	// This SwipeView contains the main application pages (Brief, Overview, Levels, Notifications,
	// and Settings).
	property SwipeView swipeView: swipeViewLoader.item
	Loader {
		id: swipeViewLoader
		// Anchor this to the PageStack's left side, so that this view slides out of view when the
		// PageStack slides in (and vice-versa), giving the impression that the SwipeView itself
		// is part of the stack.
		anchors {
			top: statusBar.bottom
			bottom: navBar.top
			right: pageStack.left
		}
		width: Theme.geometry_screen_width
		active: false
		asynchronous: true
		sourceComponent: swipeViewComponent
		visible: swipeView && swipeView.ready && pageStack.swipeViewVisible && !(root.controlsActive && !controlsInAnimation.running && !controlsOutAnimation.running)
		onLoaded: {
			// If there is an alarm, the notifications page will be shown; otherwise, show the
			// application start page, if set.
			if (!Global.notifications.alarm) {
				root.loadStartPage()
			}
			// Notify that the UI is ready to be displayed.
			Global.allPagesLoaded = true
		}
	}

	Component {
		id: swipeViewComponent
		SwipeView {
			id: _swipeView

			property bool ready: Global.allPagesLoaded && !moving // hide this view until all pages are loaded and we have scrolled back to the brief page

			onReadyChanged: if (ready) ready = true // remove binding
			anchors.fill: parent
			onCurrentIndexChanged: navBar.setCurrentIndex(currentIndex)
			contentChildren: swipePageModel.children
		}
	}

	SwipePageModel {
		id: swipePageModel
		view: swipeView
	}

	Loader {
		id: controlCardsLoader

		onActiveChanged: if (active) active = true // remove binding

		z: 1
		opacity: 0.0
		sourceComponent: ControlCardsPage { }
		active: root.controlsActive
		enabled: root.controlsActive || controlsOutAnimation.running

		anchors {
			top: statusBar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		SequentialAnimation {
			id: controlsInAnimation
			running: root.controlsActive

			ParallelAnimation {
				YAnimator {
					target: controlCardsLoader
					from: statusBar.height - Theme.geometry_controlCards_slide_distance
					to: statusBar.height
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
				OpacityAnimator {
					target: controlCardsLoader
					from: 0.0
					to: 1.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
				OpacityAnimator {
					target: swipeView
					from: 1.0
					to: 0.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
				OpacityAnimator {
					target: navBar
					from: 1.0
					to: 0.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
				ColorAnimation {
					target: statusBar
					property: "color"
					from: root.backgroundColor
					to: Theme.color_page_background
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
			}
		}

		SequentialAnimation {
			id: controlsOutAnimation

			running: controlCardsLoader.active && !root.controlsActive

			ParallelAnimation {
				YAnimator {
					target: controlCardsLoader
					from: statusBar.height
					to: statusBar.height - Theme.geometry_controlCards_slide_distance
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
				OpacityAnimator {
					target: controlCardsLoader
					from: 1.0
					to: 0.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
				OpacityAnimator {
					target: swipeView
					from: 0.0
					to: 1.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
				OpacityAnimator {
					target: navBar
					from: 0.0
					to: 1.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
				ColorAnimation {
					target: statusBar
					property: "color"
					from: Theme.color_page_background
					to: root.backgroundColor
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
			}
		}
	}

	NavBar {
		id: navBar

		x: swipeViewLoader.x
		y: root.height + 4  // nudge below the visible area for wasm
		color: root.backgroundColor
		opacity: 0
		model: swipeView ? swipeView.contentModel : null

		onCurrentIndexChanged: if (swipeView) swipeView.setCurrentIndex(currentIndex)

		Component.onCompleted: pageManager.navBar = navBar

		SequentialAnimation {
			running: !Global.splashScreenVisible

			// Force the final animation values in case the Animators are
			// not run (skipping the splash screen causes the animations to
			// start before the parent is visible).
			onStopped: {
				navBar.y = yAnimator.to
				navBar.opacity = opacityAnimator.to
			}

			PauseAnimation {
				duration: Theme.animation_navBar_initialize_delayedStart_duration
			}
			ParallelAnimation {
				YAnimator {
					id: yAnimator
					target: navBar
					from: root.height - navBar.height + Theme.geometry_navigationBar_initialize_margin
					to: root.height - navBar.height
					duration: Theme.animation_navBar_initialize_fade_duration
				}
				OpacityAnimator {
					id: opacityAnimator
					target: navBar
					from: 0.0
					to: 1.0
					duration: Theme.animation_navBar_initialize_fade_duration
				}
			}
		}

		SequentialAnimation {
			id: animateNavBarIn

			running: !!Global.pageManager && (Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen
											  || Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_ExitIdleMode)

			YAnimator {
				target: navBar
				from: root.height
				to: root.height - navBar.height
				duration: Theme.animation_page_idleResize_duration
				easing.type: Easing.InOutQuad
			}
			ScriptAction {
				script: {
					if (!!Global.pageManager) {
						Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_ExitIdleMode
					}
				}
			}
			OpacityAnimator {
				target: navBar
				from: 0.0
				to: 1.0
				duration: Theme.animation_page_idleOpacity_duration
				easing.type: Easing.InOutQuad
			}
			ScriptAction {
				script: {
					if (!!Global.pageManager) {
						Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_Interactive
					}
				}
			}
		}

		SequentialAnimation {
			id: animateNavBarOut

			running: !!Global.pageManager && (Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_EnterIdleMode
					 || Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen)

			OpacityAnimator {
				target: navBar
				from: 1.0
				to: 0.0
				duration: Theme.animation_page_idleOpacity_duration
				easing.type: Easing.InOutQuad
			}
			ScriptAction {
				script: {
					if (!!Global.pageManager) {
						Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_BeginFullScreen
					}
				}
			}
			YAnimator {
				target: navBar
				from: root.height - navBar.height
				to: root.height
				duration: Theme.animation_page_idleResize_duration
				easing.type: Easing.InOutQuad
			}
			ScriptAction {
				script: {
					if (!!Global.pageManager) {
						Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_Idle
					}
				}
			}
		}
	}

	// This stack is used to view Overview drilldown pages and Settings sub-pages. When
	// Global.pageManager.pushPage() is called, pages are pushed onto this stack.
	PageStack {
		id: pageStack

		anchors {
			top: statusBar.bottom
			bottom: parent.bottom
		}
		x: width
		width: Theme.geometry_screen_width
	}

	StatusBar {
		id: statusBar

		pageStack: pageStack
		title: !!root.currentPage ? root.currentPage.title || "" : ""
		leftButton: {
			const customButton = !!root.currentPage ? root.currentPage.topLeftButton : VenusOS.StatusBar_LeftButton_None
			if (customButton === VenusOS.StatusBar_LeftButton_None && pageStack.depth > 0) {
				return VenusOS.StatusBar_LeftButton_Back
			}
			return customButton
		}
		rightButton: !!root.currentPage ? root.currentPage.topRightButton : VenusOS.StatusBar_RightButton_None
		animationEnabled: BackendConnection.applicationVisible
		color: root.backgroundColor

		onLeftButtonClicked: {
			switch (leftButton) {
			case VenusOS.StatusBar_LeftButton_ControlsInactive:
				root.controlsActive = true
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:
				root.controlsActive = false
				break;
			case VenusOS.StatusBar_LeftButton_Back:
				pageManager.popPage()
				break
			default:
				break
			}
		}

		onPopToPage: function(toPage) {
			pageManager.popPage(toPage)
		}

		Component.onCompleted: pageManager.statusBar = statusBar
	}

	Loader {
		active: Global.displayCpuUsage
		anchors {
			bottom: parent.bottom
			right: parent.right
		}
		sourceComponent: CpuMonitor {
			color: root.backgroundColor
		}
	}

	Column {
		width: parent.width
		spacing: 0

		/* options:

			- updateDataOnClick: false
				defer the data setting - that means you have to
				handle onClicked here... (but the clicked signal will correcly NOT emit if
				the inner switch is not enabled.
				We might want a popup to confirm the setting via the dataItem.setValue() mechanism or
				some other externally settable property

			- checkable: false (default)
				this ensurse that the check box checked state (asynchronously) follows backend data ONLY and does not self-check.

			- checked: if you want to bind the internal Switch's checked state to some external binding
				rather than the internal default (VEQuickItem) one (this does happen).
				NOTE: checked could update asynchronously or not at all.
				NOTE: do not handle onCheckedChanged unless there is a really good reason to do so.

			- editable: defaults to userHasWriteAccess, but may be overridden to be more or less constrained.
				NOTE: userHasWriteAccess (and enabled) must still be true for editable to have any effect.
				NOTE: if updating external data, onClicked: if(editable) { ... } is required to adhere to the editable rules
				since onClicked will always be emitted, even if editable is false.

			- onClicked: always emitted!
				Handle if you want to do a deferred confirm / update sequence.
				use in conjunction with updateDataOnClick: false
				You would not normally want to handle onClicked if updateDataOnClick is true.
				To prevent this we would use an overridden function call instead but I'm not convinced.
		*/

		ListSwitch {
			id: readonlyListSwitch

			// example of how to show "why you can't check this switch"

			property ToastNotification toast: null

			Connections {
				target: readonlyListSwitch.toast
				function onDismissed() {
					readonlyListSwitch.toast = null
				}
			}

			text: "Readonly ListSwitch"
			editable: false // override default userHasWriteAccess binding due to "some external condition"

			// checked: true

			onClicked: {
				if(!editable) {
					toast?.close()

					if(checked) {
						toast = Global.showToastNotification(VenusOS.Notification_Warning, `you can't un-check ${text}!`,
															 Theme.animation_generator_detectGeneratorNotSet_toastNotification_autoClose_duration)
					} else {
						toast = Global.showToastNotification(VenusOS.Notification_Warning, `you can't check ${text}!`,
															 Theme.animation_generator_detectGeneratorNotSet_toastNotification_autoClose_duration)
					}
				}
			}
		}

		ListSwitch {
			id: editableListSwitch

			// example of how to have a ListSwitch automatically change a backend value

			property ToastNotification toast: null

			Connections {
				target: editableListSwitch.toast
				function onDismissed() {
					editableListSwitch.toast = null
				}
			}

			// dataItem.uid: <something valid required to test this>

			text: "Editable ListSwitch"
			editable: true // overwrite editable for this example
			updateDataOnClick: true

			// for information only (because checked changing could be asynchronous)
			onCheckedChanged: {
				toast?.close()
				toast = Global.showToastNotification(VenusOS.Notification_Info, `You changed the state to ${checked ? "CHECKED" : "UNCHECKED"}!`,
													 Theme.animation_generator_detectGeneratorNotSet_toastNotification_autoClose_duration)
			}
		}

		ListSwitch {
			id: deferredListSwitch

			// example of how we can defer the setting to a confirmation dialog

			// dataItem.uid: <something valid required to test this>

			text: "Defer data setting"
			updateDataOnClick: false
			editable: true

			onClicked: {
				console.log("Deferring data setting")
				Global.dialogLayer.open(testConfirmDialog)
			}

			Component {
				id: testConfirmDialog

				ModalWarningDialog {
					dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
					title: "Are you sure?"
					description: "Please confirm the desired change"

					onAccepted: {
						console.log("Test Confirmation Accepted")
						//deferredListSwitch.dataItem.setData(...)
						// Qt 6.8 will demand pragma ComponentBehavior: Bound for this
						// deferredListSwitch.dataItem.setValue( ... ) // TBC
					}
				}
			}
		}

		ListSwitch {
			id: stupidUseCase

			// a scenario where the internal Switch is enabled and updateOnClick, but we also
			// so something in contradiction - like try and defer...

			// dataItem.uid: <something valid required to test this>

			text: "Incorrect Defer data setting"

			updateDataOnClick: true
			editable: true

			onClicked: {
				console.log("Yeah, just don't do this... the data may be already changing asynchronously")
				// is this the ONLY reason to consider the clickHandler functions?
			}
		}

		ListSwitch {
			id: externalBindingSwitch

			text: "External checked binding"

			property bool externalValue: false

			updateDataOnClick: false
			editable: true // else it is not permitted to make changes (internally)
			checked: externalValue

			// we need to check the editable property here...
			onClicked: if(editable) externalValue = !externalValue
		}
	}
}
