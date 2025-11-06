/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a meteo device.
*/
DevicePage {
	id: root

	property string bindPrefix
	readonly property string settingsPrefix: Global.systemSettings.serviceUid + "/Settings/Service/meteo/" + device.deviceInstance

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
		ListQuantity {
			property var displayText: Units.getDisplayText(VenusOS.Units_WattsPerSquareMetre, dataItem.value, 1)
			//% "Irradiance"
			text: qsTrId("page_meteo_irradiance")
			dataItem.uid: bindPrefix + "/Irradiance"
			value: Units.getDisplayText(VenusOS.Units_WattsPerSquareMetre, dataItem.value, 1).number
			unit: VenusOS.Units_WattsPerSquareMetre
			precision: 1
		}

		ListTemperature {
			//% "Cell temperature"
			text: qsTrId("page_meteo_cell_temperature")
			preferredVisible: dataItem.valid
			dataItem.uid: bindPrefix + "/CellTemperature"
			precision: 1
		}

		ListTemperature {
			text: sensor2.dataItem.valid
				//% "External temperature (1)"
				? qsTrId("page_meteo_external_temperature_1")
				//% "External temperature"
				: qsTrId("page_meteo_external_temperature")
			preferredVisible: dataItem.valid
			dataItem.uid: bindPrefix + "/ExternalTemperature"
			precision: 1
		}

		ListTemperature {
			id: sensor2

			dataItem.uid: bindPrefix + "/ExternalTemperature2"
			//% "External temperature (2)"
			text: qsTrId("page_meteo_external_temperature_2")
			preferredVisible: dataItem.valid
			precision: 1
		}

		ListQuantity {
			dataItem.uid: bindPrefix + "/WindSpeed"
			//% "Wind speed"
			text: qsTrId("page_meteo_wind_speed")
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Speed_MetresPerSecond
			precision: 1
		}

		ListQuantity {
			dataItem.uid: bindPrefix + "/WindDirection"
			//% "Wind direction"
			text: qsTrId("page_meteo_wind_direction")
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_CardinalDirection
		}

		ListQuantity {
			dataItem.uid: bindPrefix + "/InstallationPower"
			//% "Estimated power"
			text: qsTrId("page_meteo_estimated_power")
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Watt
			precision: 1
		}

		ListQuantity {
			dataItem.uid: bindPrefix + "/TodaysYield"
			//% "Today's yield"
			text: qsTrId("page_meteo_daily_yield")
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Energy_KiloWattHour
			precision: 1
		}

		ListNavigation {
			id: settingsMenu

			text: CommonWords.settings
			onClicked: Global.pageManager.pushPage("/pages/settings/devicelist/PageMeteoSettings.qml", {
				title: CommonWords.settings,
				meteoSettingsPrefix: root.settingsPrefix
			})
			preferredVisible: root.device.productId === ProductInfo.ProductId_MeteoSensor_Imt
		}
	}
}
