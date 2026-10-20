/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Draws a caption inside a list item that has no caption of its own.

	Parent this to the list item. While the caption is empty, the list item is left unchanged.
	While it is not, the caption is drawn in extra space under the content, inside the background.
	The list item's own content is not replaced.

	contentBottomMargin is the part of the list item's bottom padding that is not the inset.
	ListTextField keeps only the inset, so it sets this to 0. Other list items use the standard
	content margin.
*/
Item {
	id: root

	property string caption
	property real contentBottomMargin: Theme.geometry_listItem_content_verticalMargin

	anchors.fill: parent
	// Above the list item's content, so a wrapped caption is not covered by it.
	z: 1

	Binding {
		target: root.parent
		property: "bottomPadding"
		when: root.parent !== null && root.caption.length > 0
		value: root.parent.bottomInset + root.contentBottomMargin + captionLabel.height
	}

	// The background can be taller than the content. Adding the caption only to bottomPadding
	// would then leave the item the same height, and the caption would cover the content.
	Binding {
		target: root.parent
		property: "implicitHeight"
		when: root.parent !== null && root.caption.length > 0
		value: !root.parent.effectiveVisible ? 0 : Math.max(
				root.parent.implicitBackgroundHeight + root.parent.topInset + root.parent.bottomInset + captionLabel.height,
				root.parent.implicitContentHeight + root.parent.topPadding + root.parent.bottomPadding)
	}

	CaptionLabel {
		id: captionLabel

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: root.parent?.leftPadding ?? 0
		anchors.rightMargin: root.parent?.rightPadding ?? 0
		anchors.bottom: parent.bottom
		anchors.bottomMargin: (root.parent?.bottomInset ?? 0) + root.contentBottomMargin
		topPadding: Theme.geometry_listItem_content_verticalSpacing
		text: root.caption
		visible: text.length > 0
		z: 1
	}
}
