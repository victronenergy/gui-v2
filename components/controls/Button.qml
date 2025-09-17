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

	property color color: showEnabled
		? (down ? Theme.color_button_down_text : Theme.color_font_primary)
		: (down ? Theme.color_button_on_text_disabled : Theme.color_button_off_text_disabled)
	property color backgroundColor: showEnabled
		? (down ? Theme.color_ok : Theme.color_darkOk)
		: (down ? Theme.color_button_on_background_disabled : Theme.color_background_disabled)
	property color borderColor: showEnabled ? Theme.color_ok : Theme.color_font_disabled
	property real borderWidth: Theme.geometry_button_border_width
	property real radius: Theme.geometry_button_radius
	property real topLeftRadius: NaN
	property real bottomLeftRadius: NaN
	property real topRightRadius: NaN
	property real bottomRightRadius: NaN
	property bool showEnabled: enabled

	onPressed: pressEffect.start(pressX/width, pressY/height)
	onReleased: pressEffect.stop()
	onCanceled: pressEffect.stop()

	down: pressed || checked
	spacing: Theme.geometry_button_spacing
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0

	implicitWidth: contentItem.implicitWidth + root.leftPadding + root.rightPadding
	implicitHeight: contentItem.implicitHeight + root.topPadding + root.bottomPadding

	icon.color: root.color
	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body1

	// flat=true means the background should not be visible.
	flat: true

	background: Rectangle {
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
		anchors.fill: parent
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
		anchors.fill: parent
	}

	KeyNavigationHighlight.active: root.activeFocus
}
