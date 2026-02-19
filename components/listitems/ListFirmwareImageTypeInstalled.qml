/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	text: CommonWords.image_type
	secondaryText: imageType.value === "large" ? CommonWords.firmware_type_large : CommonWords.firmware_type_normal
	preferredVisible: largeImageSupport.valid && largeImageSupport.value === 1

	VeQuickItem {
		id: imageType
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/ImageType"
	}
	VeQuickItem {
		id: largeImageSupport
		uid: Global.venusPlatform.serviceUid + "/Firmware/LargeImageSupport"
	}
}
