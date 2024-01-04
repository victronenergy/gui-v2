/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

ListNavigationItem {
	id: root

	property int _index
	property string bindPrefix
	property string devPrefix: root.bindPrefix + "/Devices/" + _index

	VeQuickItem {
		id: code

		property string text: valid ? "0x" + value.toString(16) : "--"

		uid: devPrefix + "/ExtendStatus/GridRelayReport/Code"
	}

	VeQuickItem {
		id: counter

		property string text: valid ? "#" + value : "--"

		uid: devPrefix + "/ExtendStatus/GridRelayReport/Count"
	}

	//: eg. 'Phase L1, device 3 (6)', where '(6)' is the index into the list of reported values
	//% "Phase L%1, device %2 (%3)"
	text: qsTrId("vebus_device_phase_x_device_x_index_x").arg((_index % 3) + 1).arg(Math.floor(_index / 3) + 1).arg(_index)
	secondaryText: counter.text + " " + code.text
	visible: code.isValid
	onClicked:  Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusError11Device.qml", {
												bindPrefix: devPrefix,
												title: text
											})
}
