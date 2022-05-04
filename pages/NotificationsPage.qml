/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	Row {
		id: noCurrentAlerts

		anchors {
			top: parent.top
			topMargin: Theme.geometry.notificationsPage.checkmark.topMargin
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.checkmark.leftMargin
		}
		spacing: Theme.geometry.notificationsPage.checkmark.spacing
		height: childrenRect.height

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
		id: label
		anchors {
			top: noCurrentAlerts.bottom
			topMargin: Theme.geometry.notificationsPage.history.topMargin
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.history.leftMargin
		}
		color: Theme.color.notificationsPage.text.color1

		//% "History"
		text: qsTrId("notifications_history")
	}
	ListView {
		anchors {
			top: label.bottom
			topMargin: Theme.geometry.notificationsPage.history.spacing
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.history.leftMargin
		}
		spacing: Theme.geometry.notificationsPage.historyView.spacing
		height: childrenRect.height
		model: ListModel {
			ListElement {
				acknowledged: false
				category: VenusOS.ToastNotification_Category_Error
				source: "Fuel tank custom name"
				description: "Fuel level low 15%"
			}
			ListElement {
				acknowledged: false
				category: VenusOS.ToastNotification_Category_Warning
				source: "RS 48/6000/100 HQ2050NMMEX"
				description: "Low battery voltage 46.69V"
			}
			ListElement {
				acknowledged: true
				category: VenusOS.ToastNotification_Category_Informative
				source: "System"
				description: "Software update available"
			}
		}
		delegate: Rectangle {
			width: Theme.geometry.notificationsPage.delegate.width
			height: Theme.geometry.notificationsPage.delegate.height
			radius: Theme.geometry.toastNotification.radius
			color: Theme.color.background.secondary
			Row {
				anchors {
					top: parent.top
					bottom: parent.bottom
					left: parent.left
					leftMargin: Theme.geometry.notificationsPage.delegate.marker.leftMargin
				}
				Rectangle {
					anchors {
						top: parent.top
						topMargin: Theme.geometry.notificationsPage.delegate.marker.topMargin
					}
					width: Theme.geometry.notificationsPage.delegate.marker.width
					height: width
					radius: Theme.geometry.notificationsPage.delegate.marker.radius
					color: acknowledged ? "transparent" : Theme.color.critical
				}
				Item {
					height: 1
					width: Theme.geometry.notificationsPage.delegate.spacing1
				}
				CP.ColorImage {
					anchors.verticalCenter: parent.verticalCenter
					fillMode: Image.PreserveAspectFit
					smooth: true
					source: category === VenusOS.ToastNotification_Category_Informative ? "qrc:/images/toast_icon_info.svg" : "qrc:/images/toast_icon_alarm.svg"
				}
				Item {
					height: 1
					width: Theme.geometry.notificationsPage.delegate.spacing2
				}
				Column {
					anchors.verticalCenter: parent.verticalCenter
					spacing: Theme.geometry.notificationsPage.delegate.spacing3
					Label {
						color: Theme.color.settingsListItem.secondaryText
						text: source
					}
					Label {
						color: Theme.color.settingsListItem.secondaryText
						text: description
					}
				}
			}
		}
	}
}
