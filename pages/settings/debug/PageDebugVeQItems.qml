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

	GradientListView {
		model: VeQItemTableModel {
			id: uidModel
			uids: [bindPrefix]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
		}

		delegate: ListNavigationItem {
/* TODO: PageDebugVeQItems is instantiated recursively
			Component {
				id: pageDebugVeQItems

				PageDebugVeQItems { }
			}
			text: model.id
			secondaryText: {
				if (enabled) {
					return ""
				}
				return model.value !== undefined ? model.value : "--"
			}

			enabled: subModel.rowCount > 0

			onClicked: {
				Global.pageManager.pushPage(pageDebugVeQItems,
						{ title: text, bindPrefix: model.uid })
			}

			VeQItemTableModel {
				id: subModel
				uids: [model.uid]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
			}
*/
		}
	}
}
