/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import "pages"

Window {
	id: root

	width: Theme.scaleFactor == 1.0 ? 800 : 1024
	height: Theme.scaleFactor == 1.0 ? 480 : 600
	color: Theme.backgroundColor

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")

	Item {
		id: offsetItem

		x: Theme.scaleFactor == 1.0 ? 0 : 12
		width: Theme.scaleFactor == 1.0 ? 800 : 1000
		height: Theme.scaleFactor == 1.0 ? 480 : 600

		NavContainer {
			id: scaleItem

			width: 800
			height: 480

			scale: Theme.scaleFactor
			/* Why are the following required? */
			x: Theme.scaleFactor == 1.0 ? 0 : 100
			y: Theme.scaleFactor == 1.0 ? 0 : 60
		}
	}
}
