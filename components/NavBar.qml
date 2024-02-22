/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {  // Use an opaque background so that page disappears behind nav bar when scrolled
	id: root

	property alias model: buttonRepeater.model
	readonly property int currentIndex: _currentIndex

	// External components should not write to these properties.
	property int _currentIndex

	function setCurrentPage(pageName) {
		for (let i = 0; i < navBarModel.count; ++i) {
			const url = navBarModel.get(i).url
			if (url.endsWith("/" + pageName)) {
				_currentIndex = i
				return
			}
		}
		console.warn("setCurrentPage(): cannot find page", pageName)
	}

	function setCurrentIndex(index) {
		if (index === _currentIndex) {
			return
		}
		if (index < 0 || index >= navBarModel.count) {
			console.log("setCurrentIndex(): invalid index", index, "nav bar count is:", navBarModel.count)
			return
		}
		_currentIndex = index
	}

	width: parent.width
	height: Theme.geometry_navigationBar_height

	Row {
		x: Theme.geometry_page_content_horizontalMargin
		width: parent.width - 2*Theme.geometry_page_content_horizontalMargin
		height: parent.height
		spacing: Theme.geometry_navigationBar_spacing

		Repeater {
			id: buttonRepeater

			model: ListModel {
				id: navBarModel

				ListElement {
					//% "Brief"
					text: qsTrId("nav_brief")
					icon: "qrc:/images/brief.svg"
					url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml"
				}
				ListElement {
					//% "Overview"
					text: qsTrId("nav_overview")
					icon: "qrc:/images/overview.svg"
					url: "qrc:/qt/qml/Victron/VenusOS/pages/OverviewPage.qml"
				}
				ListElement {
					//% "Levels"
					text: qsTrId("nav_levels")
					icon: "qrc:/images/levels.svg"
					url: "qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml"
				}
				ListElement {
					//% "Notifications"
					text: qsTrId("nav_notifications")
					icon: "qrc:/images/notifications.svg"
					url: "qrc:/qt/qml/Victron/VenusOS/pages/NotificationsPage.qml"
				}
				ListElement {
					//% "Settings"
					text: qsTrId("nav_settings")
					icon: "qrc:/images/settings.svg"
					url: "qrc:/qt/qml/Victron/VenusOS/pages/SettingsPage.qml"
				}
			}

			delegate: NavButton {
				height: root.height
				width: Theme.geometry_navigationBar_button_width
				text: model.text
				icon.source: model.icon
				checked: root.currentIndex === model.index
				enabled: root.currentIndex !== model.index
				backgroundColor: "transparent"

				onClicked: {
					root._currentIndex = model.index
				}

				Rectangle {
					anchors {
						top: parent.top
						topMargin: Theme.geometry_navigationBar_notifications_redDot_topMargin
						horizontalCenter: parent.horizontalCenter
						horizontalCenterOffset: Theme.geometry_navigationBar_notifications_redDot_horizontalCenterOffset
					}
					width: Theme.geometry_notificationsPage_delegate_marker_width
					height: width
					radius: Theme.geometry_notificationsPage_delegate_marker_radius
					color: Theme.color_critical
					visible: model.url === Global.appUrl("/pages/NotificationsPage.qml")
							 && !!Global.notifications
							 && Global.notifications.alert
				}
			}
		}
	}
}
