/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
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

	RangeModel {
		id: rangeModelFrom
	}
	RangeModel {
		id: rangeModelTo
	}

	content.children: [
		Row {
			spacing: Theme.geometry_listItem_content_spacing

			ListItemButton {
				text: Units.getCombinedDisplayText(root.unit, dataItemFrom.value, root.decimals, false)
				visible: !root.readOnly

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
						presets: Array.from({ length: 5 }, (_, i) => from + i * (to - from)/4).map(function(v) { return { value: v } })
						onAccepted: dataItemFrom.setValue(value)
					}
				}
			}
			SecondaryListLabel {
				text: Units.getCombinedDisplayText(root.unit, dataItemFrom.value, root.decimals, false)
				visible: root.readOnly
			}
			SecondaryListLabel {
				//: Used as a delimiter between two values that specify a range (e.g. '-70% to 80%')
				//% "to"
				text: qsTrId("list-spin-box-range_minimum_maximum_delimiter")
				height: parent.height
			}
			ListItemButton {
				text: Units.getCombinedDisplayText(root.unit, dataItemTo.value, root.decimals, false)
				visible: !root.readOnly

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
						presets: Array.from({ length: 5 }, (_, i) => from + i * (to - from)/4).map(function(v) { return { value: v } })
						onAccepted: dataItemTo.setValue(value)
					}
				}
			}
			SecondaryListLabel {
				text: Units.getCombinedDisplayText(root.unit, dataItemTo.value, root.decimals, false)
				visible: root.readOnly
			}
		}
	]

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
