/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "Unsupported device found"
				text: qsTrId("devicelist_unsupporteddevices_found")
				dataSource: root.bindPrefix + "/Reason"
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
