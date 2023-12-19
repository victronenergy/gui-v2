/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Item {
	id: root

	property alias icon: typeIcon
	property alias text: typeLabel.text
	property alias value: quantityLabel.value
	property alias unit: quantityLabel.unit

	property int minimumValue: 0
	property int maximumValue: 100
	property int highlightedValue: 0
	property color minimumValueColor
	property color maximumValueColor
	property color highlightedValueColor

	property alias gradient: gaugeBar.gradient
	property bool animationEnabled

	function _barYPosForValue(v) {
		const range = maximumValue - minimumValue
		if (range === 0) {
			console.warn("Ignoring zero range! Min:", minimumValue, "Max:", maximumValue)
			return 0
		}
		const tickHeight = Theme.geometry_levelsPage_environment_gauge_tick_size
		const unitsPerPixel = (gaugeTicks.height - tickHeight) / range
		const unitCount = v - minimumValue
		const pos = gaugeBar.height - (gaugeTicks.anchors.bottomMargin + (unitsPerPixel * unitCount)) - tickHeight/2
		return Math.max(0, Math.min(pos, gaugeBar.height))
	}

	width: Theme.geometry_levelsPage_environment_gauge_width
	height: parent.height

	CP.ColorImage {
		id: typeIcon

		anchors {
			top: parent.top
			topMargin: Theme.geometry_levelsPage_environment_gauge_icon_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry_levelsPage_environment_gauge_icon_size
		height: Theme.geometry_levelsPage_environment_gauge_icon_size
		fillMode: Image.Pad
		color: Theme.color_font_primary
	}

	Label {
		id: typeLabel

		anchors {
			top: typeIcon.bottom
			topMargin: Theme.geometry_levelsPage_environment_gauge_typeLabel_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: Theme.font_size_caption
		color: Theme.color_font_primary
	}

	Column {
		id: gaugeTicks

		anchors {
			top: gaugeBar.top
			bottom: gaugeBar.bottom
			topMargin: Theme.geometry_levelsPage_environment_gauge_bar_padding
			bottomMargin: Theme.geometry_levelsPage_environment_gauge_bar_padding
			horizontalCenter: parent.horizontalCenter
		}
		spacing: (height - (tickRepeater.count * Theme.geometry_levelsPage_environment_gauge_tick_size)) / (tickRepeater.count - 1)

		Repeater {
			id: tickRepeater

			model: (root.maximumValue + Theme.geometry_levelsPage_environment_gauge_tick_step - root.minimumValue) / Theme.geometry_levelsPage_environment_gauge_tick_step
			delegate: Item {
				readonly property int tickValue: {
					const invertedIndex = tickRepeater.count - index - 1
					return minimumValue + (Theme.geometry_levelsPage_environment_gauge_tick_step * invertedIndex)
				}

				width: Theme.geometry_levelsPage_environment_gauge_tick_size
				height: Theme.geometry_levelsPage_environment_gauge_tick_size

				Label {
					id: tickLabel

					anchors.verticalCenter: parent.verticalCenter
					leftPadding: Theme.geometry_levelsPage_environment_gauge_tick_margin
					text: model.index === 0 ? root.maximumValue
						: model.index === tickRepeater.count - 1 ? root.minimumValue
						: tickValue === root.highlightedValue ? tickValue
						: ""
					color: Theme.color_levelsPage_environment_gauge_tickText
					font.pixelSize: Theme.font_size_caption
				}

				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.geometry_levelsPage_environment_gauge_tick_size
					height: Theme.geometry_levelsPage_environment_gauge_tick_size
					radius: Theme.geometry_levelsPage_environment_gauge_tick_size
					color: model.index === 0 ? root.maximumValueColor
						 : model.index === tickRepeater.count - 1 ? root.minimumValueColor
						 : tickValue === root.highlightedValue ? root.highlightedValueColor
						 : Theme.color_levelsPage_environment_gauge_tick
				}
			}
		}
	}

	Rectangle {
		id: gaugeBar

		anchors {
			top: typeLabel.bottom
			topMargin: Theme.geometry_levelsPage_environment_gauge_bar_topMargin
			bottom: quantitySeparator.top
			bottomMargin: Theme.geometry_levelsPage_environment_gauge_bar_bottomMargin
			right: gaugeTicks.left
			rightMargin: Theme.geometry_levelsPage_environment_gauge_tick_margin
		}
		width: Theme.geometry_levelsPage_environment_gauge_bar_width
		radius: Theme.geometry_levelsPage_environment_gauge_bar_radius

		Rectangle {
			id: valueMarker

			visible: !isNaN(root.value)
			y: root._barYPosForValue(root.value) - height/2
			width: Theme.geometry_levelsPage_environment_gauge_valueMarker_width
			height: Theme.geometry_levelsPage_environment_gauge_valueMarker_background_height
			color: Theme.color_levelsPage_environment_panel_background

			Behavior on y {
				// Only animate when the value has changed, and not when the page is resizing
				enabled: root.animationEnabled && (!!Global.pageManager && !Global.pageManager.animatingIdleResize)
				YAnimator {}
			}

			Rectangle {
				anchors.verticalCenter: parent.verticalCenter
				width: Theme.geometry_levelsPage_environment_gauge_valueMarker_width
				height: Theme.geometry_levelsPage_environment_gauge_valueMarker_height
				color: Theme.color_font_primary
			}
		}
	}

	SeparatorBar {
		id: quantitySeparator

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_levelsPage_environment_gauge_separator_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_levelsPage_environment_gauge_separator_horizontalMargin
			bottom: quantityLabel.top
		}
	}

	QuantityLabel {
		id: quantityLabel

		anchors {
			bottom: parent.bottom
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: Theme.font_size_h1
		height: Theme.geometry_levelsPage_environment_gauge_quantityLabel_height
	}
}
