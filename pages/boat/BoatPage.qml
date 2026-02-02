/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Boat as Boat
import Victron.VenusOS

SwipeViewPage {
	id: root

	//% "Boat"
	navButtonText: qsTrId("nav_boat")
	navButtonIcon: "qrc:/images/icon_boat_32.svg"
	url: "qrc:/qt/qml/Victron/Boat/BoatPage.qml"
	backgroundColor: Theme.color_boatPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	Boat.Background { // the blue shadows
		anchors.fill: parent
		motorDrives: motorDrives
	}

	Boat.BatteryArc { // arc gauge on the far left
		id: batteryGauge

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_page_content_horizontalMargin
		}
		y: (root.Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height - height) / 2
		animationEnabled: root.animationEnabled
	}

	Boat.TimeToGo {
		id: ttg

		anchors {
			top: centerGauge.top
			topMargin: Theme.geometry_boatPage_timeToGo_topMargin
			horizontalCenter: centerGauge.horizontalCenter
		}
	}

	Boat.BatteryPercentage { // vertical center left
		id: batteryPercentage
		anchors {
			left: batteryGauge.left
			leftMargin: Theme.geometry_boatPage_batteryGauge_leftMargin
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_batteryGauge_verticalCenterOffset
		}
		motorDrives: motorDrives
	}

	QuantityLabel { // bottom left
		id: batteryTemperature

		anchors {
			top: batteryPercentage.bottom
			topMargin: Theme.geometry_boatPage_verticalMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_topRow_horizontalMargin
		}

		font.pixelSize: Theme.font_boatPage_batteryTemperature_pixelSize
		unit: Global.systemSettings.temperatureUnit
		value: Global.system && Global.system.battery ? Global.system.battery.temperature : NaN
		visible: !isNaN(value)
	}

	/*
		The center gauge gives the user a speed-related value. The value of the outer gauge and the large numbers are always related:

		1.	If there is a valid GPS with speed, we show the speed in the center
			If there is also a motordrive, we show the motordrive on the right
			If there is no motordrive, we show DC (and if available also AC) loads on the right

		2. If there is no valid GPS speed, but a motordrive, we use the current/power of the motordrive as the next best speed indicator, showing
			current/power in large letters and also the outer "speed gauge" is based on current/power
			We add the motordrive symbol and text "Motordrive" in the center to indicate, that the "speed gauge" is no longer showing speed, but
			current/power instead
			If there is RPM for the motordrive, also show the thinner RPM center gauge based on RPM
			As the motordrive current/power is now shown in the center, it does not make sense to also have it to the right (vertical center) →
			Therefore, only in this scenario without GPS, we show DC (and if available also AC ) loads at the right vertical center.
	*/
	Boat.LargeCenterGauge { // vertical center, horizontal center
		id: centerGauge

		anchors.fill: parent
		gps: _gps // primary data source
		motorDrives: motorDrives // secondary data source
		animationEnabled: root.animationEnabled
	}

	Boat.Gear { // top left
		id: leftGear

		anchors {
			bottom: batteryPercentage.top
			bottomMargin: Theme.geometry_boatPage_verticalMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_topRow_horizontalMargin
		}
		motorDrive: motorDrives.leftMotorDrive
	}

	Boat.Gear { // top right
		id: rightGear

		anchors {
			bottom: batteryPercentage.top
			bottomMargin: Theme.geometry_boatPage_verticalMargin
			right: parent.right
			rightMargin: Theme.geometry_boatPage_topRow_horizontalMargin
		}
		motorDrive: motorDrives.right !== null ? motorDrives.rightMotorDrive : motorDrives.singleMotorDrive
	}

	Boat.ConsumptionGauge { // vertical center right
		id: consumption

		anchors {
			verticalCenter: batteryPercentage.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry_boatPage_powerRow_rightMargin
		}

		motorDrives: motorDrives
		gps: _gps
	}

	/*	Don't display motordrive temperatures for v1. TBD whether we want them for v2.
	Boat.TemperatureGauges { // bottom right
		id: temperatureGauges

		anchors {
			top: batteryTemperature.top
			right: parent.right
			rightMargin: Theme.geometry_boatPage_topRow_horizontalMargin
		}
		motorDrive: motorDrives.singleMotorDrive
	}
	*/

	Boat.LoadArc { // arc gauge on the far right
		id: loadArc

		anchors {
			verticalCenter: batteryGauge.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry_page_content_horizontalMargin
		}
		animationEnabled: root.animationEnabled
		motorDrives: motorDrives
		gps: _gps
	}

	Boat.MotorDrives {
		id: motorDrives
	}

	Boat.Gps {
		id: _gps
	}

	states: State {
		name: "showing3Phases"
		when: loadArc.showing3Phases
		PropertyChanges {
			batteryGauge.anchors.leftMargin: Theme.geometry_page_content_horizontalMargin / 2
			loadArc.anchors.rightMargin: Theme.geometry_page_content_horizontalMargin / 2
		}
	}
}
