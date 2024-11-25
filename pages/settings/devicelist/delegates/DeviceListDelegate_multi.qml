/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	// multi devices are not shown in the Device List; they are shown as part of the
	// "Devices" list in the acsystem page (PageRsSystem) instead.
	allowed: false
}
