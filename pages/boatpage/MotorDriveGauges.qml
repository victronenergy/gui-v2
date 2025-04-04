/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.BoatPageComponents as BoatPageComponents
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Column {
	id: motorDriveColumn

	required property var motorDrive
	readonly property string serviceUid: motorDrive && motorDrive.serviceUid ? motorDrive.serviceUid : ""

	spacing: Theme.geometry_boatPage_motorDriveColumn_spacing

	Row {
		id: motordriveRow

		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Theme.geometry_boatPage_row_spacing

		CP.ColorImage {
			anchors {
				right: undefined
				verticalCenter: parent.verticalCenter
			}
			width: Theme.geometry_boatPage_motordriveRow_image_width
			height: width
			color: Theme.color_boatPage_icon
			source: "qrc:/images/icon_propeller_32.png"
		}

		Label {
			anchors.verticalCenter: parent.verticalCenter
			font.pixelSize: Theme.font_size_body2
			//% "Motordrive"
			text: qsTrId("boat_page_motor_drive")
		}
	}

	TemperatureGauge {
		anchors.horizontalCenter: parent.horizontalCenter
		width: childrenRect.width
		dataItem: motorDrive.motorTemperature
		unit: VenusOS.Units_Temperature_Celsius
		iconSource: "qrc:/images/icon_engine_temp_32.svg"
		visible: motorDrive.motorTemperature.valid
	}
}
