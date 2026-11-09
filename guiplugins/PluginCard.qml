/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A card with an icon, a title and a status, drawn like a Controls pane card.

	The card draws the icon, title and status in the current theme. iconSource is a single-color
	image, such as one of the PluginIcons: the card tints it with the primary font color. title and
	status are the text, not the labels that draw them. Declare any other content directly inside
	the card. It is placed below the status, or below the title when status is empty, inset by the
	card's content margin, and it is as wide as the card.

	The card is the usual control-card size, so it is visible without a layout. A page can set its
	width and height. If the content needs more room, the card grows. This does not add the card to
	the Controls pane.

	When the card has the key focus, it shows the key navigation highlight. If an item inside the
	card has focus: true, the card passes the key focus to that item instead.
*/
FocusScope {
	id: root

	// Items declared inside the card, placed below the title and status.
	default property alias content: contentColumn.data

	property url iconSource
	property string title
	property string status

	focus: true
	focusPolicy: Qt.TabFocus
	// activeFocus is also true while an item inside the card has the key focus.
	KeyNavigationHighlight.active: activeFocus && Window.activeFocusItem === root
	implicitWidth: card.implicitWidth
	implicitHeight: contentColumn.children.length > 0
			? Math.max(card.implicitHeight, contentColumn.y + contentColumn.implicitHeight
				+ Theme.geometry_controlCard_contentMargins)
			: card.implicitHeight
	width: implicitWidth
	height: implicitHeight

	ControlCard {
		id: card

		anchors.fill: parent
		focus: false
		focusPolicy: Qt.NoFocus
		icon.source: root.iconSource
		title.text: root.title
		status.text: root.status
	}

	Column {
		id: contentColumn

		z: 1
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: card.top
		anchors.leftMargin: Theme.geometry_controlCard_contentMargins
		anchors.rightMargin: Theme.geometry_controlCard_contentMargins
		anchors.topMargin: root.status.length > 0
			? card.status.y + card.status.height + Theme.geometry_controlCard_status_topMargin
			: card.title.y + card.title.height + Theme.geometry_controlCard_status_bottomMargin
	}
}
