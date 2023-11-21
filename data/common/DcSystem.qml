/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

DcDevice {
	id: dcSystem

	onValidChanged: {
		if (!!Global.dcSystems) {
			if (valid) {
				Global.dcSystems.model.addDevice(dcSystem)
			} else {
				Global.dcSystems.model.removeDevice(dcSystem)
			}
		}
	}
}
