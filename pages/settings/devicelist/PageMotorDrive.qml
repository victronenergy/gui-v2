/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	title: device.name

	Device {
		id: device
		serviceUid: root.bindPrefix
	}

	GradientListView {
		model: VisibleItemModel {
			ListQuantity {
				//% "Motor RPM"
				text: qsTrId("devicelist_motordrive_motorrpm")
				dataItem.uid: root.bindPrefix + "/Motor/RPM"
				unit: VenusOS.Units_RevolutionsPerMinute
				preferredVisible: dataItem.valid
			}

			ListTemperature {
				//% "Motor Temperature"
				text: qsTrId("devicelist_motordrive_motortemperature")
				dataItem.uid: root.bindPrefix + "/Motor/Temperature"
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				text: CommonWords.power_watts
				dataItem.uid: root.bindPrefix + "/Dc/0/Power"
				unit: VenusOS.Units_Watt
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				text: CommonWords.voltage
				dataItem.uid: root.bindPrefix + "/Dc/0/Voltage"
				unit: VenusOS.Units_Volt_DC
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				text: CommonWords.current_amps
				dataItem.uid: root.bindPrefix + "/Dc/0/Current"
				unit: VenusOS.Units_Amp
				precision: 2
				preferredVisible: dataItem.valid
			}

			ListTemperature {
				//% "Coolant Temperature"
				text: qsTrId("devicelist_motordrive_coolanttemperature")
				dataItem.uid: root.bindPrefix + "/Coolant/Temperature"
				preferredVisible: dataItem.valid
			}

			ListTemperature {
				//% "Controller Temperature"
				text: qsTrId("devicelist_motordrive_controllertemperature")
				dataItem.uid: root.bindPrefix + "/Controller/Temperature"
				preferredVisible: dataItem.valid
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
