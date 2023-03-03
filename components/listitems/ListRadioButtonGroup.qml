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

ListNavigationItem {
	id: root

	property alias source: dataPoint.source
	readonly property alias dataPoint: dataPoint
	readonly property alias value: dataPoint.value
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
	property var popDestination: null   // if undefined, will not automatically pop page when value is selected

	property int defaultIndex: -1
	//% "Unknown"
	property string defaultSecondaryText: qsTrId("settings_radio_button_group_unknown")

	signal optionClicked(index: int)

	secondaryText: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].display
			: defaultSecondaryText

	enabled: userHasReadAccess && (source === "" || dataPoint.valid)

	onClicked: {
		Global.pageManager.pushPage(optionsPageComponent, { title: text })
	}

	DataPoint {
		id: dataPoint
	}

	Component {
		id: optionsPageComponent

		Page {
			id: optionsPage

			GradientListView {
				model: root.optionModel

				delegate: ListRadioButton {
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
						}
						root.optionClicked(model.index)

						if (root.popDestination !== undefined) {
							popTimer.restart()
						}
					}
				}

				C.ButtonGroup {
					id: radioButtonGroup
				}
			}

			onIsCurrentPageChanged: {
				if (!isCurrentPage) {
					popTimer.stop()
				}
			}

			Timer {
				id: popTimer

				interval: Theme.animation.settings.radioButtonPage.autoClose.duration
				onTriggered: {
					if (root.popDestination) {
						Global.pageManager.popPage(root.popDestination)
					} else {
						Global.pageManager.popPage()
					}
				}
			}
		}
	}
}
