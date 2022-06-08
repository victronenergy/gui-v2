import QtQuick
import Victron.VenusOS

ListView {
	spacing: Theme.geometry.notificationsPage.historyView.spacing
	delegate: NotificationDelegate {
		acknowledged: model.acknowledged
		alarmActive: model.active
		description: model.description
		category: model.type
		date: model.dateTime
		source: model.service
	}
}
