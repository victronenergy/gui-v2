/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListRadioButtonGroup {
				//% "Electrical power display"
				text: qsTrId("settings_units_energy")

				optionModel: [
					//% "Power (Watts)"
					{ display: qsTrId("settings_units_watts"), value: VenusOS.Units_Watt },
					//% "Current (Amps)"
					{ display: qsTrId("settings_units_amps"), value: VenusOS.Units_Amp },
				]
				currentIndex: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp ? 1 : 0

				onOptionClicked: function(index) {
					Global.systemSettings.setElectricalQuantity(optionModel[index].value)
				}
			}

			ListRadioButtonGroup {
				text: CommonWords.temperature
				optionModel: [
					//% "Celsius"
					{ display: qsTrId("settings_units_celsius"), value: VenusOS.Units_Temperature_Celsius },
					//% "Fahrenheit"
					{ display: qsTrId("settings_units_fahrenheit"), value: VenusOS.Units_Temperature_Fahrenheit },
				]
				currentIndex: Global.systemSettings.temperatureUnit === VenusOS.Units_Temperature_Fahrenheit ? 1 : 0

				onOptionClicked: function(index) {
					Global.systemSettings.setTemperatureUnit(optionModel[index].value)
				}
			}

			VolumeUnitRadioButtonGroup { }
		}
	}
}
