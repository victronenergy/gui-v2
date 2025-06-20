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
			id: rowDelegate

			required property string uid
			required property string id
			required property var value

			text: id
			secondaryText: interactive ? "" : (JSON.stringify(value) ?? "--")
			caption: interactive || value === undefined ? "" : typeof(value)
			interactive: subModel.rowCount > 0

			Keys.onPressed: (event) => {
				if (event.key !== Qt.Key_P) {
					event.accepted = false
					return
				}

				// Print the object tree from this point, or print the value if it is a leaf node.
				if (interactive) {
					allChildrenLoader.active = true
					const childrenModel = allChildrenLoader.item
					let uidPrefix = uid.substring(0, uid.length - id.length - 1)

					let json = {}
					for (let i = 0; i < childrenModel.rowCount; ++i) {
						const childValue = childrenModel.getValue(i, VeQItemTableModel.ValueColumn)
						const childUid = childrenModel.data(childrenModel.index(i, 0), VeQItemTableModel.UniqueIdRole)
						const childPath = childUid.substring(uidPrefix.length)
						json[childPath] = childValue
					}
					// Note: "undefined" values are not printed, as they are discarded by JSON.stringify().
					if (event.modifiers & Qt.ControlModifier) {
						console.info(JSON.stringify(json, null, 2)) // pretty print
					} else {
						console.info(JSON.stringify(json))
					}
				} else {
					console.info(JSON.stringify(value))
				}
			}

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml",
						{ title: text, bindPrefix: rowDelegate.uid })
			}

			VeQItemTableModel {
				id: subModel
				uids: [rowDelegate.uid]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
			}

			Loader {
				id: allChildrenLoader

				sourceComponent: VeQItemTableModel {
					uids: [rowDelegate.uid]
					flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
				}
			}
		}
	}
}
