/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import "pages"

Window {
	id: root

	width: 800
	height: 480
	color: Theme.backgroundColor

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")

	ListView {
		id: pageStack

		width: root.width
		height: root.height - navBar.height

		interactive: false
		orientation: Qt.Horizontal
		highlightMoveDuration: 500  // TODO move into Theme if this is final

		model: ListModel {
			ListElement {
				//% "Brief"
				text: qsTrId("nav_brief")
				icon: "qrc:/images/brief.svg"
				url: "qrc:/pages/BriefPage.qml"
			}

			ListElement {
				//% "Overview"
				text: qsTrId("nav_overview")
				icon: "qrc:/images/overview.svg"
				url: "qrc:/pages/OverviewPage.qml"
			}

			ListElement {
				//% "Levels"
				text: qsTrId("nav_levels")
				icon: "qrc:/images/levels.svg"
				url: "qrc:/pages/LevelsPage.qml"
			}

			ListElement {
				//% "Notifications"
				text: qsTrId("nav_notifications")
				icon: "qrc:/images/notifications.svg"
				url: "qrc:/pages/NotificationsPage.qml"
			}

			ListElement {
				//% "Settings"
				text: qsTrId("nav_settings")
				icon: "qrc:/images/settings.png"
				url: "qrc:/pages/SettingsPage.qml"
			}
		}

		delegate: Loader {
			id: pageDelegate

			width: root.width
			height: pageStack.height
			source: model.url

			Binding {
				target: pageDelegate.item
				property: 'isTopPage'
				value: model.index === pageStack.currentIndex
			}
		}
	}

	NavBar {
		id: navBar

		anchors.bottom: parent.bottom
		anchors.bottomMargin: 3
		model: pageStack.model

		onButtonClicked: function (buttonIndex) {
			pageStack.currentIndex = buttonIndex
		}
	}
}
