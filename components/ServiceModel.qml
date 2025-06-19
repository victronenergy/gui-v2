/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Loads a QAbstractItemModel containing all services of the requested type.

	On D-Bus/Mock backends, service uids include unique device strings. For example, if the
	serviceType='tank', the uids from this model might be:
		"dbus/com.victronenergy.tank.adc_builtin1_1"
		"dbus/com.victronenergy.tank.adc_builtin1_4"

	On MQTT backends, service uids only include the service type and device instance, so the uids
	from the model would be like this instead:
		"mqtt/tank/22"
		"mqtt/tank/23"
*/
VeQItemSortTableModel {
	id: root

	required property list<string> serviceTypes

	dynamicSortFilter: BackendConnection.type !== BackendConnection.MqttSource
	filterRole: VeQItemTableModel.UniqueIdRole
	filterRegExp: BackendConnection.type === BackendConnection.MqttSource ? ""
			: "^%1/com\.victronenergy\.(?:%2)\."
					.arg(BackendConnection.uidPrefix())
					.arg(root.serviceTypes.join("|"))
	model: BackendConnection.type === BackendConnection.MqttSource ? mqttModel : Global.dataServiceModel

	readonly property VeQItemTableModel mqttModel: VeQItemTableModel {
		uids: BackendConnection.type === BackendConnection.MqttSource
			  ? root.serviceTypes.map(function(serviceType) { return "mqtt/" + serviceType })
			  : []
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}
}
