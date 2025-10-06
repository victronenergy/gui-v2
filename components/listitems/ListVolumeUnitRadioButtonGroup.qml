/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	//% "Volume unit"
	text: qsTrId("components_volumeunit_title")
	writeAccessLevel: VenusOS.User_AccessType_User
	optionModel: [
		//% "Cubic metres"
		{ display: qsTrId("components_volumeunit_cubic_metres"), value: VenusOS.Units_Volume_CubicMetre },
		//% "Litres"
		{ display: qsTrId("components_volumeunit_litres"), value: VenusOS.Units_Volume_Litre },
		//% "Gallons (US)"
		{ display: qsTrId("components_volumeunit_gallons_us"), value: VenusOS.Units_Volume_GallonUS },
		//% "Gallons (Imperial)"
		{ display: qsTrId("components_volumeunit_gallons_imperial"), value: VenusOS.Units_Volume_GallonImperial },
	]
	currentIndex: Global.systemSettings.volumeUnit === VenusOS.Units_Volume_Litre
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
