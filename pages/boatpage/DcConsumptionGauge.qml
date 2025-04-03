/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.BoatPageComponents as BoatPageComponents
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Row {
	id: root

	required property VeQuickItemsQuotient motorDriveDcConsumption
	readonly property bool showMotorDrive: motorDriveDcConsumption && !isNaN(motorDriveDcConsumption.numerator)
	readonly property var _battery: Global.system && Global.system.battery ? Global.system.battery : null

	spacing: Theme.geometry_boatPage_powerRow_spacing

	QuantityLabel {
		id: dcConsumptionLabel

		anchors.verticalCenter: parent.verticalCenter
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.geometry_boatPage_batterySoc_pixelSize
		value: root.showMotorDrive
			   ? motorDriveDcConsumption.numerator
			   : _battery
				 ? _battery.dcConsumption.value
				 : NaN
		unit: root.showMotorDrive
			  ? motorDriveDcConsumption.unit
			  : _battery
				? _battery.dcConsumption.unit
				: VenusOS.Units_None
	}

	CP.ColorImage {
		id: dcConsumptionImage

		anchors {
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_propeller_verticalCenterOffset
		}
		width: Theme.geometry_boatPage_batteryGauge_iconWidth
		height: width
		color: Theme.color_boatPage_icon
		source: root.showMotorDrive ? "qrc:/images/icon_propeller_32.svg" : "qrc:/images/icon_battery_40.png"
	}
}

