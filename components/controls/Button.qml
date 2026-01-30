/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as CP
import Victron.VenusOS

T.Button {
	id: root

	property color color: enabled
		? (down ? Theme.color_button_down_text : Theme.color_font_primary)
		: (down ? Theme.color_button_on_text_disabled : Theme.color_button_off_text_disabled)
	property color backgroundColor: enabled
		? (down ? Theme.color_ok : Theme.color_darkOk)
		: (down ? Theme.color_button_on_background_disabled : Theme.color_background_disabled)
	property color borderColor: enabled ? Theme.color_ok : Theme.color_font_disabled
	property real borderWidth: Theme.geometry_button_border_width
	property real radius: Theme.geometry_button_radius
	property real topLeftRadius: NaN
	property real bottomLeftRadius: NaN
	property real topRightRadius: NaN
	property real bottomRightRadius: NaN

	// The default implicit width/height of the background.
	property real defaultBackgroundWidth
	property real defaultBackgroundHeight: Theme.geometry_button_height

	onPressed: pressEffect.start(pressX/width, pressY/height)
	onReleased: pressEffect.stop()
	onCanceled: pressEffect.stop()

	down: pressed || checked
	spacing: Theme.geometry_button_spacing
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)

	icon.color: root.color
	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body1

	// flat=true means the background should not be visible.
	flat: true

	background: Rectangle {
		implicitWidth: root.defaultBackgroundWidth
		implicitHeight: root.defaultBackgroundHeight
		color: root.backgroundColor
		border.width: root.borderWidth
		border.color: root.borderColor
		visible: !root.flat

		// Only set the radius if none of the corner radii are set, otherwise each corner will be
		// rounded even if no radius has been set for that corner.
		radius: isNaN(root.topLeftRadius)
				&& isNaN(root.bottomLeftRadius)
				&& isNaN(root.topRightRadius)
				&& isNaN(root.bottomRightRadius)
			? root.radius
			: 0

		// Clear corner radii values if they are not set.
		topLeftRadius: isNaN(root.topLeftRadius) ? undefined : root.topLeftRadius
		bottomLeftRadius: isNaN(root.bottomLeftRadius) ? undefined : root.bottomLeftRadius
		topRightRadius: isNaN(root.topRightRadius) ? undefined : root.topRightRadius
		bottomRightRadius: isNaN(root.bottomRightRadius) ? undefined : root.bottomRightRadius
	}

	contentItem: CP.IconLabel {
		spacing: root.spacing
		display: root.display
		icon: root.icon
		text: root.text
		font: root.font
		color: root.color
	}

	PressEffect {
		id: pressEffect
		radius: root.radius
		anchors {
			fill: parent
			topMargin: root.topInset
			bottomMargin: root.bottomInset
			leftMargin: root.leftInset
			rightMargin: root.rightInset
		}
	}

	KeyNavigationHighlight.active: root.activeFocus
	KeyNavigationHighlight.topMargin: root.topInset
	KeyNavigationHighlight.bottomMargin: root.bottomInset
	KeyNavigationHighlight.leftMargin: root.leftInset
	KeyNavigationHighlight.rightMargin: root.rightInset
}
