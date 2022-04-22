import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Item {
	id: root

	property alias icon: typeIcon
	property alias text: typeLabel.text
	property alias value: quantityDisplay.value
	property alias physicalQuantity: quantityDisplay.physicalQuantity

	property real minimumValue: 0
	property real maximumValue: 100
	property alias zeroMarkerVisible: zeroMarker.visible
	property bool reduceFontSize
	property alias gradient: gaugeBar.gradient
	property bool animationEnabled: true

	function _barYPosForValue(v) {
		const range = maximumValue - minimumValue
		if (range === 0) {
			console.warn("Ignoring zero range! Min:", minimumValue, "Max:", maximumValue)
			return 0
		}
		const unitsPerPixel = gaugeBar.height / range
		const unitCount = v - minimumValue
		return Math.round(gaugeBar.height - (unitsPerPixel * unitCount))
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
		font.pixelSize: Theme.font.size.s
		color: Theme.color.font.primary
	}

	Rectangle {
		id: gaugeBar

		anchors {
			top: typeLabel.bottom
			topMargin: Theme.geometry.levelsPage.environment.gauge.bar.topMargin
			bottom: quantityDisplay.top
			bottomMargin: Theme.geometry.levelsPage.environment.gauge.bar.bottomMargin
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry.levelsPage.environment.gauge.bar.width
		radius: Theme.geometry.levelsPage.environment.gauge.bar.radius

		Rectangle {
			id: valueMarker

			y: root._barYPosForValue(Math.max(root.minimumValue, Math.min(root.maximumValue, root.value))) - height/2
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

		// Short line to left of '0' text
		Rectangle {
			anchors {
				verticalCenter: zeroMarker.verticalCenter
				right: parent.left
				rightMargin: width
			}
			width: Theme.geometry.levelsPage.environment.gauge.zeroMarker.width
			height: Theme.geometry.levelsPage.environment.gauge.zeroMarker.height
			visible: zeroMarker.visible
			color: Theme.color.font.secondary
		}

		Label {
			id: zeroMarker

			x: parent.width/2 - width/2
			y: visible ? root._barYPosForValue(0) - height/2 : 0
			text: "0"
			font.pixelSize: Theme.font.size.s
			color: Theme.color.levelsPage.environment.gauge.zeroMarker
		}

		// Short line to right of '0' text
		Rectangle {
			anchors {
				verticalCenter: zeroMarker.verticalCenter
				left: parent.right
				leftMargin: width
			}
			width: Theme.geometry.levelsPage.environment.gauge.zeroMarker.width
			height: Theme.geometry.levelsPage.environment.gauge.zeroMarker.height
			visible: zeroMarker.visible
			color: Theme.color.font.secondary
		}
	}

	ValueQuantityDisplay {
		id: quantityDisplay

		anchors {
			bottom: parent.bottom
			bottomMargin: Theme.geometry.levelsPage.environment.gauge.quantityDisplay.bottomMargin
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: root.reduceFontSize ? Theme.font.size.m : Theme.font.size.xl
		alignToBaseline: true
	}
}
