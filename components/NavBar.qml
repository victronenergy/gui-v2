/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {  // Use an opaque background so that page disappears behind nav bar when scrolled
	id: root

	property alias model: buttonRepeater.model
	property int currentIndex
	property url currentUrl

	width: parent.width
	height: Theme.geometry.navigationBar.height

	Row {
		x: Theme.geometry.page.content.horizontalMargin
		width: parent.width - 2*Theme.geometry.page.content.horizontalMargin
		height: parent.height
		spacing: Theme.geometry.navigationBar.spacing

		Repeater {
			id: buttonRepeater

			model: ListModel {
				ListElement {
					//% "Brief"
					text: qsTrId("nav_brief")
					icon: "qrc:/images/brief.svg"
					url: "pages/BriefPage.qml"
				}
				ListElement {
					//% "Overview"
					text: qsTrId("nav_overview")
					icon: "qrc:/images/overview.svg"
					url: "pages/OverviewPage.qml"
				}
				ListElement {
					//% "Levels"
					text: qsTrId("nav_levels")
					icon: "qrc:/images/levels.svg"
					url: "pages/LevelsPage.qml"
				}
				ListElement {
					//% "Notifications"
					text: qsTrId("nav_notifications")
					icon: "qrc:/images/notifications.svg"
					url: "pages/NotificationsPage.qml"
				}
				ListElement {
					//% "Settings"
					text: qsTrId("nav_settings")
					icon: "qrc:/images/settings.png"
					url: "pages/SettingsPage.qml"
				}
			}

			delegate: NavButton {
				height: root.height
				width: Theme.geometry.navigationBar.button.width
				text: model.text
				icon.source: model.icon
				checked: root.currentIndex === model.index
				enabled: root.currentIndex !== model.index
				backgroundColor: "transparent"

				onClicked: {
					root.currentIndex = model.index
					root.currentUrl = model.url
				}

				Component.onCompleted: {
					if (model.index === root.currentIndex) {
						root.currentUrl = model.url
					}
				}

				Rectangle {
					anchors {
						top: parent.top
						topMargin: Theme.geometry.navigationBar.notifications.redDot.topMargin
						horizontalCenter: parent.horizontalCenter
						horizontalCenterOffset: Theme.geometry.navigationBar.notifications.redDot.horizontalCenterOffset
					}
					width: Theme.geometry.notificationsPage.delegate.marker.width
					height: width
					radius: Theme.geometry.notificationsPage.delegate.marker.radius
					color: Theme.color.critical
					visible: model.url === "pages/NotificationsPage.qml" && !!Global.notifications && Global.notifications.activeModel.hasNewNotifications
				}
			}
		}
	}
}
