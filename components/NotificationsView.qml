import QtQuick
import Victron.VenusOS

ListView {
	spacing: Theme.geometry.notificationsPage.historyView.spacing
	height: childrenRect.height
	delegate: NotificationDelegate {}
	add: Transition {
		NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 1000 }
		NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 400 }
	}
}
