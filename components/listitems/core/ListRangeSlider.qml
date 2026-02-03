/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A list setting item with a range slider, which has two handles.

	There are two ways to control the slider values:

	1. By setting 'firstDataItem.uid' and 'secondDataItem.uid' to paths that will be automatically
	set to the first and second slider values when the handles are dragged.

	2. By setting the 'firstValue' and 'secondValue' properties directly, instead of setting
	the data uids. The value properties will still be updated whenever the handles are dragged.
	NOTE: this means the value binding is overwritten when the slider moves!! It can still be
	assigned with an initial value, but after a user interaction, the binding is gone.
*/
ListSetting {
	id: root

	property int decimals
	property string suffix
	readonly property alias firstDataItem: firstDataItem
	readonly property alias secondDataItem: secondDataItem
	readonly property bool dataValid: firstDataItem.valid && secondDataItem.valid

	// Slider properties.
	// Note that if firstDataItem.uid is not set, the 'firstValue' binding is overwritten when the
	// first handle is dragged; same for secondDataItem and secondValue.
	property real from: {
		const v = firstDataItem.valid ? firstDataItem.min || 0 : 0
		return fromSourceValue !== undefined ? root.fromSourceValue(v) : v
	}
	property real to: {
		const v = secondDataItem.valid ? secondDataItem.max || 100 : 100
		return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
	}
	property real firstValue: {
		const v = isNaN(firstDataItem.value) ? 0 : firstDataItem.value
		return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
	}
	property real secondValue: {
		const v = isNaN(secondDataItem.value) ? 0 : secondDataItem.value
		return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
	}
	property real stepSize: (to-from) / Theme.geometry_slider_steps
	property color firstColor: "transparent"
	property color secondColor: "transparent"

	// Optional functions that convert to/from the VeQuickItem values.
	property var toSourceValue: undefined
	property var fromSourceValue: undefined

	// Remove padding around the edges, so that the internal Slider can expand its touch area.
	topPadding: 0
	bottomPadding: 0

	interactive: (firstDataItem.uid === "" || firstDataItem.valid) &&
				 (secondDataItem.uid === "" || secondDataItem.valid)

	// Layout has 2 columns, 2 rows. The caption spans across both columns.
	// | Primary label | Slider |
	// | Caption                |
	contentItem: GridLayout {
		columns: 2
		rowSpacing: 0 // not needed, as padding is added below the label

		Label {
			// Since the root top/bottomPadding is 0, need to add some padding here.
			topPadding: Theme.geometry_listItem_content_verticalMargin
			bottomPadding: Theme.geometry_listItem_content_verticalMargin
			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap
			verticalAlignment: Text.AlignVCenter

			// Fix the label width; the slider fills the rest of the horizontal area.
			Layout.preferredWidth: Theme.geometry_slider_text_width
		}

		RangeSlider {
			id: sliderItem

			// Make space for labels on either side.
			leftInset: Theme.geometry_rangeSlider_labelWidth + Theme.geometry_slider_spacing
			rightInset: Theme.geometry_rangeSlider_labelWidth + Theme.geometry_slider_spacing
			leftPadding: leftInset
			rightPadding: rightInset

			enabled: root.clickable
			from: root.from
			to: root.to
			stepSize: root.stepSize
			first.value: root.firstValue
			second.value: root.secondValue
			firstColor: root.firstColor
			secondColor: root.secondColor

			// Expand the vertical touch area, to make it easier to click.
			Layout.preferredHeight: implicitHeight + (2 * Theme.geometry_listItem_content_verticalMargin)
			Layout.fillWidth: true

			// Update data value when mouse is released, to avoid spamming data changes.
			// If the value is linked to the backend, then update the backend value; otherwise,
			// update the firstValue or secondValue property directly.
			Connections {
				target: sliderItem.first
				function onPressedChanged() {
					if (!sliderItem.first.pressed) {
						const v = root.toSourceValue !== undefined ? root.toSourceValue(sliderItem.first.value) : sliderItem.first.value
						if (firstDataItem.uid.length > 0) {
							firstDataItem.setValue(v)
						} else {
							root.firstValue = v
						}
					}
				}
			}
			Connections {
				target: sliderItem.second
				function onPressedChanged() {
					if (!sliderItem.second.pressed) {
						const v = root.toSourceValue !== undefined ? root.toSourceValue(sliderItem.second.value) : sliderItem.second.value
						if (secondDataItem.uid.length > 0) {
							secondDataItem.setValue(v)
						} else {
							root.secondValue = v
						}
					}
				}
			}

			SecondaryListLabel {
				width: Theme.geometry_rangeSlider_labelWidth
				height: parent.height
				wrapMode: Text.NoWrap
				horizontalAlignment: Text.AlignRight
				verticalAlignment: Text.AlignVCenter
				text: Units.formatNumber(sliderItem.first.value, root.decimals) + root.suffix
			}

			SecondaryListLabel {
				anchors.right: parent.right
				width: Theme.geometry_rangeSlider_labelWidth
				height: parent.height
				wrapMode: Text.NoWrap
				verticalAlignment: Text.AlignVCenter
				text: Units.formatNumber(sliderItem.second.value, root.decimals) + root.suffix
			}
		}

		Label {
			text: root.caption
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0

			Layout.columnSpan: 2
			Layout.maximumWidth: root.availableWidth
			Layout.bottomMargin: Theme.geometry_listItem_content_verticalMargin
		}
	}

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			slider.focus = true
			event.accepted = true
			return
		case Qt.Key_Escape:
		case Qt.Key_Return:
		case Qt.Key_Enter:
			if (slider.activeFocus) {
				slider.focus = false
				event.accepted = true
				return
			}
			break
		}
		event.accepted = false
	}

	VeQuickItem {
		id: firstDataItem
	}

	VeQuickItem {
		id: secondDataItem
	}
}
