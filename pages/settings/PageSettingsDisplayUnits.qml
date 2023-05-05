/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListRadioButtonGroup {
				//% "Temperature"
				text: qsTrId("settings_units_temperature")

				optionModel: [
					//% "Celsius"
					{ display: qsTrId("settings_units_celsius"), value: VenusOS.Units_Temperature_Celsius },
					//% "Fahrenheit"
					{ display: qsTrId("settings_units_fahrenheit"), value: VenusOS.Units_Temperature_Fahrenheit },
				]
				currentIndex: Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Fahrenheit ? 1 : 0

				onOptionClicked: function(index) {
					Global.systemSettings.temperatureUnit.setValue(optionModel[index].value)
				}
			}

			ListRadioButtonGroup {
				//% "Volume"
				text: qsTrId("settings_units_volume")

				optionModel: [
					//% "Cubic meters"
					{ display: qsTrId("settings_units_cubic_meters"), value: VenusOS.Units_Volume_CubicMeter },
					//% "Liters"
					{ display: qsTrId("settings_units_liters"), value: VenusOS.Units_Volume_Liter },
					//% "Gallons (US)"
					{ display: qsTrId("settings_units_gallons_us"), value: VenusOS.Units_Volume_GallonUS },
					//% "Gallons (Imperial)"
					{ display: qsTrId("settings_units_gallons_imperial"), value: VenusOS.Units_Volume_GallonImperial },
				]
				currentIndex: Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_Liter
						? 1
						: Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_GallonUS
						  ? 2
						  : Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_GallonImperial
							? 3
							: 0

				onOptionClicked: function(index) {
					Global.systemSettings.volumeUnit.setValue(optionModel[index].value)
				}
			}
		}
	}
}
