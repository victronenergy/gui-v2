/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListSetting {
	id: root

	readonly property alias dataItemFrom: dataItemFrom
	readonly property alias dataItemTo: dataItemTo
	readonly property alias dataItemModifiedFrom: dataItemModifiedFrom
	readonly property alias dataItemModifiedTo: dataItemModifiedTo

	readonly property alias rangeModelFrom: rangeModelFrom
	readonly property alias rangeModelTo: rangeModelTo

	property int unit: VenusOS.Units_None
	property int decimals: 0

	// If true, displays a text label instead of a button.
	property bool readOnly: false

	interactive: true

	contentItem: FocusScope {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelsColumn.height
		focus: false

		// If focus moves elsewhere, remove the focus on the contentItem so that the user must press
		// space next time to refocus the buttons.
		onActiveFocusChanged: {
			if (!activeFocus) {
				focus = false
			}
		}

		ColumnLayout {
			id: labelsColumn

			anchors {
				left: parent.left
				right: buttonRow.left
				rightMargin: root.spacing
				verticalCenter: parent.verticalCenter
			}
			spacing: Theme.geometry_listItem_content_verticalSpacing

			Label {
				text: root.text
				textFormat: root.textFormat
				font: root.font
				wrapMode: Text.Wrap

				Layout.fillWidth: true
			}

			CaptionLabel {
				width: parent.width
				text: root.caption
				visible: text.length > 0

				Layout.fillWidth: true
			}
		}

		Row {
			id: buttonRow

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			spacing: Theme.geometry_listItem_content_spacing

			ListItemButton {
				text: Units.getCombinedDisplayText(root.unit, dataItemFrom.value, root.decimals, Units.NoDecimalAdjustment)
				down: root.clickable && (pressed || checked)
				enabled: root.clickable && !root.readOnly
				flat: root.readOnly
				focus: true

				KeyNavigation.right: maximumValueButton
				Keys.onLeftPressed: (e) => { e.accepted = true }
				Keys.onEscapePressed: root.contentItem.focus = false
				Keys.onEnterPressed: root.contentItem.focus = false
				Keys.onReturnPressed: root.contentItem.focus = false

				onClicked: Global.dialogLayer.open(numberSelectorComponentFrom, { value: dataItemFrom.value })

				Binding on borderColor {
					when: dataItemModifiedFrom.value === 1
					value: Theme.color_button_on_border_modified
				}

				Component {
					id: numberSelectorComponentFrom

					NumberSelectorDialog {
						//% "Minimum value (%1)"
						title: qsTrId("list-spin-box-range_minimum_value_with_arguments").arg(root.text)
						suffix: Units.defaultUnitString(root.unit)
						stepSize: rangeModelFrom.stepSize
						from: rangeModelFrom.minimumValue
						to: rangeModelFrom.maximumValue
						decimals: root.decimals
						presets: Array.from({ length: 5 }, (_, i) => from + i * (to - from)/4).map(function(v) { return { value: v.toFixed(root.decimals) } })
						onAccepted: dataItemFrom.setValue(value)
					}
				}
			}

			SecondaryListLabel {
				anchors.verticalCenter: parent.verticalCenter
				//: Used as a delimiter between two values that specify a range (e.g. '-70% to 80%')
				//% "to"
				text: qsTrId("list-spin-box-range_minimum_maximum_delimiter")
			}

			ListItemButton {
				id: maximumValueButton

				text: Units.getCombinedDisplayText(root.unit, dataItemTo.value, root.decimals, Units.NoDecimalAdjustment)
				down: root.clickable && (pressed || checked)
				enabled: root.clickable && !root.readOnly
				flat: root.readOnly

				Keys.onRightPressed: (e) => { e.accepted = true }
				Keys.onEscapePressed: root.contentItem.focus = false
				Keys.onEnterPressed: root.contentItem.focus = false
				Keys.onReturnPressed: root.contentItem.focus = false

				onClicked: Global.dialogLayer.open(numberSelectorComponentTo, { value: dataItemTo.value })

				Binding on borderColor {
					when: dataItemModifiedTo.value === 1
					value: Theme.color_button_on_border_modified
				}

				Component {
					id: numberSelectorComponentTo

					NumberSelectorDialog {
						//% "Maximum value (%1)"
						title: qsTrId("list-spin-box-range_maximum_value_with_arguments").arg(root.text)
						suffix: Units.defaultUnitString(root.unit)
						stepSize: rangeModelTo.stepSize
						from: rangeModelTo.minimumValue
						to: rangeModelTo.maximumValue
						decimals: root.decimals
						presets: Array.from({ length: 5 }, (_, i) => from + i * (to - from)/4).map(function(v) { return { value: v.toFixed(root.decimals) } })
						onAccepted: dataItemTo.setValue(value)
					}
				}
			}
		}
	}

	Keys.onSpacePressed: {
		if (readOnly || !root.checkWriteAccessLevel() || !root.clickable) {
			return
		}
		contentItem.focus = true
	}

	RangeModel {
		id: rangeModelFrom
	}
	RangeModel {
		id: rangeModelTo
	}

	VeQuickItem {
		id: dataItemFrom
		decimals: root.decimals
	}
	VeQuickItem {
		id: dataItemTo
		decimals: root.decimals
	}
	VeQuickItem {
		id: dataItemModifiedFrom
	}
	VeQuickItem {
		id: dataItemModifiedTo
	}
}
