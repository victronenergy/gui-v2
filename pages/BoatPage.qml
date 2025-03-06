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
	readonly property real _unexpandedHeight: Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	//% "Boat"
	navButtonText: qsTrId("nav_boat")
	navButtonIcon: "qrc:/images/icon_boat_32.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BoatPage.qml"
	backgroundColor: Theme.color_boatPage_background
	fullScreenWhenIdle: true

	CP.ColorImage {
		id: topLeft

		anchors {
			top: parent.top
			topMargin: 85 // 119
			left: parent.left
			leftMargin: 58 // 89
		}

		width: 193
		height: 69
		rotation: 180
		source: "qrc:/images/boat_glow.png"
	}

	CP.ColorImage {
		id: bottomLeft

		anchors {
			top: parent.top
			topMargin: 227 // 296
			left: topLeft.left
		}
		width: 193
		height: 69
		mirror: true
		source: "qrc:/images/boat_glow.png"
	}

	CP.ColorImage {
		id: topRight
		anchors {
			top: topLeft.top
			right: parent.right
			rightMargin: 58 // 89
		}
		width: 193
		height: 69
		mirror: true
		rotation: 180
		source: "qrc:/images/boat_glow.png"
	}

	CP.ColorImage {
		id: bottomRight
		anchors {
			bottom: bottomLeft.bottom
			right: topRight.right
		}
		width: 193
		height: 69
		source: "qrc:/images/boat_glow.png"
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

	Column {
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

	/*
	CircularSingleGauge {
		id: centerGauge

		readonly property var properties: Gauges.tankProperties(VenusOS.Tank_Type_Battery)
		readonly property var battery: Global.system.battery

		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		width: 360 //Theme.geometry_mainGauge_size
		height: 360 // width
		name: properties.name
		icon.source: battery.icon
		value: visible && !isNaN(battery.stateOfCharge) ? battery.stateOfCharge : 0
		voltage: battery.voltage
		current: battery.current
		power: battery.power
		status: Theme.getValueStatus(value, properties.valueType)
		caption: Utils.formatBatteryTimeToGo(battery.timeToGo, VenusOS.Battery_TimeToGo_LongFormat)
		startAngle: 225
		endAngle: 115
		animationEnabled: false
		shineAnimationEnabled: false

		Rectangle {
			anchors.fill: parent
			color: "green"
			opacity: 0.1
		}
	}
	*/

	ProgressArc {
		anchors {
			top: parent.top
			topMargin: 32
			horizontalCenter: parent.horizontalCenter
		}
		//y: (root._unexpandedHeight - height) / 2
		rotation: 225
		width: 320 //Theme.geometry_mainGauge_size
		height: 320 // width
		radius: width/2
		startAngle: 0
		endAngle: 270
		value: 33 // visible && !isNaN(battery.stateOfCharge) ? battery.stateOfCharge : 0
		//progressColor: Theme.color_darkOk,Theme.statusColorValue(loader.gaugeStatus)
		//remainderColor: Theme.color_darkOk,Theme.statusColorValue(loader.gaugeStatus, true)
		strokeWidth: 24
		animationEnabled: false

		CP.ColorImage {
			anchors {
				verticalCenter: parent.verticalCenter
			}
			//transformOrigin: Item.BottomRight

			width: 40
			height: width
			color: stateOfCharge.valueColor
			source: "qrc:/images/indicator_5_.png"
		}
	}



	/*
qml:
Battery: {
"objectName":"",
"systemServiceUid":"mqtt/system/0",
"stateOfCharge":null,
"voltage":null,
"power":null,
"current":null,
"temperature":null,
"timeToGo":null,
"icon":"qrc:/images/icon_battery_24.svg",
"mode":0,
"_stateOfCharge":{
"objectName":"",
"min":0,
"max":2147483647,
"defaultMin":0,
"defaultMax":2147483647,
"text":"--",
"uid":"mqtt/system/0/Dc/Battery/Soc",
"state":4,"
seen":true,
"unit":"",
"decimals":0,
"invalidText":"--",
"displayUnit":-1,
"sourceUnit":-1,
"sourceMin":2147483647,
"sourceMax":2147483647,
"defaultSourceMin":0,
"defaultSourceMax":2147483647,
"isSetting":true,
"isValid":false,
"invalidate":true},
"_voltage":{
"objectName":"",
"min":0,
"max":2147483647,
"defaultMin":0,
"defaultMax":2147483647,
"text":"--",
"uid":"mqtt/system/0/Dc/Battery/Voltage",
"state":4,
"seen":true,
"unit":"",
"decimals":0,
"invalidText":"--",
"displayUnit":-1,
"sourceUnit":-1,
"sourceMin":2147483647,
"sourceMax":2147483647,
"defaultSourceMin":0,
"defaultSourceMax":2147483647,
"isSetting":true,
"isValid":false,
"invalidate":true
},
"_power":{
"objectName":"",
"min":0,
"max":2147483647,
"defaultMin":0,
"defaultMax":2147483647,
"text":"--",
"uid":"mqtt/system/0/Dc/Battery/Power",
"state":4,
"seen":true,
"unit":"",
"decimals":0,
"invalidText":"--",
"displayUnit":-1,
"sourceUnit":-1,
"sourceMin":2147483647,
"sourceMax":2147483647,
"defaultSourceMin":0,
"defaultSourceMax":2147483647,
"isSetting":true,
"isValid":false,
"invalidate":true},
"_current":{
"objectName":"","min":0,"max":2147483647,"defaultMin":0,"defaultMax":2147483647,"text":"--","uid":"mqtt/system/0/Dc/Battery/Current","state":4,"seen":true,"unit":"","decimals":0,"invalidText":"--","displayUnit":-1,"sourceUnit":-1,"sourceMin":2147483647,"sourceMax":2147483647,"defaultSourceMin":0,"defaultSourceMax":2147483647,"isSetting":true,"isValid":false,"invalidate":true},"_temperature":{"objectName":"","min":0,"max":2147483647,"defaultMin":0,"defaultMax":2147483647,"text":"--","uid":"mqtt/system/0/Dc/Battery/Temperature","state":4,"seen":true,"unit":"","decimals":0,"invalidText":"--","displayUnit":-1,"sourceUnit":-1,"sourceMin":2147483647,"sourceMax":2147483647,"defaultSourceMin":0,"defaultSourceMax":2147483647,"isSetting":true,"isValid":false,"invalidate":true},
"_timeToGo":{
"objectName":"","min":0,"max":2147483647,"defaultMin":0,"defaultMax":2147483647,"text":"--","uid":"mqtt/system/0/Dc/Battery/TimeToGo","state":4,"seen":true,"unit":"","decimals":0,"invalidText":"--","displayUnit":-1,"sourceUnit":-1,"sourceMin":2147483647,"sourceMax":2147483647,"defaultSourceMin":0,"defaultSourceMax":2147483647,"isSetting":true,"isValid":false,"invalidate":true}}
*/

}

