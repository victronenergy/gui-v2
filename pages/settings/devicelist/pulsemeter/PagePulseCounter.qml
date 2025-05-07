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
				//% "Aggregate"
				text: qsTrId("pulsecounter_aggregate")
				dataItem.uid: bindPrefix + "/Aggregate"
				unit: Global.systemSettings.volumeUnit
			}

			ListNavigation {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/pulsemeter/PagePulseCounterSetup.qml",
							{ "title": text, "bindPrefix": root.bindPrefix, "inputNumber": device.deviceInstance })
				}
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
