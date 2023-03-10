/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
	id: root

	listView: GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListRadioButtonGroup {
				//% "Energy"
				text: qsTrId("settings_units_energy")

				optionModel: [
					//% "Watts"
					{ display: qsTrId("settings_units_watts"), value: VenusOS.Units_Energy_Watt },
					//% "Amps"
					{ display: qsTrId("settings_units_amps"), value: VenusOS.Units_Energy_Amp },
				]
				listPage: root
				listIndex: ObjectModel.index
				currentIndex: Global.systemSettings.energyUnit.value === VenusOS.Units_Energy_Amp ? 1 : 0

				onOptionClicked: function(index) {
					Global.systemSettings.energyUnit.setValue(optionModel[index].value)
				}
			}

			ListRadioButtonGroup {
				//% "Temperature"
				text: qsTrId("settings_units_temperature")

				optionModel: [
					//% "Celsius"
					{ display: qsTrId("settings_units_celsius"), value: VenusOS.Units_Temperature_Celsius },
					//% "Fahrenheit"
					{ display: qsTrId("settings_units_fahrenheit"), value: VenusOS.Units_Temperature_Fahrenheit },
				]
				listPage: root
				listIndex: ObjectModel.index
				currentIndex: Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Fahrenheit ? 1 : 0

				onOptionClicked: function(index) {
					Global.systemSettings.temperatureUnit.setValue(optionModel[index].value)
				}
			}

			ListRadioButtonGroup {
				//% "Volume"
				text: qsTrId("settings_units_volume")

				optionModel: [
					//% "m3"
					{ display: qsTrId("settings_units_m3"), value: VenusOS.Units_Volume_CubicMeter },
					//% "Liters"
					{ display: qsTrId("settings_units_liters"), value: VenusOS.Units_Volume_Liter },
					//% "Gallons (US)"
					{ display: qsTrId("settings_units_gallons_us"), value: VenusOS.Units_Volume_GallonUS },
					//% "Gallons (Imperial)"
					{ display: qsTrId("settings_units_gallons_imperial"), value: VenusOS.Units_Volume_GallonImperial },
				]
				listPage: root
				listIndex: ObjectModel.index
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
