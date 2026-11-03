/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Loads one plugin card for the Controls or Switches pane.

	The pane sets this item's width and height. That size is applied to the loaded card. If the
	card cannot be created, this shows a card that says the plugin's card failed.
*/
FocusScope {
	id: root

	required property url cardUrl
	required property string pluginName

	readonly property bool failed: cardLoader.status === Loader.Error
	readonly property string title: cardLoader.item && cardLoader.item.title !== undefined
			? cardLoader.item.title : ""
	//: %1 = the name of the plugin whose card could not be created
	//% "Card from plugin %1 failed"
	readonly property string failedCardText: qsTrId("plugin_card_load_failed")
	// Substitute the name only when the translation has a placeholder. The id itself has none, and
	// arg() would warn on every card.
	readonly property string errorText: failed && failedCardText.indexOf("%1") >= 0
			? failedCardText.arg(pluginName) : failedCardText

	focus: true
	implicitWidth: root.failed ? errorCard.implicitWidth
			: (cardLoader.item ? cardLoader.item.implicitWidth : 0)
	implicitHeight: root.failed ? errorCard.implicitHeight
			: (cardLoader.item ? cardLoader.item.implicitHeight : 0)

	Loader {
		id: cardLoader

		anchors.fill: parent
		source: root.cardUrl
		focus: status === Loader.Ready
		visible: status === Loader.Ready
	}

	// PluginCard sets its own size. The pane's size replaces that.
	Binding {
		target: cardLoader.item
		property: "width"
		value: root.width
		when: cardLoader.item !== null
	}
	Binding {
		target: cardLoader.item
		property: "height"
		value: root.height
		when: cardLoader.item !== null
	}

	ControlCard {
		id: errorCard

		objectName: "pluginCardLoadError"
		anchors.fill: parent
		visible: root.failed
		focus: root.failed
		focusPolicy: root.failed ? Qt.TabFocus : Qt.NoFocus
		KeyNavigationHighlight.active: activeFocus
		implicitWidth: Theme.geometry_controlCard_maximumWidth
		implicitHeight: Math.max(Theme.geometry_controlCard_height,
				status.y + status.implicitHeight + Theme.geometry_controlCard_contentMargins)
		icon.source: "qrc:/images/icon_warning_24.svg"
		icon.color: Theme.color_critical
		title.text: root.pluginName
		status.text: root.errorText
		status.color: Theme.color_critical
	}
}
