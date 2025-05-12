/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string modbustcpServiceUid: BackendConnection.serviceUidForType("modbustcp")

	function _shortServiceName(serviceName) {
		if (serviceName === undefined) {
			return ""
		}
		return serviceName.split('.', 3).join('.')
	}

	function _formatName(productName, serviceName) {
		if (productName !== undefined) {
			return productName
		}
		if (serviceName !== undefined) {
			return _shortServiceName(serviceName)
		}
		return "--"
	}

	VeQuickItem {
		id: serviceCount
		uid: root.modbustcpServiceUid + "/Services/Count"
	}

	GradientListView {
		model: serviceCount.value || 0

		delegate: ListItem {
			id: serviceDelegate

			readonly property string servicePath: root.modbustcpServiceUid + "/Services/" + model.index

			text: root._formatName(productName.value, serviceName.value)
			//: Modbus TCP service details. %1 = service name or uid, %2 = unit id
			//% "%1 | Unit ID: %2"
			caption: qsTrId("settings_modbus_unit_name_and_id")
					.arg(root._shortServiceName(serviceName.value))
					.arg(unitId.value)

			VeQuickItem {
				id: serviceName
				uid: serviceDelegate.servicePath + "/ServiceName"
			}

			// TODO the uid is wrong on MQTT, need something like mqtt/<type>/ProductName
			// but it is currently mqtt/com.victronenergy.<service>/ProductName
			VeQuickItem {
				id: productName
				uid: serviceName.valid ? "%1/%2/ProductName".arg(BackendConnection.uidPrefix()).arg(serviceName.value) : ""
			}

			VeQuickItem {
				id: unitId
				uid: serviceDelegate.servicePath + "/UnitId"
			}
		}
	}
}
