/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string serviceUid
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)
	property int inputNumber
	readonly property int inputType: {
		if (serviceType === "vebus"
				&& serviceUid === Global.inverterChargers.veBusDevices.firstObject?.serviceUid
				&& _systemSetupType.valid) {
			// The /SystemSetup/AcInput<x> settings only apply to the first/main vebus service.
			return  _systemSetupType.value
		} else if (_type.valid) {
			return _type.value
		}
		return -1
	}

	property VeQuickItem _systemSetupType: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput" + inputNumber
	}

	property VeQuickItem _type: VeQuickItem {
		// The /Type setting is only available for acsystem services.
		uid: root.serviceType === "acsystem" ? root.serviceUid + "/Ac/In/" + inputNumber + "/Type" : ""
	}
}
