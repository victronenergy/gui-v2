/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property InputCurrentLimitDialog inputCurrentLimitDialog: InputCurrentLimitDialog {
		visible: false
	}
	property InverterChargerModeDialog inverterChargerModeDialog: InverterChargerModeDialog {
		visible: false
	}

	anchors.fill: parent
}
