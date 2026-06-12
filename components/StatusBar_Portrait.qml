/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item { // Doesn't need to be a FocusScope, as we don't need key navigation in portrait layout.
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

			readonly property bool controlsPaneActive: (Global.mainView?.cardsActive ?? false)
					&& Global.mainView.cardsLoader.sourceComponent === Global.mainView.controlCardsComponent

			readonly property int buttonType: {
				if (controlsPaneActive) {
					return VenusOS.StatusBar_LeftButton_ControlsActive
				}
				return Global.mainView.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None
			}

			leftInset: Theme.geometry_statusBar_spacing / 2
			rightInset: Theme.geometry_statusBar_spacing / 2
			bottomInset: Theme.geometry_statusBar_spacing
			icon.source: buttonType === VenusOS.StatusBar_LeftButton_ControlsInactive ? "qrc:/images/icon_controls_off_32.svg"
				: buttonType === VenusOS.StatusBar_LeftButton_ControlsActive ? "qrc:/images/icon_controls_on_32.svg"
				: ""
			enabled: !breadcrumbs.enabled && buttonType !== VenusOS.StatusBar_LeftButton_None
			visible: enabled && (!(Global.mainView?.cardsActive ?? false) || controlsPaneActive)

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

			readonly property bool auxCardsOpened: (Global.mainView?.cardsActive ?? false)
					&& Global.mainView.cardsLoader.sourceComponent === Global.mainView.auxCardsComponent

			leftInset: Theme.geometry_statusBar_spacing / 2
			rightInset: pluginPaneButtons.hasPluginPanes ? 0 : Theme.geometry_statusBar_horizontalMargin
			bottomInset: Theme.geometry_statusBar_spacing

			visible: (!root.pageStack.opened && Global.switches.groups.count > 0
					&& !(Global.mainView?.cardsActive ?? false))
					|| auxCardsOpened
			icon.source: auxCardsOpened ? "qrc:/images/icon_smartswitch_on_32.svg"
					: "qrc:/images/icon_smartswitch_off_32.svg"
			enabled: !breadcrumbs.enabled
			KeyNavigation.right: pluginPaneButtons.hasPluginPanes && pluginPaneButtons.count > 0
					? pluginPaneButtons.itemAt(0) : null

			Layout.alignment: Qt.AlignTop

			onClicked: {
				if (auxCardsOpened) {
					root.cardsDeactivated()
				} else {
					root.auxCardsActivated()
				}
			}
		}

		// Plugin QuickAccessPane (type 4) buttons
		GuiPluginIntegrationModel {
			id: pluginQuickAccessModelPortrait
			type: GuiPluginLoader.QuickAccessPane
		}

		Repeater {
			id: pluginPaneButtons

			readonly property bool hasPluginPanes: !root.pageStack.opened && pluginQuickAccessModelPortrait.count > 0
			model: pluginQuickAccessModelPortrait

		delegate: StatusBarButton {
				id: pluginPaneButtonPortrait

				required property int index
				required property string pluginName
				required property url url
				readonly property url pluginIcon: pluginQuickAccessModelPortrait.integrationAt(index).icon
				readonly property url pluginIconActive: pluginQuickAccessModelPortrait.integrationAt(index).iconActive

					readonly property bool paneOpened: Global.mainView.cardsActive
						&& Global.mainView.cardsLoader.sourceComponent === _portraitPaneComponent

				visible: !(Global.mainView?.cardsActive ?? false) || paneOpened
				leftInset: Theme.geometry_statusBar_spacing / 2
				rightInset: index === pluginPaneButtons.count - 1 ? Theme.geometry_statusBar_horizontalMargin : Theme.geometry_statusBar_spacing / 2
				bottomInset: Theme.geometry_statusBar_spacing
				icon.cache: false
				icon.source: (paneOpened && String(pluginIconActive).length > 0)
						? pluginPaneButtonPortrait.pluginIconActive : pluginPaneButtonPortrait.pluginIcon
				enabled: !breadcrumbs.enabled
				KeyNavigation.left: index > 0 ? pluginPaneButtons.itemAt(index - 1) : auxButton
				KeyNavigation.right: index < pluginPaneButtons.count - 1
						? pluginPaneButtons.itemAt(index + 1) : null

				Layout.alignment: Qt.AlignTop

				onClicked: {
					if (paneOpened) {
						Global.mainView.cardsLoader.hide()
					} else {
						Global.mainView.cardsLoader.show(_portraitPaneComponent)
					}
				}

				Component {
					id: _portraitPaneComponent

					Page {
						title: pluginPaneButtonPortrait.pluginName

						Loader {
							anchors.fill: parent
							source: pluginPaneButtonPortrait.url
						}
					}
				}
			}
		}
	}
}
