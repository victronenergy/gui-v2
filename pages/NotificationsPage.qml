/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	NotificationsView {
		id: historicalNotificationsView
		anchors {
			top: parent.top
			topMargin: Theme.geometry_notificationsPage_topMargin - Theme.geometry_statusBar_height
			bottom: parent.bottom
			left: parent.left
			leftMargin: Theme.geometry_notificationsPage_horizontalMargin
			right: parent.right
		}
		header: Item {
			id: headerItem
			width: parent.width
			height: history.y + history.height

			NotificationsView {
				id: activeNotificationsView // these notifications are active and/or not acknowledged
				width: parent.width
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
					topMargin: Theme.geometry_notificationsPage_checkmark_topMargin - Theme.geometry_statusBar_height
					left: parent.left
					leftMargin: Theme.geometry_notificationsPage_checkmark_leftMargin - Theme.geometry_notificationsPage_horizontalMargin
				}
				visible: Global.notifications.activeModel.count === 0
				spacing: Theme.geometry_notificationsPage_checkmark_spacing

				CP.ColorImage {
					anchors.top: parent.top
					source: "qrc:/images/icon_checkmark_48"
				}
				Label {
					anchors.verticalCenter: parent.verticalCenter
					color: Theme.color_notificationsPage_text_color
					font.pixelSize: Theme.font_size_body3

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
						? Theme.geometry_notificationsPage_history_topMargin : Theme.geometry_notificationsPage_delegate_topMargin
					left: parent.left
				}
				bottomPadding: Theme.geometry_notificationsPage_history_bottomPadding

				visible: historicalNotificationsView.count !== 0
				color: Theme.color_notificationsPage_text_color
				text: CommonWords.history
			}
		}
		model: Global.notifications.historicalModel
		add: Transition {
			SequentialAnimation {
				PropertyAction { property: "opacity"; value: 0}
				PauseAnimation { duration: Theme.animation_notificationsPage_delegate_displaced_duration }
				OpacityAnimator { from: 0; to: 1.0; duration: Theme.animation_notificationsPage_delegate_opacity_duration }
			}
		}
		displaced: Transition {
			ParallelAnimation {
				XAnimator { duration: Theme.animation_notificationsPage_delegate_displaced_duration }
				YAnimator { duration: Theme.animation_notificationsPage_delegate_displaced_duration }
			}
		}
		ScrollBar.vertical: ScrollBar {
			anchors.right: parent.right
		}
	}

	ViewGradient{
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			rightMargin: Theme.geometry_notificationsPage_delegate_rightMargin
		}
	}
}
