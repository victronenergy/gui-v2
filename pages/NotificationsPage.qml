/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SwipeViewPage {
	id: root

	title: CommonWords.notifications
	iconSource: Global.notifications?.navBarNotificationCounterVisible ? "qrc:/images/notifications_subtract.svg" : "qrc:/images/notifications.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/NotificationsPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	focusPolicy: notificationsView.count > 0 ? Qt.TabFocus : Qt.NoFocus

	GradientListView {
		id: notificationsView

		height: parent.height - (portraitSilenceButton.visible ? portraitSilenceButton.height : 0)

		// prevent the nav bar buttons from clicking the notifications when it is shown
		// over the top of the notificationsView
		clip: true

		readonly property int activeNotifications: NotificationModel.activeAlarms + NotificationModel.activeWarnings + NotificationModel.activeInfos
		readonly property int unacknowledgedNotifications: NotificationModel.unacknowledgedAlarms + NotificationModel.unacknowledgedWarnings + NotificationModel.unacknowledgedInfos
		header: (activeNotifications > 0 || unacknowledgedNotifications > 0) ? null : noAlertsHeader
		onHeaderItemChanged: {
			if (headerItem) {
				notificationsView.positionViewAtBeginning()
			}
		}

		section.property: "section"
		section.delegate: SettingsListHeader {
			id: sectionDelegate
			required property int section
			bottomPadding: Theme.geometry_gradientList_spacing
			text: sectionDelegate.section === 0 ?
					//: List section header, for the section which contains current/active notifications
					//% "Active Notifications"
					qsTrId("notifications_page_active_notifications")
				: sectionDelegate.section === 1 ?
					//: List section header, for the section which contains inactive (but unseen) notifications
					//% "Inactive Notifications"
					qsTrId("notifications_page_inactive_notifications")
				: CommonWords.history
		}

		model: NotificationSortFilterProxyModel {
			sourceModel: NotificationModel
		}

		delegate: NotificationDelegate {
			id: del

			Keys.onSpacePressed: {
				if (!del.acknowledged) {
					NotificationModel.acknowledge(modelId)
				}
			}
			Keys.enabled: Global.keyNavigationEnabled

			// When the delegate is clicked, acknowledge it.
			PressArea {
				anchors.fill: parent
				enabled: !del.acknowledged
				radius: Theme.geometry_listItem_radius
				onReleased: NotificationModel.acknowledge(del.modelId)
			}
		}

		KeyNavigation.down: portraitSilenceButton.visible ? portraitSilenceButton : null

		Component {
			id: noAlertsHeader

			Row {
				width: notificationsView.width
				height: checkmarkIcon.height + (2 * Theme.geometry_listItem_content_horizontalMargin)

				Item {
					id: iconContainer

					anchors.verticalCenter: parent.verticalCenter
					width: checkmarkIcon.width + 2*checkmarkIcon.anchors.leftMargin
					height: parent.height

					Image {
						id: checkmarkIcon
						anchors {
							verticalCenter: parent.verticalCenter
							left: parent.left
							leftMargin: Theme.geometry_listItem_content_horizontalMargin - 8 // (48 - 32) / 2, to centre with delegate icons
						}
						source: "qrc:/images/icon_checkmark_48"
					}
				}

				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width - iconContainer.width
					color: Theme.color_font_primary
					font.pixelSize: Theme.font_size_h1

					//% "No active notifications"
					text: qsTrId("notifications_no_active_notifications")
				}
			}
		}
	}

	SilenceAlarmButton {
		id: portraitSilenceButton

		anchors.top: notificationsView.bottom
		width: notificationsView.width
		leftInset: Theme.geometry_listItem_content_horizontalMargin
		rightInset: Theme.geometry_listItem_content_horizontalMargin
		topInset: Theme.geometry_listItem_content_verticalMargin
		bottomInset: Theme.geometry_listItem_content_verticalMargin
		enabled: Theme.screenSize === Theme.Portrait && Global.mainView?.notificationButtonsEnabled
		visible: enabled

		KeyNavigationHighlight.leftMargin: Theme.geometry_button_border_width
		KeyNavigationHighlight.rightMargin: Theme.geometry_button_border_width
		KeyNavigationHighlight.topMargin: Theme.geometry_button_border_width
		KeyNavigationHighlight.bottomMargin: Theme.geometry_button_border_width

		onClicked: NotificationModel.acknowledgeAll()
	}

	// automatically acknowledge all Info notifications,
	// and also all non-active Warning+Alarm notifications,
	// upon navigating away from this page.
	onIsCurrentPageChanged: {
		if (!isCurrentPage) {
			NotificationModel.acknowledgeType(VenusOS.Notification_Info)
			NotificationModel.acknowledgeAllInactive()
		}
	}
}
