/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A list setting item with a slider.

	There are two ways to control the slider value:

	1. By setting 'dataItem.uid' to a path that will be automatically set to the slider value when
	the handle is dragged.

	2. By setting the 'value' property directly, instead of setting dataItem.uid. The value property
	will still be updated whenever the handle is dragged.
	NOTE: this means the value binding is overwritten when the slider moves!! It can still be
	assigned with an initial value, but after a user interaction, the binding is gone.
*/
ListSetting {
	id: root

	readonly property alias dataItem: dataItem

	// Slider properties.
	// Note that if dataItem.uid is not set, the 'value' binding is overwritten when the handle is
	// dragged.
	property real from: dataItem.min !== undefined ? dataItem.min : 0
	property real to: dataItem.max !== undefined ? dataItem.max : 1
	property real stepSize: (to-from) / Theme.geometry_slider_steps
	property real value: to > from && dataItem.valid ? dataItem.value : 0

	// Remove padding around the edges, so that the internal Slider can expand its touch area.
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0

	interactive: (dataItem.uid === "" || dataItem.valid)

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

		Slider {
			id: sliderItem

			// Make space for plus/minus buttons on either side.
			leftInset: Theme.geometry_slider_button_size + Theme.geometry_slider_spacing
			rightInset: Theme.geometry_slider_button_size + Theme.geometry_slider_spacing + root.horizontalContentPadding
			leftPadding: leftInset
			rightPadding: rightInset

			from: root.from
			to: root.to
			stepSize: root.stepSize
			live: true
			value: root.value
			enabled: root.clickable
			snapMode: Slider.SnapAlways

			onPositionChanged: {
				if (dataItem.uid.length > 0) {
					// Break the 'value: dataItem.value' binding after the value is initially set, otherwise
					// the backend value and the slider value will fight each other.
					value = value
					dataItem.setValue(valueAt(position))
				} else {
					// The value is not tied to a backend value, so update the property directly.
					root.value = valueAt(position)
				}
			}

			// Expand the vertical touch area, to make it easier to click.
			Layout.preferredHeight: implicitHeight + (2 * Theme.geometry_listItem_content_verticalMargin)
			Layout.fillWidth: true

			// Minus button
			Button {
				// Use insets to vertically expand the touch area, to make it easier to click.
				width: Theme.geometry_slider_button_size
				height: sliderItem.height
				topInset: (sliderItem.height - Theme.geometry_slider_button_size) / 2
				bottomInset: (sliderItem.height - Theme.geometry_slider_button_size) / 2

				icon.source: "qrc:/images/icon_minus.svg"
				icon.color: root.clickable
					   ? (pressed ? Theme.color_button_icon_down : Theme.color_button_icon)
					   : Theme.color_background_disabled
				flat: true

				onClicked: {
					if (sliderItem.value > sliderItem.from) {
						sliderItem.decrease()
					}
				}
			}

			// Plus button
			Button {
				// Use insets to expand the touch area, to make it easier to click.
				anchors.right: parent.right
				width: Theme.geometry_slider_button_size + root.horizontalContentPadding
				height: sliderItem.height
				topInset: (sliderItem.height - Theme.geometry_slider_button_size) / 2
				bottomInset: (sliderItem.height - Theme.geometry_slider_button_size) / 2
				rightInset: root.horizontalContentPadding
				rightPadding: root.horizontalContentPadding

				icon.source: "qrc:/images/icon_plus.svg"
				icon.color: sliderItem.enabled
					   ? (pressed ? Theme.color_button_icon_down : Theme.color_button_icon)
					   : Theme.color_background_disabled
				flat: true

				onClicked: {
					if (sliderItem.value < sliderItem.to) {
						sliderItem.increase()
					}
				}
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
		id: dataItem
	}
}
