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

			// When 'P' is pressed, print the stringified object tree from this node, or if it is a
			// leaf node with no children, just print the stringified value.
			Keys.onPressed: (event) => {
				if (event.key !== Qt.Key_P) {
					event.accepted = false
					return
				}
				if (interactive) {
					allChildrenLoader.active = true
					const childrenModel = allChildrenLoader.item
					const uidPrefix = uid.substring(0, uid.length - id.length - 1)
					let json = {}
					for (let i = 0; i < childrenModel.rowCount; ++i) {
						let childValue = childrenModel.getValue(i, VeQItemTableModel.ValueColumn)
						if (childValue === undefined) {
							const childItem = childrenModel.data(childrenModel.index(i, 0), VeQItemTableModel.ItemRole)
							if (childItem.isLeaf) {
								// Replace 'undefined' with 'null', else the value is discarded by
								// JSON.stringify() as 'undefined' is not a valid JSON value.
								childValue = null
							} else {
								// This is a parent node, so do not include it in the JSON output.
								continue
							}
						}
						const childUid = childrenModel.data(childrenModel.index(i, 0), VeQItemTableModel.UniqueIdRole)
						const childPath = childUid.substring(uidPrefix.length)
						json[childPath] = childValue
					}
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
