/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListQuantityItem {
				//% "Motor RPM"
				text: qsTrId("devicelist_motordrive_motorrpm")
				dataItem.uid: root.bindPrefix + "/Motor/RPM"
				unit: VenusOS.Units_RevolutionsPerMinute
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTemperatureItem {
				//% "Motor Temperature"
				text: qsTrId("devicelist_motordrive_motortemperature")
				dataItem.uid: root.bindPrefix + "/Motor/Temperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListQuantityItem {
				text: CommonWords.power_watts
				dataItem.uid: root.bindPrefix + "/Dc/0/Power"
				unit: VenusOS.Units_Watt
				allowed: defaultAllowed && dataItem.isValid
			}

			ListQuantityItem {
				text: CommonWords.voltage
				dataItem.uid: root.bindPrefix + "/Dc/0/Voltage"
				unit: VenusOS.Units_Volt_DC
				allowed: defaultAllowed && dataItem.isValid
			}

			ListQuantityItem {
				text: CommonWords.current_amps
				dataItem.uid: root.bindPrefix + "/Dc/0/Current"
				unit: VenusOS.Units_Amp
				precision: 2
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTemperatureItem {
				//% "Controller Temperature"
				text: qsTrId("devicelist_motordrive_controllertemperature")
				dataItem.uid: root.bindPrefix + "/Controller/Temperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
