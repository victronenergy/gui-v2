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

	property color color: !showEnabled ? Theme.color_font_disabled
			: down ? Theme.color_button_down_text
			: Theme.color_font_primary
	property color backgroundColor: !showEnabled ? Theme.color_background_disabled
			: down ? downColor
			: flat ? "transparent"
			: Theme.color_darkOk
	property color downColor: flat ? "transparent"
			: Theme.color_ok
	property color borderColor: showEnabled ? Theme.color_ok : Theme.color_font_disabled
	property real borderWidth: flat ? 0 : Theme.geometry_button_border_width
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
	flat: true

	background: Rectangle {
		color: root.backgroundColor
		border.width: root.borderWidth
		border.color: root.borderColor

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

		PressEffect {
			id: pressEffect
			radius: root.radius
			anchors.fill: parent
		}
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

	KeyNavigationHighlight.active: root.activeFocus
}
