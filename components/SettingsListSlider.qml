/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

SettingsListItem {
	id: root

	property string source
	readonly property alias veItem: veItem
	readonly property alias slider: slider

	property real _emittedValue

	signal valueChanged(value: real)

	onValueChanged: function(value) {
		if (source.length > 0) {
			veItem.setValue(value)
		}
	}

	content.spacing: Theme.geometry.settingsListItem.slider.spacing
	content.children: [
		Button {
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

			from: veItem.min !== undefined ? veItem.min : 0
			to: veItem.max !== undefined ? veItem.max : 1
			stepSize: (to-from) / Theme.geometry.settingsListItem.slider.stepDivsion
			value: to > from && veItem.value !== undefined ? veItem.value : 0

			onPressedChanged: {
				if (slider.value !== root._emittedValue) {
					root._emittedValue = slider.value
					root.valueChanged(slider.value)
				}
			}
		},

		Button {
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

	VeQuickItem {
		id: veItem
		uid: source.length > 0 && dbusConnected ? "dbus/" + source : ""
	}
}
