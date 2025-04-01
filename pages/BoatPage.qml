/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.BoatPageComponents as BoatPageComponents
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

SwipeViewPage {
	id: root

	property string activeGpsUid
	readonly property var _motorDrive: Global.allDevicesModel.motorDriveDevices.firstObject

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
		unit: VenusOS.Units_Speed_MetresPerSecond
		onNumeratorChanged: console.log(objectName, "numerator:", numerator)
		onDenominatorChanged: console.log(objectName, "denominator:", denominator)
	}

	property VeQuickItemsQuotient motorDriveRpm: VeQuickItemsQuotient {
		objectName: "motorDriveRpm"
		numeratorUid: _motorDrive ? _motorDrive.serviceUid + "/Motor/RPM" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Motordrive/Rpm/Max" : ""
		unit: VenusOS.Units_RevolutionsPerMinute
	}

	property VeQuickItemsQuotient motorDrivePower: VeQuickItemsQuotient {
		objectName: "motorDrivePower"
		numeratorUid: _motorDrive ? _motorDrive.serviceUid + "/Dc/0/Power" : ""
		denominatorUid : Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Motordrive/DC/Power/Max" : ""
		unit: VenusOS.Units_Watt
	}

	property VeQuickItemsQuotient motorDriveCurrent: VeQuickItemsQuotient {
		objectName: "motorDriveCurrent"
		numeratorUid: _motorDrive ? _motorDrive.serviceUid + "/Dc/0/Current" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Motordrive/DC/Current/Max" : ""
		unit: VenusOS.Units_Amp
	}

	readonly property VeQuickItemsQuotient _motorDriveDcConsumption: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp
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
		id: _motorDriveTemperatureDc0

		uid: _motorDrive ? _motorDrive.serviceUid + "/Dc/0/Temperature" : ""
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

	BoatPageComponents.Background { // the blue shadows
		anchors.fill: parent
	}

	BoatPageComponents.BatteryArc { // arc gauge on the far left
		id: batteryGauge

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_page_content_horizontalMargin
		}
		y: (root.Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height - height) / 2
	}

	BoatPageComponents.TimeToGo { // top left
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_timeToGo_topMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_timeToGo_leftMargin
		}
	}

	BoatPageComponents.BatteryPercentage { // vertical center left
		id: batteryPercentage
		anchors {
			left: batteryGauge.left
			leftMargin: Theme.geometry_boatPage_batteryGauge_leftMargin
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_batteryGauge_verticalCenterOffset
		}
	}

	QuantityLabel { // bottom left
		readonly property var _battery: Global.system && Global.system.battery ? Global.system.battery : null

		anchors {
			top: batteryPercentage.bottom
			topMargin: Theme.geometry_boatPage_batteryTemperature_topMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_batteryTemperature_leftMargin
		}

		font.pixelSize: Theme.geometry_boatPage_batteryTemperature_pixelSize
		unit: Global.systemSettings.temperatureUnit
		value: _battery.temperature
		visible: !isNaN(value)
	}

	BoatPageComponents.LargeCenterGauge {
		id: centerGauge
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_centerGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}

		// Always show GPS speed in the center, unless it is unavailable. Then, we show motordrive or system dc consumption
		dataSource: gpsSpeed.valid
					? gpsSpeed
					: _motorDriveDcConsumption
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

	BoatPageComponents.MotorDriveGauges {
		id: motorDriveColumn

		anchors {
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_motorDriveColumn_verticalCenterOffset
			horizontalCenter: parent.horizontalCenter
		}
		visible: centerGauge.dataSource === _motorDriveDcConsumption
		motorDriveDcConsumption: _motorDriveDcConsumption
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

	BoatPageComponents.Gear { // top right
		id: gear

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_gear_topMargin
			right: parent.right
			rightMargin: Theme.geometry_boatPage_gear_rightMargin
		}
	}

	BoatPageComponents.DcConsumptionGauge { // vertical center right
		anchors {
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_batteryGauge_verticalCenterOffset
			right: parent.right
			rightMargin: Theme.geometry_boatPage_powerRow_rightMargin
		}

		motorDriveDcConsumption: _motorDriveDcConsumption
	}

	BoatPageComponents.TemperatureGauges { // bottom right
		anchors {
			top: batteryPercentage.bottom
			topMargin: Theme.geometry_boatPage_batteryTemperature_topMargin
			right: parent.right
			rightMargin: Theme.geometry_boatPage_motorDrive_temperatures_rightMargin
		}
	}

	SideGauge { // arc gauge on the far right
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
}
