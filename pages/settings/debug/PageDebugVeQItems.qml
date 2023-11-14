/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix: BackendConnection.type === BackendConnection.DBusSource
		? "dbus"
		: BackendConnection.type === BackendConnection.MqttSource
		  ? "mqtt"
		  : ""

	GradientListView {
		model: VeQItemTableModel {
			id: uidModel
			uids: [bindPrefix]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
		}

		delegate: ListNavigationItem {
			text: model.id
			secondaryText: {
				if (enabled) {
					return ""
				}
				return model.value !== undefined ? model.value : "--"
			}

			enabled: subModel.rowCount > 0

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml",
						{ title: text, bindPrefix: model.uid })
			}

			VeQItemTableModel {
				id: subModel
				uids: [model.uid]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
			}
		}
	}
}
