/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils
import Victron.Units

Page {
	id: root

	property string meteoSettingsPrefix
	readonly property var optionModel: [
		{ display: CommonWords.enabled, value: "enabled" },
		{ display: CommonWords.disabled, value: "disabled" },
		//% "Auto-detect"
		{ display: qsTrId("page_meteo_settings_auto_detect"), value: "auto-detect" },
	]

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				//% "Wind speed sensor"
				text: qsTrId("page_meteo_settings_wind_speed_sensor")
				dataItem.uid: meteoSettingsPrefix + "/WindSpeedSensor"
				optionModel: root.optionModel
			}

			ListRadioButtonGroup {
				//% "External temperature sensor"
				text: qsTrId("page_meteo_settings_external_temperature_sensor")
				dataItem.uid: meteoSettingsPrefix + "/ExternalTemperatureSensor"
				optionModel: root.optionModel
			}
		}
	}
}
