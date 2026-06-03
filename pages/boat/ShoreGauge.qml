/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	required property bool isShoreConnected
	readonly property bool isShoreCharging: isShoreConnected && Global.acInputs.highlightedInput && Global.acInputs.highlightedInput.power > 0

	spacing: Theme.geometry_boatPage_row_spacing

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_boatPage_shoreGauge_icon_size
		height: width
		fillMode: Image.PreserveAspectFit
		color: isShoreCharging ? Theme.color_boatPage_regenProgress : Theme.color_boatPage_icon
		source: isShoreCharging ? "qrc:/images/icon_shore_charging.svg" : "qrc:/images/icon_shore.svg"
		opacity: isShoreConnected ? 1 : 0
	}

	ElectricalQuantityLabel {
		id: label

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font_boatPage_shoreGauge_label_pixelSize
		sourceType: VenusOS.ElectricalQuantity_Source_Ac
		dataObject: isShoreConnected ? Global.acInputs.highlightedInput : null
	}
}