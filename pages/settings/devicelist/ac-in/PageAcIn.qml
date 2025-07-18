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

	property string bindPrefix

	serviceUid: bindPrefix
	settingsModel: PageAcInModel {
		bindPrefix: root.bindPrefix
		productId: root.device.productId
	}
	extraDeviceInfo: SettingsColumn {
		width: parent?.width ?? 0
		topPadding: spacing
		preferredVisible: dataManagerVersion.preferredVisible

		ListText {
			id: dataManagerVersion
			//% "Data manager version"
			text: qsTrId("ac-in-modeldefault_data_manager_version")
			dataItem.uid: root.bindPrefix + "/DataManagerVersion"
			preferredVisible: dataItem.valid
		}
	}
}
