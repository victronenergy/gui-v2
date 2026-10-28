/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a pulsemeter device.
*/
DevicePage {
	id: root


	settingsModel: VisibleItemModel {
		ListQuantity {
			//% "Aggregate"
			text: qsTrId("pulsecounter_aggregate")
			dataItem.uid: root.serviceUid + "/Aggregate"
			unit: Global.systemSettings.volumeUnit
		}

		ListNavigation {
			text: CommonWords.setup
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/pulsemeter/PagePulseCounterSetup.qml",
						{ "title": text, "bindPrefix": root.serviceUid, "inputNumber": device.deviceInstance })
			}
		}
	}
}
