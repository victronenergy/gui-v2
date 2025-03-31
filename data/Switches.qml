/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// A list of the switchable output groups on the system. A group may be:
	// - a custom named group created by the user, containing one or more switchable outputs
	// - a group for a particular switch device, containing all the switchable outputs on that
	// device that do not belong to a custom named group.
	readonly property SwitchableOutputGroupModel groups: SwitchableOutputGroupModel {}

	readonly property Instantiator _modelBuilder: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterFlags: VeQItemSortTableModel.FilterOffline
			filterRegExp: "\.SwitchableOutput\.[0-9]$"
			model: VeQItemTableModel {
				uids: BackendConnection.uidPrefix()

				// TODO only add children to depth=1, instead of adding all children. That would
				// reduce the number of items to be filtered by the VeQItemSortTableModel.
				flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		delegate: QtObject {
			id: outputObject

			required property string uid
			required property string id
			property string currentNamedGroup
			property bool inDeviceGroup

			function addToGroup(newGroup) {
				// If the group name is set, then add the output to that named group. Otherwise, add
				// it to the default group for its device.
				if (newGroup.length > 0) {
					root.groups.addOutputToNamedGroup(newGroup, outputObject.uid)
					outputObject.currentNamedGroup = newGroup
				} else {
					const serviceUid = BackendConnection.serviceUidFromUid(outputObject.uid)
					if (!root.groups.hasKnownDevice(serviceUid)) {
						// Provide the model with a Device with the correct name, instance, etc.
						// Note: the model takes ownership of the device.
						root.groups.addKnownDevice(root._deviceComponent.createObject(root.groups, { serviceUid: serviceUid }))
					}
					root.groups.addOutputToDeviceGroup(serviceUid, outputObject.uid)
					inDeviceGroup = true
				}
			}

			function removeFromGroup() {
				if (currentNamedGroup.length > 0) {
					root.groups.removeOutputFromNamedGroup(currentNamedGroup, uid)
					currentNamedGroup = ""
				}
				if (inDeviceGroup) {
					const serviceUid = BackendConnection.serviceUidFromUid(outputObject.uid)
					root.groups.removeOutputFromDeviceGroup(serviceUid, uid)
					inDeviceGroup = false
				}
			}

			//--- implementation details below

			readonly property VeQuickItem _group: VeQuickItem {
				uid: `${outputObject.uid}/Settings/Group`
				onValueChanged: {
					outputObject.removeFromGroup()
					outputObject.addToGroup(value)
				}
			}
		}

		onObjectRemoved: (index, outputObject) => {
			outputObject.removeFromGroup()
		}
	}

	readonly property Component _deviceComponent: Component {
		Device {}
	}

	Component.onCompleted: Global.switches = root
}
