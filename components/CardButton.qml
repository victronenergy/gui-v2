/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	implicitHeight: Theme.geometry_card_button_height
	leftPadding: Theme.geometry_controlCard_contentMargins
	rightPadding: Theme.geometry_controlCard_contentMargins
	flat: false
	borderWidth: 0

	KeyNavigationHighlight.leftMargin: -Theme.geometry_controlCard_contentMargins / 2
	KeyNavigationHighlight.rightMargin: -Theme.geometry_controlCard_contentMargins / 2
	KeyNavigationHighlight.topMargin: -Theme.geometry_controlCard_contentMargins / 2
	KeyNavigationHighlight.bottomMargin: -Theme.geometry_controlCard_contentMargins / 2
}
