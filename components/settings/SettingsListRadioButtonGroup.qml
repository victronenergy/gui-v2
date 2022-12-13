/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

// Each item in the model is expected to have at least 2 values:
//      - "display": the text to display for this option
//      - "value": some backend value associated with this option
//
// The default behaviour supports a simple array-based model. When using a ListModel or C++ model,
// set the currentIndex and secondaryText properties manually.

SettingsListNavigationItem {
	id: root

	property alias source: dataPoint.source
	readonly property alias dataPoint: dataPoint
	property var optionModel: []
	property int currentIndex: {
		if (!optionModel || optionModel.length === undefined || source.length === 0 || !dataPoint.valid) {
			return defaultIndex
		}
		for (let i = 0; i < optionModel.length; ++i) {
			if (optionModel[i].value === dataPoint.value) {
				return i
			}
		}
		return defaultIndex
	}

	readonly property var currentValue: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].value
			: undefined

	property bool updateOnClick: true

	property int defaultIndex: -1
	//% "Unknown"
	property string defaultSecondaryText: qsTrId("settings_radio_button_group_unknown")

	readonly property var currentValue: currentIndex >= 0 && model.length !== undefined && currentIndex < model.length
			? model[currentIndex].value
			: undefined

	signal optionClicked(index: int)

	secondaryText: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].display
			: defaultSecondaryText

	enabled: source === "" || dataPoint.valid

	onClicked: {
		Global.pageManager.pushPage(optionsPageComponent, { title: text })
	}

	DataPoint {
		id: dataPoint
	}

	Component {
		id: optionsPageComponent

		Page {
			SettingsListView {
				model: root.optionModel

				delegate: SettingsListRadioButton {
					id: radioButton

					text: Array.isArray(root.optionModel)
						  ? modelData.display || ""
						  : model.display || ""
					caption.text: Array.isArray(root.optionModel)
						  ? modelData.caption || ""
						  : model.caption || ""
					enabled: Array.isArray(root.optionModel)
						  ? !modelData.readOnly
						  : !model.readOnly
					checked: root.currentIndex === model.index
					showAccessLevel: root.showAccessLevel
					writeAccessLevel: root.showAccessLevel
					C.ButtonGroup.group: radioButtonGroup

					onClicked: {
						if (root.updateOnClick) {
							if (source.length > 0) {
								dataPoint.setValue(Array.isArray(root.optionModel) ? modelData.value : model.value)
							}
							root.currentIndex = model.index

							// TODO should we auto-pop to the parent page when an option is selected,
							// to mimic the behavior in gui-v1? How to do that without creating an
							// abrupt and unexpected page change?
						}
						root.optionClicked(model.index)
					}
				}

				C.ButtonGroup {
					id: radioButtonGroup
				}
			}
		}
	}
}
