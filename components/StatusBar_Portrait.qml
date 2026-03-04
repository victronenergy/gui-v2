/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	id: root

	required property PageStack pageStack

	signal controlCardsActivated()
	signal auxCardsActivated()
	signal cardsDeactivated()
	signal sidePanelToggled()

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: Theme.geometry_statusBar_height

	RowLayout {
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			bottom: parent.bottom
		}
		spacing: 0

		StatusBarButton {
			id: backButton

			leftInset: Theme.geometry_statusBar_spacing
			bottomInset: Theme.geometry_statusBar_spacing
			icon.source: "qrc:/images/icon_back_32.svg"
			enabled: breadcrumbs.enabled
			visible: breadcrumbs.visible
			opacity: breadcrumbs.opacity

			Layout.alignment: Qt.AlignTop
			KeyNavigation.right: controlCardsButton
			onClicked: Global.pageManager.popPage()
		}

		Breadcrumbs {
			id: breadcrumbs

			pageStack: root.pageStack
			Layout.fillWidth: true
			Layout.topMargin: ((backButton.height - height) / 2) - Theme.geometry_statusBar_spacing/2
			Layout.alignment: Qt.AlignTop
		}

		Label {
			leftPadding: Theme.geometry_statusBar_horizontalMargin
			rightPadding: Theme.geometry_statusBar_spacing
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.font_size_body3
			fontSizeMode: Text.HorizontalFit
			text: Global.mainView?.currentPage?.title ?? ""
			visible: !breadcrumbs.visible

			Layout.fillWidth: true
			Layout.alignment: Qt.AlignTop
			Layout.preferredHeight: Theme.geometry_statusBar_button_height
		}

		StatusBarButton {
			id: notificationButton

			enabled: Global.notifications?.statusBarNotificationIconVisible ?? false
			visible: !breadcrumbs.visible && enabled
			leftInset: Theme.geometry_statusBar_spacing
			rightInset: Theme.geometry_statusBar_spacing / 2
			bottomInset: Theme.geometry_statusBar_spacing
			color: Global.notifications?.statusBarNotificationIconColor ?? "transparent"
			icon.source: Global.notifications?.statusBarNotificationIconSource ?? ""

			Layout.alignment: Qt.AlignTop
			KeyNavigation.right: controlCardsButton

			onClicked: Global.mainView.goToNotificationsPage()
		}

		StatusBarButton {
			id: controlCardsButton

			readonly property int buttonType: Global.mainView.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None

			leftInset: Theme.geometry_statusBar_spacing / 2
			rightInset: Theme.geometry_statusBar_spacing / 2
			bottomInset: Theme.geometry_statusBar_spacing
			icon.source: buttonType === VenusOS.StatusBar_LeftButton_ControlsInactive ? "qrc:/images/icon_controls_off_32.svg"
				: buttonType === VenusOS.StatusBar_LeftButton_ControlsActive ? "qrc:/images/icon_controls_on_32.svg"
				: ""
			enabled: !breadcrumbs.enabled && buttonType !== VenusOS.StatusBar_LeftButton_None
			visible: enabled

			Layout.alignment: Qt.AlignTop
			KeyNavigation.right: auxButton

			onClicked: {
				switch (buttonType) {
				case VenusOS.StatusBar_LeftButton_ControlsInactive:
					root.controlCardsActivated()
					break
				case VenusOS.StatusBar_LeftButton_ControlsActive:
					root.cardsDeactivated()
					break;
				default:
					break
				}
			}
		}

		StatusBarButton {
			id: auxButton

			readonly property bool auxCardsOpened: Global.mainView.cardsActive
					&& controlCardsButton.buttonType !== VenusOS.StatusBar_LeftButton_ControlsActive

			// Expand clickable area on right and bottom edges, and on left if leftButton is hidden.
			leftInset: Theme.geometry_statusBar_spacing / 2
			rightInset: Theme.geometry_statusBar_horizontalMargin
			bottomInset: Theme.geometry_statusBar_spacing

			visible: ((!root.pageStack.opened && Global.switches.groups.count > 0)
					|| auxCardsOpened) // allow cards to be closed if all switches are disconnected while opened
			icon.source: controlCardsButton.buttonType === VenusOS.StatusBar_LeftButton_ControlsActive ? ""
					: auxCardsOpened ? "qrc:/images/icon_smartswitch_on_32.svg"
					: "qrc:/images/icon_smartswitch_off_32.svg"
			enabled: !breadcrumbs.enabled && controlCardsButton.buttonType !== VenusOS.StatusBar_LeftButton_ControlsActive

			Layout.alignment: Qt.AlignTop

			onClicked: {
				if (auxCardsOpened) {
					root.cardsDeactivated()
				} else {
					root.auxCardsActivated()
				}
			}
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
				for (const button of [controlCardsButton, auxButton, breadcrumbs, notificationButton]) {
					if (button.enabled) {
						button.focus = true
						break
					}
				}
			}
		}
	}
}
