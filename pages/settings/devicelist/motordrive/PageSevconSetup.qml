/*
** Copyright (C) 2025 Victron Energy B.V.
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
			ListSwitch {
				//% "Motor Direction Inverted"
				text: qsTrId("devicelist_motordrive_motordirectioninverted")
				dataItem.uid: root.bindPrefix + "/Motor/DirectionInverted"
				dataItem.invalidate: false
				preferredVisible: dataItem.valid
			}
		}
	}
}
