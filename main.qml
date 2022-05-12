/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Window {
	id: root

	property alias dialogManager: content.dialogManager

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")
	color: content.mainView.backgroundColor

	width: [800, 1024][Theme.screenSize]
	height: [480, 600][Theme.screenSize]

	ApplicationContent {
		id: content
		anchors.centerIn: parent
		width: [800, 1024][Theme.screenSize]
		height: [480, 600][Theme.screenSize]
		clip: Qt.platform.os == "wasm"
	}
}
