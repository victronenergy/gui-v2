/*
** Copyside (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias title: header.title
	property alias icon: header.icon
	property alias quantityLabel: quantityLabel
	property alias sideComponent: sideLoader.sourceComponent
	property alias bottomComponent: bottomLoader.sourceComponent
	property bool loadersActive

	width: parent.width
	height: bottomLoader.y + bottomLoader.height

	WidgetHeader {
		id: header
	}

	ElectricalQuantityLabel {
		id: quantityLabel
		anchors.top: header.bottom
		font.pixelSize: Theme.font_briefPage_quantityLabel_size
	}

	Loader {
		id: sideLoader
		anchors {
			right: parent.right
			top: header.bottom
			bottom: quantityLabel.bottom
			bottomMargin: quantityLabel.bottomPadding
		}
		width: Theme.geometry_monitorWidget_sideWidget_width
		active: root.loadersActive
	}

	Loader {
		id: bottomLoader
		anchors {
			top: quantityLabel.bottom
			topMargin: Theme.geometry_monitorWidget_bottomWidget_topMargin
		}
		width: parent.width
		active: root.loadersActive
	}
}
