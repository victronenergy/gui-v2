/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.BoatPageComponents as BoatPageComponents
import QtQuick.Controls.impl as CP
import Victron.VenusOS

SwipeViewPage {
	id: root

	readonly property var _battery: Global.system && Global.system.battery ? Global.system.battery : null

	readonly property VeQuickItemsQuotient _systemDcLoad: VeQuickItemsQuotient {
		objectName: "systemDcLoad"
		numeratorUid: BackendConnection.serviceUidForType("system") + "/Dc/System/Power"
		denominatorUid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/System/Power/Max"
		unit: VenusOS.Units_Watt
	}

	//% "Boat"
	navButtonText: qsTrId("nav_boat")
	navButtonIcon: "qrc:/images/icon_boat_32.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BoatPage.qml"
	backgroundColor: Theme.color_boatPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

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
		animationEnabled: root.animationEnabled
	}

	BoatPageComponents.TimeToGo { // top left
		anchors {
			bottom: batteryPercentage.top
			bottomMargin: Theme.geometry_boatPage_verticalMargin
			left: batteryTemperature.left
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
		id: batteryTemperature

		anchors {
			top: batteryPercentage.bottom
			topMargin: Theme.geometry_boatPage_verticalMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_batteryTemperature_leftMargin
		}

		font.pixelSize: Theme.font_boatPage_batteryTemperature_pixelSize
		unit: Global.systemSettings.temperatureUnit
		value: _battery.temperature
		visible: !isNaN(value)
	}

	/*
		If there is GPS:

			Show speed
			Only show RPM, if there is a motordrive with valid RPM path and valid data

		If there is no GPS but a Motordrive:

			Show „Motordrive“ with the propeller icon
			Only show temperatures, for which the paths exist and has valid data
			Only show RPM gauge, if path exists and has valid data

		If there is no GPS and no Motordrive:

			Show „DC load“ with its „DC load“ icon
			Show no temperature below
			Show no RPM gauge
	*/
	BoatPageComponents.LargeCenterGauge { // vertical center, horizontal center
		id: centerGauge

		gps: _gps // primary data source
		motorDrive: _motorDrive // secondary data source
		systemDcLoad: _systemDcLoad // tertiary data source
		animationEnabled: root.animationEnabled
	}

	Loader {
		anchors {
			verticalCenter: batteryGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_boatPage_motorDriveColumn_verticalCenterOffset
			horizontalCenter: parent.horizontalCenter
		}
		sourceComponent: centerGauge.activeDataSource === _motorDrive.dcConsumption ||
						 (centerGauge.activeDataSource === null && _motorDrive.rpm.valid)
		? motorDriveColumn
		: null

		Component {
			id: motorDriveColumn

			BoatPageComponents.MotorDriveGauges {
				motorDrive: _motorDrive
			}
		}
	}

	BoatPageComponents.Gear { // top right
		id: gear

		anchors {
			bottom: consumption.top
			bottomMargin: Theme.geometry_boatPage_verticalMargin
			right: temperatureGauges.right
		}
	}

	BoatPageComponents.ConsumptionGauge { // vertical center right
		id: consumption

		anchors {
			verticalCenter: batteryPercentage.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry_boatPage_powerRow_rightMargin
		}

		motorDriveDcConsumption: _motorDrive.dcConsumption
		gps: _gps
	}

	BoatPageComponents.TemperatureGauges { // bottom right
		id: temperatureGauges

		anchors {
			top: consumption.bottom
			topMargin: Theme.geometry_boatPage_verticalMargin
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
		animationEnabled: root.animationEnabled
		valueType: VenusOS.Gauges_ValueType_NeutralPercentage
		value: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp && !isNaN(_motorDrive.current.percentage)
			   ? _motorDrive.current.percentage
			   : !isNaN(_motorDrive.power.percentage)
				 ? _motorDrive.power.percentage
				 : 0
	}

	BoatPageComponents.MotorDrive {
		id: _motorDrive
	}

	BoatPageComponents.Gps {
		id: _gps
	}
}
