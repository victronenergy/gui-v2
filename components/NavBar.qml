/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property alias model: buttonRepeater.model
	property int currentIndex
	property url currentUrl

	anchors.horizontalCenter: parent.horizontalCenter
	height: Theme.geometry.navigationBar.height
	spacing: Theme.geometry.navigationBar.spacing

	Repeater {
		id: buttonRepeater

		delegate: NavButton {
			height: root.height
			width: Theme.geometry.navigationBar.button.width
			text: qsTrId(model.text)
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
				visible: model.url === "qrc:/pages/NotificationsPage.qml" && Global.notifications.activeModel.hasNewNotifications
			}
		}
	}
}
