/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Item {
	id: root

	property bool showFullDetails

	visible: centerService.value !== "none"

	readonly property bool _useTemperature: BackendConnection.portableIdInfo(centerService.value).type === "temperature"

	VeQuickItem {
		id: centerService
		uid: Services.settings.serviceUid + "/Settings/Gui2/BriefView/CenterService"
	}

	VeQuickItem {
		id: temperature
		uid: {
			if (root._useTemperature) {
				const idInfo = BackendConnection.portableIdInfo(centerService.value)
				const model = Services.environment.model
				// deviceForDeviceInstance() is not bindable, so depend on count to re-evaluate
				// when the device is added to (or removed from) the model.
				const count = model.count
				const device = model.deviceForDeviceInstance(idInfo.instance)
				if (device) {
					return device.serviceUid + "/Temperature"
				}
			}
			return ""
		}
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Services.settings.temperatureUnit)
	}

	Row {
		anchors {
			bottom: centerLabel.top
			bottomMargin: Theme.geometry_briefPage_centerGauge_centerText_verticalMargin
			horizontalCenter: parent.horizontalCenter
			horizontalCenterOffset: -(icon.width / 4) // cancel out the icon's internal whitespace
		}
		visible: root.showFullDetails

		CP.ColorImage {
			id: icon

			source: Services.system.battery.icon
			color: Theme.color_font_primary
		}

		Label {
			// Keep the name bounding box inside the circle to avoid truncation
			width: Math.min(implicitWidth, 0.6 * (root.width - icon.width))
			anchors.verticalCenter: icon.verticalCenter
			minimumPixelSize: Theme.font_briefPage_battery_title_minimumPixelSize
			font.pixelSize: Theme.font_briefPage_battery_title_maximumPixelSize
			color: Theme.color_font_primary
			text: CommonWords.battery
			fontSizeMode: Text.HorizontalFit
		}
	}

	FittedQuantityLabel {
		id: centerLabel

		readonly property bool _displayCenterTemperature: root._useTemperature && temperature.valid && temperature.value !== null

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		width: parent.width - (2 * Theme.geometry_briefPage_centerGauge_centerText_horizontalSpacing)
		unit: _displayCenterTemperature && !root.showFullDetails ? Services.settings.temperatureUnit : VenusOS.Units_Percentage
		value: _displayCenterTemperature && !root.showFullDetails ? (temperature.value ?? NaN) : Services.system.battery.stateOfCharge
		minimumPixelSize: Theme.font_briefPage_battery_percentage_minimumPixelSize
		maximumPixelSize: Theme.font_briefPage_battery_percentage_maximumPixelSize
	}

	Loader {
		anchors {
			top: centerLabel.bottom
			topMargin: Theme.geometry_briefPage_centerGauge_centerText_verticalMargin
			horizontalCenter: parent.horizontalCenter
		}
		width: parent.width
		height: active ? implicitHeight : 0
		active: root.showFullDetails && temperature.valid && temperature.value !== null

		sourceComponent: Column {
			spacing: Theme.geometry_briefPage_centerGauge_temperature_spacing

			SeparatorBar {
				anchors.horizontalCenter: parent.horizontalCenter
				width: centerLabelMetrics.width
				height: Theme.geometry_briefPage_centerGauge_separator_height

				TextMetrics {
					id: centerLabelMetrics
					font.family: centerLabel.font.family
					font.pixelSize: centerLabel.font.pixelSize
					text: "100%"
				}
			}

			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: Theme.geometry_briefPage_centerGauge_centerText_horizontalSpacing

				CP.ColorImage {
					anchors.verticalCenter: parent.verticalCenter
					source: "qrc:/images/icon_temp_32.svg"
					color: Theme.color_font_primary
				}

				QuantityLabel {
					anchors.verticalCenter: parent.verticalCenter
					valueColor: Theme.color_briefPage_temperature_value_text_color
					unitColor: Theme.color_briefPage_temperature_unit_text_color
					font.pixelSize: Theme.font_briefPage_temperature_pixelSize
					unit: Services.settings.temperatureUnit
					value: temperature.value
				}
			}
		}
	}
}
