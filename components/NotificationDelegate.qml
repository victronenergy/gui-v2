import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	property bool acknowledged
	property bool alarmActive
	property int category
	property date date
	property string source
	property string description

	function _formatTimestamp(date) {
		let ms = Math.floor(ClockTime.currentDateTime - date)
		let minutes = Math.floor(ms / 60000)
		if (minutes < 1) {
			//% "now"
			return qsTrId("notifications_page_now")
		}
		if (minutes < 60) {
			//% "%1m ago"
			return qsTrId("%1m ago").arg(minutes) // eg. "26m ago"
		}
		let hours = Math.floor(minutes / 60)
		let days = Math.floor(hours / 24)
		if (days < 1) {
			//% "%1h %2m ago"
			return qsTrId("%1h %2m ago").arg(hours).arg(minutes % 60) // eg. "2h 10m ago"
		}
		if (days < 7) {
			return date.toLocaleString(Qt.locale(), "ddd hh:mm") // eg. "Mon 09:06"
		}
		return date.toLocaleString(Qt.locale(), "MMM dd hh:mm") // eg. "Mar 27 10:20"
	}

	width: Theme.geometry.notificationsPage.delegate.width
	height: Theme.geometry.notificationsPage.delegate.height
	radius: Theme.geometry.toastNotification.radius
	color: mouseArea.containsPress ? Theme.color.listItem.down.background : Theme.color.background.secondary

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
			color: root.acknowledged ? "transparent" : Theme.color.critical
		}
		Item {
			height: 1
			width: Theme.geometry.notificationsPage.delegate.icon.spacing
		}
		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			fillMode: Image.PreserveAspectFit
			color: root.category === VenusOS.Notification_Info
				   ? (root.alarmActive ? Theme.color.ok : Theme.color.darkOk)
				   : root.category === VenusOS.Notification_Warning
					 ? (root.alarmActive ? Theme.color.warning : Theme.color.darkWarning)
					 : (root.alarmActive ? Theme.color.critical : Theme.color.darkCritical)
			source: root.category === VenusOS.Notification_Info
					? "qrc:/images/toast_icon_info.svg" : "qrc:/images/toast_icon_alarm.svg"
		}
		Item {
			height: 1
			width: Theme.geometry.notificationsPage.delegate.description.spacing.horizontal
		}
		Column {
			anchors.verticalCenter: parent.verticalCenter
			spacing: Theme.geometry.notificationsPage.delegate.description.spacing.vertical

			Label {
				color: Theme.color.listItem.secondaryText
				text: root.source
			}
			Label {
				color: Theme.color.font.primary
				font.pixelSize: Theme.font.size.body2
				text: qsTrId(root.description)
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
		color: Theme.color.notificationsPage.text.color
		text: _formatTimestamp(root.date)
	}
	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked: model.acknowledged = true
	}
}
