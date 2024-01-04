/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

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

			bottomContent.children: [
				ListTextItem {
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

			VeQuickItem {
				id: productName
				uid: serviceName.value ? serviceName.value + "/ProductName" : ""
			}

			VeQuickItem {
				id: unitId
				uid: serviceDelegate.servicePath + "/UnitId"
			}
		}
	}
}
