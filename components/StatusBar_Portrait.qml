/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Item { // Doesn't need to be a FocusScope, as we don't need key navigation in portrait layout.
	id: root

	required property PageStack pageStack

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
			KeyNavigation.right: quickAccessView.firstFocusableButton
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
			font.pixelSize: Theme.font_size_body2
			fontSizeMode: Text.HorizontalFit
			text: Global.mainView?.currentPage?.title ?? ""
			visible: !breadcrumbs.visible

			Layout.fillWidth: true
			Layout.alignment: Qt.AlignTop
			Layout.preferredHeight: Theme.geometry_statusBar_button_height
		}

		StatusBarButton {
			id: notificationButton

			enabled: Services.notifications.statusBarNotificationIconVisible
			visible: !breadcrumbs.visible && enabled
			leftInset: Theme.geometry_statusBar_spacing
			rightInset: Theme.geometry_statusBar_spacing / 2
			bottomInset: Theme.geometry_statusBar_spacing
			color: Services.notifications.statusBarNotificationIconColor
			icon.source: Services.notifications.statusBarNotificationIconSource

			Layout.alignment: Qt.AlignTop
			KeyNavigation.right: quickAccessView.firstFocusableButton

			onClicked: Global.mainView.goToNotificationsPage()
		}

		// Quick Access (control, aux and plugin buttons). Hidden on sub-pages, where backButton and the
		// breadcrumbs are shown instead.
		QuickAccessView {
			id: quickAccessView

			firstLeftInset: Theme.geometry_statusBar_spacing / 2
			lastRightInset: Theme.geometry_statusBar_horizontalMargin
			buttonInset: Theme.geometry_statusBar_spacing / 2
			bottomInset: Theme.geometry_statusBar_spacing
			collapseHiddenButtons: true
			// Show a single plugin button in the row. If there is more than one, move them all into
			// the overflow popup.
			maximumPluginButtons: 1

			model: Global.mainView?.cardsLoader.quickAccessModel ?? null
			visible: !breadcrumbs.visible

			Layout.alignment: Qt.AlignTop
		}
	}
}
