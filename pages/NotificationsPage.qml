/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Victron.VenusOS

Page {
	id: root

	onHeightChanged: console.log("NotificationsPage: height:", height)

	Flickable {
		id: flickable

		width: parent.width
		height: parent.height
		contentHeight: historicalNotificationsView.y + historicalNotificationsView.height
		onContentHeightChanged: console.log("flickable: contentHeight:", contentHeight)

		boundsBehavior: Flickable.StopAtBounds

		NotificationsView {
			id: activeNotificationsView // these notifications are active and/or not acknowledged

			onCountChanged: console.log("activeNotificationsView: count:", count)
			onHeightChanged: console.log("activeNotificationsView: height:", height)
			anchors {
				top: parent.top
				topMargin: Theme.geometry.notificationsPage.active.topMargin // 83 56
				left: parent.left
				leftMargin: Theme.geometry.notificationsPage.leftMargin
			}
			model: Global.notifications.model
		}
		Row {
			id: noCurrentAlerts

			anchors {
				top: activeNotificationsView.bottom
				topMargin: Theme.geometry.notificationsPage.checkmark.topMargin
				left: parent.left
				leftMargin: Theme.geometry.notificationsPage.checkmark.leftMargin
			}
			visible: Global.notifications.model.count === 0
			spacing: Theme.geometry.notificationsPage.checkmark.spacing

			CP.ColorImage {
				anchors.verticalCenter: parent.verticalCenter
				source: "qrc:/images/icon_checkmark_48"
				fillMode: Image.PreserveAspectFit
				smooth: true
			}
			Label {
				anchors.verticalCenter: parent.verticalCenter
				color: Theme.color.notificationsPage.text.color1
				font.pixelSize: Theme.font.size.l

				//% "No current alerts"
				text: qsTrId("notifications_no_current_alerts")
			}
		}
		Label {
			id: history
			anchors {
				top: noCurrentAlerts.visible ? noCurrentAlerts.bottom : activeNotificationsView.bottom
				topMargin: noCurrentAlerts.visible ? Theme.geometry.notificationsPage.history.topMargin : Theme.geometry.notificationsPage.delegate.topMargin
				left: parent.left
				leftMargin: Theme.geometry.notificationsPage.leftMargin
			}
			visible: historicalNotificationsView.count !== 0
			color: Theme.color.notificationsPage.text.color1
			//% "History"
			text: qsTrId("notifications_history")
		}
		NotificationsView { // these notifications are inactive and have been acknowledged
			id: historicalNotificationsView
			anchors {
				top: history.bottom
				topMargin: Theme.geometry.notificationsPage.history.spacing
				left: history.left
			}
			model: Global.notifications.historyModel
			onCountChanged: console.log("historyNotificationsView: count:", count)
		}
	}
	/*
	LinearGradient {
		id: mask
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		height: Theme.geometry.notificationsPage.gradient.height
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0; color: Theme.color.notificationsPage.gradient.topColor }
			GradientStop { position: 1; color: Theme.color.notificationsPage.gradient.bottomColor }
		}
		visible: false
	}

	OpacityMask {
		anchors.fill: mask
		source: root
		maskSource: mask
	}
	*/
	Rectangle {
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		height: Theme.geometry.notificationsPage.gradient.height
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0; color: Theme.color.notificationsPage.gradient.topColor }
			GradientStop { position: 1; color: Theme.color.notificationsPage.gradient.bottomColor }
		}
	}

}
