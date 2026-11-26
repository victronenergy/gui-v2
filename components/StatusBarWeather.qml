/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays the VRM weather and temperature, or local temperature.

	- When the vrm service provides the weather condition and temperature, this shows the condition
	  (as an icon) and the temperature. If the data is more than an hour old, the icon and number
	  are faded.
	- Otherwise, if an outdoor temperature sensor is available, this shows a thermometer icon and
	  the sensor's temperature.
*/
Item {
	id: root

	readonly property bool active: icon.status !== Image.Null

	readonly property bool hasVrmWeather: Services.vrm.heartbeat > 0
			&& Services.vrm.weatherCondition !== VenusOS.WeatherCondition_Unknown

	implicitWidth: weatherLayout.implicitWidth
	implicitHeight: weatherLayout.implicitHeight

	RowLayout {
		id: weatherLayout

		anchors.centerIn: parent
		spacing: Theme.geometry_statusBar_spacing_small

		CP.ColorImage {
			id: icon

			source: root.hasVrmWeather ? VenusOS.weather_conditionToIcon(Services.vrm.weatherCondition)
					: outdoorTemperatureServices.count > 0 ? "qrc:/images/icon_temp_32.svg"
					: ""
			color: root.hasVrmWeather && (ClockTime.clockTime - Services.vrm.heartbeat) > (60 * 60)
					? Theme.color_font_secondary // We have VRM weather, but it's over an hour old.
					: Theme.color_font_primary

			FilteredDeviceModel {
				id: outdoorTemperatureServices
				serviceTypes: ["temperature"]
				childFilterIds: { "temperature": ["TemperatureType"] }
				childFilterFunction: (device, childItems) => {
					return childItems["TemperatureType"]?.value === VenusOS.Temperature_DeviceType_Outdoor
				}
			}
		}

		QuantityLabel {
			value: temperature.value ?? NaN
			unit: Services.settings.temperatureUnit
			valueColor: icon.color
			unitColor: icon.color
			formatHints: Units.CompactUnitFormat
			font.pixelSize: Theme.font_size_body2

			VeQuickItem {
				id: temperature
				uid: root.hasVrmWeather ? Services.vrm.serviceUid + "/Weather/Temperature"
						: outdoorTemperatureServices.firstObject ? outdoorTemperatureServices.firstObject.serviceUid + "/Temperature"
						: ""
				sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
				displayUnit: Units.unitToVeUnit(Services.settings.temperatureUnit)
			}
		}
	}
}