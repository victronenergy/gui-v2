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

			ListQuantityItem {
				property var displayText: Units.getDisplayText(VenusOS.Units_WattsPerSquareMeter, dataValue, 1)
				//% "Irradiance"
				text: qsTrId("page_meteo_irradiance")
				dataSource: bindPrefix + "/Irradiance"
				value: Units.getDisplayText(VenusOS.Units_WattsPerSquareMeter, dataValue, 1).number
				unit: VenusOS.Units_WattsPerSquareMeter
				precision: 1
			}

			ListTemperatureItem {
				//% "Cell temperature"
				text: qsTrId("page_meteo_cell_temperature")
				dataSource: bindPrefix + "/CellTemperature"
			}

			ListTemperatureItem {
				text: sensor2.dataValid ?
						  //% "External temperature (1)"
						  qsTrId("page_meteo_external_temperature_1") :
						  //% "External temperature"
						  qsTrId("page_meteo_external_temperature")
				dataSource: bindPrefix + "/ExternalTemperature"
			}

			ListTemperatureItem {
				id: sensor2

				dataSource: bindPrefix + "/ExternalTemperature2"
				//% "External temperature (2)"
				text: qsTrId("page_meteo_external_temperature_2")
				visible: dataValid
			}

			ListQuantityItem {
				dataSource: bindPrefix + "/WindSpeed"
				//% "Wind speed"
				text: qsTrId("page_meteo_wind_speed")
				visible: dataValid
				value: dataValue
				unit: VenusOS.Units_Speed_MetresPerSecond
				precision: 1
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
