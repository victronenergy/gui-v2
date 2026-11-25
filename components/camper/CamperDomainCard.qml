/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP

Item {
	id: root

	required property CamperTheme theme
	// Screen px per design px, from the scene.
	required property real designScale
	// Formats a finite power in Watts as { number, unit }. The host provides it, so that gui-v2 uses Units.
	required property var powerFormatter

	property url iconSource
	property string title
	property real value: NaN
	property bool active: false
	property bool alarm: false

	readonly property real _hPadding: theme.cardHorizontalPadding * designScale
	readonly property real _rowHeight: theme.cardRowHeight * designScale

	readonly property var _formattedValue: isFinite(value) ? powerFormatter(value) : { number: "--", unit: "" }

	// Hugs the wider row, as the design's card does.
	implicitWidth: Math.ceil(Math.max(titleRow.implicitWidth, valueLabel.implicitWidth) + 2 * _hPadding)
	implicitHeight: Math.round(theme.cardHeight * designScale)

	// The design's drop shadow, from a pre-blurred 9-slice image: a blur effect would cost a shader
	// pass per card. The image is drawn at its own scale, then scaled down to the scene.
	BorderImage {
		// These match tools/camper-card-shadow.py: image px per design px, and in design px, how far
		// the shadow reaches past the card and the size of each slice.
		readonly property real _imageScale: 8
		readonly property real _reach: 6
		readonly property real _slice: 14

		x: -_reach * root.designScale
		y: (root.theme.cardShadowOffsetY - _reach) * root.designScale
		width: (root.width / root.designScale + 2 * _reach) * _imageScale
		height: (root.height / root.designScale + 2 * _reach) * _imageScale
		scale: root.designScale / _imageScale
		transformOrigin: Item.TopLeft
		source: "qrc:/images/camper/camper_card_shadow.png"
		border.left: _slice * _imageScale
		border.right: _slice * _imageScale
		border.top: _slice * _imageScale
		border.bottom: _slice * _imageScale
	}

	Rectangle {
		id: background

		anchors.fill: parent
		radius: root.theme.cardRadius * root.designScale
		color: root.alarm ? root.theme.colors.cardAlarmBackground
			: root.active ? root.theme.colors.cardActiveBackground
			: root.theme.colors.cardBackground
	}

	// Drawn over the fill, so that a translucent border tints it as in the design.
	Rectangle {
		anchors.fill: parent
		radius: background.radius
		color: "transparent"
		border.width: Math.max(1, Math.round(root.theme.cardBorderWidth * root.designScale))
		border.color: root.alarm ? root.theme.colors.cardAlarmBorder
			: root.active ? root.theme.colors.cardActiveBorder
			: root.theme.colors.cardBorder
	}

	Column {
		x: root._hPadding
		y: root.theme.cardVerticalPadding * root.designScale
		opacity: root.active || root.alarm ? 1 : root.theme.cardInactiveContentOpacity

		Row {
			id: titleRow

			height: root._rowHeight
			spacing: root.theme.cardIconSpacing * root.designScale

			CP.ColorImage {
				width: Math.round(root.theme.cardIconSize * root.designScale)
				height: width
				anchors.verticalCenter: parent.verticalCenter
				source: root.iconSource
				sourceSize: Qt.size(width, height)
				color: root.theme.colors.secondaryText
			}

			Text {
				anchors.verticalCenter: parent.verticalCenter
				text: root.title
				color: root.theme.colors.secondaryText
				font.family: root.theme.fontFamily
				font.pixelSize: Math.round(root.theme.titleFontSize * root.designScale)
				font.weight: root.theme.titleFontWeight
				font.letterSpacing: root.theme.titleLetterSpacing * root.designScale
			}
		}

		// The value and unit share one style with no gap, so they are one label.
		Text {
			id: valueLabel

			height: root._rowHeight
			verticalAlignment: Text.AlignVCenter
			text: root._formattedValue.number + root._formattedValue.unit
			color: root.theme.colors.primaryText
			font.family: root.theme.quantityFontFamily
			font.pixelSize: Math.round(root.theme.valueFontSize * root.designScale)
			font.weight: root.theme.valueFontWeight
			font.letterSpacing: root.theme.valueLetterSpacing * root.designScale
		}
	}
}
