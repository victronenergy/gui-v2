/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string serviceUid

	readonly property AcPhase phase1: AcPhase {
		serviceUid: root.serviceUid + "/Ac/Out/L1"
	}
	readonly property AcPhase phase2: AcPhase {
		serviceUid: root.serviceUid + "/Ac/Out/L2"
	}
	readonly property AcPhase phase3: AcPhase {
		serviceUid: root.serviceUid + "/Ac/Out/L3"
	}
	readonly property var phases: [phase1, phase2, phase3]
}
