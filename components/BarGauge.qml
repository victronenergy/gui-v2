/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A vertical or horizontal bar gauge.

	This is drawn as a foreground rectangle (showing the progress) on top of a background rectangle
	(showing the total value). The progress (as indicated by the edge of the foreground) is straight
	until it approaches the total, at which point the corners will begin to round off to match the
	corner radii of the background.
*/
Item {
	id: root

	required property bool animationEnabled
	property real value: 0.0
	property int orientation: Qt.Vertical
	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	property int borderWidth
	property color borderColor: Theme.color_overviewPage_widget_border
	property int radius: Theme.geometry_overviewPage_widget_radius

	// The status that determines the foreground/background colours. The calculation uses 'value'
	// rather than 'animatedValue' to reduce possible colour changes.
	readonly property int valueStatus: isNaN(value) ? Theme.Ok
			: Theme.getValueStatus(Math.max(0, Math.min(1, value)) * 100, valueType)
	property color foregroundColor: Theme.color_darkOk,Theme.statusColorValue(valueStatus)
	property color backgroundColor: Theme.color_darkOk,Theme.statusColorValue(valueStatus, true)

	// The radius of the two end corners (on top edge when vertical, or right edge when horizontal).
	// By default, these are progressively rounded as the progress reaches the total, to prevent the
	// progress rect fill colour from spilling over the bgRect corners.
	property int endRadius: Math.max(0, clampedRadius - (_totalSize - _progressSize))

	// The radius of the two start corners (on bottom edge when vertical, or left edge when horizontal).
	readonly property int startRadius: clampedRadius

	// Ensure the radius is not larger than what is supported by the bar dimensions; otherwise
	// the calculated endRadius does not fit as snugly.
	readonly property int clampedRadius: Math.max(0, Math.min(radius, (orientation === Qt.Vertical ? width : height) / 2))

	// Same as value, but clamped and animated for value changes.
	readonly property real animatedValue: _clampedAnimatedValue

	//--- Internal values below ---

	// The total/progress width in horizontal orientation, or height in vertical.
	readonly property real _totalSize: orientation === Qt.Vertical ? height : width
	readonly property real _progressSize: orientation === Qt.Vertical ? height * animatedValue : width * animatedValue

	// When _progressSize is smaller than the radius, shrink the width (when vertical) or
	// height (when horizontal) to prevent the fgRect fill from spilling over bgRect's corners.
	// Note: this means at very small values, the bar will appear as a tiny dot.
	readonly property real _autoShrinkOffset: _progressSize < clampedRadius ? 2 * (clampedRadius - _progressSize) : 0

	property real _clampedAnimatedValue: isNaN(value) ? 0
			: value > 1.0 ? 1.0
			: value < 0.0 ? 0.0
			: value
	Behavior on _clampedAnimatedValue {
		enabled: root.animationEnabled
		NumberAnimation { duration: Theme.animation_briefPage_sidePanel_sliderValueChange_duration }
	}

	implicitWidth: orientation === Qt.Vertical ? Theme.geometry_barGauge_vertical_width_large : Theme.geometry_control_width
	implicitHeight: orientation === Qt.Vertical ? Theme.geometry_button_height : Theme.geometry_barGauge_horizontal_height

	// Base rectangle filled with background color.
	Rectangle {
		id: bgRect

		anchors.fill: parent
		radius: root.clampedRadius
		color: root.backgroundColor
	}

	// Rectangle filled with foreground colour, which indicates the current progress.
	// (Instead of using a MultiEffect+mask to crop the edges of the foreground rectangle when the
	// progress reaches the start/end, just adjust the rectangle's geometry/radius to fit, as the
	// masking approach does not render reliably; see issue #3186. Item::clip also cannot be used
	// for this as clipping has straight edges, not rounded.)
	Rectangle {
		id: fgRect

		x: root.orientation === Qt.Vertical && root._autoShrinkOffset > 0 ? (root.width - width) / 2 : 0
		y: root.orientation === Qt.Vertical ? root.height - root._progressSize : (root._autoShrinkOffset > 0 ? (root.height - height) / 2 : 0)
		width: root.orientation === Qt.Vertical ? root.width - root._autoShrinkOffset : root._progressSize
		height: root.orientation === Qt.Vertical ? root._progressSize : root.height - root._autoShrinkOffset
		topLeftRadius: root.orientation === Qt.Vertical ? endRadius : startRadius
		topRightRadius: endRadius
		bottomLeftRadius: startRadius
		bottomRightRadius: root.orientation === Qt.Vertical ? startRadius : endRadius
		color: root.foregroundColor
	}

	// Rectangle with border, which is overlaid on top.
	Rectangle {
		anchors.fill: parent
		border.width: root.borderWidth
		border.color: root.borderColor
		color: "transparent"
		radius: root.clampedRadius
		visible: root.borderWidth > 0
	}
}
