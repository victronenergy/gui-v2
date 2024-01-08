/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	//: Title for a list of units of volume (e.g. cubic meters, liters, gallons)
	//% "Volume"
	text: qsTrId("components_volumeunit_volume")

	optionModel: [
		//% "Cubic meters"
		{ display: qsTrId("components_volumeunit_cubic_meters"), value: VenusOS.Units_Volume_CubicMeter },
		//% "Liters"
		{ display: qsTrId("components_volumeunit_liters"), value: VenusOS.Units_Volume_Liter },
		//% "Gallons (US)"
		{ display: qsTrId("components_volumeunit_gallons_us"), value: VenusOS.Units_Volume_GallonUS },
		//% "Gallons (Imperial)"
		{ display: qsTrId("components_volumeunit_gallons_imperial"), value: VenusOS.Units_Volume_GallonImperial },
	]
	currentIndex: Global.systemSettings.volumeUnit === VenusOS.Units_Volume_Liter
			? 1
			: Global.systemSettings.volumeUnit === VenusOS.Units_Volume_GallonUS
			  ? 2
			  : Global.systemSettings.volumeUnit === VenusOS.Units_Volume_GallonImperial
				? 3
				: 0

	onOptionClicked: function(index) {
		Global.systemSettings.setVolumeUnit(optionModel[index].value)
	}
}
