/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Indicator for GenericInput_Type_Temperature type.
*/
Item {
	id: root

	required property GenericInput genericInput

	focus: true
	KeyNavigationHighlight.active: activeFocus

	GenericInputCardDelegateHeader {
		id: header

		anchors {
			top: parent.top
			topMargin: Theme.geometry_switches_header_topMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
		}
		genericInput: root.genericInput
	}

	GenericInputCardDelegateBackground {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}

		MiniSlider {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_valueIndicator_horizontalMargin
				right: quantityLabel.left
				rightMargin: Theme.geometry_valueIndicator_spacing
				verticalCenter: parent.verticalCenter
			}

			height: Theme.geometry_valueIndicator_slider_height // 6
			borderWidth: Theme.geometry_valueIndicator_slider_borderWidth // 0
			indicatorBackgroundWidth: Theme.geometry_valueIndicator_slider_handle_width

			// Set to false so control is not interactive, change requires
			// colors to overridden.
			enabled: false

			value: root.genericInput.value
			from: root.genericInput.rangeMin
			to: root.genericInput.rangeMax

			handle: Rectangle {
				x: parent.sliderX - (width / 2) + (parent.indicatorBackgroundWidth / 2)
				y: (parent.height - height) / 2
				width: parent.indicatorBackgroundWidth
				height: parent.height
				color: Theme.color_white

				Rectangle {
					anchors.centerIn: parent
					width: parent.width - Theme.geometry_valueIndicator_slider_handle_border_width * 2
					height: parent.height
					color: Theme.color_black
				}
			}

			background: Rectangle {
				implicitWidth: parent.width
				implicitHeight: parent.height
				radius: parent.height/2

				// the background is the border with an additional rectangle for fill
				gradient: Gradient {
					orientation: Qt.Horizontal
					GradientStop { position: 0.0; color: Theme.color_temperatureslider_gradient_min_border }
					GradientStop { position: 1.0; color: Theme.color_temperatureslider_gradient_max_border }
				}
			}
		}

		QuantityLabel {
			id: quantityLabel

			anchors {
				right: parent.right
				rightMargin: Theme.geometry_valueIndicator_horizontalMargin
				verticalCenter: parent.verticalCenter
			}

			unit: Global.systemSettings.temperatureUnit
			value: Units.convert(root.genericInput.value, VenusOS.Units_Temperature_Celsius, Global.systemSettings.temperatureUnit)
			precision: root.genericInput.decimals
			font.pixelSize: Theme.font_size_body2
		}
	}
}
