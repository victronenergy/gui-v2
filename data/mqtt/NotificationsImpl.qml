/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	model: VeQItemSortTableModel {
		dynamicSortFilter: true
		filterRole: VeQItemTableModel.UniqueIdRole
		filterRegExp: "^mqtt\/platform\/0\/Notifications\/\\d+$"
		model: VeQItemTableModel {
			uids: ["mqtt/platform/0/Notifications"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}

	delegate: Notification {
		required property string id
		notificationId: id
	}
}
