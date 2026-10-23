/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for an AC input device.

	The device could be one of the main AC inputs (i.e. a grid/shore or genset). It could also be,
	for example, an energy meter configured with a specific role (such as heatpump, genset,
	pvinverter, or evcharger) or a generic AC load.
*/
DevicePage {
	id: root

	settingsModel: PageAcInModel {
		bindPrefix: root.serviceUid
		productId: root.device.productId
		deviceSettingsPage: root
	}
	extraDeviceInfo: SettingsColumn {
		width: parent?.width ?? 0
		preferredVisible: dataManagerVersion.preferredVisible

		ListText {
			id: dataManagerVersion
			//% "Data manager version"
			text: qsTrId("ac-in-modeldefault_data_manager_version")
			dataItem.uid: root.serviceUid + "/DataManagerVersion"
			preferredVisible: dataItem.valid
		}
	}
}
