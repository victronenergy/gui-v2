/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

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

	DataPoint {
		id: serviceCount
		source: "com.victronenergy.modbustcp/Services/Count"
	}

	GradientListView {
		model: serviceCount.value || 0

		delegate: ListItem {
			id: serviceDelegate

			readonly property string servicePath: "com.victronenergy.modbustcp/Services/" + model.index

			text: root._formatName(productName.value, serviceName.value)

			bottomContentChildren: [
				ListTextItem {
					id: serviceDetails
					implicitHeight: serviceDetails.primaryLabel.height
					text: root._shortServiceName(serviceName.value)
					//% "Unit ID: %1"
					secondaryText: qsTrId("settings_modbus_unit_id").arg(unitId.value)
				}
			]

			DataPoint {
				id: serviceName
				source: serviceDelegate.servicePath + "/ServiceName"
			}

			DataPoint {
				id: productName
				source: serviceName.value ? serviceName.value + "/ProductName" : ""
			}

			DataPoint {
				id: unitId
				source: serviceDelegate.servicePath + "/UnitId"
			}
		}
	}
}
