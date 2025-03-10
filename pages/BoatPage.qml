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
	readonly property real speed: _speed.isValid ? _speed.value : NaN
	readonly property real maxSpeed: 35.0 // TODO - move to Settings/gui/gauges once this has been added to vePlatform
	readonly property real normalizedSpeed: (speed || 0) / maxSpeed // typically between 0 and 1
	readonly property int maxRpm: 3000 // TODO
	readonly property real normalizedRpm: _rpm.isValid && maxRpm /* TODO */ ? (Math.abs(_rpm.value) || 0) / maxRpm : NaN
	readonly property var motorDrive: Global.allDevicesModel.motorDriveDevices.firstObject
	readonly property real current: _current.isValid ? _current.value : NaN
	readonly property real power: _power.isValid ? _power.value : NaN
	readonly property int direction: _direction.isValid ? _direction.value : NaN
	readonly property string speedUnits: _speedUnits.isValid ? _speedUnits.value : ""
	property string activeGpsUid

	//% "Boat"
	navButtonText: qsTrId("nav_boat")
	navButtonIcon: "qrc:/images/icon_boat_32.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BoatPage.qml"
	backgroundColor: Theme.color_boatPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	VeQuickItem {
		id: _rpm

		uid: motorDrive ? motorDrive.serviceUid + "/Motor/RPM" : ""
	}

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

	VeQuickItem {
		id: _speedUnits

		uid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gps/SpeedUnit" : ""
	}

	VeQuickItem {
		id: _current

		uid: motorDrive ? motorDrive.serviceUid + "/Dc/0/Current" : ""
	}

	VeQuickItem {
		id: _power

		uid: motorDrive ? motorDrive.serviceUid + "/Dc/0/Power" : ""
	}

	VeQuickItem {
		id: _speed

		uid: activeGpsUid ? activeGpsUid + "/Speed" : ""
	}

	Instantiator {
		model: Global.allDevicesModel.gpsDevices
		delegate: QtObject {
			property var qi: VeQuickItem {
				uid: modelData.serviceUid + "/Speed"
				onValueChanged: {
					if (!activeGpsUid && isValid) {
						console.log(uid, "is now the active gps")
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
			topMargin: Theme.geometry_boatPage_shadow_topRow_topMargin // 119
			left: parent.left
			leftMargin: Theme.geometry_boatPage_shadow_horizontalMargin // 89
		}

		rotation: 180
	}

	Shadow {
		id: shadowBottomLeft

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_shadow_bottomRow_topMargin // 296
			left: shadowTopLeft.left
		}
		mirror: true
	}

	Shadow {
		id: shadowTopRight
		anchors {
			top: shadowTopLeft.top
			right: parent.right
			rightMargin: Theme.geometry_boatPage_shadow_horizontalMargin // 89
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
			font.pixelSize: Theme.font_size_h1
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

		font.pixelSize: Theme.font_size_body3
		unit: Global.systemSettings.temperatureUnit
		value: battery.temperature
	}

	ProgressArc {
		id: speedGauge

		readonly property real angularRange: endAngle - startAngle

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_speedGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: Theme.geometry_boatPage_speedGauge_rotation
		width: Theme.geometry_boatPage_speedGauge_width
		height: width
		radius: width/2
		startAngle: Theme.geometry_boatPage_speedGauge_startAngle
		endAngle: Theme.geometry_boatPage_speedGauge_endAngle
		value: 100 * normalizedSpeed
		strokeWidth: Theme.geometry_boatPage_speedGauge_strokeWidth
		animationEnabled: false

		Rectangle {
			id: needle
			anchors {
				bottom: parent.verticalCenter
				horizontalCenter: parent.horizontalCenter
			}

			width: speedGauge.strokeWidth
			height: Theme.geometry_boatPage_speedGauge_needleHeight
			radius: width / 2
			color: Theme.color_boatPage_needle
			transformOrigin: Item.Bottom
			rotation: (speedGauge.angularRange * normalizedSpeed)
			Rectangle {
				anchors {
					top: parent.top
					topMargin: radius
					horizontalCenter: parent.horizontalCenter
				}
				width: Theme.geometry_boatPage_speedGauge_innerNeedleWidth
				height: Theme.geometry_boatPage_speedGauge_innerNeedleHeight
				radius: width / 2
				gradient: Gradient {
					GradientStop {
						position: 0.0
						color: "white"
					}
					GradientStop {
						position: 0.4
						color: "white"
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
		rotation: speedGauge.rotation
		width: Theme.geometry_boatPage_rpmGauge_width
		height: width
		radius: width/2
		startAngle: speedGauge.startAngle
		endAngle: speedGauge.endAngle
		value: 100 * normalizedRpm
		strokeWidth: Theme.geometry_boatPage_rpmGauge_strokeWidth
		animationEnabled: false
	}

	Label {
		id: min

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmGauge_minmax_topMargin
			left: speedGauge.left
			leftMargin: Theme.geometry_boatPage_rpmGauge_minmax_leftMargin
		}

		verticalAlignment: Text.AlignVCenter
		color: Theme.color_font_secondary
		font.pixelSize: Theme.geometry_boatPage_rpm_min_max_pixelSize
		text: "0"
	}

	Label {
		anchors {
			top: min.top
			right: speedGauge.right
			rightMargin: Theme.geometry_boatPage_rpmGauge_minmax_rightMargin
		}

		color: Theme.color_font_secondary
		font.pixelSize: Theme.geometry_boatPage_rpm_min_max_pixelSize
		text: maxRpm
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
		text: Math.round(speed)
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
		text: speedUnits
	}

	Label {
		id: rpmLabel
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmLabel_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		visible: _rpm.isValid
		verticalAlignment: Text.AlignVCenter
		topPadding: Theme.geometry_boatPage_rpmLabel_topPadding
		font.pixelSize: Theme.font_size_h1
		text: _rpm.isValid ? Math.abs(_rpm.value) : ""
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
			font.pixelSize: Theme.font_size_body3
			width: Theme.geometry_boatPage_gearIndicator_width
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
			top: parent.top
			topMargin: Theme.geometry_boatPage_powerRow_topMargin
			right: parent.right
			rightMargin: Theme.geometry_boatPage_powerRow_rightMargin
		}

		spacing: Theme.geometry_boatPage_powerRow_spacing

		component BatteryQuantityLabel : QuantityLabel {
			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.font_size_h1
		}

		BatteryQuantityLabel {
			id: currentLabel

			visible: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp && !isNaN(current)
			value: current
			unit: VenusOS.Units_Amp
		}

		BatteryQuantityLabel {
			id: powerLabel

			visible: !currentLabel.visible && _power.isValid
			value: _power.value
			unit: VenusOS.Units_Watt
		}

		Image {
			id: propeller

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: Theme.geometry_boatPage_propeller_verticalCenterOffset
			}
			visible: currentLabel.visible || powerLabel.visible
			source: "qrc:/images/icon_propeller_32.svg"
		}

		BatteryQuantityLabel {
			id: batteryCurrentLabel
			visible: !propeller.visible && !isNaN(current)
			value: battery.current
			unit: VenusOS.Units_Amp
		}

		BatteryQuantityLabel {
			id: batteryPowerLabel
			visible: !propeller.visible && !batteryCurrentLabel.visible && battery.power !== undefined
			value: battery.power
			unit: VenusOS.Units_Watt
		}

		Image {
			anchors {
				verticalCenter: parent.verticalCenter
			}
			visible: batteryCurrentLabel.visible || batteryPowerLabel.visible
			source: "qrc:/images/icon_battery_24.svg"
		}
	}

	Column {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_motorDrive_temperatures_topMargin
			right: parent.right
			rightMargin: Theme.geometry_boatPage_motorDrive_temperatures_rightMargin
		}

		spacing: Theme.geometry_boatPage_motorDrive_temperaturesColumn_spacing

		component TemperatureGauge : Row {
			required property VeQuickItem veQuickItem
			required property int unit
			required property string source

			anchors.right: parent.right
			spacing: Theme.geometry_boatPage_motorDrive_temperaturesRow_spacing

			QuantityLabel {
				anchors.verticalCenter: parent.verticalCenter
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: Theme.font_size_body3
				value: veQuickItem && veQuickItem.value || 0
				unit: parent.unit
			}

			Image {
				anchors.verticalCenter: parent.verticalCenter
				source: parent.source
			}
		}

		TemperatureGauge {
			veQuickItem: _motorDriveTemperature
			unit: VenusOS.Units_Temperature_Celsius
			source: "qrc:/images/icon_engine_temp_32.svg"
		}

		TemperatureGauge {
			veQuickItem: _motorDriveCoolantTemperature
			unit: VenusOS.Units_Temperature_Celsius
			source: "qrc:/images/icon_temp_coolant_32.svg"
		}

		TemperatureGauge {
			veQuickItem: _motorDriveControllerTemperature
			unit: VenusOS.Units_Temperature_Celsius
			source: "qrc:/images/icon_motorController_32.svg"
		}
	}
}
