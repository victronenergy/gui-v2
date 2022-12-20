/*
** Copyright (C) 2023 Victron Energy B.V.
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

	SettingsListView {
		model: VeQItemTableModel {
			id: uidModel
			uids: [bindPrefix]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: SettingsListNavigationItem {
			text: model.id
			secondaryText: enabled ? "" : (model.value || "--")
			enabled: subModel.rowCount > 0

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml",
						{ title: text, bindPrefix: model.uid })
			}

			VeQItemTableModel {
				id: subModel
				uids: [model.uid]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}
	}
}
