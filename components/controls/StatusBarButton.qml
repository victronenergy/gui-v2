/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	defaultBackgroundWidth: Theme.geometry_statusBar_button_height
	defaultBackgroundHeight: Theme.geometry_statusBar_button_height
	radius: 0
	backgroundColor: "transparent"  // don't show background when disabled
	display: Button.IconOnly
	color: Theme.color_ok

	// For convenience, bind the paddings to the offsets that are used to expand the clickable
	// area. If the button only contains an icon, no additional padding is required as the icon
	// fits within the default defaultBackgroundWidth/Height.
	leftPadding: leftInset
	rightPadding: rightInset
	topPadding: topInset
	bottomPadding: bottomInset

	opacity: Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive ? 1.0 : 0.0
	Behavior on opacity {
		enabled: Global.animationEnabled
		OpacityAnimator {
			duration: Theme.animation_page_idleOpacity_duration
		}
	}
}
