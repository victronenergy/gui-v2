/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls as C
import Victron.Velib
import Victron.VenusOS

Page {
	id: root

	controlsButton.visible: false

	C.StackView {
		id: navStack
		clip: true

		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			bottom: navBar.top
		}

		initialItem: navBar.currentUrl

		// Fade new navigation pages in
		replaceEnter: Transition {
			PropertyAnimation {
				property: "opacity"
				from: 0.0
				to: 1.0
				duration: 250
			}
		}
		replaceExit: Transition {
			PropertyAnimation {
				property: "opacity"
				from: 1.0
				to: 0.0
				duration: 250
			}
		}
	}

	NavBar {
		id: navBar

		anchors.bottom: parent.bottom
		model: ListModel {
			ListElement {
				//% "Brief"
				text: qsTrId("nav_brief")
				icon: "qrc:/images/brief.svg"
				iconWidth: 28
				iconHeight: 28
				url: "qrc:/pages/BriefPage.qml"
			}

			ListElement {
				//% "Overview"
				text: qsTrId("nav_overview")
				icon: "qrc:/images/overview.svg"
				iconWidth: 28
				iconHeight: 22
				url: "qrc:/pages/OverviewPage.qml"
			}

			ListElement {
				//% "Levels"
				text: qsTrId("nav_levels")
				icon: "qrc:/images/levels.svg"
				iconWidth: 28
				iconHeight: 20
				url: "qrc:/pages/LevelsPage.qml"
			}

			ListElement {
				//% "Notifications"
				text: qsTrId("nav_notifications")
				icon: "qrc:/images/notifications.svg"
				iconWidth: 28
				iconHeight: 26
				url: "qrc:/pages/NotificationsPage.qml"
			}

			ListElement {
				//% "Settings"
				text: qsTrId("nav_settings")
				icon: "qrc:/images/settings.png"
				iconWidth: 24
				iconHeight: 24
				url: "qrc:/pages/SettingsPage.qml"
			}
		}

		property var currentUrl: navBar.model.get(0).url
		onButtonClicked: function (buttonIndex) {
			var navUrl = model.get(buttonIndex).url
			if (navUrl != currentUrl) {
				currentUrl = navUrl
				navStack.replace(null, navUrl)
			}
		}
	}
}
