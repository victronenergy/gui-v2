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
			filterRegExp: "\/SwitchableOutput\/(?:\\w+)$" // output id may be int or string
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

			property bool initialized
			property string currentNamedGroup
			property bool inDeviceGroup

			readonly property SwitchableOutput output: SwitchableOutput {
				uid: outputObject.uid
				onGroupChanged: outputObject.updateGroupModel()
				onFormattedNameChanged: outputObject.updateSortToken()
				onTypeChanged: outputObject.updateGroupModel()
				onShowUIControlChanged: outputObject.updateGroupModel()
			}

			function updateGroupModel() {
				if (initialized) {
					removeFromGroup()
					addToGroup()
				}
			}

			function addToGroup() {
				if (output.type !== VenusOS.SwitchableOutput_Type_Momentary
						&& output.type !== VenusOS.SwitchableOutput_Type_Latching
						&& output.type !== VenusOS.SwitchableOutput_Type_Dimmable) {
					// Only momentary/latching/dimmable outputs are controllable and should appear
					// in the aux cards, so do not add other types of outputs to the model.
					return
				}
				if (!output.showUIControl) {
					return
				}

				// If the group name is set, then add the output to that named group. Otherwise, add
				// it to the default group for its device.
				if (output.group.length > 0) {
					root.groups.addOutputToNamedGroup(output.group, output.uid, output.formattedName)
					outputObject.currentNamedGroup = output.group
				} else {
					const serviceUid = BackendConnection.serviceUidFromUid(output.uid)
					if (!root.groups.hasKnownDevice(serviceUid)) {
						// Provide the model with a Device with the correct name, instance, etc.
						// Note: the model takes ownership of the device.
						root.groups.addKnownDevice(root._deviceComponent.createObject(root.groups, { serviceUid: serviceUid }))
					}
					root.groups.addOutputToDeviceGroup(serviceUid, output.uid, output.formattedName)
					inDeviceGroup = true
				}
			}

			function removeFromGroup() {
				if (currentNamedGroup.length > 0) {
					root.groups.removeOutputFromNamedGroup(currentNamedGroup, uid)
					currentNamedGroup = ""
				}
				if (inDeviceGroup) {
					const serviceUid = BackendConnection.serviceUidFromUid(output.uid)
					root.groups.removeOutputFromDeviceGroup(serviceUid, uid)
					inDeviceGroup = false
				}
			}

			function updateSortToken() {
				if (currentNamedGroup.length > 0) {
					root.groups.updateSortTokenInGroup(root.groups.indexOfNamedGroup(currentNamedGroup), output.uid, output.formattedName)
				} else if (inDeviceGroup) {
					const serviceUid = BackendConnection.serviceUidFromUid(output.uid)
					root.groups.updateSortTokenInGroup(root.groups.indexOfDeviceGroup(serviceUid), output.uid, output.formattedName)
				}
			}
		}

		onObjectAdded: (index, outputObject) => {
			outputObject.addToGroup()
			outputObject.initialized = true
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
