/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	readonly property Instantiator relayObjects: Instantiator {
		model: VeQItemTableModel {
			uids: BackendConnection.type === BackendConnection.MqttSource ? ["mqtt/system/0/Relay"]
				: ["%1/com.victronenergy.system/Relay".arg(BackendConnection.uidPrefix())]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: QtObject {
			readonly property int relayNumber: model.id
			readonly property int relayState: _relayState.isValid ? _relayState.value : VenusOS.Relays_State_Inactive
			readonly property int relayFunction: _relayFunction.isValid ? _relayFunction.value : -1

			readonly property VeQuickItem _relayState: VeQuickItem {
				uid: model.uid + "/State"
			}

			readonly property VeQuickItem _relayFunction: VeQuickItem {
				uid: relayNumber === 0
					 ? Global.systemSettings.serviceUid + "/Settings/Relay/Function"
					 : Global.systemSettings.serviceUid + "/Settings/Relay/%1/Function".arg(relayNumber)
			}

			readonly property string _updateToken: relayState + ":" + relayFunction
			on_UpdateTokenChanged: root.updateRelayProperties(relayNumber, relayState, relayFunction)

			function setRelayState(newRelayState) {
				_relayState.setValue(newRelayState)
			}
		}
	}

	function setRelayState(relayNumber, relayState) {
		for (let i = 0; i < relayObjects.count; ++i) {
			const relayObject = relayObjects.objectAt(i)
			if (relayObject.relayNumber === relayNumber) {
				relayObject.setRelayState(relayState)
				return
			}
		}
	}

	function updateRelayProperties(relayNumber, relayState, relayFunction) {
		for (let i = 0; i < count; ++i) {
			const data = get(i)
			if (data.relayNumber === relayNumber) {
				if (relayFunction !== VenusOS.Relay_Function_Manual) {
					// Relay no longer has 'manual' function. Remove it from the model.
					remove(i)
				} else {
					// Update the relay properties.
					set(i, { relayState: relayState, relayFunction: relayFunction })
				}
				return
			}
		}

		// Add a new relay entry to the model.
		if (relayFunction === VenusOS.Relay_Function_Manual) {
			insert(insertionIndex(relayNumber), { relayNumber: relayNumber, relayState: relayState, relayFunction: relayFunction })
		}
	}

	function insertionIndex(relayNumber) {
		for (let i = 0; i < count; ++i) {
			const data = get(i)
			if (data.relayNumber > relayNumber) {
				return i
			}
		}
		return count
	}
}
