/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListLabel {
				//% "The settings details for this device will be provided in a future update."
				text: qsTrId("devicelist_not_yet_implemented")
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("qrc:/qt/qml/Victron/VenusOS/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
