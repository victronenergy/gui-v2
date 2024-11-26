/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DcDevice {
	id: dcLoad

	onValidChanged: {
		if (!!Global.dcLoads) {
			if (valid) {
				Global.dcLoads.model.addDevice(dcLoad);
			} else {
				Global.dcLoads.model.removeDevice(dcLoad.serviceUid);
			}
		}
	}
}
