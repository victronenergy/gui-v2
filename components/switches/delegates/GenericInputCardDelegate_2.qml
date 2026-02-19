/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Indicator for GenericInput_Type_RangedValue type.
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

			height: 6 //Theme.geometry_rangedValue_slider_height
			borderWidth: 0 //Theme.geometry_rangedValue_slider_height
			indicatorBackgroundWidth: 0

			// Set to false so control is not interactive, change requires
			// colors to overridden.
			enabled: false
			highlightColor: Theme.color_ok
			backgroundColor: Theme.color_darkOk

			value: root.genericInput.value
			from: root.genericInput.rangeMin
			to: root.genericInput.rangeMax

			handle: Item {}
		}

		QuantityLabel {
			id: quantityLabel

			anchors {
				right: parent.right
				rightMargin: Theme.geometry_valueIndicator_horizontalMargin
				verticalCenter: parent.verticalCenter
			}

			unit: root.genericInput.unitType
			value: root.genericInput.value
			precision: root.genericInput.decimals
			font.pixelSize: Theme.font_size_body2
		}
	}
}
