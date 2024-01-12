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
				//% "Aggregate"
				text: qsTrId("pulsecounter_aggregate")
				dataItem.uid: bindPrefix + "/Aggregate"
				unit: Global.systemSettings.volumeUnit
			}

			ListNavigationItem {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/pulsemeter/PagePulseCounterSetup.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
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
