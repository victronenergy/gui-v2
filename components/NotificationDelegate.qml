import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
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
			color: category === VenusOS.ToastNotification_Category_Informative ? Theme.color.ok :
																				 category === VenusOS.ToastNotification_Category_Warning ? Theme.color.warning : Theme.color.critical
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
	Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry.notificationsPage.delegate.topMargin
			right: parent.right
			rightMargin: Theme.geometry.notificationsPage.delegate.rightMargin
		}
		color: Theme.color.notificationsPage.text.color1

		text: date
	}
	MouseArea {
		anchors.fill: parent
		onClicked: console.log("clicked", index)
	}
}
