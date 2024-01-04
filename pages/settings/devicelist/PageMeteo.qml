/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

Page {
	id: root

	property string bindPrefix
	readonly property string settingsPrefix: Global.systemSettings.serviceUid + "/Settings/Service/meteo/" + deviceInstance.value

	VeQuickItem {
		id: deviceInstance

		uid: bindPrefix + "/DeviceInstance"
	}

	GradientListView {
		model: ObjectModel {

			ListQuantityItem {
				property var displayText: Units.getDisplayText(VenusOS.Units_WattsPerSquareMeter, dataItem.value, 1)
				//% "Irradiance"
				text: qsTrId("page_meteo_irradiance")
				dataItem.uid: bindPrefix + "/Irradiance"
				value: Units.getDisplayText(VenusOS.Units_WattsPerSquareMeter, dataItem.value, 1).number
				unit: VenusOS.Units_WattsPerSquareMeter
				precision: 1
			}

			ListTemperatureItem {
				//% "Cell temperature"
				text: qsTrId("page_meteo_cell_temperature")
				dataItem.uid: bindPrefix + "/CellTemperature"
			}

			ListTemperatureItem {
				text: sensor2.dataItem.isValid ?
						  //% "External temperature (1)"
						  qsTrId("page_meteo_external_temperature_1") :
						  //% "External temperature"
						  qsTrId("page_meteo_external_temperature")
				dataItem.uid: bindPrefix + "/ExternalTemperature"
			}

			ListTemperatureItem {
				id: sensor2

				dataItem.uid: bindPrefix + "/ExternalTemperature2"
				//% "External temperature (2)"
				text: qsTrId("page_meteo_external_temperature_2")
				visible: dataItem.isValid
			}

			ListQuantityItem {
				dataItem.uid: bindPrefix + "/WindSpeed"
				//% "Wind speed"
				text: qsTrId("page_meteo_wind_speed")
				visible: dataItem.isValid
				value: dataItem.value
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
