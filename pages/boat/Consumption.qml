/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	readonly property bool useWatt: Global.systemSettings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_PreferWatts || Global.systemSettings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_Mixed
	readonly property int sourceUnit: root.useWatt ? VenusOS.Units_WattHourPerKilometre : VenusOS.Units_AmpHourPerKilometre
	readonly property int displayUnit: {
		if (root.useWatt) {
			switch (Global.systemSettings.speedUnit) {
				case VenusOS.Units_Speed_MilesPerHour:
					return VenusOS.Units_WattHourPerMile;
				case VenusOS.Units_Speed_Knots:
					return VenusOS.Units_WattHourPerNauticalMile;
				case VenusOS.Units_Speed_KilometresPerHour:
				case VenusOS.Units_Speed_MetresPerSecond:
				default:
					return VenusOS.Units_WattHourPerKilometre;
			}
		} else {
			switch (Global.systemSettings.speedUnit) {
				case VenusOS.Units_Speed_MilesPerHour:
					return VenusOS.Units_AmpHourPerMile;
				case VenusOS.Units_Speed_Knots:
					return VenusOS.Units_AmpHourPerNauticalMile;
				case VenusOS.Units_Speed_KilometresPerHour:
				case VenusOS.Units_Speed_MetresPerSecond:
				default:
					return VenusOS.Units_AmpHourPerKilometre;
			}
		}
	}
	visible: consumptionItem.valid

	VeQuickItem {
		id: consumptionItem

		uid: Global.system.serviceUid ? Global.system.serviceUid + "/MotorDrive/" + (root.useWatt ? "ConsumptionWhkm" : "ConsumptionAhkm") : ""
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}

	Label {
		anchors.right: parent.right
		font.pixelSize: Theme.font_boatPage_consumption_label_pixelSize
		color: Theme.color_font_secondary
		//% "Consumption"
		text: qsTrId("boat_page_consumption_label")
	}

	QuantityLabel {
		anchors.right: parent.right
		font.pixelSize: Theme.font_boatPage_consumption_value_pixelSize
		value: consumptionItem.valid ? consumptionItem.value : 0
		unit: root.displayUnit
		unitColor: Theme.color_font_secondary
		formatHints: Units.NoScaling
	}
}
