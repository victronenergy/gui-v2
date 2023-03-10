/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

ListPage {
	id: root

	property string bindPrefix: BackendConnection.type === BackendConnection.DBusSource
		? "dbus"
		: BackendConnection.type === BackendConnection.MqttSource
		  ? "mqtt"
		  : ""

	listView: GradientListView {
		model: VeQItemTableModel {
			id: uidModel
			uids: [bindPrefix]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: ListNavigationItem {
			text: model.id
			secondaryText: enabled ? "" : (model.value || "--")
			enabled: subModel.rowCount > 0

			listPage: root
			listIndex: model.index
			onClicked: {
				listPage.navigateTo("/pages/settings/debug/PageDebugVeQItems.qml",
						{ title: text, bindPrefix: model.uid }, listIndex)
			}

			VeQItemTableModel {
				id: subModel
				uids: [model.uid]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}
	}
}
