/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.Boat as Boat
import Victron.VenusOS

Boat.Background { // the blue shadows
	id: root

	required property bool animationEnabled

	motorDrives: motorDrives


	Boat.SlotLeftArc {
		id: slotLeftArc
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_page_content_horizontalMargin
		}
		y: (root.Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height - height) / 2
		motorDrives: motorDrives
		gps: _gps
		animationEnabled: root.animationEnabled
	}

	Boat.SlotVerticalCenterLeft {
		id: slotVerticalCenterLeft
		anchors {
			left: slotLeftArc.left
			leftMargin: Theme.geometry_boatPage_batteryGauge_leftMargin
			verticalCenter: slotLeftArc.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_batteryGauge_verticalCenterOffset
		}
		motorDrives: motorDrives
		gps: _gps
	}

	// @temporary: waiting for design
	CP.ColorImage {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_boatPage_topRow_horizontalMargin
			bottom: slotVerticalCenterLeft.top
			bottomMargin: Theme.geometry_boatPage_verticalMargin
		}

		width: Theme.geometry_boatPage_shoreGauge_icon_size
		height: width
		color: Theme.color_boatPage_icon
		source: "qrc:/images/shore.svg"

		visible: Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Shore && (_gps.valid || motorDrives.dcConsumption.quotient.valid)
	}

	Boat.TimeToGo { // bottom left
		id: ttg

		anchors {
			top: slotVerticalCenterLeft.bottom
			topMargin: Theme.geometry_boatPage_verticalMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_topRow_horizontalMargin
		}
	}

	Boat.Range { // center
		id: range

		anchors {
			top: centerGauge.top
			topMargin: Theme.geometry_boatPage_range_topMargin
			horizontalCenter: centerGauge.horizontalCenter
		}
	}

	Boat.Consumption { // bottom right
		id: consumption

		anchors {
			top: slotVerticalCenterLeft.bottom
			topMargin: Theme.geometry_boatPage_verticalMargin
			right: parent.right
			rightMargin: Theme.geometry_boatPage_topRow_horizontalMargin
		}
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

	Boat.SlotVerticalCenterRight {
		id: slotVerticalCenterRight
		anchors {
			verticalCenter: slotVerticalCenterLeft.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry_boatPage_powerRow_rightMargin
		}
		motorDrives: motorDrives
		gps: _gps
	}

	Boat.LoadArc { // arc gauge on the far right
		id: loadArc

		anchors {
			verticalCenter: slotLeftArc.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry_page_content_horizontalMargin
		}
		animationEnabled: root.animationEnabled
		motorDrives: motorDrives
		gps: _gps
	}

	VeQuickItem {
		id: showTemperaturesItem
		uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/ShowTemperatures" : ""
	}

	Boat.Temperatures {
		id: temperatures

		anchors {
			horizontalCenter: parent.horizontalCenter
		}
		y: Theme.geometry_screen_height - Theme.geometry_statusBar_height - temperatures.height - Theme.geometry_boatPage_temperature_bottomMargin
		visible: showTemperaturesItem.value ?? false

		motorDrives: motorDrives
	}

	Boat.MotorDrives {
		id: motorDrives
	}

	Boat.Gps {
		id: _gps
	}

	Item {
		id: shorePowerListener

		property int previousSource: Global.acInputs.activeInSource

		Connections {
			target: Global.acInputs

			function onActiveInSourceChanged() {
				if (shorePowerListener.previousSource !== VenusOS.AcInputs_InputSource_Shore &&
					Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Shore) {
					// Wake up display when shore power gets connected
					ScreenBlanker.setDisplayOn();
				}

				shorePowerListener.previousSource = Global.acInputs.activeInSource
			}
		}
	}

	Binding {
		target: Global
		property: "boatPageActive"
		value: parent.visible && (_gps.valid || motorDrives.dcConsumption.quotient.valid)
	}

	states: State {
		name: "showing3Phases"
		when: loadArc.showing3Phases
		PropertyChanges {
			slotLeftArc.anchors.leftMargin: Theme.geometry_page_content_horizontalMargin / 2
			loadArc.anchors.rightMargin: Theme.geometry_page_content_horizontalMargin / 2
		}
	}
}
