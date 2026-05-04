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
	topPadding: topInset + Theme.geometry_button_padding
	bottomPadding: bottomInset + Theme.geometry_button_padding
	leftPadding: leftInset + Theme.geometry_button_padding
	rightPadding: rightInset + Theme.geometry_button_padding

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)

	icon.color: root.color
	font.family: Global.fontFamily
	font.pixelSize: Theme.font_button_size
	display: text.length && icon.source.toString().length ? T.AbstractButton.TextBesideIcon
			: text.length ? T.AbstractButton.TextOnly
			: T.AbstractButton.IconOnly

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

	contentItem: Item {
		implicitWidth: root.display === T.AbstractButton.IconOnly ? contentIcon.implicitWidth
				: root.display === T.AbstractButton.TextOnly ? contentLabel.implicitWidth
				: root.display === T.AbstractButton.TextBesideIcon ? contentLabel.implicitWidth + contentIcon.implicitWidth
				: Math.max(contentLabel.implicitWidth, contentIcon.implicitWidth)  // TextUnderIcon
		implicitHeight: root.display === T.AbstractButton.IconOnly ? contentIcon.height
				: root.display === T.AbstractButton.TextOnly ? contentLabel.implicitHeight
				: root.display === T.AbstractButton.TextBesideIcon ? Math.max(contentLabel.implicitHeight, contentIcon.height)
				: contentLabel.implicitHeight + contentIcon.height  // TextUnderIcon

		Label {
			id: contentLabel

			y: root.display === T.AbstractButton.TextUnderIcon ? contentIcon.height + root.spacing : (parent.height - height) / 2
			width: parent.width
			leftPadding: root.display === T.AbstractButton.TextBesideIcon ? contentIcon.width + root.spacing : 0
			horizontalAlignment: root.display === T.AbstractButton.TextBesideIcon ? Text.AlignLeft : Text.AlignHCenter
			text: root.text
			color: root.color
			font: root.font
			visible: root.display !== T.AbstractButton.IconOnly
			elide: Text.ElideRight
		}

		CP.ColorImage {
			id: contentIcon

			x: root.display === T.AbstractButton.TextBesideIcon ? 0 : (parent.width - width) / 2
			y: root.display === T.AbstractButton.TextUnderIcon ? 0 : (parent.height - height) / 2
			width: root.icon.width || Theme.geometry_icon_size_medium
			height: root.icon.height || Theme.geometry_icon_size_medium
			source: root.icon.source
			color: root.icon.color
			visible: root.display !== T.AbstractButton.TextOnly
		}
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
