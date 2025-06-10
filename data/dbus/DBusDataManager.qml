/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Dbus

QtObject {
	id: root

	property var notifications: NotificationsImpl {}

	property VeQItemTableModel servicesTableModel: VeQItemTableModel {
		uids: ["dbus"]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem

		Component.onCompleted: Global.dataServiceModel = servicesTableModel
	}
}
