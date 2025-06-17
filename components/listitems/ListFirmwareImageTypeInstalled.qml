/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	text: CommonWords.image_type
	secondaryText: signalK.valid || nodeRed.valid ? CommonWords.firmware_type_large : CommonWords.firmware_type_normal
	preferredVisible: largeImageSupport.valid && largeImageSupport.value === 1

	VeQuickItem {
		id: signalK
		uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
	}
	VeQuickItem {
		id: nodeRed
		uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
	}
	VeQuickItem {
		id: largeImageSupport
		uid: Global.venusPlatform.serviceUid + "/Firmware/LargeImageSupport"
	}
}
