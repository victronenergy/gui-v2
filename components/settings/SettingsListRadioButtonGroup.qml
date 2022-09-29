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
	property var model: []
	property int currentIndex
	property bool updateOnClick: true

	property int defaultIndex: -1
	//% "Unknown"
	property string defaultSecondaryText: qsTrId("settings_list_radio_button_group_unknown")

	signal optionClicked(index: int)

	secondaryText: currentIndex >= 0 && model.length !== undefined && currentIndex < model.length
			? model[currentIndex].display
			: defaultSecondaryText

	currentIndex: {
		if (!model || model.length === undefined || source.length === 0 || dataPoint.value === undefined) {
			return defaultIndex
		}
		for (let i = 0; i < model.length; ++i) {
			if (model[i].value === dataPoint.value) {
				return i
			}
		}
		return defaultIndex
	}

	onClicked: {
		Global.pageManager.pushPage(optionsPageComponent)
	}

	DataPoint {
		id: dataPoint
	}

	Component {
		id: optionsPageComponent

		Page {
			SettingsListView {
				model: root.model

				delegate: SettingsListRadioButton {
					id: radioButton

					text: Array.isArray(root.model)
						  ? modelData.display || ""
						  : model.display || ""
					caption.text: Array.isArray(root.model)
						  ? modelData.caption || ""
						  : model.caption || ""
					checked: root.currentIndex === model.index
					showAccessLevel: root.showAccessLevel
					writeAccessLevel: root.showAccessLevel
					C.ButtonGroup.group: radioButtonGroup

					onClicked: {
						if (root.updateOnClick) {
							if (source.length > 0) {
								dataPoint.setValue(Array.isArray(root.model) ? modelData.value : model.value)
							}
							root.currentIndex = model.index
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
