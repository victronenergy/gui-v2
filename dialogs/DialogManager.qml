/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias inputCurrentLimitDialog: inputCurrentLimitDialog

	anchors.fill: parent

	InputCurrentLimitDialog {
		id: inputCurrentLimitDialog
		visible: false
	}
}
