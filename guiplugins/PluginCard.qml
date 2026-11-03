/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A card with an icon, a title and a status, drawn like the cards in the Controls pane.

	A plugin can show the card on a page of its own, in a PluginCardListView, or add it to the
	Controls pane or the Switches pane, after gui-v2's own cards.

	The card draws the icon, title and status in the current theme. iconSource is a single-color
	image, such as one of the PluginIcons: the card tints it with the primary font color. title and
	status are the text, not the labels that draw them. Declare any other content directly inside
	the card. It is placed in a column below the status, or below the title when status is empty,
	and it is as wide as the card, as in gui-v2's own cards. Every list item in the card must be
	flat: set flat: true on it, so that it is drawn as in gui-v2's own cards, with its own margins.
	Do not use a PluginSettingsListHeader or a PluginPrimaryListLabel, which ignore flat; use a
	PluginLabel. Content that is not a list item, such as a PluginLabel or a PluginButton, starts at
	the left edge of the card: set its x to contentMargin, so that it lines up with the icon and the
	status. If it wraps, or fills the line, also set its width to the card's width minus twice
	contentMargin.

	The card is the usual control-card size, so it is visible without a layout, and grows if the
	content needs more room. A page can set its width and height. A PluginCardListView, and the
	Controls and Switches panes, set the card's size. In portrait layout, the card still grows to
	fit its content. Otherwise, it is as tall as the list or pane, so the content must fit in that
	height.

	Key navigation works as in gui-v2's own cards. When the card has the key focus, the Up and Down
	keys move the focus between the list items and controls declared directly inside the card. At
	the first or last of them, the key goes to the item that holds the card. Items inside a Row or
	other layout in the card are not reached. If nothing inside the card can take the key focus,
	the card keeps it, and shows the key navigation highlight.
*/
FocusScope {
	id: root

	// Items declared inside the card, placed below the title and status.
	default property alias content: contentColumn._data

	property url iconSource
	property string title
	property string status
	// The margin between the card's left edge and its icon and status. Set x to it on content
	// that is not a list item, such as a PluginLabel or a PluginButton.
	readonly property real contentMargin: Theme.geometry_controlCard_contentMargins

	focus: true
	focusPolicy: Qt.TabFocus
	// activeFocus is also true while an item inside the card has the key focus. The column keeps
	// the key focus when nothing inside it can take it.
	KeyNavigationHighlight.active: activeFocus
			&& (Window.activeFocusItem === root || Window.activeFocusItem === contentColumn)
	implicitWidth: card.implicitWidth
	implicitHeight: Math.max(card.implicitHeight,
			contentColumn.y + contentColumn.implicitHeight + Theme.geometry_controlCard_contentMargins)
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

	// Moves the key focus between its children on Up and Down, as in gui-v2's own cards.
	SettingsColumn {
		id: contentColumn

		z: 1
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: card.top
		anchors.topMargin: root.status.length > 0
			? card.status.y + card.status.height + Theme.geometry_controlCard_status_topMargin
			: card.title.y + card.title.height + Theme.geometry_controlCard_status_bottomMargin
	}
}
