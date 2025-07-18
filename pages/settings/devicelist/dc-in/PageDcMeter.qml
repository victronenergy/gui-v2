/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of generic DC meter settings for a DC device.
*/
DevicePage {
	id: root

	property alias bindPrefix: dcMeterMode.bindPrefix

	serviceUid: bindPrefix
	settingsModel: PageDcMeterModel {
		id: dcMeterMode
	}
}
