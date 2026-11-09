import QtQuick
import Victron.GuiPlugins

/*
	A card with an icon, a title and a status, and content of your own.

	The card draws the icon, title and status. The bar is content declared inside the card, drawn
	with a PluginPalette color. The card is not added to the Controls pane.
*/
PluginPage {
	PluginCard {
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter

		title: "Pump"
		status: PluginWords.off
		iconSource: PluginIcons.battery

		Rectangle {
			width: parent.width
			height: 8
			radius: 4
			color: PluginPalette.color_brand
		}
	}
}
