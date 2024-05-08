/*
** Copyside (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property alias title: header.title
	property alias icon: header.icon
	property alias quantityLabel: quantityLabel
	property alias sideComponent: sideLoader.sourceComponent
	property alias bottomComponent: bottomLoader.sourceComponent
	property bool loadersActive

	width: parent.width
	bottomPadding: Theme.geometry_monitorWidget_verticalMargin

	WidgetHeader {
		id: header
		z: 1    // place the title above the side component if it overflows
	}

	Row {
		width: parent.width
		height: quantityLabel.height

		ElectricalQuantityLabel {
			id: quantityLabel
			font.pixelSize: Theme.font_briefPage_quantityLabel_size
			width: parent.width - sideLoader.width
			alignment: Qt.AlignLeft
		}

		Loader {
			id: sideLoader
			anchors {
				top: parent.top
				bottom: parent.bottom
				bottomMargin: Theme.geometry_monitorWidget_sideWidget_bottomMargin
			}
			width: Theme.geometry_monitorWidget_sideWidget_width
			active: root.loadersActive
		}
	}

	Item {
		width: 1
		height: bottomLoader.status === Loader.Ready ? Theme.geometry_monitorWidget_quantityLabel_bottomMargin : 0
	}

	Loader {
		id: bottomLoader
		width: parent.width
		active: root.loadersActive
	}
}
