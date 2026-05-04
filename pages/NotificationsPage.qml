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
	showTopGradient: Theme.screenSize === Theme.Portrait && !notificationsView.atYBeginning

	GradientListView {
		id: notificationsView

		height: parent.height - (silenceButtonLoader.active ? silenceButtonLoader.height : 0)

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

		Component {
			id: noAlertsHeader

			Row {
				width: notificationsView.width
				height: Theme.geometry_listItem_height + (2 * Theme.geometry_page_content_verticalMargin)
				leftPadding: Theme.geometry_listItem_content_horizontalMargin
				rightPadding: Theme.geometry_listItem_content_horizontalMargin

				Item {
					id: iconContainer

					anchors.verticalCenter: parent.verticalCenter
					width: Theme.geometry_icon_size_medium + (2 * Theme.geometry_listItem_content_horizontalMargin)
					height: parent.height

					Image {
						anchors.centerIn: parent
						source: "qrc:/images/icon_checkmark_48.svg"
						sourceSize: Qt.size(Theme.geometry_notificationsPage_placeholder_icon_size, Theme.geometry_notificationsPage_placeholder_icon_size)
					}
				}

				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width - iconContainer.width
					color: Theme.color_font_primary
					font.pixelSize: Theme.font_notification_placeholder_size
					wrapMode: Text.Wrap

					//% "No active notifications"
					text: qsTrId("notifications_no_active_notifications")
				}
			}
		}
	}

	// In portrait, show the "Silence alarm" button at the bottom of this page, instead of in the
	// status bar.
	Loader {
		id: silenceButtonLoader

		anchors.bottom: root.bottom
		active: Theme.screenSize === Theme.Portrait && Global.mainView?.notificationButtonsEnabled
		sourceComponent: SilenceAlarmButton {
			width: notificationsView.width
			leftInset: Theme.geometry_listItem_content_horizontalMargin
			rightInset: Theme.geometry_listItem_content_horizontalMargin
			topInset: Theme.geometry_listItem_content_verticalMargin
			bottomInset: Theme.geometry_listItem_content_verticalMargin

			onClicked: NotificationModel.acknowledgeAll()
		}
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
