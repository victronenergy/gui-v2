/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

Page {
	id: root

	property string bindPrefix
	readonly property string settingsPrefix: "com.victronenergy.settings/Settings/Service/meteo/" + deviceInstance.value

	DataPoint {
		id: deviceInstance

		source: bindPrefix + "/DeviceInstance"
	}

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "Irradiance"
				text: qsTrId("page_meteo_irradiance")
				secondaryText: Units.getCombinedDisplayText(VenusOS.Units_WattsPerSquareMeter, dataValue, 1)
				dataSource: bindPrefix + "/Irradiance"
			}

			ListTextItem {
				readonly property real temperature: Units.convertFromCelsius(dataValue, Global.systemSettings.temperatureUnit.value)

				dataSource: bindPrefix + "/CellTemperature"
				//% "Cell temperature"
				text: qsTrId("page_meteo_cell_temperature")
				secondaryText: Units.getCombinedDisplayText(Global.systemSettings.temperatureUnit.value, temperature, 1)
			}

			ListTextItem {
				readonly property real temperature: Units.convertFromCelsius(dataValue, Global.systemSettings.temperatureUnit.value)

				dataSource: bindPrefix + "/ExternalTemperature"
				text: sensor2.dataValid ?
						  //% "External temperature (1)"
						  qsTrId("page_meteo_external_temperature_1") :
						  //% "External temperature"
						  qsTrId("page_meteo_external_temperature")
				secondaryText: Units.getCombinedDisplayText(Global.systemSettings.temperatureUnit.value, temperature, 1) //displayText.number + displayText.unit
			}

			ListTextItem {
				id: sensor2

				dataSource: bindPrefix + "/ExternalTemperature2"
				//% "External temperature (2)"
				text: qsTrId("page_meteo_external_temperature_2")
				visible: dataValid
			}

			ListTextItem {
				dataSource: bindPrefix + "/WindSpeed"
				//% "Wind speed"
				text: qsTrId("page_meteo_wind_speed")
				secondaryText: Units.getCombinedDisplayText(VenusOS.Units_Speed_MetresPerSecond, dataValue, 1)
				visible: dataValid
			}

			ListNavigationItem {
				id: settingsMenu

				text: CommonWords.settings
				onClicked: Global.pageManager.pushPage("/pages/settings/devicelist/PageMeteoSettings.qml", {
														   "title": CommonWords.settings,
														   meteoSettingsPrefix: root.settingsPrefix
													   })
			}
		}
	}
}
