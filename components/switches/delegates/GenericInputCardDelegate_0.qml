/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Indicator for GenericInput_Type_Discrete type.
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
			topMargin: Theme.geometry_size_8
			left: parent.left
			leftMargin: Theme.geometry_shared_24_24_16
			right: parent.right
			rightMargin: Theme.geometry_shared_24_24_16
		}
		genericInput: root.genericInput
	}

	GenericInputCardDelegateBackground {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_shared_24_24_16
			right: parent.right
			rightMargin: Theme.geometry_shared_24_24_16
			top: header.bottom
		}

		Label {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_size_12
				right: stateLabel.left
				rightMargin: Theme.geometry_valueIndicator_spacing
				verticalCenter: parent.verticalCenter
			}
			text: root.genericInput.primaryLabel || CommonWords.state
			color: Theme.color_listItem_secondaryText
			font.pixelSize: Theme.font_size_body2
			elide: Text.ElideRight
		}

		Label {
			id: stateLabel

			anchors {
				right: parent.right
				rightMargin: Theme.geometry_size_12
				verticalCenter: parent.verticalCenter
			}
			text: root.genericInput.textValue || root.genericInput.value
			font.pixelSize: Theme.font_size_body2
		}
	}
}
