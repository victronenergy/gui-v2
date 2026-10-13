/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	required property int minimumValue
	required property int maximumValue
	required property int stepSize
	required property int highlightedValue
	required property color minimumValueColor
	required property color maximumValueColor
	required property color highlightedValueColor
	required property Gradient gradient
	required property bool animationEnabled
	required property real value
	property int orientation: Qt.Vertical

	function _barPosForValue(v) {
		const range = maximumValue - minimumValue
		if (range === 0) {
			console.warn("Ignoring zero range! Min:", minimumValue, "Max:", maximumValue)
			return 0
		}
		const tickSize = Theme.geometry_size_4
		const totalLength = orientation === Qt.Horizontal ? gaugeBar.width : gaugeTicks.height
		const unitsPerPixel = (totalLength - tickSize) / range
		const unitCount = v - minimumValue
		let pos = (unitsPerPixel * unitCount) + tickSize/2
		if (orientation === Qt.Vertical) {
			// For vertical bars, the value is inverted, i.e. the min value is at the bottom.
			pos = totalLength - pos
		}
		return Math.max(0, Math.min(pos, totalLength))
	}

	implicitHeight: root.orientation === Qt.Vertical ? 0
			: gaugeBar.height + gaugeTicks.height + Theme.geometry_size_8

	Rectangle {
		id: gaugeBar

		x: root.orientation === Qt.Horizontal ? 0
			: parent.width/2 - valueMarker.width + Theme.geometry_size_4/2
		width: root.orientation === Qt.Vertical ? Theme.geometry_size_8 : parent.width
		height: root.orientation === Qt.Vertical
				? parent.height - bottomSeparator.height - 2*Theme.geometry_size_8
				: Theme.geometry_size_8
		radius: root.orientation === Qt.Vertical ? width / 2 : height / 2
		gradient: root.gradient
		rotation: root.orientation === Qt.Vertical ? 0 : 180 // when horizontal, min is on left, max on right
	}

	Flow {
		id: gaugeTicks

		anchors {
			horizontalCenter: root.orientation === Qt.Vertical ? parent.horizontalCenter : gaugeBar.horizontalCenter
			verticalCenter: root.orientation === Qt.Vertical ? gaugeBar.verticalCenter : undefined
			top: root.orientation === Qt.Vertical ? undefined : gaugeBar.bottom
			topMargin: Theme.geometry_size_8
		}
		flow: root.orientation === Qt.Vertical ? Flow.TopToBottom : Flow.LeftToRight
		spacing: ((root.orientation === Qt.Vertical ? gaugeBar.height - 2*Theme.geometry_size_4 : gaugeBar.width)
					- (tickRepeater.count * Theme.geometry_size_4))
						/ (tickRepeater.count - 1)

		Repeater {
			id: tickRepeater

			model: (root.maximumValue + root.stepSize - root.minimumValue) / root.stepSize
			delegate: Item {
				required property int index
				readonly property int tickValue: {
					// For vertical bars, the value is inverted, i.e. the min value is at the bottom.
					const tickIndex = root.orientation === Qt.Vertical ? tickRepeater.count - index - 1 : index
					return minimumValue + (root.stepSize * tickIndex)
				}

				width: Theme.geometry_size_4
				height: Theme.geometry_size_4

				Label {
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: root.orientation === Qt.Vertical ? undefined : parent.horizontalCenter
					leftPadding: Theme.geometry_inset_landscape
					text: tickValue === root.maximumValue ? root.maximumValue
						: tickValue === root.minimumValue ? root.minimumValue
						: tickValue === root.highlightedValue ? tickValue
						: ""
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_levelsGauge_secondary
				}

				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.geometry_size_4
					height: Theme.geometry_size_4
					radius: Theme.geometry_size_4
					color: tickValue === root.maximumValue ? root.maximumValueColor
						 : tickValue === root.minimumValue ? root.minimumValueColor
						 : tickValue === root.highlightedValue ? root.highlightedValueColor
						 : Theme.color_levelsPage_environment_gauge_tick
					visible: root.orientation === Qt.Vertical
				}
			}
		}
	}

	Rectangle {
		id: valueMarker

		visible: !isNaN(root.value)
		x: root.orientation === Qt.Vertical ? gaugeBar.x : root._barPosForValue(root.value) - width/2
		y: root.orientation === Qt.Vertical ? Theme.geometry_size_4 + root._barPosForValue(root.value) - height/2 : 0
		width: root.orientation === Qt.Vertical
			   ? Theme.geometry_environmentGauge_valueMarker_background_width
			   : gaugeBar.height
		height: root.orientation === Qt.Vertical
				? Theme.geometry_size_8
				: gaugeBar.height
		color: Theme.color_environmentGaugePanel_background
		radius: root.orientation === Qt.Horizontal ? height / 2 : 0

		Behavior on x {
			// Only animate when the value has changed, and not when the page is resizing
			enabled: root.animationEnabled && (!Global.pageManager?.animatingIdleResize)
					&& root.orientation === Qt.Horizontal
			XAnimator {}
		}
		Behavior on y {
			enabled: root.animationEnabled && (!Global.pageManager?.animatingIdleResize)
					 && root.orientation === Qt.Vertical
			YAnimator {}
		}

		Rectangle {
			anchors {
				fill: parent
				leftMargin: root.orientation === Qt.Vertical ? 0 : Theme.geometry_size_2
				rightMargin: root.orientation === Qt.Vertical ? 0 : Theme.geometry_size_2
				topMargin: Theme.geometry_size_2
				bottomMargin: Theme.geometry_size_2
			}
			color: Theme.color_font_primary

			// When horizontal, round all corners. In vertical, only round right-edge corners.
			topLeftRadius: root.orientation === Qt.Horizontal ? height / 2 : 0
			bottomLeftRadius: root.orientation === Qt.Horizontal ? height / 2 : 0
			topRightRadius: height / 2
			bottomRightRadius: height / 2
		}
	}

	SeparatorBar {
		id: bottomSeparator

		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		visible: root.orientation === Qt.Vertical
	}
}
