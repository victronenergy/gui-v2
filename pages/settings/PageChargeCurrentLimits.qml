/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Page {
	id: root

	SettingsListView {
		header: DvccCommonSettings {
			width: parent.width
		}

		model: VeQItemSortTableModel {
			property alias all: childValues

			filterRole: VeQItemTableModel.ValueRole
			sortColumn: childValues.sortValueColumn
			dynamicSortFilter: true

			model: VeQItemChildModel {
				id: childValues

				childId: "Link/ChargeCurrent"
				model: VeQItemSortTableModel {
					filterFlags: VeQItemSortTableModel.FilterOffline
					dynamicSortFilter: true
					filterRole: VeQItemTableModel.UniqueIdRole
					filterRegExp: "^dbus/com\.victronenergy\.(inverter|solarcharger)\."
					model: Global.dataServiceModel
				}

				// And sort them by n2kInstance, description
				sortDelegate: VeQItemSortDelegate {
					DataPoint {
						id: n2kDeviceInstance
						source: buddy.id + "/N2kDeviceInstance"
					}
					DataPoint {
						id: productName
						source: buddy.id + "/ProductName"
					}
					DataPoint {
						id: customName
						source: buddy.id + "/CustomName"
					}
					sortValue: (n2kDeviceInstance.value || 0) + (customName.value || productName.value || "")
				}
			}
		}

		delegate: SettingsListTextGroup {
			readonly property string dcCurrentText: dcCurrent.value === undefined
				? "--"
				: Utils.toFloat(dcCurrent.value, 3) + "A"
			//% "Max: %1"
			readonly property string maxValueText: maxValue.value === undefined
				? "-- "
				: qsTrId("settings_dvcc_max").arg(Utils.toFloat(maxValue.value, 3))

			width: parent.width
			text: "[" + (n2kDeviceInstance.value || 0) + "] " + (customName.value || productName.value || "")
			model: [ dcCurrentText, maxValueText ]

			DataPoint {
				id: n2kDeviceInstance
				source: buddy.id + "/N2kDeviceInstance"
			}

			DataPoint {
				id: dcCurrent
				source: buddy.id + "/Dc/0/Current"
			}

			DataPoint {
				id: maxValue
				source: buddy.id + "/Link/ChargeCurrent"
			}

			DataPoint {
				id: productName
				source: buddy.id + "/ProductName"
			}
			DataPoint {
				id: customName
				source: buddy.id + "/CustomName"
			}
		}
	}
}
