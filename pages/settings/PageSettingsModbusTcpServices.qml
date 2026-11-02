/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
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

	VeQuickItem {
		id: serviceCount
		uid: root.modbustcpServiceUid + "/Services/Count"
	}

	GradientListView {
		model: serviceCount.value || 0

		header: PrimaryListLabel {
			//% "See the Settings → VRM → VRM device instances menu to change the Modbus-TCP unit IDs."
			text: qsTrId("settings_modbus_tcp_unit_id_note")
		}

		delegate: ListText {
			id: serviceDelegate

			readonly property string servicePath: root.modbustcpServiceUid + "/Services/" + model.index

			text: device.name || root._shortServiceName(serviceName.value) || "--"
			contentItem: ListItemLabelLayout {
				primaryText: serviceDelegate.text
				primaryLabel.font: serviceDelegate.font

				CaptionLabel {
					//: Modbus TCP service details. %1 = service name or uid, %2 = unit id
					//% "%1 | unit ID: %2"
					text: qsTrId("settings_modbus_unit_name_and_id")
							.arg(root._shortServiceName(serviceName.value))
							.arg(unitId.value)
					Layout.fillWidth: true
					Layout.columnSpan: parent.columns
				}
			}

			Device {
				id: device
				serviceUid: !serviceName.valid || !vrmInstanceId.valid ? ""
					 : BackendConnection.serviceUidFromName(serviceName.value, vrmInstanceId.value)
			}

			VeQuickItem {
				id: serviceName
				uid: serviceDelegate.servicePath + "/ServiceName"
			}

			VeQuickItem {
				id: vrmInstanceId
				uid: serviceDelegate.servicePath + "/VrmInstanceId"
			}

			VeQuickItem {
				id: unitId
				uid: serviceDelegate.servicePath + "/UnitId"
			}
		}
	}
}
