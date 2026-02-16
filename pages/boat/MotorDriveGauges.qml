/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Column {
	id: root

	required property MotorDrives motorDrives
	property bool showDcConsumption

	spacing: Theme.geometry_boatPage_motorDriveColumn_spacing

	Row {
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Theme.geometry_boatPage_row_spacing

		CP.ColorImage {
			id: motorDriveIcon
			width: Theme.geometry_boatPage_motordriveRow_image_width
			height: Theme.geometry_boatPage_motordriveRow_image_width
			color: Theme.color_boatPage_icon
			source: "qrc:/images/icon_propeller_32.png"
		}

		Label {
			anchors.verticalCenter: parent.verticalCenter
			width: Math.min(root.width - motorDriveIcon.width, implicitWidth)
			verticalAlignment: Text.AlignVCenter
			minimumPixelSize: Theme.font_size_tiny
			font.pixelSize: Theme.font_size_body2
			fontSizeMode: Text.HorizontalFit
			//% "Motordrive"
			text: qsTrId("boat_page_motor_drive")
		}
	}

	ElectricalQuantityLabel {
		id: label

		anchors.horizontalCenter: parent.horizontalCenter
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_boatPage_centerGauge_consumption_pixelSize
		visible: root.motorDrives.dcConsumption.quotient.valid && root.showDcConsumption
		sourceType: VenusOS.ElectricalQuantity_Source_Dc
		dataObject: root.motorDrives.dcConsumption.scalar
	}
}
