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

			bottomContentChildren: [
				ListText {
					id: serviceDetails
					implicitHeight: serviceDetails.primaryLabel.height
					text: root._shortServiceName(serviceName.value)
					//% "Unit ID: %1"
					secondaryText: qsTrId("settings_modbus_unit_id").arg(unitId.value)
				}
			]

			VeQuickItem {
				id: serviceName
				uid: serviceDelegate.servicePath + "/ServiceName"
			}

			// TODO the uid is wrong on MQTT, need something like mqtt/<type>/ProductName
			// but it is currently mqtt/com.victronenergy.<service>/ProductName
			VeQuickItem {
				id: productName
				uid: serviceName.isValid ? "%1/%2/ProductName".arg(BackendConnection.uidPrefix()).arg(serviceName.value) : ""
			}

			VeQuickItem {
				id: unitId
				uid: serviceDelegate.servicePath + "/UnitId"
			}
		}
	}
}
