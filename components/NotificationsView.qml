import QtQuick
import Victron.VenusOS

ListView {
	spacing: Theme.geometry.notificationsPage.historyView.spacing
	delegate: NotificationDelegate {
		acknowledged: model.acknowledged
		active: model.active
		category: model.category
		date: model.date
		source: model.source
		description: model.description
	}
}
