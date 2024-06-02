/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	Instantiator {
		model: VeQItemTableModel {
			uids: [ root.bindPrefix + "/Devices" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: Device {
			id: rsDevice

			required property string uid

			// There are two paths for determining the service uid for each
			// multi device on this AC system:
			// com.victronenergy.acsystem.xx/Devices/<index>/Service = com.victronenergy.multi.xx
			// com.victronenergy.acsystem.xx/Devices/<index>/Instance = <DeviceInstance>
			readonly property VeQuickItem _serviceName: VeQuickItem { uid: rsDevice.uid + "/Service" }
			readonly property VeQuickItem _serviceInstance: VeQuickItem { uid: rsDevice.uid + "/Instance" }

			serviceUid: BackendConnection.serviceUidFromName(_serviceName.value || "", _serviceInstance.value || 0)

			onValidChanged: {
				if (valid) {
					rsDeviceModel.addDevice(rsDevice)
				} else {
					rsDeviceModel.removeDevice(rsDevice)
				}
			}
		}
	}

	DeviceModel {
		id: rsDeviceModel
		modelId: "multirs"
	}

	GradientListView {
		// A model of all the multi RS devices for this AC system, sorted by custom/product name.
		// Instead of assigning a DeviceModel to the ListView, use AggregateDeviceModel as a
		// convenience for sorting the model by custom/product name, rather than by device instance.
		model: AggregateDeviceModel {
			sourceModels: [ rsDeviceModel ]
		}

		delegate: ListNavigationItem {
			id: rsDeviceDelegate

			required property BaseDevice device
			readonly property VeQuickItem _state: VeQuickItem { uid: device.serviceUid + "/State" }

			text: device.name
			secondaryText: Global.system.systemStateToText(_state.value)

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageMultiRs.qml",
						{ "title": text, "bindPrefix": device.serviceUid })
			}
		}
	}
}
