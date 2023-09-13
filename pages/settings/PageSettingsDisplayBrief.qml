/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C
import Gauges

Page {
	id: root

	property var _gaugeOptionsModel: Gauges.briefCentralGauges.map(function(gaugeType) {
		const name = Gauges.tankProperties(gaugeType).name || ""
		return { display: name, value: gaugeType }
	})

	// Use this intermediate model that is built when the page loads, to avoid changing the model
	// while the radio button group sub-page is shown, as that causes the group options to be rebuilt.
	property var _gaugesModel
	C.StackView.onActivating: {
		_gaugesModel = Global.systemSettings.briefView.centralGauges.value || []
	}

	GradientListView {
		model: root._gaugesModel

		delegate: ListRadioButtonGroup {
			//: Level number
			//% "Level %1"
			text: qsTrId("settings_briefview_level").arg(model.index + 1)
			optionModel: root._gaugeOptionsModel
			currentIndex: {
				const savedGaugePrefs = Global.systemSettings.briefView.centralGauges.value || []
				const preferredGaugeForLevel = savedGaugePrefs[model.index]
				return Gauges.briefCentralGauges.indexOf(preferredGaugeForLevel)
			}

			onOptionClicked: function(index) {
				let savedGaugePrefs = Global.systemSettings.briefView.centralGauges.value
				if (savedGaugePrefs.length) {
					savedGaugePrefs[model.index] = optionModel[index].value
					Global.systemSettings.briefView.centralGauges.setValue(savedGaugePrefs)
				}
			}
		}

		footer: ListSwitch {
			//: Show percentage values in Brief view
			//% "Show %"
			text: qsTrId("settings_briefview_show_percentage")
			checked: Global.systemSettings.briefView.showPercentages.value === 1
			onClicked: Global.systemSettings.briefView.showPercentages.setValue(checked ? 1 : 0)
		}
	}
}
