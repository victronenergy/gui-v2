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

	width: Theme.geometry.screen.width
	height: Theme.geometry.screen.height

	ApplicationContent {
		id: content
		anchors.centerIn: parent
		width: Theme.geometry.screen.width
		height: Theme.geometry.screen.height
		clip: Qt.platform.os == "wasm"
	}
}
