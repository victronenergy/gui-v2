/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Each item in the model is expected to have at least 2 values:
//      - "display": the text to display for this option
//      - "value": some backend value associated with this option
//
// The default behaviour supports a simple array-based model. When using a ListModel or C++ model,
// set the currentIndex and secondaryText properties manually.

ListNavigation {
	id: root

	readonly property alias dataItem: dataItem
	property var optionModel: []
	property int currentIndex: {
		if (!optionModel || optionModel.length === undefined || dataItem.uid.length === 0 || !dataItem.valid) {
			return defaultIndex
		}
		for (let i = 0; i < optionModel.length; ++i) {
			if (optionModel[i].value === dataItem.value) {
				return i
			}
		}
		return defaultIndex
	}

	readonly property var currentValue: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].value
			: undefined

	property bool updateCurrentIndexOnClick: true
	property bool updateDataOnClick: true
	property var popDestination: null   // if undefined, will not automatically pop page when value is selected
	property var validatePassword

	property int defaultIndex: -1
	//% "Unknown"
	property string defaultSecondaryText: qsTrId("settings_radio_button_group_unknown")

	property Component optionFooter

	signal optionClicked(index: int)
	signal aboutToPop()

	secondaryText: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].display
			: defaultSecondaryText

	interactive: (dataItem.uid === "" || dataItem.valid)

	onClicked: {
		// onClicked is not emitted if interactive: false
		Global.pageManager.pushPage(optionsPageComponent, { title: Qt.binding(function() { return root.text }) })
	}

	VeQuickItem {
		id: dataItem
	}

	Component {
		id: optionsPageComponent

		RadioButtonListPage {
			footer: root.optionFooter
			optionModel: root.optionModel
			currentIndex: root.currentIndex
			updateCurrentIndexOnClick: root.updateCurrentIndexOnClick
			popDestination: root.popDestination
			showAccessLevel: root.showAccessLevel
			writeAccessLevel: root.writeAccessLevel
			validatePassword: root.validatePassword

			onOptionClicked: (index, value) => {
				if (root.updateDataOnClick && dataItem.uid.length > 0) {
					dataItem.setValue(value)
				}
				root.optionClicked(index)
			}
			onAboutToPop: {
				root.aboutToPop()
			}
		}
	}
}
