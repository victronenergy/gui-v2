/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SegmentedButtonRow {
	id: buttons

	width: Theme.geometry.levelsPage.buttons.width
	height: Theme.geometry.levelsPage.buttons.height
	fontPixelSize: Theme.levelsPage.buttons.font.size
	model: ListModel {
		ListElement {
			//% "Tanks"
			text: QT_TRID_NOOP("levels_page_tanks")
		}
		ListElement {
			//% "Environment"
			text: QT_TRID_NOOP("levels_page_environment")
		}
	}

	Behavior on anchors.topMargin { NumberAnimation { duration: Theme.animation.statusBar.slide.duration; easing.type: Easing.InOutQuad } }
}
