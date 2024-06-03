/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// CheapBarGauge is cheaper to render than BarGauge or ClippingBarGauge
// as it does not require any shader or clip to work.
// However, there are some trade-offs:
// - the top of the foreground bar is rounded, unlike the design.
// - vertical gauges are not animated, as it would require animating
//   at a minimum both y and height, and at very small values also
//   x and width and radius.
// - at very small values, it will appear as a tiny dot rather than
//   matching design (i.e. squared fill of the background groove).
//
// CheapBarGauge should be used on the OverviewPage and BriefPage
// on GX devices (or any future view where animation is common).

Rectangle {
	id: bgRect

	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	readonly property int valueStatus: Theme.getValueStatus(_value * 100, valueType)
	property alias foregroundParent: fgRect.parent
	property color foregroundColor: Theme.color_darkOk,Theme.statusColorValue(valueStatus)
	property color backgroundColor: Theme.color_darkOk,Theme.statusColorValue(valueStatus, true)
	property color surfaceColor: Theme.color_levelsPage_gauge_separatorBarColor
	property real value: 0.0
	property int orientation: Qt.Vertical
	property bool animationEnabled

	color: backgroundColor
	width: _isVertical ? Theme.geometry_barGauge_vertical_width_large : parent.width
	height: _isVertical ? parent.height : Theme.geometry_barGauge_horizontal_height
	radius: _isVertical ? width / 2 : height / 2

	readonly property bool _isVertical: orientation === Qt.Vertical
	readonly property bool _valueNaN: isNaN(value)
	readonly property real _value: _valueNaN ? 0
		: value > 1.0 ? 1.0
		: value < 0.0 ? 0.0
		: value

	Rectangle {
		id: fgRect
		x: _isVert && _useSmallerRadius ? (bgRect.width - width)/2 : 0
		y: _isVert ? _bgHeight - _fgSize : (_useSmallerRadius ? (bgRect.height - height)/2 : 0)
		width: _isVert ? (_useSmallerRadius ? height : _bgWidth) : _fgSize
		height: _isVert ? _fgSize : (_useSmallerRadius ? width : _bgHeight)
		color: bgRect.foregroundColor
		radius: _useSmallerRadius ? _smallerRadius : bgRect.radius

		property bool _isVert: bgRect._isVertical
		property bool _useSmallerRadius: _smallerRadius < bgRect.radius
		property real _smallerRadius: _isVert ? height/2 : width/2
		property real _bgHeight: bgRect.height
		property real _bgWidth: bgRect.width
		property real _fgSize: _isVert ? _bgHeight * bgRect._value : _bgWidth * bgRect._value

		Behavior on width {
			enabled: !bgRect._isVertical && bgRect.animationEnabled
			NumberAnimation {
				duration: Theme.animation_briefPage_sidePanel_sliderValueChange_duration
			}
		}
	}
}
