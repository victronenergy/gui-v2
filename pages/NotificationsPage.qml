/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root
	NotificationsView {
		id: historicalNotificationsView
		anchors {
			top: parent.top
			topMargin: Theme.geometry.notificationsPage.topMargin - Theme.geometry.statusBar.height
			bottom: parent.bottom
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.horizontalMargin
			right: parent.right
		}
		header: Item {
			id: headerItem
			height: history.y + history.height

			NotificationsView {
				id: activeNotificationsView // these notifications are active and/or not acknowledged
				implicitHeight: childrenRect.height
				interactive: false
				model: Global.notifications.activeModel
				// When a new notification is raised, scroll to the top of the list header.
				// We can't do this via 'onCountChanged', as the count changes before headerItem.height is updated.
				onHeightChanged: historicalNotificationsView.contentY = -headerItem.height
			}
			Row {
				id: noCurrentAlerts

				anchors {
					top: activeNotificationsView.bottom
					topMargin: Theme.geometry.notificationsPage.checkmark.topMargin - Theme.geometry.statusBar.height
					left: parent.left
					leftMargin: Theme.geometry.notificationsPage.checkmark.leftMargin - Theme.geometry.notificationsPage.horizontalMargin
				}
				visible: Global.notifications.activeModel.count === 0
				spacing: Theme.geometry.notificationsPage.checkmark.spacing

				CP.ColorImage {
					anchors.top: parent.top
					source: "qrc:/images/icon_checkmark_48"
					fillMode: Image.PreserveAspectFit
					smooth: true
				}
				Label {
					anchors.verticalCenter: parent.verticalCenter
					color: Theme.color.notificationsPage.text.color
					font.pixelSize: Theme.font.size.body3

					//% "No current alerts"
					text: qsTrId("notifications_no_current_alerts")
				}
			}
			Label {
				id: history
				anchors {
					top: Global.notifications.activeModel.count === 0
						? noCurrentAlerts.bottom : activeNotificationsView.bottom
					topMargin: Global.notifications.activeModel.count === 0
						? Theme.geometry.notificationsPage.history.topMargin : Theme.geometry.notificationsPage.delegate.topMargin
					left: parent.left
				}
				bottomPadding: Theme.geometry.notificationsPage.history.bottomPadding

				visible: historicalNotificationsView.count !== 0
				color: Theme.color.notificationsPage.text.color
				//% "History"
				text: qsTrId("notifications_history")
			}
		}
		model: Global.notifications.historicalModel
		add: Transition {
			SequentialAnimation {
				PropertyAction { property: "opacity"; value: 0}
				PauseAnimation { duration: Theme.animation.notificationsPage.delegate.displaced.duration }
				NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: Theme.animation.notificationsPage.delegate.opacity.duration }
			}
		}
		displaced: Transition {
			NumberAnimation { properties: "x,y"; duration: Theme.animation.notificationsPage.delegate.displaced.duration }
		}
		ScrollBar.vertical: ScrollBar {
			anchors.right: parent.right
		}
	}
	Rectangle {
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			rightMargin: Theme.geometry.notificationsPage.delegate.rightMargin
		}
		height: Theme.geometry.notificationsPage.gradient.height
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0; color: Theme.color.notificationsPage.gradient.topColor }
			GradientStop { position: 1; color: Theme.color.notificationsPage.gradient.bottomColor }
		}
	}
}
