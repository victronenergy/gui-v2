/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListView {
	spacing: Theme.geometry_notificationsPage_historyView_spacing
	delegate: NotificationDelegate {
		notification: model.notification
	}
}
