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
	readonly property real speed: _speed.value
	readonly property real maxSpeed: 35.0 // TODO - move to Settings/gui/gauges once this has been added to plvePlatform
	property real normalizedSpeed: (speed || 0) / maxSpeed // typically between 0 and 1
	readonly property int maxRpm: 3000
	readonly property real normalizedRpm: (Math.abs(rpm.value) || 0) / maxRpm
	property var motorDrive: Global.allDevicesModel.motorDriveDevices.firstObject
	readonly property real current: _current.value
	readonly property real power: _power.value
	property string activeGpsUid
	readonly property real _unexpandedHeight: Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height
	readonly property int direction: _direction.value === undefined ? -1 : _direction.value
	readonly property string speedUnits: _speedUnits.value || ""

	//% "Boat"
	navButtonText: qsTrId("nav_boat")
	navButtonIcon: "qrc:/images/icon_boat_32.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BoatPage.qml"
	backgroundColor: Theme.color_boatPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	VeQuickItem {
		id: rpm

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
					if (!activeGpsUid && value !== undefined) {
						console.log(uid, "is now the active gps")
						root.activeGpsUid = modelData.serviceUid
					}
				}
			}
		}
	}

	component Shadow : CP.ColorImage {
		width: 193
		height: 69
		source: "qrc:/images/boat_glow.png"
	}


	Shadow {
		id: shadowTopLeft

		anchors {
			top: parent.top
			topMargin: 85 // 119
			left: parent.left
			leftMargin: 58 // 89
		}

		rotation: 180
	}

	Shadow {
		id: shadowBottomLeft

		anchors {
			top: parent.top
			topMargin: 227 // 296
			left: shadowTopLeft.left
		}
		mirror: true
	}

	Shadow {
		id: shadowTopRight
		anchors {
			top: shadowTopLeft.top
			right: parent.right
			rightMargin: 58 // 89
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
		y: (root._unexpandedHeight - height) / 2

		direction: PathArc.Clockwise
		startAngle: 243.25 // 243.5
		endAngle: 293 // 296.5
		strokeWidth: 15
		horizontalAlignment: Qt.AlignLeft
		animationEnabled: false // if set to true, the arc flickers momentarily when it becomes visible. Not sure why.
		valueType: VenusOS.Gauges_ValueType_NeutralPercentage
		value: battery.stateOfCharge || 0
	}

	Column { // battery 'Time to go' data
		anchors {
			top: parent.top
			topMargin: 80 - 4
			left: parent.left
			leftMargin: 66
		}

		visible: !!battery

		Row {
			readonly property int secs: battery.timeToGo
			readonly property int days: Math.floor(secs / 86400)
			readonly property int hours: Math.floor((secs - (days * 86400)) / 3600)
			readonly property int minutes: Math.floor((secs - (hours * 3600)) / 60)

			Label {
				font.pixelSize: 28
				visible: parent.days
				text: parent.days
			}

			Label {
				font.pixelSize: 28
				visible: parent.days
				color: Theme.color_font_secondary
				text: "d "
			}

			Label {
				font.pixelSize: 28
				visible: parent.hours
				text: parent.hours
			}

			Label {
				font.pixelSize: 28
				visible: parent.hours
				color: Theme.color_font_secondary
				text: "h "
			}

			Label {
				font.pixelSize: 28
				text: parent.minutes
			}

			Label {
				font.pixelSize: 28
				color: Theme.color_font_secondary
				text: "m"
			}
		}

		Label {
			font.pixelSize: 22
			color: Theme.color_font_secondary
			//% "Time To Go"
			text: qsTrId("boat_page_time_to_go")
		}
	}

	Row {
		id: row

		anchors {
			left: batteryGauge.left
			leftMargin: 25 // 30
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: 15 // 10
		}

		spacing: 4

		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			width: 40
			height: width
			color: stateOfCharge.valueColor
			source: "qrc:/images/icon_battery_24.svg"
		}

		QuantityLabel {
			id: stateOfCharge

			anchors.verticalCenter: parent.verticalCenter
			font.pixelSize: 34
			unit: VenusOS.Units_Percentage
			value: battery.stateOfCharge
		}
	}

	QuantityLabel {
		anchors {
			top: row.bottom
			topMargin: 29- 8
			left: row.left
			leftMargin: 42 - 26// 66
		}

		font.pixelSize: 28
		unit: Global.systemSettings.temperatureUnit
		value: battery.temperature
	}

	ProgressArc {
		id: speedGauge

		readonly property real angularRange: endAngle - startAngle

		anchors {
			top: parent.top
			topMargin: 32
			horizontalCenter: parent.horizontalCenter
		}
		//y: (root._unexpandedHeight - height) / 2
		rotation: 225
		width: 320 // Theme.geometry_mainGauge_size
		height: 320 // width
		radius: width/2
		startAngle: 0
		endAngle: 270
		value: 100 * normalizedSpeed
		strokeWidth: 24
		animationEnabled: false

		Rectangle {
			id: needle
			anchors {
				bottom: parent.verticalCenter
				//bottomMargin: -needle.radius
				horizontalCenter: parent.horizontalCenter
			}

			width: speedGauge.strokeWidth
			height: 169 - 9
			radius: width / 2
			color: "black"
			transformOrigin: Item.Bottom
			rotation: (speedGauge.angularRange * normalizedSpeed) // parent.transitionAngle //
			Rectangle {
				anchors {
					top: parent.top
					topMargin: radius
					horizontalCenter: parent.horizontalCenter
				}
				width: 10
				height: 49
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
			topMargin: 66
			horizontalCenter: parent.horizontalCenter
		}
		rotation: 225
		width: 252
		height: width
		radius: width/2
		startAngle: 0
		endAngle: 270
		value: 100 * normalizedRpm
		strokeWidth: 8
		animationEnabled: false
	}

	Label {
		id: min

		anchors {
			top: parent.top
			topMargin: 299 + 10
			left: speedGauge.left
			leftMargin: 55
		}

		verticalAlignment: Text.AlignVCenter
		color: Theme.color_font_secondary
		font.pixelSize: 24
		text: "0"
	}

	Label {
		anchors {
			top: min.top
			right: speedGauge.right
			rightMargin: 50
		}

		color: Theme.color_font_secondary
		font.pixelSize: 24
		text: maxRpm
	}

	Label {
		anchors {
			top: parent.top
			topMargin: 95 - 20
			horizontalCenter: parent.horizontalCenter
		}
		color: Theme.color_font_primary
		font.pixelSize: 128
		font.weight: Font.Medium
		text: Math.round(speed)
	}

	readonly property int delta: 13
	Label {
		anchors {
			top: parent.top
			topMargin: 220 - delta
			horizontalCenter: parent.horizontalCenter
		}

		verticalAlignment: Text.AlignVCenter
		font.pixelSize: 22
		color: Theme.color_font_secondary
		text: speedUnits
	}

	Label {
		anchors {
			top: parent.top
			topMargin: 253 - delta
			horizontalCenter: parent.horizontalCenter
		}

		verticalAlignment: Text.AlignVCenter
		topPadding: 8
		font.pixelSize: 34
		text: Math.abs(rpm.value)
	}

	Label {
		anchors {
			top: parent.top
			topMargin: 301 - delta
			horizontalCenter: parent.horizontalCenter
		}
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: 22
		color: Theme.color_font_secondary
		//% "RPM"
		text: qsTrId("boat_page_rpm")
	}

	Row {
		id: gear

		anchors {
			top: parent.top
			topMargin: 108
			right: parent.right
			rightMargin: 90
		}

		spacing: 8

		component GearIndicator : Label {
			required property int gear

			color: direction === gear ? Theme.color_font_primary : Theme.color_font_secondary
			font.pixelSize: 28
			width: 24
			horizontalAlignment: Text.AlignHCenter

			Rectangle {
				anchors {
					bottom: parent.top
					bottomMargin: 4
					horizontalCenter: parent.horizontalCenter
				}
				radius: 3
				height: 5
				width: 26
				color: "#387DC5" // same for light & dark mode
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

		/*
		Label {
			color: direction === VenusOS.MotorDriveGear_Forward ? Theme.color_font_primary : Theme.color_font_secondary
			font.pixelSize: 28
			width: 24
			text: "F" // intentionally not translated

			Rectangle {
				anchors {
					bottom: parent.top
					bottomMargin: 6
					horizontalCenter: parent.horizontalCenter
				}
				height: 5
				width: 26
				color: "#387DC5" // same for light & dark mode
			}
		}

		Label {
			color: direction === VenusOS.MotorDriveGear_Neutral ? Theme.color_font_primary : Theme.color_font_secondary
			font.pixelSize: 28
			width: 24
			text: "N" // intentionally not translated
		}

		Label {
			color: direction === VenusOS.MotorDriveGear_Reverse ? Theme.color_font_primary : Theme.color_font_secondary
			font.pixelSize: 28
			width: 24
			text: "R" // intentionally not translated
		}
		*/
	}

	Row {
		anchors {
			top: parent.top
			topMargin: 169
			right: parent.right
			rightMargin: 58
		}

		spacing: 4

		QuantityLabel {
			id: currentLabel

			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			visible: current !== undefined
			font.pixelSize: 34
			value: current
			unit: VenusOS.Units_Amp
		}

		QuantityLabel {
			id: powerLabel

			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			visible: !currentLabel.visible && _power.isValid
			font.pixelSize: 34
			value: _power.value
			unit: VenusOS.Units_Watt
		}

		Image {
			id: propeller

			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: 3
			}
			visible: currentLabel.visible || powerLabel.visible
			source: "qrc:/images/icon_propeller_32.svg"
		}

		QuantityLabel {
			id: batteryCurrentLabel
			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			visible: !propeller.visible && current !== undefined
			font.pixelSize: 34
			value: battery.current
			unit: VenusOS.Units_Amp
		}

		QuantityLabel {
			id: batteryPowerLabel
			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			visible: !propeller.visible && !batteryCurrentLabel.visible && battery.power !== undefined
			font.pixelSize: 34
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
		id: rhsLower

		anchors {
			top: parent.top
			topMargin: 237
			right: parent.right
			rightMargin: 90
		}

		spacing: -2

		component TemperatureGauge : Row {
			required property VeQuickItem veQuickItem
			required property int unit
			required property string source

			anchors.right: parent.right
			spacing: 4
			//visible: veQuickItem && veQuickItem.isValid

			QuantityLabel {
				anchors.verticalCenter: parent.verticalCenter
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: 28
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
