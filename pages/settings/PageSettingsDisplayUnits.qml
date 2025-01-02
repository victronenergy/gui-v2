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

			ListVolumeUnitRadioButtonGroup {
				//: Title for a list of units of volume (e.g. cubic meters, liters, gallons)
				//% "Volume"
				text: qsTrId("components_volumeunit_volume")
			}

			ListRadioButtonGroup {
				//% "Electrical power display"
				text: qsTrId("settings_units_energy")

				optionModel: [
					//% "Power (Watts)"
					{ display: qsTrId("settings_units_watts"), value: VenusOS.Units_Watt },
					{
						//% "Current (Amps)"
						display: qsTrId("settings_units_amps"),
						value: VenusOS.Units_Amp,
						//% "Note: If current cannot be displayed (for example, when showing a total for combined AC and DC sources) then power will be shown instead."
						caption: qsTrId("settings_units_amps_exceptions"),
					},
				]
				currentIndex: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp ? 1 : 0

				onOptionClicked: function(index) {
					Global.systemSettings.setElectricalQuantity(optionModel[index].value)
				}
			}
		}
	}
}
