/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	id: root

	required property PageStack pageStack
	property string title
	property alias backgroundColor: backgroundRect.color

	property int leftButton: VenusOS.StatusBar_LeftButton_None
	property int rightButton: VenusOS.StatusBar_RightButton_None
	readonly property bool notificationButtonsEnabled: Global.mainView.currentPage && !!Global.mainView.currentPage.url && !Global.mainView.currentPage.url.endsWith("NotificationsPage.qml") && !Global.portraitMode
	readonly property bool notificationButtonVisible: alarmButton.enabled || alarmButton.animating

	property bool animationEnabled

	signal leftButtonClicked()
	signal rightButtonClicked()
	signal auxButtonClicked()
	// PageStack.get(...) returns an Item, so the arg for 'popToPage' needs to be 'Item'. If we make it a 'Page', it works fine on the desktop,
	// but shows an unusual failure on the device. There is an error message about "passing incompatible arguments to signals is not supported",
	// and the page stack pops 1 too many pages.
	signal popToPage(toPage: Item)

	width: parent.width
	height: Theme.geometry_statusBar_height
	opacity: 0.0

	Component.onCompleted: if (!animationEnabled) { root.opacity = 1.0 }

	Rectangle {
		id: backgroundRect
		anchors.fill: parent
	}

	SequentialAnimation {
		running: !Global.splashScreenVisible && animationEnabled

		PauseAnimation {
			duration: Theme.animation_statusBar_initialize_delayedStart_duration
		}
		OpacityAnimator {
			target: root
			from: 0.0
			to: 1.0
			duration: Theme.animation_statusBar_initialize_fade_duration
		}
	}

	component StatusBarButton : Button {
		radius: 0
		defaultBackgroundWidth: Theme.geometry_statusBar_button_height
		defaultBackgroundHeight: Theme.geometry_statusBar_button_height
		backgroundColor: "transparent"  // don't show background when disabled
		display: Button.IconOnly
		color: Theme.color_ok
		opacity: enabled && Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive ? 1.0 : 0.0
		onActiveFocusChanged: {
			if (activeFocus) {
				breadcrumbs.updateFocusEdgeHint()
			}
		}

		// For convenience, bind the paddings to the offsets that are used to expand the clickable
		// area. If the button only contains an icon, no additional padding is required as the icon
		// fits within the default defaultBackgroundWidth/Height.
		leftPadding: leftInset
		rightPadding: rightInset
		topPadding: topInset
		bottomPadding: bottomInset

		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator {
				duration: Theme.animation_page_idleOpacity_duration
			}
		}
	}

	component NotificationButton : Button {
		readonly property bool animating: animator.running

		opacity: enabled ? 1 : 0
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_caption
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator {
				id: animator
				duration: Theme.animation_toastNotification_fade_duration
			}
		}
	}

	StatusBarButton {
		id: leftButton

		x: !Global.portraitMode || root.leftButton === VenusOS.StatusBar_LeftButton_Back ? 0
		 : (parent.width - rightButtonRow.width - auxButton.width - width)

		// Expand clickable area on left and bottom edges.
		leftInset: Theme.geometry_statusBar_horizontalMargin
		bottomInset: Theme.geometry_statusBar_spacing

		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsInactive ? "qrc:/images/icon_controls_off_32.svg"
			: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive ? "qrc:/images/icon_controls_on_32.svg"
			: root.leftButton === VenusOS.StatusBar_LeftButton_Back ? "qrc:/images/icon_back_32.svg"
			: ""
		enabled: root.leftButton !== VenusOS.StatusBar_LeftButton_None
		KeyNavigation.right: auxButton

		onClicked: root.leftButtonClicked()
	}

	StatusBarButton {
		id: auxButton

		readonly property bool auxCardsOpened: Global.mainView.cardsActive
				&& root.leftButton !== VenusOS.StatusBar_LeftButton_ControlsActive

		// Expand clickable area on right and bottom edges, and on left if leftButton is hidden.
		x: !Global.portraitMode ? leftButton.width + -leftInset
		 : (parent.width - rightButtonRow.width - width)

		leftInset: leftButton.enabled ? 0 : Theme.geometry_statusBar_spacing
		rightInset: Global.portraitMode ? 0 : Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		visible: (!root.pageStack.opened && Global.switches.groups.count > 0)
				|| auxCardsOpened // allow cards to be closed if all switches are disconnected while opened
		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive ? ""
				: auxCardsOpened ? "qrc:/images/icon_smartswitch_on_32.svg"
				: "qrc:/images/icon_smartswitch_off_32.svg"
		enabled: root.leftButton !== VenusOS.StatusBar_LeftButton_ControlsActive
		KeyNavigation.right: breadcrumbs

		onClicked: root.auxButtonClicked()
	}

	Label {
		id: portraitTitle

		anchors.verticalCenter: parent.verticalCenter
		x: Theme.geometry_settings_breadcrumb_horizontalMargin + (root.leftButton === VenusOS.StatusBar_LeftButton_Back ? leftButton.width : 0)
		width: parent.width - x - rightButtonRow.width - auxButton.width - (root.leftButton === VenusOS.StatusBar_LeftButton_Back ? 0 : leftButton.width)

		visible: Global.portraitMode
		font.pixelSize: Theme.font_size_h1
		fontSizeMode: Text.HorizontalFit
		verticalAlignment: Text.AlignVCenter
		text: root.title.length > 0 ? root.title
			: breadcrumbs.currentIndex >= 0 ? breadcrumbs.getText(breadcrumbs.currentIndex)
			: ""
	}

	Breadcrumbs {
		id: breadcrumbs

		property int focusEdgeHint: Qt.LeftEdge

		function updateFocusEdgeHint() {
			// When breadcrumbs list is focused: if focus is arriving from the left side, focus the
			// the left-most breadcrumb, or if from the right side, focus the right-most breadcrumb.
			if (leftButton.activeFocus || auxButton.activeFocus) {
				focusEdgeHint = Qt.LeftEdge
			} else if (rightButton.activeFocus || sleepButton.activeFocus) {
				focusEdgeHint = Qt.RightEdge
			} else {
				// Focus is coming from the main list view below, so do not change the current index
				focusEdgeHint = -1
			}
		}

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_breadcrumb_topMargin
			left: leftButton.right
			leftMargin: Theme.geometry_settings_breadcrumb_horizontalMargin
			right: rightButtonRow.left
		}
		height: Theme.geometry_settings_breadcrumb_height
		model: root.pageStack.opened ? root.pageStack.depth + 1 : null // '+ 1' because we insert a dummy breadcrumb with the text "Settings"
		visible: !Global.portraitMode && count >= 2
		enabled: visible // don't receive focus when invisble
		focus: false // don't give status bar initial focus to the breadcrumbs

		getText: function(index) {
			return index === 0
					? Global.mainView.navBar.activeButtonText // eg: "Settings"
					: pageStack.get(index - 1).title // eg: "Device list"
		}

		onClicked: function(index) {
			const isTopBreadcrumb = index === breadcrumbs.count - 1
			const isBottomBreadcrumb = index === 0

			if (isBottomBreadcrumb) { // the bottom breadcrumb is a special case, we inserted a dummy breadcrumb with the text "Settings" which doesn't relate to anything in the pageStack
				Global.pageManager.popAllPages()
				return
			}

			if (isTopBreadcrumb) { // ignore clicks on the top of the breadcrumb trail. We don't need to navigate there, we are already there...
				return
			}

			root.popToPage(pageStack.get(index - 1)) // subtract 1, because we inserted a dummy "Settings" breadcrumb at the beginning
		}

		onActiveFocusChanged: {
			if (activeFocus && focusEdgeHint >= 0) {
				// Focus the first (left-most) or last (right-most) breadcrumb, depending the side
				// that the key navigation is arriving from.
				currentIndex = focusEdgeHint === Qt.LeftEdge ? 0 : count - 1
				focusEdgeHint = -1
			}
		}

		KeyNavigation.right: notificationButton

		Connections {
			target: root.pageStack
			enabled: root.pageStack.opened && Global.keyNavigationEnabled
			function onDepthChanged() {
				// When pages are pushed/popped, reset the focus to be on the last breadcrumb.
				breadcrumbs.currentIndex = breadcrumbs.count - 1
			}
		}
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
		visible: !Global.portraitMode && !breadcrumbs.visible
		text: ClockTime.currentTime
	}

	Row {
		id: connectivityRow

		anchors {
			left: clockLabel.right
			leftMargin: Theme.geometry_statusBar_spacing
			verticalCenter: parent.verticalCenter
		}
		visible: !Global.portraitMode && !breadcrumbs.visible
		spacing: Theme.geometry_statusBar_spacing

		CP.IconImage {
			anchors.verticalCenter: parent.verticalCenter
			color: Theme.color_font_primary
			source: {
				if (!signalStrength.valid) {
					return ""
				} else if (signalStrength.value > 75) {
					return "qrc:/images/icon_WiFi_4_32.svg"
				} else if (signalStrength.value > 50) {
					return "qrc:/images/icon_WiFi_3_32.svg"
				} else if (signalStrength.value > 25) {
					return "qrc:/images/icon_WiFi_2_32.svg"
				} else if (signalStrength.value > 0) {
					return "qrc:/images/icon_WiFi_1_32.svg"
				} else {
					return "qrc:/images/icon_WiFi_noconnection_32.svg"
				}
			}

			VeQuickItem {
				id: signalStrength

				uid: Global.venusPlatform.serviceUid +  "/Network/Wifi/SignalStrength"
			}
		}

		GsmStatusIcon {
			height: Theme.geometry_status_bar_gsmModem_icon_height
			anchors.verticalCenter: parent.verticalCenter
		}
	}

	StatusBarButton {
		id: notificationButton

		anchors {
			left: connectivityRow.right
			leftMargin: Theme.geometry_statusBar_spacing
		}
		// Expand clickable area on right and bottom edges.
		rightInset: Theme.geometry_statusBar_spacing / 2
		bottomInset: Theme.geometry_statusBar_spacing

		// The notificationButton should always be shown, even when the page is not interactive
		opacity: 1
		visible: !Global.portraitMode && !breadcrumbs.visible && (Global.notifications?.statusBarNotificationIconVisible ?? false)

		color: Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Alarm
			   ? Theme.color_critical
			   : Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Warning
				 ? Theme.color_warning :
				   Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Info ? Theme.color_ok : "transparent"
		icon.source: Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Info ?
						 "qrc:/images/icon_info_32.svg" : "qrc:/images/icon_warning_32.svg"
		onClicked: Global.mainView.goToNotificationsPage()
		KeyNavigation.right: alarmButton
	}

	NotificationButton {
		id: alarmButton

		anchors {
			left: notificationButton.right
			verticalCenter: parent.verticalCenter
		}
		// Expand clickable area on horizontal and bottom edges.
		leftInset: Theme.geometry_statusBar_spacing / 2
		leftPadding: leftInset + Theme.geometry_silenceAlarmButton_horizontalPadding
		rightInset: Theme.geometry_statusBar_spacing / 2
		rightPadding: rightInset + Theme.geometry_silenceAlarmButton_horizontalPadding
		topInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		visible: !Global.portraitMode
		enabled: visible && notificationButtonsEnabled && (Global.notifications?.silenceAlarmVisible ?? false)
		flat: false
		backgroundColor: down ? Theme.color_critical : Theme.color_critical_background
		borderWidth: 0
		// ensure highlight border can be seen against critical backgroundColor
		KeyNavigationHighlight.margins: -(4 * Theme.geometry_button_border_width)
		icon.source: "qrc:/images/icon_alarm_snooze_24.svg"
		text: CommonWords.silence_alarm

		onClicked: NotificationModel.acknowledgeAll()
	}

	Row {
		id: rightButtonRow

		height: parent.height
		anchors.right: parent.right

		StatusBarButton {
			id: rightButton

			// Expand clickable area on left and bottom edges.
			leftInset: Theme.geometry_statusBar_spacing
			bottomInset: Theme.geometry_statusBar_spacing

			enabled: root.rightButton != VenusOS.StatusBar_RightButton_None
			visible: enabled
			icon.source: root.rightButton === VenusOS.StatusBar_RightButton_SidePanelActive
						 ? "qrc:/images/icon_sidepanel_on_32.svg"
						 : root.rightButton === VenusOS.StatusBar_RightButton_SidePanelInactive
						   ? "qrc:/images/icon_sidepanel_off_32.svg"
						   : root.rightButton === VenusOS.StatusBar_RightButton_Add
							 ? "qrc:/images/icon_plus.svg"
							 : root.rightButton === VenusOS.StatusBar_RightButton_Refresh
							   ? "qrc:/images/icon_refresh_32.svg"
							   : ""
			KeyNavigation.left: alarmButton
			KeyNavigation.right: sleepButton

			onClicked: root.rightButtonClicked()
		}

		StatusBarButton {
			id: sleepButton

			// Expand clickable area on right and bottom edges, and on left edge if right button is
			// hidden. This is the right-most button in the row, so on the right edge, use
			// Theme.geometry_statusBar_horizontalMargin instead of Theme.geometry_statusBar_spacing.
			leftInset: rightButton.visible ? 0 : Theme.geometry_statusBar_spacing
			rightInset: Theme.geometry_statusBar_horizontalMargin
			bottomInset: Theme.geometry_statusBar_spacing

			icon.source: "qrc:/images/icon_screen_sleep_32.svg"
			visible: enabled
			enabled: ScreenBlanker.supported
					&& ScreenBlanker.enabled
					&& Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
					&& !Global.portraitMode
			onClicked: ScreenBlanker.setDisplayOff()
		}
	}

	// The status bar should never become the focused item; if it does, it means there was no
	// previously focused button in the status bar, or the last focused button is now disabled and
	// not focusable. So, find the first available button and focus that instead.
	Connections {
		target: Global.main
		enabled: Global.keyNavigationEnabled
		function onActiveFocusItemChanged() {
			if (Global.main.activeFocusItem === root) {
				for (const button of [leftButton, auxButton, breadcrumbs, notificationButton, alarmButton, rightButton, sleepButton]) {
					if (button.enabled) {
						button.focus = true
						break
					}
				}
			}
		}
	}
}
