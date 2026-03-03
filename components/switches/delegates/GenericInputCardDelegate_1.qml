/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Indicator for GenericInput_Type_UnrangedValue type.
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

		Label {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_valueIndicator_horizontalMargin
				right: quantityLabel.left
				rightMargin: Theme.geometry_valueIndicator_spacing
				verticalCenter: parent.verticalCenter
			}

			//: Refers to the current value of the input.
			//% "Value"
			text: root.genericInput.primaryLabel || qsTrId("generic_input_value")
			color: Theme.color_listItem_secondaryText
			font.pixelSize: Theme.font_size_body2
			elide: Text.ElideRight
		}

		IOChannelQuantityLabel {
			id: quantityLabel

			anchors {
				right: parent.right
				rightMargin: Theme.geometry_valueIndicator_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			ioChannel: root.genericInput
			value: valueItem.value

			VeQuickItem {
				id: valueItem
				uid: root.genericInput.uid + "/Value"
				sourceUnit: Units.unitToVeUnit(root.genericInput.unitType)
				displayUnit: Units.unitToVeUnit(Global.systemSettings.toPreferredUnit(root.genericInput.unitType))
			}
		}
	}
}
