/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Rectangle {
	id: root

	required property CamperTheme theme
	// Screen px per design px, from the scene.
	required property real designScale

	property real value: NaN
	property bool charging: false
	property bool discharging: false
	property bool alarm: false
	readonly property real _doubleBorderWidth: border.width * 2

	// The alarm look wins over charging or discharging.
	readonly property color _fillColor: alarm ? theme.colors.batteryAlarmFill
			: discharging ? theme.colors.batteryDischargingFill
			: charging ? theme.colors.batteryChargingFill
			: theme.colors.batteryIdleFill

	implicitWidth: Math.round(theme.batteryWidth * designScale)
	implicitHeight: Math.round(theme.batteryHeight * designScale)
	radius: theme.batteryRadius * designScale
	color: theme.colors.batteryBackground
	border.width: Math.max(1, Math.round(theme.batteryBorderWidth * designScale))
	border.color: alarm ? theme.colors.batteryAlarmBorder
			: discharging ? theme.colors.batteryDischargingBorder
			: charging ? theme.colors.batteryChargingBorder
			: theme.colors.batteryIdleBorder

	Rectangle { // The internal color representing charge amount
		anchors {
			left: parent.left
			leftMargin: root._doubleBorderWidth
			top: parent.top
			topMargin: root._doubleBorderWidth
			bottom: parent.bottom
			bottomMargin: root._doubleBorderWidth
		}

		readonly property real _fullWidth: root.width - root.border.width * 4
		readonly property real _innerRadius: Math.max(0, root.radius - root.border.width)
		// Round the right edge only once it reaches the outline's corners, so a full battery
		// follows the outline instead of poking past it.
		readonly property real _rightRadius: Math.max(0, _innerRadius - (_fullWidth - width))

		width: _fullWidth * (isFinite(root.value) ? Math.max(0, Math.min(100, root.value)) / 100 : 0)
		bottomLeftRadius: _innerRadius
		topLeftRadius: _innerRadius
		bottomRightRadius: _rightRadius
		topRightRadius: _rightRadius
		color: root._fillColor
	}

	Rectangle {
		width: Math.round(root.theme.batteryNubWidth * root.designScale)
		height: Math.round(root.theme.batteryNubHeight * root.designScale)
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
			property color color: root.theme.colors.batteryIcon
			property bool style: root.charging

			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
			}
			width: height
			height: Math.round(root.theme.batteryIconSize * root.designScale)
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
			visible: root.charging || root.discharging
		}

		Text {
			id: batteryText
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				left: batteryIcon.visible ? batteryIcon.right : parent.left
			}

			text: isFinite(root.value) ? Math.round(root.value) + "%" : "--%"
			color: root.theme.colors.batteryText
			font.family: root.theme.quantityFontFamily
			font.pixelSize: Math.round(root.theme.valueFontSize * root.designScale)
			font.weight: root.theme.valueFontWeight
			font.letterSpacing: root.theme.valueLetterSpacing * root.designScale
		}
	}
}