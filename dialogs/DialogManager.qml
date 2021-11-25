/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	property var activeDialog
	property alias inputCurrentLimitDialog: inputCurrentLimitDialog

	anchors.fill: parent

	InputCurrentLimitDialog {
		id: inputCurrentLimitDialog

		active: activeDialog === inputCurrentLimitDialog
		onAccepted: activeDialog = null
		onRejected: activeDialog = null
	}
}
