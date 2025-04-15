/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

SwipeViewPage {
	id: root

	//% "Notifications"
	navButtonText: qsTrId("nav_notifications")
	navButtonIcon: Global.notifications?.navBarNotificationCounterVisible ? "qrc:/images/notifications_subtract.svg" : "qrc:/images/notifications.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/NotificationsPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	GradientListView {
		id: notificationsView

		// prevent the nav bar buttons from clicking the notifications when it is shown
		// over the top of the notificationsView
		clip: true

		header: Global.notifications.activeOrUnAcknowledgedCount === 0 ? noAlertsHeader : null
		onHeaderItemChanged: {
			if (headerItem) {
				notificationsView.positionViewAtBeginning()
			}
		}

		section.property: "activeOrUnAcknowledged"
		section.delegate: SettingsListHeader {
			required property bool section

			height: section ? 0 : implicitHeight
			bottomPadding: Theme.geometry_gradientList_spacing
			text: section ? "" : CommonWords.history
		}

		model: Global.notifications.sortedModel
		spacing: Theme.geometry_gradientList_spacing
		delegate: NotificationDelegate {
			id: notifDelegate

			// When the delegate is clicked, acknowledge it.
			PressArea {
				anchors.fill: parent
				enabled: !notifDelegate.acknowledged
				radius: notifDelegate.radius
				// we have access to the BaseNotification via the notification role
				// but it needs to be "as" Notification for us to be able to call updateAcknowledged()
				onReleased: (notifDelegate.notification as Notification)?.updateAcknowledged(true)
			}
		}

		Component {
			id: noAlertsHeader

			Row {
				width: notificationsView.width
				height: checkmarkIcon.height + (2 * Theme.geometry_listItem_content_horizontalMargin)

				Item {
					id: iconContainer

					anchors.verticalCenter: parent.verticalCenter
					width: checkmarkIcon.width + (2 * Theme.geometry_listItem_content_horizontalMargin)
					height: parent.height

					Image {
						id: checkmarkIcon
						anchors.centerIn: parent
						source: "qrc:/images/icon_checkmark_48"
					}
				}

				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width - iconContainer.width
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_body3

					//% "No current alerts"
					text: qsTrId("notifications_no_current_alerts")
				}
			}
		}
	}
}
