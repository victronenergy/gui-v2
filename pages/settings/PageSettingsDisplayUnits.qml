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

		model: VisibleItemModel {
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

			SettingsListHeader {
				//: GPS units
				//% "GPS"
				text: qsTrId("settings_units_gps")
			}

			ListRadioButtonGroup {
				//: Format of reported GPS data
				//% "Format"
				text: qsTrId("settings_gps_format")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gps/Format"
				optionModel: [
					//: Example of GPS data in the 'Degrees, Minutes, Seconds' format
					//% "52° 20' 41.6\" N, 5° 13' 12.3\" E"
					{ display: qsTrId("settings_gps_format_dms_example"), value: VenusOS.GpsData_Format_DegreesMinutesSeconds },
					//: Example of GPS data in the 'Decimal Degrees' format
					//% "52.34489, 5.22008"
					{ display: qsTrId("settings_gps_format_dd_example"), value: VenusOS.GpsData_Format_DecimalDegrees },
					//: Example of GPS data in the 'Degrees Minutes' format
					//% "52° 20.693 N, 5° 13.205 E"
					{ display: qsTrId("settings_gps_format_dm_example"), value: VenusOS.GpsData_Format_DegreesMinutes },
				]
			}

			ListRadioButtonGroup {
				//: Speed unit for reported GPS data
				//% "Speed Unit"
				text: qsTrId("settings_gps_speed_unit")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gps/SpeedUnit"
				optionModel: [
					//% "Kilometers per hour"
					{ display: qsTrId("settings_gps_format_kmh"), value: "km/h" },
					//% "Meters per second"
					{ display: qsTrId("settings_gps_format_ms"), value: "m/s" },
					//% "Miles per hour"
					{ display: qsTrId("settings_gps_format_mph"), value: "mph" },
					//% "Knots"
					{ display: qsTrId("settings_gps_format_kt"), value: "kt" },
				]
			}
		}
	}
}
