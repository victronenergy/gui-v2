/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix: BackendConnection.type === BackendConnection.DBusSource
		? "dbus"
		: BackendConnection.type === BackendConnection.MqttSource
		  ? "mqtt"
		  : "mock"

	GradientListView {
		model: VeQItemTableModel {
			id: uidModel
			uids: [bindPrefix]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
		}

		delegate: ListNavigation {
			text: model.id
			secondaryText: interactive ? "" : (model.value ?? "--")
			interactive: subModel.rowCount > 0

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
