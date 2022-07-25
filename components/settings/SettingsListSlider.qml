/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias source: dataPoint.source
	readonly property alias slider: slider

	property real _emittedValue

	signal valueChanged(value: real)

	onValueChanged: function(value) {
		if (source.length > 0) {
			dataPoint.setValue(value)
		}
	}

	content.spacing: Theme.geometry.settingsListItem.slider.spacing
	content.children: [
		Button {
			anchors.verticalCenter: slider.verticalCenter
			icon.width: Theme.geometry.settingsListItem.slider.button.size
			icon.height: Theme.geometry.settingsListItem.slider.button.size
			icon.source: "/images/icon_minus.svg"

			onClicked: {
				if (slider.value > slider.from) {
					slider.decrease()
					root._emittedValue = slider.value
					root.valueChanged(slider.value)
				}
			}
		},

		Slider {
			id: slider

			width: Theme.geometry.settingsListItem.slider.width
			live: false

			from: dataPoint.min !== undefined ? dataPoint.min : 0
			to: dataPoint.max !== undefined ? dataPoint.max : 1
			stepSize: (to-from) / Theme.geometry.settingsListItem.slider.stepDivsion
			value: to > from && dataPoint.value !== undefined ? dataPoint.value : 0

			onPressedChanged: {
				if (slider.value !== root._emittedValue) {
					root._emittedValue = slider.value
					root.valueChanged(slider.value)
				}
			}
		},

		Button {
			anchors.verticalCenter: slider.verticalCenter
			icon.width: Theme.geometry.settingsListItem.slider.button.size
			icon.height: Theme.geometry.settingsListItem.slider.button.size
			icon.source: "/images/icon_plus.svg"

			onClicked: {
				if (slider.value < slider.to) {
					slider.increase()
					root._emittedValue = slider.value
					root.valueChanged(slider.value)
				}
			}
		}
	]

	DataPoint {
		id: dataPoint
	}
}
