import QtQuick
import Victron.VenusOS

ListView {
	spacing: Theme.geometry.notificationsPage.historyView.spacing
	height: childrenRect.height
	delegate: NotificationDelegate {}
}
