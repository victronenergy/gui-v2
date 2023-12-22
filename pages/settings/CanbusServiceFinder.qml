/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Loader {
	id: root

	property string gateway

	// On D-Bus, the vecan/rvc service is dbus/com.victronenergy.(vecan|rvc).(can0|can1)
	// On MQTT, the service is found by looking through mqtt/vecan/* or mqtt/rvc/* and finding a
	// service with the matching gateway (either "can0" or "can1").
	readonly property string vecanServiceUid: BackendConnection.type === BackendConnection.MqttSource
			 ? _mqttVecanServiceUid
			 : "%1/com.victronenergy.vecan.%2".arg(BackendConnection.uidPrefix()).arg(gateway)
	readonly property string rvcServiceUid: BackendConnection.type === BackendConnection.MqttSource
			 ? _mqttRvcServiceUid
			 : "%1/com.victronenergy.rvc.%2".arg(BackendConnection.uidPrefix()).arg(gateway)

	property string _mqttVecanServiceUid
	property string _mqttRvcServiceUid

	active: BackendConnection.type === BackendConnection.MqttSource
	sourceComponent: QtObject {
		property Instantiator vecanObjects: Instantiator {
			model: VeQItemTableModel {
				uids: ["mqtt/vecan"]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
			delegate: VeQuickItem {
				uid: model.uid + "/Identifier"
				onValueChanged: {
					if (value !== undefined && value == root.gateway) {
						root._mqttVecanServiceUid = model.uid
					}
				}
			}
		}
		property Instantiator rvcObjects: Instantiator {
			model: VeQItemTableModel {
				uids: ["mqtt/rvc"]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
			delegate: VeQuickItem {
				uid: model.uid + "/Identifier"
				onValueChanged: {
					if (value !== undefined && value == root.gateway) {
						root._mqttRvcServiceUid = model.uid
					}
				}
			}
		}
	}
}
