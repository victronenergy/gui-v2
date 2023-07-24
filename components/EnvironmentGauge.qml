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
		const tickHeight = Theme.geometry.levelsPage.environment.gauge.tick.size
		const unitsPerPixel = (gaugeTicks.height - tickHeight) / range
		const unitCount = v - minimumValue
		const pos = gaugeBar.height - (gaugeTicks.anchors.bottomMargin + (unitsPerPixel * unitCount)) - tickHeight/2
		return Math.max(0, Math.min(pos, gaugeBar.height))
	}

	width: Theme.geometry.levelsPage.environment.gauge.width
	height: parent.height

	CP.ColorImage {
		id: typeIcon

		anchors {
			top: parent.top
			topMargin: Theme.geometry.levelsPage.environment.gauge.icon.topMargin
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry.levelsPage.environment.gauge.icon.size
		height: Theme.geometry.levelsPage.environment.gauge.icon.size
		fillMode: Image.Pad
		color: Theme.color.font.primary
	}

	Label {
		id: typeLabel

		anchors {
			top: typeIcon.bottom
			topMargin: Theme.geometry.levelsPage.environment.gauge.typeLabel.topMargin
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: Theme.font.size.caption
		color: Theme.color.font.primary
	}

	Column {
		id: gaugeTicks

		anchors {
			top: gaugeBar.top
			bottom: gaugeBar.bottom
			topMargin: Theme.geometry.levelsPage.environment.gauge.bar.padding
			bottomMargin: Theme.geometry.levelsPage.environment.gauge.bar.padding
			horizontalCenter: parent.horizontalCenter
		}
		spacing: (height - (tickRepeater.count * Theme.geometry.levelsPage.environment.gauge.tick.size)) / (tickRepeater.count - 1)

		Repeater {
			id: tickRepeater

			model: (root.maximumValue + Theme.geometry.levelsPage.environment.gauge.tick.step - root.minimumValue) / Theme.geometry.levelsPage.environment.gauge.tick.step
			delegate: Item {
				readonly property int tickValue: {
					const invertedIndex = tickRepeater.count - index - 1
					return minimumValue + (Theme.geometry.levelsPage.environment.gauge.tick.step * invertedIndex)
				}

				width: Theme.geometry.levelsPage.environment.gauge.tick.size
				height: Theme.geometry.levelsPage.environment.gauge.tick.size

				Label {
					id: tickLabel

					anchors.verticalCenter: parent.verticalCenter
					leftPadding: Theme.geometry.levelsPage.environment.gauge.tick.margin
					text: model.index === 0 ? root.maximumValue
						: model.index === tickRepeater.count - 1 ? root.minimumValue
						: tickValue === root.highlightedValue ? tickValue
						: ""
					color: Theme.color.levelsPage.environment.gauge.tickText
					font.pixelSize: Theme.font.size.caption
				}

				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.geometry.levelsPage.environment.gauge.tick.size
					height: Theme.geometry.levelsPage.environment.gauge.tick.size
					radius: Theme.geometry.levelsPage.environment.gauge.tick.size
					color: model.index === 0 ? root.maximumValueColor
						 : model.index === tickRepeater.count - 1 ? root.minimumValueColor
						 : tickValue === root.highlightedValue ? root.highlightedValueColor
						 : Theme.color.levelsPage.environment.gauge.tick
				}
			}
		}
	}

	Rectangle {
		id: gaugeBar

		anchors {
			top: typeLabel.bottom
			topMargin: Theme.geometry.levelsPage.environment.gauge.bar.topMargin
			bottom: quantitySeparator.top
			bottomMargin: Theme.geometry.levelsPage.environment.gauge.bar.bottomMargin
			right: gaugeTicks.left
			rightMargin: Theme.geometry.levelsPage.environment.gauge.tick.margin
		}
		width: Theme.geometry.levelsPage.environment.gauge.bar.width
		radius: Theme.geometry.levelsPage.environment.gauge.bar.radius

		Rectangle {
			id: valueMarker

			visible: !isNaN(root.value)
			y: root._barYPosForValue(root.value) - height/2
			width: Theme.geometry.levelsPage.environment.gauge.valueMarker.width
			height: Theme.geometry.levelsPage.environment.gauge.valueMarker.background.height
			color: Theme.color.levelsPage.environment.panel.background

			Behavior on y {
				// Only animate when the value has changed, and not when the page is resizing
				enabled: root.animationEnabled && !Global.pageManager.animatingIdleResize
				NumberAnimation {}
			}

			Rectangle {
				anchors.verticalCenter: parent.verticalCenter
				width: Theme.geometry.levelsPage.environment.gauge.valueMarker.width
				height: Theme.geometry.levelsPage.environment.gauge.valueMarker.height
				color: Theme.color.font.primary
			}
		}
	}

	SeparatorBar {
		id: quantitySeparator

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.levelsPage.environment.gauge.separator.horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry.levelsPage.environment.gauge.separator.horizontalMargin
			bottom: quantityLabel.top
		}
	}

	QuantityLabel {
		id: quantityLabel

		anchors {
			bottom: parent.bottom
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: Theme.font.size.h1
		height: Theme.geometry.levelsPage.environment.gauge.quantityLabel.height
	}
}
