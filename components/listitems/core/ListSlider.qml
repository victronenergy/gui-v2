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

	interactive: (dataItem.uid === "" || dataItem.valid)

	contentItem: FocusScope {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.implicitHeight

		TwoLabelItemLayout {
			id: contentLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			captionText: root.caption
			secondaryComponent: sliderComponent
			alwaysStretchCaption: true
		}

		Component {
			id: sliderComponent

			Slider {
				id: sliderItem

				width: Theme.screenSize === Theme.Portrait
						? root.availableWidth
						: root.availableWidth - root.spacing - Theme.geometry_listItem_primaryText_minimumWidth

				// Make space for plus/minus buttons on either side.
				leftInset: minusButton.width + Theme.geometry_listItem_content_spacing
				rightInset: plusButton.width + Theme.geometry_listItem_content_spacing
				leftPadding: leftInset
				rightPadding: rightInset

				from: root.from
				to: root.to
				stepSize: root.stepSize
				live: true
				value: root.value
				enabled: root.clickable
				snapMode: Slider.SnapAlways
				focus: true

				Keys.onPressed: (event) => {
					switch (event.key) {
					case Qt.Key_Escape:
					case Qt.Key_Return:
					case Qt.Key_Enter:
						if (activeFocus) {
							// Remove focus to exit "edit" mode.
							root.contentItem.focus = false
							event.accepted = true
							return
						}
						break
					}
					event.accepted = false
				}

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

				Button {
					id: minusButton

					anchors.verticalCenter: parent.verticalCenter
					// Use insets to vertically expand the touch area, to make it easier to click.
					defaultBackgroundWidth: Theme.geometry_slider_button_size
					defaultBackgroundHeight: Theme.geometry_slider_button_size
					topInset: (sliderItem.height - defaultBackgroundHeight) / 2
					bottomInset: (sliderItem.height - defaultBackgroundHeight) / 2

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

				Button {
					id: plusButton

					anchors.verticalCenter: parent.verticalCenter
					// Use insets to expand the touch area, to make it easier to click.
					anchors.right: parent.right
					defaultBackgroundWidth: Theme.geometry_slider_button_size
					defaultBackgroundHeight: Theme.geometry_slider_button_size
					topInset: (sliderItem.height - defaultBackgroundHeight) / 2
					bottomInset: (sliderItem.height - defaultBackgroundHeight) / 2

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
		}
	}

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			// Enter "edit" mode where left/right keys change the value.
			contentItem.focus = true
			event.accepted = true
			return
		case Qt.Key_Up:
		case Qt.Key_Down:
			if (contentItem.activeFocus) {
				// Block navigation away from this item, until Esc/Enter is pressed.
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
