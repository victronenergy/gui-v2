/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQItemSortTableModel {
		id: dbusModel

		filterFlags: VeQItemSortTableModel.FilterOffline
		dynamicSortFilter: true
		filterRole: VeQItemTableModel.UniqueIdRole
		filterRegExp: "^dbus/com\.victronenergy\.(inverter|solarcharger)\."
		model: BackendConnection.type === BackendConnection.DBusSource ? Global.dataServiceModel : null
	}

	VeQItemSortTableModel {
		id: mqttModel

		filterFlags: VeQItemSortTableModel.FilterOffline
		dynamicSortFilter: true
		filterRole: VeQItemTableModel.UniqueIdRole
		model: VeQItemTableModel {
			uids: BackendConnection.type === BackendConnection.MqttSource ? ["mqtt/inverter","mqtt/solarcharger"] : []
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}

	GradientListView {
		header: DvccCommonSettings {
			bottomPadding: Theme.geometry_gradientList_spacing
			width: parent.width
		}

		model: VeQItemSortTableModel {
			filterRole: VeQItemTableModel.ValueRole
			sortColumn: childValues.sortValueColumn
			dynamicSortFilter: true

			model: VeQItemChildModel {
				id: childValues

				childId: "Link/ChargeCurrent"
				model: BackendConnection.type === BackendConnection.DBusSource
					   ? dbusModel
					   : BackendConnection.type === BackendConnection.MqttSource
						 ? mqttModel
						 : null

				// And sort them by n2kInstance, description
				sortDelegate: VeQItemSortDelegate {

					VeQuickItem {
						id: n2kDeviceInstanceChild
						uid: buddy.uid + "/N2kDeviceInstance"
					}
					VeQuickItem {
						id: productNameChild
						uid: buddy.uid + "/ProductName"
					}
					VeQuickItem {
						id: customNameChild
						uid: buddy.uid + "/CustomName"
					}
					sortValue: (n2kDeviceInstanceChild.value || 0) + (customNameChild.value || productNameChild.value || "")
				}
			}
		}

		delegate: ListQuantityGroup {
			width: parent.width
			text: "[" + (n2kDeviceInstance.value || 0) + "] " + (customName.value || productName.value || "")
			model: QuantityObjectModel {
				QuantityObject { object: dcCurrent; unit: VenusOS.Units_Amp }
				QuantityObject { object: maxValue.valid ? maxValue : null; key: "summary" }
			}

			VeQuickItem {
				id: n2kDeviceInstance
				uid: buddy.uid + "/N2kDeviceInstance"
			}

			VeQuickItem {
				id: dcCurrent
				uid: buddy.uid + "/Dc/0/Current"
			}

			VeQuickItem {
				id: maxValue

				//% "Max: %1"
				readonly property string summary: valid ? qsTrId("settings_dvcc_max").arg(Units.formatNumber(value, 3)) : ""

				uid: buddy.uid + "/Link/ChargeCurrent"
			}

			VeQuickItem {
				id: productName
				uid: buddy.uid + "/ProductName"
			}
			VeQuickItem {
				id: customName
				uid: buddy.uid + "/CustomName"
			}
		}
	}
}
