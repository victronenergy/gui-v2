/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	readonly property int displayUnit: {
		switch (Global.systemSettings.speedUnit) {
			case VenusOS.Units_Speed_MilesPerHour:
				return VenusOS.Units_Mile;
			case VenusOS.Units_Speed_Knots:
				return VenusOS.Units_Nautical_Mile;
			case VenusOS.Units_Speed_MetresPerSecond:
			case VenusOS.Units_Speed_KilometresPerHour:
			default:
				return VenusOS.Units_Kilometre;
		}
	}
	visible: rangeItem.valid

	VeQuickItem {
		id: rangeItem

		uid: Global.system.serviceUid ? Global.system.serviceUid + "/MotorDrive/Range" : ""
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Kilometre)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}

	Label {
		anchors.horizontalCenter: parent.horizontalCenter
		font.pixelSize: Theme.font_boatPage_range_label_pixelSize
		color: Theme.color_font_secondary
		//% "Range"
		text: qsTrId("boat_page_range_label")
	}

	QuantityLabel {
		anchors.horizontalCenter: parent.horizontalCenter
		font.pixelSize: Theme.font_boatPage_range_value_pixelSize
		value: rangeItem.valid ? rangeItem.value : 0
		unit: root.displayUnit
		formatHints: Units.NoScaling
	}
}
