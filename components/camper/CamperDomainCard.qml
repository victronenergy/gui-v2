/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Item {
	id: root

	property url iconSource
	property string title
	property real value: NaN
	property bool active: false
	property bool warning: false
	property bool alarm: false
	property string valueOverride: ""
	property string unitOverride: ""

	readonly property color _cardColor: alarm ? "#FFE9DF"
			: warning ? "#FFF3E6"
			: active ? "#C5DBF8"
			: "#FFFFFF"
	readonly property color _cardBorderColor: alarm ? "#E86A3D"
			: warning ? "#E99B44"
			: active ? "#2F70D8"
			: "#DCE3EB"
	readonly property color _primaryTextColor: alarm ? "#B14824"
			: warning ? "#8F5A20"
			: "#6D757F"
	readonly property color _secondaryTextColor: _primaryTextColor
	readonly property real _borderWidth: active || warning || alarm ? 2
			: 1
	readonly property real _radius: Math.max(10, Math.round(height * 0.19))
	readonly property real _iconSize: Math.max(12, Math.round(height * 0.23))
	readonly property real _hMargin: Math.max(10, Math.round(width * 0.10))
	readonly property real _vMargin: Math.max(7, Math.round(height * 0.11))
	readonly property real _unitSpacing: 4
	readonly property int _titleFontSize: Math.max(14, Math.round(height * 0.25))
	readonly property int _valueFontSize: Math.max(28, Math.round(height * 0.40))
	readonly property bool _iconNeedsBacking: !active && !warning && !alarm

	readonly property var _formattedValue: _formatPower(value, valueOverride, unitOverride)

	function _formatPower(power, overrideValue, overrideUnit) {
		if (overrideValue.length > 0) {
			return {
				valueText: overrideValue,
				unitText: overrideUnit
			}
		}
		if (!isFinite(power)) {
			return { valueText: "--", unitText: "" }
		}

		const absoluteValue = Math.abs(power)
		if (absoluteValue >= 1000) {
			const kiloWattsDecimals = absoluteValue >= 10000 ? 0
					: 1
			return {
				valueText: (absoluteValue / 1000).toFixed(kiloWattsDecimals),
				unitText: "kW"
			}
		}

		return {
			valueText: Math.round(absoluteValue).toString(),
			unitText: "W"
		}
	}

	Rectangle {
		anchors {
			fill: card
			topMargin: 3
		}
		radius: card.radius
		color: "#2A000000"
	}

	Rectangle {
		id: card

		anchors.fill: parent
		color: root._cardColor
		border.width: root._borderWidth
		border.color: root._cardBorderColor
		radius: root._radius

		Column {
			anchors {
				fill: parent
				leftMargin: root._hMargin
				rightMargin: root._hMargin
				topMargin: root._vMargin
				bottomMargin: root._vMargin
			}
			spacing: Math.max(3, Math.round(root._vMargin * 0.55))

			Row {
				width: parent.width
				height: root._iconSize
				spacing: Math.max(6, Math.round(root._hMargin * 0.40))

				Rectangle {
					width: root._iconSize
					height: root._iconSize
					radius: width * 0.50
					color: root._iconNeedsBacking ? "#95A1AF"
						: "transparent"

					Image {
						anchors.centerIn: parent
						width: root._iconNeedsBacking ? Math.max(10, Math.round(parent.width * 0.62))
							: parent.width
						height: width
						source: root.iconSource
						fillMode: Image.PreserveAspectFit
						opacity: root._iconNeedsBacking ? 1.0
							: 0.95
						smooth: true
					}
				}

				Text {
					width: parent.width - root._iconSize - parent.spacing
					anchors.verticalCenter: parent.verticalCenter
					text: root.title
					color: root._primaryTextColor
					font.bold: true
					font.pixelSize: root._titleFontSize
					elide: Text.ElideRight
				}
			}

			Item {
				width: parent.width
				height: parent.height - root._iconSize - parent.spacing

				Text {
					id: valueText

					anchors {
						left: parent.left
						bottom: parent.bottom
					}
					text: root._formattedValue.valueText
					color: root._primaryTextColor
					font.pixelSize: root._valueFontSize
					font.weight: Font.DemiBold
					elide: Text.ElideRight
				}

				Text {
					anchors {
						left: valueText.right
						leftMargin: root._unitSpacing
						baseline: valueText.baseline
					}
					text: root._formattedValue.unitText
					color: root._secondaryTextColor
					font.pixelSize: root._titleFontSize
					visible: text.length > 0
				}
			}
		}
	}
}
