/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import QtCore

BaseDeviceModel {
	id: root

	property string serviceType

	property Instantiator gridObjects: Instantiator {
		model: modelLoader.item

		delegate: Device {
			id: device

			readonly property real power: _power.value === undefined ? NaN : _power.value
			readonly property int gensetStatusCode: _gensetStatusCode.value === undefined ? -1 : _gensetStatusCode.value

			readonly property VeQuickItem _power: VeQuickItem {
				uid: device.serviceUid + "/Ac/Power"
			}

			readonly property VeQuickItem _gensetStatusCode: VeQuickItem {
				uid: device.serviceUid + "/StatusCode"
			}

			serviceUid: model.uid
			onValidChanged: {
				if (valid) {
					root.addDevice(device)
				} else {
					root.removeDevice(device)
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
