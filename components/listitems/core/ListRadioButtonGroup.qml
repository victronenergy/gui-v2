/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

// Each item in the model is expected to have at least 2 values:
//      - "display": the text to display for this option
//      - "value": some backend value associated with this option
//
// The default behaviour supports a simple array-based model. When using a ListModel or C++ model,
// set the currentIndex and secondaryText properties manually.

ListSetting {
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

	property string secondaryText: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].display
			: defaultSecondaryText
	property color secondaryTextColor: Theme.color_font_secondary
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

	property Component optionHeader
	property Component optionFooter

	signal optionClicked(index: int)
	signal aboutToPop()

	function click() {
		// Open the options page if the user has write access; otherwise, show the toast error.
		if (root.interactive && root.checkWriteAccessLevel()) {
			Global.pageManager.pushPage(optionsPageComponent, { title: Qt.binding(function() { return root.text }) })
			return true
		}
		return false
	}

	interactive: (dataItem.uid === "" || dataItem.valid)
	hasSubMenu: clickable

	contentItem: GridLayout {
		columns: root.interactive ? 2 : 1
		columnSpacing: root.spacing
		rowSpacing: Theme.geometry_listItem_content_verticalSpacing

		TwoLabelLayout {
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
			secondaryLabel.color: root.secondaryTextColor

			Layout.fillWidth: true
		}

		ForwardIcon {
			visible: root.interactive
		}

		CaptionLabel {
			visible: text.length > 0
			text: root.caption

			Layout.columnSpan: root.interactive ? 2 : 1
			Layout.fillWidth: true
		}
	}

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor

		ListPressArea {
			anchors.fill: parent
			enabled: root.interactive
			onClicked: root.click()
		}
	}

	Keys.onSpacePressed: click()
	Keys.onRightPressed: click()

	VeQuickItem {
		id: dataItem
	}

	Component {
		id: optionsPageComponent

		RadioButtonListPage {
			header: root.optionHeader
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
