/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Loader {
	id: root

	required property string serviceType

	sourceComponent: BackendConnection.type === BackendConnection.MqttSource ? _mqttModelComponent
		 : _dbusOrMockModelComponent

	readonly property Component _dbusOrMockModelComponent: Component {
		VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^%1/com\.victronenergy\.%2\.".arg(BackendConnection.uidPrefix()).arg(root.serviceType)
			model: Global.dataServiceModel
		}
	}

	readonly property Component _mqttModelComponent: Component {
		VeQItemTableModel {
			uids: [ "mqtt/" + root.serviceType ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}
}
