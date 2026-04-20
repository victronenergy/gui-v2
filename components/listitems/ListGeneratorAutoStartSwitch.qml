/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSwitch {
	id: root
	//% "Auto start functionality"
	text: qsTrId("list_generator_auto_start_switch_auto_start_functionality")
	updateDataOnClick: false

	onClicked: {
		if (!checked) {
			root.dataItem.setValue(1)
		} else {
			// check if they really want to disable
			Global.dialogLayer.open(confirmationDialogComponent)
		}
	}

	Component {
		id: confirmationDialogComponent

		GeneratorDisableAutoStartDialog {
			onAccepted: root.dataItem.setValue(0)
		}
	}
}
