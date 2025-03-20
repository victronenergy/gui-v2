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
		model: VisibleItemModel {
			ListText {
				//% "Unsupported device found"
				text: qsTrId("devicelist_unsupporteddevices_found")
				dataItem.uid: root.bindPrefix + "/Reason"
			}

			ListNavigation {
				id: deviceInfoItem
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": Qt.binding(function() { return deviceInfoItem.text }), "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
