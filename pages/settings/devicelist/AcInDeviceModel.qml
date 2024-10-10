/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseDeviceModel {
	id: root

	property string serviceType

	property Instantiator gridObjects: Instantiator {
		model: modelLoader.item

		delegate: Device {
			id: device

			readonly property int gensetStatusCode: _gensetStatusCode.isValid ? _gensetStatusCode.value : -1

			readonly property real power: {
				if (_power.isValid)
					return _power.value

				var power = 0
				var nrOfPhases = _nrOfPhases.isValid ? _nrOfPhases.value : 3
				if (_powerL1.isValid && nrOfPhases > 0)
					power += _powerL1.value
				if (_powerL2.isValid && nrOfPhases > 1)
					power += _powerL2.value
				if (_powerL3.isValid && nrOfPhases > 2)
					power += _powerL3.value
				return (_powerL1.isValid || _powerL2.isValid || _powerL3.isValid) ? power : NaN
			}

			readonly property VeQuickItem _power: VeQuickItem {
				uid: device.serviceUid + "/Ac/Power"
			}

			readonly property VeQuickItem _powerL1: VeQuickItem {
				uid: device.serviceUid + "/Ac/L1/Power"
			}

			readonly property VeQuickItem _powerL2: VeQuickItem {
				uid: device.serviceUid + "/Ac/L2/Power"
			}

			readonly property VeQuickItem _powerL3: VeQuickItem {
				uid: device.serviceUid + "/Ac/L3/Power"
			}

			readonly property VeQuickItem _nrOfPhases: VeQuickItem {
				uid: device.serviceUid + "/NrOfPhases"
			}

			readonly property VeQuickItem _gensetStatusCode: VeQuickItem {
				uid: device.serviceUid + "/StatusCode"
			}

			serviceUid: model.uid
			onValidChanged: {
				if (valid) {
					root.addDevice(device)
				} else {
					root.removeDevice(device.serviceUid)
				}
			}
		}
	}

	property var modelLoader: Loader {
		sourceComponent: BackendConnection.type === BackendConnection.DBusSource ? dbusModelComponent
			 : BackendConnection.type === BackendConnection.MqttSource ? mqttModelComponent
			 : null
	}

	property var dbusModelComponent: Component {
		VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\." + root.serviceType + "\."
			model: BackendConnection.type === BackendConnection.DBusSource ? Global.dataServiceModel : null
		}
	}

	property var mqttModelComponent: Component {
		VeQItemTableModel {
			uids: BackendConnection.type === BackendConnection.MqttSource ? ["mqtt/" + root.serviceType ] : []
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}

	modelId: serviceType
}
