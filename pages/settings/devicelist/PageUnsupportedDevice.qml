/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for an unsupported device.
*/
DevicePage {
	id: root

	property string bindPrefix

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
		ListText {
			//% "Unsupported device found"
			text: qsTrId("devicelist_unsupporteddevices_found")
			dataItem.uid: root.bindPrefix + "/Reason"
		}
	}
}
