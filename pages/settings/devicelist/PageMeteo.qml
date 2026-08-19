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

	VeQuickItem {
		id: todaysYieldItem
		uid: bindPrefix + "/TodaysYield"
	}
	VeQuickItem {
		id: installationPowerItem
		uid: bindPrefix + "/InstallationPower"
	}
	VeQuickItem {
		id: windDirectionItem
		uid: bindPrefix + "/WindDirection"
	}
	VeQuickItem {
		id: windSpeedItem
		uid: bindPrefix + "/WindSpeed"
	}
	VeQuickItem {
		id: externalTemperature2Item
		uid: bindPrefix + "/ExternalTemperature2"
	}
	VeQuickItem {
		id: externalTemperatureItem
		uid: bindPrefix + "/ExternalTemperature"
	}
	VeQuickItem {
		id: cellTemperatureItem
		uid: bindPrefix + "/CellTemperature"
	}

	serviceUid: bindPrefix

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			id: errorCodeDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/ErrorCode" }
			preferredVisible: errorCodeDC.dataItem.valid && (configStatus === 2 || configStatus === 3)
			ListLink {
				//% "Configuration required"
				text: qsTrId("page_meteo_configuration_required")
				url: "https://ve3.nl/solarsense"
				// Check bits 26-27 of ErrorCode for Configuration Incomplete status
				// 0=Unsupported, 1=OK, 2=Warning, 3=Alarm
				property int configStatus: errorCode.valid ? ((errorCode.value >> 26) & 0x3) : 1
				//: %1 = url text
				//% "Setup is needed for power estimation. For instructions, open the QR code to scan it with your portable device.<br />Or insert the link: %1"
				caption: qsTrId("page_meteo_config_caption").arg(formattedUrl)

				VeQuickItem {
					id: errorCode
					uid: root.bindPrefix + "/ErrorCode"
				}
			}
		}

		DelegateComponent {
			ListQuantity {
				property var displayText: Units.getDisplayText(VenusOS.Units_WattsPerSquareMetre, dataItem.value, 1)
				//% "Irradiance"
				text: qsTrId("page_meteo_irradiance")
				dataItem.uid: bindPrefix + "/Irradiance"
				value: Units.getDisplayText(VenusOS.Units_WattsPerSquareMetre, dataItem.value, 1).number
				unit: VenusOS.Units_WattsPerSquareMetre
				decimals: 1
			}
		}

		DelegateComponent {
			preferredVisible: cellTemperatureItem.valid
			ListTemperature {
				//% "Cell temperature"
				text: qsTrId("page_meteo_cell_temperature")
				dataItem.uid: bindPrefix + "/CellTemperature"
				decimals: 1
			}
		}

		DelegateComponent {
			preferredVisible: externalTemperatureItem.valid
			ListTemperature {
				text: externalTemperature2Item.valid
					//% "External temperature (1)"
					? qsTrId("page_meteo_external_temperature_1")
					//% "External temperature"
					: qsTrId("page_meteo_external_temperature")
				dataItem.uid: bindPrefix + "/ExternalTemperature"
				decimals: 1
			}
		}

		DelegateComponent {
			preferredVisible: externalTemperature2Item.valid
			ListTemperature {
				id: sensor2

				dataItem.uid: bindPrefix + "/ExternalTemperature2"
				//% "External temperature (2)"
				text: qsTrId("page_meteo_external_temperature_2")
				decimals: 1
			}
		}

		DelegateComponent {
			preferredVisible: windSpeedItem.valid
			ListQuantity {
				dataItem.uid: bindPrefix + "/WindSpeed"
				//% "Wind speed"
				text: qsTrId("page_meteo_wind_speed")
				unit: VenusOS.Units_Speed_MetresPerSecond
				decimals: 1
			}
		}

		DelegateComponent {
			preferredVisible: windDirectionItem.valid
			ListQuantity {
				dataItem.uid: bindPrefix + "/WindDirection"
				//% "Wind direction"
				text: qsTrId("page_meteo_wind_direction")
				unit: VenusOS.Units_CardinalDirection
			}
		}

		DelegateComponent {
			preferredVisible: installationPowerItem.valid
			ListQuantity {
				dataItem.uid: bindPrefix + "/InstallationPower"
				//% "Estimated power"
				text: qsTrId("page_meteo_estimated_power")
				unit: VenusOS.Units_Watt
				decimals: 1
			}
		}

		DelegateComponent {
			preferredVisible: todaysYieldItem.valid
			ListQuantity {
				dataItem.uid: bindPrefix + "/TodaysYield"
				//% "Today's yield"
				text: qsTrId("page_meteo_daily_yield")
				unit: VenusOS.Units_Energy_KiloWattHour
				decimals: 1
			}
		}

		DelegateComponent {
			preferredVisible: root.device.productId === ProductInfo.ProductId_MeteoSensor_Imt
			ListNavigation {
				id: settingsMenu

				text: CommonWords.settings
				onClicked: Global.pageManager.pushPage("/pages/settings/devicelist/PageMeteoSettings.qml", {
					title: CommonWords.settings,
					meteoSettingsPrefix: root.settingsPrefix
				})
			}
		}
	}
}