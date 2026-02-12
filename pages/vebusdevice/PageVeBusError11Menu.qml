/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigation {
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

	text: CommonWords.vebus_phase_device.arg((_index % 3) + 1).arg(Math.floor(_index / 3) + 1).arg(_index)
	secondaryText: counter.text + " " + code.text
	preferredVisible: code.valid
	onClicked:  Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusError11Device.qml", {
												bindPrefix: devPrefix,
												title: text
											})
}
