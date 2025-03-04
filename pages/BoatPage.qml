/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

SwipeViewPage {
	id: root

	readonly property var battery: Global.system && Global.system.battery ? Global.system.battery : null
	readonly property var motorDrive: Global.allDevicesModel.motorDriveDevices.firstObject
	readonly property int direction: _direction.valid ? _direction.value : NaN
	property string activeGpsUid

	property VeQuickItemsQuotient gpsSpeed: VeQuickItemsQuotient {
		property string units: _speedUnits.valid ? _speedUnits.value : ""
		readonly property real value: {
			switch (units) {
			case "km/h":
				return numerator * 3.6
			case "mph":
				return numerator * 2.236936
			case "kt":
				return numerator * (3600/1852)
			default: // meters per second
				return numerator
			}
		}

		property VeQuickItem _speedUnits : VeQuickItem {
			uid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gps/SpeedUnit" : ""
		}
		objectName: "gpsSpeed"
		numeratorUid: activeGpsUid ? activeGpsUid + "/Speed" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Speed/Max" : ""
		denominator: 20 // TODO - remove this once platform supports max speed
		unit: VenusOS.Units_Speed_MetresPerSecond
	}

	property VeQuickItemsQuotient motorDriveRpm: VeQuickItemsQuotient {
		objectName: "motorDriveRpm"
		numeratorUid: motorDrive ? motorDrive.serviceUid + "/Motor/RPM" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Motordrive/Rpm/Max" : ""
		denominator: 5000 // TODO - remove this once platform supports max rpm
		unit: VenusOS.Units_RevolutionsPerMinute
	}

	property VeQuickItemsQuotient motorDrivePower: VeQuickItemsQuotient {
		objectName: "motorDrivePower"
		numeratorUid: motorDrive ? motorDrive.serviceUid + "/Dc/0/Power" : ""
		denominatorUid : Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Motordrive/DC/Power/Max" : ""
		denominator: 8000 // TODO - remove this once platform supports max power
		unit: VenusOS.Units_Watt
	}

	property VeQuickItemsQuotient motorDriveCurrent: VeQuickItemsQuotient {
		objectName: "motorDriveCurrent"
		numeratorUid: motorDrive ? motorDrive.serviceUid + "/Dc/0/Current" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Motordrive/DC/Current/Max" : ""
		denominator: 8000 // TODO - remove this once platform supports max current
		unit: VenusOS.Units_Amp
	}

	readonly property VeQuickItemsQuotient motorDriveDcConsumption: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp && motorDriveCurrent.valid
																	? motorDriveCurrent
																	: motorDrivePower

	//% "Boat"
	navButtonText: qsTrId("nav_boat")
	navButtonIcon: "qrc:/images/icon_boat_32.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BoatPage.qml"
	backgroundColor: Theme.color_boatPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	VeQuickItem {
		id: _motorDriveTemperature

		uid: motorDrive ? motorDrive.serviceUid + "/Motor/Temperature" : ""
	}

	VeQuickItem {
		id: _motorDriveTemperatureDc0

		uid: motorDrive ? motorDrive.serviceUid + "/Dc/0/Temperature" : ""
	}

	VeQuickItem {
		id: _motorDriveControllerTemperature

		uid: motorDrive ? motorDrive.serviceUid + "/Controller/Temperature" : ""
	}

	VeQuickItem {
		id: _motorDriveCoolantTemperature

		uid: motorDrive ? motorDrive.serviceUid + "/Coolant/Temperature" : ""
	}

	VeQuickItem { //  0=neutral, 1=reverse, 2=forward (optional)
		id: _direction

		uid: motorDrive ? motorDrive.serviceUid + "/Motor/Direction" : ""
	}

	Instantiator { // There can be multiple GPSes, for v1 of boat page we just pick the first one we find and use that.
		model: Global.allDevicesModel.gpsDevices
		delegate: QtObject {
			property var qi: VeQuickItem {
				uid: modelData.serviceUid + "/Speed"
				onValueChanged: {
					if (!activeGpsUid && valid) {
						console.log(modelData.serviceUid, "is now the active gps")
						root.activeGpsUid = modelData.serviceUid
					}
				}
			}
		}
	}

	component Shadow : CP.ColorImage {
		width: Theme.geometry_boatPage_shadow_width
		height: Theme.geometry_boatPage_shadow_height
		source: "qrc:/images/boat_glow.png"
	}

	Shadow {
		id: shadowTopLeft

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_shadow_topRow_topMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_shadow_horizontalMargin
		}

		rotation: 180
	}

	Shadow {
		id: shadowBottomLeft

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_shadow_bottomRow_topMargin
			left: shadowTopLeft.left
		}
		mirror: true
	}

	Shadow {
		id: shadowTopRight
		anchors {
			top: shadowTopLeft.top
			right: parent.right
			rightMargin: Theme.geometry_boatPage_shadow_horizontalMargin
		}
		mirror: true
		rotation: 180
	}

	Shadow {
		id: shadowBottomRight
		anchors {
			bottom: shadowBottomLeft.bottom
			right: shadowTopRight.right
		}
	}

	SideGauge {
		id: batteryGauge

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_page_content_horizontalMargin
		}
		y: (root.Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height - height) / 2

		direction: PathArc.Clockwise
		startAngle: Theme.geometry_boatPage_batteryGauge_startAngle
		endAngle: Theme.geometry_boatPage_batteryGauge_endAngle
		strokeWidth: Theme.geometry_boatPage_batteryGauge_strokeWidth
		horizontalAlignment: Qt.AlignLeft
		animationEnabled: false
		valueType: VenusOS.Gauges_ValueType_NeutralPercentage
		value: battery.stateOfCharge || 0
	}

	Column {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_timeToGo_topMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_timeToGo_leftMargin
		}

		visible: !!battery

		Row {
			readonly property int secs: battery.timeToGo
			readonly property int days: Math.floor(secs / 86400)
			readonly property int hours: Math.floor((secs - (days * 86400)) / 3600)
			readonly property int minutes: Math.floor((secs - (days * 86400) - (hours * 3600)) / 60)

			spacing: Theme.geometry_boatPage_timeToGo_rowSpacing

			component TimeToGoQuantityLabel : QuantityLabel {
				font.pixelSize: Theme.font_size_body3
				anchors.verticalCenter: parent.verticalCenter
			}

			TimeToGoQuantityLabel {
				id: daysLabel

				unit: VenusOS.Units_Time_Day
				visible: value
				value: parent.days
			}

			TimeToGoQuantityLabel {
				id: hoursLabel

				unit: VenusOS.Units_Time_Hour
				visible: value || daysLabel.visible
				value: parent.hours
			}

			TimeToGoQuantityLabel {
				unit: VenusOS.Units_Time_Minute
				visible: value || hoursLabel.visible
				value: parent.minutes
			}
		}

		Label {
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_secondary
			//% "Time To Go"
			text: qsTrId("boat_page_time_to_go")
		}
	}

	Row {
		id: row

		anchors {
			left: batteryGauge.left
			leftMargin: Theme.geometry_boatPage_batteryGauge_leftMargin
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_batteryGauge_verticalCenterOffset
		}

		spacing: Theme.geometry_boatPage_batteryGauge_rowSpacing

		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			width: Theme.geometry_boatPage_batteryGauge_iconWidth
			height: width
			color: stateOfCharge.valueColor
			source: "qrc:/images/icon_battery_24.svg"
		}

		QuantityLabel {
			id: stateOfCharge

			anchors.verticalCenter: parent.verticalCenter
			font.pixelSize: Theme.geometry_boatPage_batterySoc_pixelSize
			unit: VenusOS.Units_Percentage
			value: battery.stateOfCharge
		}
	}

	QuantityLabel {
		anchors {
			top: row.bottom
			topMargin: Theme.geometry_boatPage_batteryTemperature_topMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_batteryTemperature_leftMargin
		}

		font.pixelSize: Theme.geometry_boatPage_batteryTemperature_pixelSize
		unit: Global.systemSettings.temperatureUnit
		value: battery.temperature
	}

	ProgressArc {
		id: centerGauge

		// Always show GPS speed in the center, unless it is unavailable. Then, we show motordrive or system dc consumption
		readonly property VeQuickItemsQuotient dataSource: gpsSpeed.valid
														   ? gpsSpeed
														   : motorDriveDcConsumption

		readonly property real _angularRange: endAngle - startAngle

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_centerGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: Theme.geometry_boatPage_centerGauge_rotation
		width: Theme.geometry_boatPage_centerGauge_width
		height: width
		radius: width/2
		startAngle: Theme.geometry_boatPage_centerGauge_startAngle
		endAngle: Theme.geometry_boatPage_centerGauge_endAngle
		value: dataSource.percentage
		strokeWidth: Theme.geometry_boatPage_centerGauge_strokeWidth
		animationEnabled: false
		objectName: "centerGauge"
		onDataSourceChanged: console.log(objectName, "dataSource:", dataSource ? dataSource.objectName : "null")

		Rectangle {
			id: needle
			anchors {
				bottom: parent.verticalCenter
				horizontalCenter: parent.horizontalCenter
			}

			width: centerGauge.strokeWidth
			height: Theme.geometry_boatPage_centerGauge_needleHeight
			radius: width / 2
			color: Theme.color_boatPage_background
			transformOrigin: Item.Bottom
			rotation: (centerGauge._angularRange * centerGauge.dataSource.normalizedValue)
			Rectangle {
				anchors {
					top: parent.top
					topMargin: radius
					horizontalCenter: parent.horizontalCenter
				}
				width: Theme.geometry_boatPage_centerGauge_innerNeedleWidth
				height: Theme.geometry_boatPage_centerGauge_innerNeedleHeight
				radius: width / 2
				gradient: Gradient {
					GradientStop {
						position: 0.0
						color: Theme.color_boatPage_needle
					}
					GradientStop {
						position: 0.4
						color: Theme.color_boatPage_needle
					}
					GradientStop {
						position: 0.6
						color: "transparent"
					}
					GradientStop {
						position: 1
						color: "transparent"
					}
				}
			}
		}
	}

	ProgressArc {
		id: rpmGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: centerGauge.rotation
		width: Theme.geometry_boatPage_rpmGauge_width
		height: width
		radius: width/2
		startAngle: centerGauge.startAngle
		endAngle: centerGauge.endAngle
		value: motorDriveRpm.percentage
		strokeWidth: Theme.geometry_boatPage_rpmGauge_strokeWidth
		animationEnabled: false
		visible: centerGauge.dataSource === gpsSpeed
	}

	Label {
		id: centerGaugeMinimumValue

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmGauge_minmax_topMargin
			left: centerGauge.left
			leftMargin: Theme.geometry_boatPage_rpmGauge_minmax_leftMargin
		}

		verticalAlignment: Text.AlignVCenter
		color: Theme.color_font_secondary
		font.pixelSize: Theme.geometry_boatPage_rpm_min_max_pixelSize
		text: "0"
		visible: rpmGauge.visible
	}

	Label {
		id: centerGaugeMaximumValue

		anchors {
			top: centerGaugeMinimumValue.top
			right: centerGauge.right
			rightMargin: Theme.geometry_boatPage_rpmGauge_minmax_rightMargin
		}

		color: Theme.color_font_secondary
		font.pixelSize: Theme.geometry_boatPage_rpm_min_max_pixelSize
		text: motorDriveRpm.denominator
		visible: rpmGauge.visible
	}

	Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_speedLabel_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		verticalAlignment: Text.AlignVCenter
		color: Theme.color_font_primary
		font.pixelSize: Theme.geometry_boatPage_speed_pixelSize
		font.weight: Font.Medium
		visible: centerGauge.dataSource === gpsSpeed
		text: Math.round(centerGauge.dataSource.numerator)
	}

	Column {
		id: motorDriveColumn

		anchors {
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_motorDriveColumn_verticalCenterOffset
			horizontalCenter: parent.horizontalCenter
		}
		visible: centerGauge.dataSource === motorDriveDcConsumption
		height: childrenRect.height
		spacing: Theme.geometry_boatPage_motorDriveColumn_spacing

		Row {
			id: motordriveRow

			anchors.horizontalCenter: parent.horizontalCenter
			spacing: Theme.geometry_boatPage_motordriveRow_spacing

			CP.ColorImage {
				anchors {
					right: undefined
					verticalCenter: parent.verticalCenter
				}
				width: Theme.geometry_boatPage_motordriveRow_image_width
				height: width
				color: Theme.color_boatPage_icon
				source: "qrc:/images/icon_propeller_32.svg"
			}

			Label {
				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: Theme.geometry_boatPage_motordriveRow_label_pixelSize
				//% "Motordrive"
				text: qsTrId("boat_page_motor_drive")
			}
		}

		QuantityLabel {
			id: motordriveLabel

			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Theme.geometry_boatPage_motorDriveDcConsumption_pixelSize
			value: motorDriveDcConsumption.numerator
			unit: motorDriveDcConsumption.unit
		}

		TemperatureGauge {
			anchors.horizontalCenter: parent.horizontalCenter
			width: childrenRect.width
			veQuickItem: _motorDriveTemperature
			unit: VenusOS.Units_Temperature_Celsius
			source: "qrc:/images/icon_engine_temp_32.svg"
		}
	}

	Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_speedUnitsLabel_topMargin
			horizontalCenter: parent.horizontalCenter
		}

		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_font_secondary
		visible: centerGauge.dataSource === gpsSpeed
		text: gpsSpeed.units
	}

	Label {
		id: rpmLabel
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmLabel_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		visible: !isNaN(motorDriveRpm.numerator) && centerGauge.dataSource === gpsSpeed
		verticalAlignment: Text.AlignVCenter
		topPadding: Theme.geometry_boatPage_rpmLabel_topPadding
		font.pixelSize: Theme.font_size_h1
		text: Math.abs(motorDriveRpm.numerator)
	}

	Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmText_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		visible: rpmLabel.visible
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_font_secondary
		//% "RPM"
		text: qsTrId("boat_page_rpm")
	}

	Row {
		id: gear

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_gear_topMargin
			right: parent.right
			rightMargin: Theme.geometry_boatPage_gear_rightMargin
		}

		spacing: Theme.geometry_boatPage_gearRow_spacing

		component GearIndicator : Label {
			required property int gear

			color: direction === gear ? Theme.color_font_primary : Theme.color_font_secondary
			font.pixelSize: Theme.geometry_boatPage_gear_pixelSize
			width: Theme.geometry_boatPage_gearIndicator_width
			height: width
			horizontalAlignment: Text.AlignHCenter

			Rectangle {
				anchors {
					bottom: parent.top
					bottomMargin: Theme.geometry_boatPage_gearHighlighter_bottomMargin
					horizontalCenter: parent.horizontalCenter
				}
				radius: Theme.geometry_boatPage_gearHighlighter_radius
				height: Theme.geometry_boatPage_gearHighlighter_height
				width: Theme.geometry_boatPage_gearHighlighter_width
				color: Theme.color_boatPage_gearHighlighter
				visible: direction === gear
			}
		}

		GearIndicator {
			gear: VenusOS.MotorDriveGear_Forward
			text: "F" // intentionally not translated
		}

		GearIndicator {
			gear: VenusOS.MotorDriveGear_Neutral
			text: "N" // intentionally not translated
		}

		GearIndicator {
			gear: VenusOS.MotorDriveGear_Reverse
			text: "R" // intentionally not translated
		}
	}

	Row {
		anchors {
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_batteryGauge_verticalCenterOffset
			right: parent.right
			rightMargin: Theme.geometry_boatPage_powerRow_rightMargin
		}

		spacing: Theme.geometry_boatPage_powerRow_spacing

		component BatteryQuantityLabel : QuantityLabel {
			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.geometry_boatPage_batterySoc_pixelSize
		}

		BatteryQuantityLabel {
			id: dcConsumptionLabel

			visible: !isNaN(motorDriveDcConsumption.numerator)
			value: motorDriveDcConsumption.numerator
			unit: motorDriveDcConsumption.unit
		}

		CP.ColorImage {
			id: propeller

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: Theme.geometry_boatPage_propeller_verticalCenterOffset
			}
			width: Theme.geometry_boatPage_batteryGauge_iconWidth
			height: width
			visible: dcConsumptionLabel.visible
			color: Theme.color_boatPage_icon
			source: "qrc:/images/icon_propeller_32.svg"
		}

		BatteryQuantityLabel {
			id: batteryCurrentLabel
			visible: !propeller.visible && !isNaN(battery.current)
			value: battery.current
			unit: VenusOS.Units_Amp
		}

		BatteryQuantityLabel {
			id: batteryPowerLabel
			visible: !propeller.visible && !batteryCurrentLabel.visible && battery.power !== undefined
			value: battery.power
			unit: VenusOS.Units_Watt
		}

		CP.ColorImage {
			anchors {
				verticalCenter: parent.verticalCenter
			}
			width: Theme.geometry_boatPage_batteryGauge_iconWidth
			height: width
			visible: batteryCurrentLabel.visible || batteryPowerLabel.visible
			color: Theme.color_boatPage_icon
			source: "qrc:/images/icon_battery_24.svg"
		}
	}

	Column {
		anchors {
			top: row.bottom
			topMargin: Theme.geometry_boatPage_batteryTemperature_topMargin
			right: parent.right
			rightMargin: Theme.geometry_boatPage_motorDrive_temperatures_rightMargin
		}

		spacing: Theme.geometry_boatPage_motorDrive_temperaturesColumn_spacing

		TemperatureGauge {
			anchors.right: parent.right
			veQuickItem: _motorDriveTemperature
			unit: VenusOS.Units_Temperature_Celsius
			source: "qrc:/images/icon_engine_temp_32.svg"
		}

		TemperatureGauge {
			anchors.right: parent.right
			veQuickItem: _motorDriveCoolantTemperature
			unit: VenusOS.Units_Temperature_Celsius
			source: "qrc:/images/icon_temp_coolant_32.svg"
		}

		TemperatureGauge {
			anchors.right: parent.right
			veQuickItem: _motorDriveControllerTemperature
			unit: VenusOS.Units_Temperature_Celsius
			source: "qrc:/images/icon_motorController_32.svg"
		}
	}

	SideGauge {
		id: powerGauge

		anchors {
			top: batteryGauge.top
			right: parent.right
			rightMargin: Theme.geometry_page_content_horizontalMargin
		}

		direction: PathArc.Counterclockwise
		startAngle: Theme.geometry_boatPage_batteryGauge_endAngle - 180
		endAngle: Theme.geometry_boatPage_batteryGauge_startAngle - 180
		strokeWidth: Theme.geometry_boatPage_batteryGauge_strokeWidth
		horizontalAlignment: Qt.AlignRight
		animationEnabled: false
		valueType: VenusOS.Gauges_ValueType_NeutralPercentage
		value: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp && !isNaN(motorDriveCurrent.percentage)
			   ? motorDriveCurrent.percentage
			   : !isNaN(motorDrivePower.percentage)
				 ? motorDrivePower.percentage
				 : 0
	}

	component TemperatureGauge : Row {
		required property VeQuickItem veQuickItem
		required property int unit
		required property string source

		spacing: Theme.geometry_boatPage_motorDrive_temperaturesRow_spacing

		QuantityLabel {
			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.geometry_boatPage_batteryTemperature_pixelSize
			value: veQuickItem && veQuickItem.value || 0
			unit: parent.unit
		}

		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			color: Theme.color_boatPage_icon
			source: parent.source
		}
	}
}
