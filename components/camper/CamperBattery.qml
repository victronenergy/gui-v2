/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Rectangle {
	id: root

	// BatteryState
	// 0 - Idle
	// 1 - Charging
	// 2 - Discharging
	// 3 - Low
	property int batteryState: 1
	property int charge: 66
	property int colorScheme: 0

	readonly property real batteryNubWidth: Math.max(4, Math.round(height * 0.08))
	readonly property color _backgroundColor: colorScheme === 0 ? "#F8F9FA" : "#121518"
	readonly property var _batteryColor: colorScheme === 0 ? [ "#CCE5FF", "#C0F0D4", "#FFE4B8", "#FBD2C5" ] : [ "#002A54", "#042E15", "#522F00", "#561400" ]
	readonly property var _batteryBorderColor: colorScheme === 0 ? [ "#005FBE", "#148443", "#FF9500", "#DB3500" ] : [ "#3395FF", "#33E47D", "#FF9500", "#FF5C28" ]
	readonly property color _iconColor: root.colorScheme === 0 ? "#121518" : "#F1F3F5"
	readonly property color _textColor: root.colorScheme === 0 ? "#343A40" : "#DEE2E6"

	readonly property real _doubleBorderWidth: border.width * 2

	radius: Math.round(height/5)
	color: _backgroundColor
	border.width: Math.max(1, height/22)
	border.color: _batteryBorderColor[root.batteryState]

	Rectangle { // The internal color representing charge amount
		anchors {
			left: parent.left
			leftMargin: root._doubleBorderWidth
			top: parent.top
			topMargin: root._doubleBorderWidth
			bottom: parent.bottom
			bottomMargin: root._doubleBorderWidth
		}

		width: (root.width - root.border.width * 4) * (root.charge / 100)
		bottomLeftRadius: root.radius - root.border.width
		topLeftRadius: root.radius - root.border.width
		bottomRightRadius: 0 // math here
		topRightRadius: 0 // math here
		color: _batteryColor[root.batteryState]
	}

	Rectangle {
		width: root.batteryNubWidth
		height: Math.round(parent.height/3)
		x: parent.width + width/4
		y: Math.round((parent.height - height)/2)
		bottomRightRadius: width
		topRightRadius: width
		color: root.border.color
	}

	Item {
		anchors.centerIn: parent
		width: batteryIcon.visible ? batteryText.implicitWidth + batteryIcon.width : batteryText.implicitWidth
		height: parent.height

		Canvas {
			id: batteryIcon
			property color color: root._iconColor
			property bool style: root.batteryState === 1 ? true : false

			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
			}
			width: height
			height: Math.max(16, Math.round(parent.height * 0.45))
			onPaint: {
				const ctx = getContext("2d")
				ctx.clearRect(0, 0, width, height)
				ctx.fillStyle = color
				ctx.beginPath()
				if (style) { // bolt
					ctx.moveTo(width * 0.58, 0)
					ctx.lineTo(width * 0.06, height * 0.52)
					ctx.lineTo(width * 0.42, height * 0.52)
					ctx.lineTo(width * 0.30, height)
					ctx.lineTo(width * 0.94, height * 0.40)
					ctx.lineTo(width * 0.54, height * 0.40)
				} else { // arrow
					ctx.moveTo(width * 0.35, height * 0.1)
					ctx.lineTo(width * 0.35, height * 0.5)
					ctx.lineTo(width * 0.1, height * 0.5)
					ctx.lineTo(width * 0.5, height * 0.9)
					ctx.lineTo(width * 0.9, height * 0.5)
					ctx.lineTo(width * 0.65, height * 0.5)
					ctx.lineTo(width * 0.65, height * 0.1)
				}
				ctx.closePath()
				ctx.fill()
			}
			onColorChanged: requestPaint()
			onStyleChanged: requestPaint()
			onWidthChanged: requestPaint()
			onHeightChanged: requestPaint()
			Component.onCompleted: requestPaint()
			visible: root.batteryState === 1 || root.batteryState === 2
		}

		Text {
			id: batteryText
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				left: batteryIcon.visible ? batteryIcon.right : parent.left
			}

			text: root.charge + "%"
			color: root._textColor
			font.pixelSize: Math.max(16, Math.round(parent.height * 0.6))
			font.bold: true
		}
	}
}