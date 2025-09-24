/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property FilteredDeviceModel model

	//% "DC Load"
	title: qsTrId("dcload")

	GradientListView {
		id: settingsListView

		header: SettingsColumn {
			width: parent.width
			bottomPadding: settingsListView.spacing

			BaseListItem {
				width: parent.width
				height: summary.height

				QuantityTableSummary {
					id: summary

					width: parent.width
					rightPadding: Theme.geometry_listItem_content_horizontalMargin + Theme.geometry_icon_size_medium
					summaryModel: [
						{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
						{ text: CommonWords.energy, unit: VenusOS.Units_Energy_KiloWattHour },
					]
					bodyHeaderText: CommonWords.total
					bodyModel: QuantityObjectModel {
						QuantityObject { object: Global.system.dcload; key: "power"; unit: VenusOS.Units_Watt }
						QuantityObject { object: Global.system.dcload; key: "energy"; unit: VenusOS.Units_Energy_KiloWattHour }
					}
				}
			}
		}

		model: root.model
		delegate: ListQuantityGroupNavigation {
			id: deviceDelegate

			required property var device

			text: device.name
			quantityModel: QuantityObjectModel {
				QuantityObject { object: dcDevice; key: "voltage"; unit: VenusOS.Units_Volt_DC }
				QuantityObject { object: dcDevice; key: "current"; unit: VenusOS.Units_Amp }
				QuantityObject { object: dcDevice; key: "power"; unit: VenusOS.Units_Watt }
			}

			onClicked: root._showSettingsPage(device)

			DcDevice {
				id: dcDevice
				serviceUid: deviceDelegate.device.serviceUid
			}
		}
	}
}
