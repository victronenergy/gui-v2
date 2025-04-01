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

	required property var motorDriveDcConsumption
	readonly property var _motorDrive: Global.allDevicesModel.motorDriveDevices.firstObject

	anchors {
		verticalCenter: batteryGauge.verticalCenter
		verticalCenterOffset: Theme.geometry_boatPage_motorDriveColumn_verticalCenterOffset
		horizontalCenter: parent.horizontalCenter
	}
	visible: centerGauge.dataSource === motorDriveDcConsumption
	height: childrenRect.height
	spacing: Theme.geometry_boatPage_motorDriveColumn_spacing

	Row {
		id: motordriveRow

		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Theme.geometry_boatPage_motordriveRow_spacing

		CP.ColorImage {
			anchors {
				right: undefined
				verticalCenter: parent.verticalCenter
			}
			width: Theme.geometry_boatPage_motordriveRow_image_width
			height: width
			color: Theme.color_boatPage_icon
			source: "qrc:/images/icon_propeller_32.svg"
		}

		Label {
			anchors.verticalCenter: parent.verticalCenter
			font.pixelSize: Theme.geometry_boatPage_motordriveRow_label_pixelSize
			//% "Motordrive"
			text: qsTrId("boat_page_motor_drive")
		}
	}

	QuantityLabel {
		id: motordriveLabel

		anchors.horizontalCenter: parent.horizontalCenter
		font.pixelSize: Theme.geometry_boatPage_motorDriveDcConsumption_pixelSize
		value: motorDriveDcConsumption.numerator
		unit: motorDriveDcConsumption.unit
	}

	TemperatureGauge {
		anchors.horizontalCenter: parent.horizontalCenter
		width: childrenRect.width
		veQuickItem: _motorDriveTemperature
		unit: VenusOS.Units_Temperature_Celsius
		source: "qrc:/images/icon_engine_temp_32.svg"
	}

	VeQuickItem {
		id: _motorDriveTemperature

		uid: _motorDrive ? _motorDrive.serviceUid + "/Motor/Temperature" : ""
	}
}
