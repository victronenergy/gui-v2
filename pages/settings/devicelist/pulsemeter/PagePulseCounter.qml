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

	property string bindPrefix

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
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
	}
}
