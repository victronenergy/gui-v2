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

			readonly property real power: _power.isValid ? _power.value : NaN
			readonly property int gensetStatusCode: _gensetStatusCode.isValid ? _gensetStatusCode.value : -1

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
					root.removeDevice(device.serviceUid)
				}
			}
		}
	}

	property Loader modelLoader: Loader {
		sourceComponent: BackendConnection.type === BackendConnection.MqttSource ? mqttModelComponent
			 : dbusOrMockModelComponent
	}

	property Component dbusOrMockModelComponent: Component {
		VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^%1/com\.victronenergy\.%2\.".arg(BackendConnection.uidPrefix()).arg(root.serviceType)
			model: Global.dataServiceModel
		}
	}

	property Component mqttModelComponent: Component {
		VeQItemTableModel {
			uids: ["mqtt/" + root.serviceType ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}

	modelId: serviceType
}
