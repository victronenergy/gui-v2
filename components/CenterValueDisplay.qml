/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	required property int gaugeCount
	required property real maximumWidth
	readonly property bool isTemperature: _valueDevice.isValid && BackendConnection.serviceTypeFromUid(_valueDevice.value) === "temperature"

	property alias icon: icon
	property alias label: label
	property alias quantity: quantity

	implicitWidth: label.visible ? Math.max(icon.width + label.width, quantity.width) : quantity.width
	implicitHeight: label.visible ? icon.height + quantity.height : quantity.height
	visible: (!root._valueDisplay.isValid || (root.gaugeCount <= root._valueDisplay.value)) && (_device.isValid && !isNaN(_device.value))

	property VeQuickItem _valueDisplay: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/CenterValueDisplay"
	}

	property VeQuickItem _labelDisplay: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/CenterValueLabelDisplay"
	}

	property VeQuickItem _valueDevice: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/CenterValueDevice"
	}

	property VeQuickItem _device: VeQuickItem {
		uid: _valueDevice.value + "/" + (root.isTemperature ? "Temperature" : "Soc")
	}

	CP.ColorImage {
		id: icon
		anchors.right: label.left
		width: Theme.geometry_icon_size_small
		height: Theme.geometry_icon_size_small
		visible: label.visible
		color: Theme.color_font_primary
		source: root.isTemperature ? "qrc:/images/icon_temp_32.svg" : "qrc:/images/icon_battery_24.svg"
	}
	Label {
		id: label
		anchors {
			// usually, center the label over the quantity,
			// except when there is only one gauge or the quantity only has 1 digit
			// in which case take icon width into account (i.e. properly centered).
			horizontalCenterOffset: (root.gaugeCount == 1 || quantity.valueText.length <= 1) ? icon.width/2 : 0
			horizontalCenter: quantity.horizontalCenter
			verticalCenter: icon.verticalCenter
		}
		visible: !root._labelDisplay.isValid || (root.gaugeCount <= root._labelDisplay.value)
		font.pixelSize: (root.isTemperature && gaugeCount > 2) ? Theme.font_size_body1 : Theme.font_size_body2
		color: Theme.color_font_primary
		text: root.isTemperature ? CommonWords.temperature : CommonWords.battery
		width: Math.min(implicitWidth, root.maximumWidth)
		elide: Text.ElideRight
	}
	QuantityLabel {
		id: quantity
		anchors {
			top: icon.visible ? icon.bottom : parent.top
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: root.isTemperature && gaugeCount > 2 ? Theme.font_briefPage_battery_percentage_pixelSize - 12
			: root.isTemperature && gaugeCount > 1 ? Theme.font_briefPage_battery_percentage_pixelSize - 8 // temperature units takes lots of space.
			: gaugeCount <= 2 ? Theme.font_briefPage_battery_percentage_pixelSize + 4 // larger font size if we have more space.
			: valueText.length < 3 ? Theme.font_briefPage_battery_percentage_pixelSize // default font size.
			: Theme.font_briefPage_battery_percentage_pixelSize - 8 // 5-inch "100%" fits with this font size with 3 gauges.
		unit: root.isTemperature ? Global.systemSettings.temperatureUnit : VenusOS.Units_Percentage
		value: !root._device.isValid ? NaN
			: root.isTemperature ? Global.systemSettings.convertFromCelsius(root._device.value)
			: root._device.value
	}
}
